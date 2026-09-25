import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../l10n/generated/app_localizations.dart';
import 'vitals/vital_type.dart';
import '../l10n/vital_labels.dart';
import '../models/app_user.dart';
import '../models/patient.dart';
import '../models/vital_reminder.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/patient_service.dart';
import '../services/reminder_service.dart';

/// Holds "who is signed in", "which patients they can see", "which patient
/// is active" and "which reminders they've switched on" — and keeps this
/// device's scheduled notifications matching those reminders.
class AppState extends ChangeNotifier {
  final AuthService authService;
  final PatientService patientService;
  final ReminderService reminderService;
  final ReminderScheduler scheduler;

  AppState({
    required this.authService,
    required this.patientService,
    required this.reminderService,
    required this.scheduler,
  }) {
    _authSub = authService.authStateChanges.listen(_onFirebaseUserChanged);
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;
  StreamSubscription<List<Patient>>? _patientsSub;
  StreamSubscription<List<VitalReminder>>? _remindersSub;

  String? uid;
  AppUser? currentUser;
  Patient? activePatient;
  List<Patient> patients = const [];
  List<VitalReminder> reminders = const [];

  bool _authResolved = false;
  bool _patientsLoaded = false;
  bool _userPickedPatient = false;
  bool _ensuredProfile = false;

  /// True until we know whether someone is signed in and, if so, have their
  /// first patient list — avoids flashing the "add a patient" screen.
  bool get isLoading => !_authResolved || (uid != null && !_patientsLoaded);

  bool get isSignedIn => uid != null;

  String get languageCode => currentUser?.preferredLanguage ?? 'en';

  Future<void> _onFirebaseUserChanged(User? firebaseUser) async {
    // Not awaited: state must flip immediately on sign-out, and a stream's
    // cancel() future can be slow (or never complete on some fakes).
    unawaited(_cancelDataSubs());
    if (firebaseUser == null) {
      uid = null;
      currentUser = null;
      activePatient = null;
      patients = const [];
      reminders = const [];
      _authResolved = true;
      _patientsLoaded = false;
      _userPickedPatient = false;
      _ensuredProfile = false;
      notifyListeners();
      return;
    }

    uid = firebaseUser.uid;
    _authResolved = true;
    _patientsLoaded = false;
    notifyListeners();

    _profileSub = authService.watchUserProfile(firebaseUser.uid).listen((user) {
      if (user == null && !_ensuredProfile) {
        _ensuredProfile = true;
        authService.ensureUserProfile(firebaseUser);
      }
      currentUser = user;
      _resolveActivePatient();
      _syncReminders();
      notifyListeners();
    }, onError: _logStreamError);

    _patientsSub = patientService
        .watchPatientsForUser(firebaseUser.uid)
        .listen(
          (updated) {
            patients = updated;
            _patientsLoaded = true;
            _resolveActivePatient();
            _syncReminders();
            notifyListeners();
          },
          onError: (Object e) {
            _patientsLoaded = true;
            _logStreamError(e);
            notifyListeners();
          },
        );

    _remindersSub = reminderService.watchReminders(firebaseUser.uid).listen((updated) {
      reminders = updated;
      _syncReminders();
      notifyListeners();
    }, onError: _logStreamError);
  }

  void _logStreamError(Object e) => debugPrint('AppState stream error: $e');

  void _resolveActivePatient() {
    if (patients.isEmpty) {
      activePatient = null;
      return;
    }
    final current = activePatient == null ? null : _findPatient(activePatient!.id);
    if (current != null && _userPickedPatient) {
      activePatient = current; // keep fresh (e.g. height just edited)
      return;
    }
    final preferred = _findPatient(currentUser?.activePatientId ?? '');
    activePatient = preferred ?? current ?? patients.first;
  }

  Patient? _findPatient(String id) {
    for (final p in patients) {
      if (p.id == id) return p;
    }
    return null;
  }

  Patient? patientById(String id) => _findPatient(id);

  Future<void> setActivePatient(Patient patient) async {
    _userPickedPatient = true;
    activePatient = patient;
    notifyListeners();
    if (uid != null) await authService.setActivePatient(uid!, patient.id);
  }

  VitalReminder? reminderFor(String patientId, VitalType type) {
    for (final r in reminders) {
      if (r.patientId == patientId && r.type == type) return r;
    }
    return null;
  }

  Future<void> saveReminder(VitalReminder reminder) async {
    if (uid == null) return;
    // Optimistic so the switch responds instantly; the stream confirms it.
    reminders = [...reminders.where((r) => r.docId != reminder.docId), reminder];
    _syncReminders();
    notifyListeners();
    await reminderService.saveReminder(uid!, reminder);
  }

  Future<void> setLanguage(String languageCode) async {
    if (uid == null) return;
    await authService.setPreferredLanguage(uid!, languageCode);
  }

  /// Rebuilds this device's notification schedule from the reminders list.
  /// Reminders for a patient this account can no longer see are skipped.
  void _syncReminders() {
    if (uid == null || !_patientsLoaded) return;
    final l10n = lookupAppLocalizations(Locale(languageCode));
    final scheduled = <ScheduledReminder>[];
    for (final r in reminders.where((r) => r.enabled)) {
      final patient = _findPatient(r.patientId);
      if (patient == null) continue;
      final vitalName = VitalLabels.name(l10n, r.type);
      scheduled.add(
        ScheduledReminder(
          patientId: r.patientId,
          type: r.type,
          hour: r.hour,
          minute: r.minute,
          title: l10n.reminderNotificationTitle(vitalName),
          body: patient.isSelf ? l10n.reminderNotificationBodySelf : l10n.reminderNotificationBody(patient.name),
        ),
      );
    }
    scheduler.sync(scheduled);
  }

  Future<void> signOut() async {
    await scheduler.cancelAll();
    await authService.signOut();
  }

  /// Detaches the current subscriptions synchronously, then cancels them —
  /// so new subscriptions created right after can never be cancelled by a
  /// late-running call.
  Future<void> _cancelDataSubs() async {
    final old = [_profileSub, _patientsSub, _remindersSub];
    _profileSub = null;
    _patientsSub = null;
    _remindersSub = null;
    for (final sub in old) {
      await sub?.cancel();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cancelDataSubs();
    super.dispose();
  }
}
