import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/vitals/bmi.dart';
import '../../core/vitals/reference_ranges.dart';
import '../../core/vitals/vital_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/vital_labels.dart';
import '../../models/patient.dart';
import '../../models/vital_reading.dart';
import '../../services/vital_service.dart';
import '../../widgets/cached_stream_builder.dart';
import '../../widgets/flag_chip.dart';
import '../../widgets/formatters.dart';
import '../../widgets/patient_switcher.dart';
import '../entry/vital_entry_screen.dart';
import '../history/vital_history_screen.dart';
import '../patients/edit_patient_screen.dart';

/// One tile per vital (design doc §2 — no crowded all-in-one form): the
/// latest reading with its flag, a big "+" to log a new one, and a tap
/// through to that vital's own history and chart.
class VitalsHomeScreen extends StatelessWidget {
  const VitalsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AppState>().activePatient;
    if (patient == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const PatientSwitcherTitle(), toolbarHeight: 72),
      body: ListView(
        key: ValueKey('vitals_list_${patient.id}'),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final type in VitalType.values) ...[
            _VitalTile(patient: patient, type: type),
            const SizedBox(height: 12),
          ],
          _BmiCard(patient: patient),
          const SizedBox(height: 20),
          const DisclaimerText(),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final Patient patient;
  final VitalType type;

  const _VitalTile({required this.patient, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = VitalLabels.name(l10n, type);

    return CachedStreamBuilder<VitalReading?>(
      streamKey: '${patient.id}_${type.key}',
      create: () => context.read<VitalService>().watchLatest(patient.id, type),
      builder: (context, snapshot) {
        final latest = snapshot.data;
        final range = latest?.range;
        return Card(
          key: ValueKey('tile_${type.key}'),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VitalHistoryScreen(patient: patient, type: type),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(VitalLabels.icon(type), color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        if (latest == null)
                          Text(l10n.noReadingsYet, style: theme.textTheme.bodyMedium)
                        else ...[
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: latest.displayValue,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' ${type.unit}', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (range != null) FlagChip(result: range, dense: true),
                              Text(
                                [
                                  if (latest.glucoseContext != null)
                                    VitalLabels.glucoseContext(l10n, latest.glucoseContext!),
                                  formatReadingTime(context, latest.measuredAt),
                                ].join(' · '),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: ValueKey('add_${type.key}'),
                    iconSize: 30,
                    style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
                    tooltip: l10n.addVitalReading(name),
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VitalEntryScreen(patient: patient, type: type),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// BMI is computed, never entered: latest weight + the patient's height.
class _BmiCard extends StatelessWidget {
  final Patient patient;

  const _BmiCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CachedStreamBuilder<VitalReading?>(
      streamKey: patient.id,
      create: () => context.read<VitalService>().watchLatest(patient.id, VitalType.weight),
      builder: (context, snapshot) {
        final weight = snapshot.data?.value;
        final bmi = Bmi.calculate(weightKg: weight, heightCm: patient.heightCm);
        final RangeResult? range = bmi == null ? null : ReferenceRanges.bmi(bmi);

        Widget body;
        if (patient.heightCm == null) {
          body = Row(
            children: [
              Expanded(child: Text(l10n.bmiNeedsHeight, style: theme.textTheme.bodyMedium)),
              TextButton(
                key: const ValueKey('bmi_add_height'),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditPatientScreen(patient: patient))),
                child: Text(l10n.addHeight),
              ),
            ],
          );
        } else if (bmi == null) {
          body = Text(l10n.bmiNeedsWeight, style: theme.textTheme.bodyMedium);
        } else {
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(Bmi.format(bmi), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (range != null) FlagChip(result: range, dense: true),
                ],
              ),
              const SizedBox(height: 4),
              Text(l10n.bmiFromLatest(VitalReading.formatNumber(patient.heightCm!)), style: theme.textTheme.bodySmall),
            ],
          );
        }

        return Card(
          key: const ValueKey('tile_bmi'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.straighten, color: theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.bmi, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      body,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
