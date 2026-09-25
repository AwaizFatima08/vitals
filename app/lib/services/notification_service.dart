import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/vitals/vital_type.dart';

/// One daily notification to schedule on this device.
class ScheduledReminder {
  final String patientId;
  final VitalType type;
  final int hour;
  final int minute;
  final String title;
  final String body;

  const ScheduledReminder({
    required this.patientId,
    required this.type,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });

  String get payload => ReminderPayload(patientId: patientId, type: type).encode();

  /// Stable per patient+vital, so re-syncing replaces rather than duplicates.
  int get notificationId => notificationIdFor(patientId, type);

  static int notificationIdFor(String patientId, VitalType type) {
    var hash = 0;
    for (final codeUnit in '${patientId}_${type.key}'.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}

/// What a tapped reminder should open: the entry screen for this vital.
class ReminderPayload {
  final String patientId;
  final VitalType type;

  const ReminderPayload({required this.patientId, required this.type});

  String encode() => '$patientId|${type.key}';

  static ReminderPayload? decode(String? raw) {
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length != 2 || parts[0].isEmpty) return null;
    final type = VitalType.fromKey(parts[1]);
    if (type == null) return null;
    return ReminderPayload(patientId: parts[0], type: type);
  }
}

/// The seam AppState talks to, so tests can swap in a fake.
abstract class ReminderScheduler {
  /// Makes the set of scheduled notifications on this device exactly
  /// [reminders] — anything not in the list is cancelled.
  Future<void> sync(List<ScheduledReminder> reminders);

  Future<void> cancelAll();
}

/// Optional per-vital daily reminders (design doc §4). Deliberately gentle:
/// normal-priority, inexact daily notifications — this app "does not nag
/// unless asked to", so no alarms, no full-screen intents, no exact-alarm
/// permission.
class NotificationService implements ReminderScheduler {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final StreamController<ReminderPayload> _tapController = StreamController<ReminderPayload>.broadcast();

  /// Emits when the user taps a reminder while the app is running.
  Stream<ReminderPayload> get onReminderTapped => _tapController.stream;

  static const String _channelId = 'livehealthy_vitals_reminders';
  static const String _channelName = 'Vital check reminders';
  static const String _channelDescription = 'Optional daily reminders to check a vital sign';

  /// Returns the payload of the reminder that launched the app, if any.
  Future<ReminderPayload?> initialize() async {
    try {
      await _configureLocalTimeZone();
      const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = ReminderPayload.decode(response.payload);
          if (payload != null) _tapController.add(payload);
        },
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.defaultImportance,
            ),
          );
      _initialized = true;

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        return ReminderPayload.decode(launch!.notificationResponse?.payload);
      }
    } catch (e) {
      // Reminders are optional; never block app start on them.
      debugPrint('NotificationService.initialize failed: $e');
    }
    return null;
  }

  /// Asks for POST_NOTIFICATIONS (Android 13+). Only called when the user
  /// actually switches a reminder on — never at first launch.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    } catch (e) {
      // Don't block saving the reminder; worst case it's silently not shown.
      debugPrint('requestNotificationsPermission failed: $e');
      return true;
    }
  }

  @override
  Future<void> sync(List<ScheduledReminder> reminders) async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: nextInstanceOf(reminder.hour, reminder.minute, tz.TZDateTime.now(tz.local)),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: reminder.payload,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    if (_initialized) await _plugin.cancelAll();
  }

  /// Today at hour:minute if that's still ahead, otherwise tomorrow.
  @visibleForTesting
  static tz.TZDateTime nextInstanceOf(int hour, int minute, tz.TZDateTime now) {
    var scheduled = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }
}
