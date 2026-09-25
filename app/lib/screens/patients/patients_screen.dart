import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/vital_labels.dart';
import '../../models/patient.dart';
import '../../models/vital_reading.dart';
import 'edit_patient_screen.dart';

/// Everyone this account tracks — the same list Pill Reminder shows. Tap to
/// make a patient active; the edit icon changes name/height.
class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('patients_add'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditPatientScreen())),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addPatient),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: appState.patients.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final patient = appState.patients[index];
          return _PatientTile(patient: patient, isActive: appState.activePatient?.id == patient.id);
        },
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final Patient patient;
  final bool isActive;

  const _PatientTile({required this.patient, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final details = [
      VitalLabels.relationship(l10n, patient.relationship),
      if (patient.heightCm != null) '${VitalReading.formatNumber(patient.heightCm!)} cm',
      if (patient.memberUids.length > 1) l10n.sharedWithCaregivers,
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? theme.colorScheme.primary : const Color(0xFFE2E8E5),
          width: isActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        key: ValueKey('patient_${patient.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(child: Text(patient.name.isEmpty ? '?' : patient.name.characters.first.toUpperCase())),
        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(details.join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) Icon(Icons.check_circle, color: theme.colorScheme.primary),
            IconButton(
              tooltip: l10n.editPatient,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPatientScreen(patient: patient))),
            ),
          ],
        ),
        onTap: () => context.read<AppState>().setActivePatient(patient),
      ),
    );
  }
}
