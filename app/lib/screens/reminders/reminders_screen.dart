import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/vitals/vital_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/vital_labels.dart';
import '../../models/vital_reminder.dart';
import '../../services/notification_service.dart';
import '../../widgets/formatters.dart';
import '../../widgets/patient_switcher.dart';

/// Optional per-vital daily reminders for the active patient (design doc
/// §4). Everything starts OFF — the notification permission is only asked
/// for the first time someone switches one on.
class RemindersScreen extends StatelessWidget {
  /// Overridable for tests (no platform channel there).
  final Future<bool> Function()? requestPermission;

  const RemindersScreen({super.key, this.requestPermission});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final patient = appState.activePatient;
    if (patient == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const PatientSwitcherTitle(), toolbarHeight: 72),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(l10n.remindersIntro, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          for (final type in VitalType.values) ...[
            _ReminderTile(
              patientId: patient.id,
              type: type,
              reminder: appState.reminderFor(patient.id, type),
              requestPermission: requestPermission ?? NotificationService.instance.requestPermission,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final String patientId;
  final VitalType type;
  final VitalReminder? reminder;
  final Future<bool> Function() requestPermission;

  const _ReminderTile({
    required this.patientId,
    required this.type,
    required this.reminder,
    required this.requestPermission,
  });

  VitalReminder get _current {
    if (reminder != null) return reminder!;
    final t = VitalReminder.defaultTimeFor(type);
    return VitalReminder(patientId: patientId, type: type, enabled: false, hour: t.hour, minute: t.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = _current;
    final time = formatTimeOfDay(context, current.hour, current.minute);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            key: ValueKey('reminder_switch_${type.key}'),
            secondary: Icon(VitalLabels.icon(type)),
            title: Text(VitalLabels.name(l10n, type), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(current.enabled ? l10n.reminderAt(time) : l10n.reminderOff),
            value: current.enabled,
            onChanged: (on) => _toggle(context, on),
          ),
          if (current.enabled)
            ListTile(
              key: ValueKey('reminder_time_${type.key}'),
              leading: const SizedBox(width: 24),
              title: Text(time, style: Theme.of(context).textTheme.titleMedium),
              trailing: TextButton(onPressed: () => _pickTime(context), child: Text(l10n.change)),
              onTap: () => _pickTime(context),
            ),
        ],
      ),
    );
  }

  Future<void> _toggle(BuildContext context, bool on) async {
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (on) {
      final granted = await requestPermission();
      if (!granted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.notificationsBlocked)));
        return;
      }
    }
    await appState.saveReminder(_current.copyWith(enabled: on));
  }

  Future<void> _pickTime(BuildContext context) async {
    final appState = context.read<AppState>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _current.hour, minute: _current.minute),
    );
    if (picked == null) return;
    await appState.saveReminder(_current.copyWith(hour: picked.hour, minute: picked.minute));
  }
}
