import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/vital_labels.dart';

/// AppBar title that shows whose readings are on screen and, when there is
/// more than one patient, lets you switch with one tap.
class PatientSwitcherTitle extends StatelessWidget {
  const PatientSwitcherTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final patient = appState.activePatient;
    final canSwitch = appState.patients.length > 1;
    final theme = Theme.of(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.activePatientLabel, style: theme.textTheme.labelMedium),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                patient?.name ?? '',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (canSwitch) const Icon(Icons.arrow_drop_down),
          ],
        ),
      ],
    );

    if (!canSwitch) return title;
    return InkWell(
      key: const ValueKey('patient_switcher'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => showPatientPicker(context),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: title),
    );
  }
}

Future<void> showPatientPicker(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final appState = sheetContext.watch<AppState>();
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.switchPatient, style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            for (final p in appState.patients)
              ListTile(
                leading: CircleAvatar(child: Text(p.name.isEmpty ? '?' : p.name.characters.first.toUpperCase())),
                title: Text(p.name),
                subtitle: Text(VitalLabels.relationship(l10n, p.relationship)),
                trailing: p.id == appState.activePatient?.id
                    ? Icon(Icons.check_circle, color: Theme.of(sheetContext).colorScheme.primary)
                    : null,
                onTap: () {
                  appState.setActivePatient(p);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      );
    },
  );
}
