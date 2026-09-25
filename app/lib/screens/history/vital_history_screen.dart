import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/vitals/bmi.dart';
import '../../core/vitals/vital_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/vital_labels.dart';
import '../../models/patient.dart';
import '../../models/vital_reading.dart';
import '../../services/vital_service.dart';
import '../../widgets/cached_stream_builder.dart';
import '../../widgets/flag_chip.dart';
import '../../widgets/formatters.dart';
import '../../widgets/vital_chart.dart';
import '../entry/vital_entry_screen.dart';

/// History for one vital: 7/30/90-day chart plus the list of readings.
/// Tap a reading to edit or delete it.
class VitalHistoryScreen extends StatefulWidget {
  final Patient patient;
  final VitalType type;

  const VitalHistoryScreen({super.key, required this.patient, required this.type});

  @override
  State<VitalHistoryScreen> createState() => _VitalHistoryScreenState();
}

class _VitalHistoryScreenState extends State<VitalHistoryScreen> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = VitalLabels.name(l10n, widget.type);
    // Keep height fresh if it was edited while this screen is open.
    final patient = context.watch<AppState>().patientById(widget.patient.id) ?? widget.patient;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // "Last 7 days" = today plus the 6 days before it.
    final from = today.subtract(Duration(days: _days - 1));
    final to = today.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('history_add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addReading),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VitalEntryScreen(patient: patient, type: widget.type),
          ),
        ),
      ),
      body: CachedStreamBuilder<List<VitalReading>>(
        streamKey: '${patient.id}_${widget.type.key}_$_days',
        create: () => context.read<VitalService>().watchReadings(patient.id, widget.type, since: from),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorGeneric));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final readings = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Text(patient.name, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 7, label: Text(l10n.range7)),
                  ButtonSegment(value: 30, label: Text(l10n.range30)),
                  ButtonSegment(value: 90, label: Text(l10n.range90)),
                ],
                selected: {_days},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _days = s.first),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
                  child: VitalChart(
                    readings: readings,
                    type: widget.type,
                    from: from,
                    to: to,
                    heightCm: patient.heightCm,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.readingsCount(readings.length), style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final r in readings) _ReadingTile(reading: r, patient: patient),
              const SizedBox(height: 16),
              const DisclaimerText(),
            ],
          );
        },
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final VitalReading reading;
  final Patient patient;

  const _ReadingTile({required this.reading, required this.patient});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isWeight = reading.type == VitalType.weight;
    final flag = isWeight ? reading.bmiRange(patient.heightCm) : reading.range;
    final bmi = reading.bmi(patient.heightCm);

    final details = <String>[
      formatReadingTime(context, reading.measuredAt),
      if (reading.glucoseContext != null) VitalLabels.glucoseContext(l10n, reading.glucoseContext!),
      if (bmi != null) '${l10n.bmi} ${Bmi.format(bmi)}',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('reading_${reading.id}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VitalEntryScreen(patient: patient, type: reading.type, existing: reading),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: reading.displayValue,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ${reading.type.unit}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 2),
                    Text(details.join(' · '), style: theme.textTheme.bodySmall),
                    if (reading.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '“${reading.note}”',
                        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              if (flag != null) FlagChip(result: flag, dense: true),
            ],
          ),
        ),
      ),
    );
  }
}
