import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/vitals/stats.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/vital_reading.dart';

/// Average / lowest / highest (+ morning vs evening, glucose by context,
/// share in range) for the readings currently on the chart.
class VitalStatsCard extends StatelessWidget {
  final VitalStats stats;

  const VitalStatsCard({super.key, required this.stats});

  String _n(double v) => VitalReading.formatNumber(double.parse(v.toStringAsFixed(1)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = stats.type.displayUnit;
    final rows = <(String, String)>[];

    if (stats.type.isDual) {
      final avg = stats.bpAverage;
      if (avg != null) rows.add((l10n.statsAverage, '${avg.display}$unit'));
      if (stats.systolic != null) {
        rows.add((l10n.statsLowest, '${_n(stats.systolic!.min)}/${_n(stats.diastolic!.min)}$unit'));
        rows.add((l10n.statsHighest, '${_n(stats.systolic!.max)}/${_n(stats.diastolic!.max)}$unit'));
      }
      if (stats.bpMorning != null) rows.add((l10n.statsMorning, '${stats.bpMorning!.display}$unit'));
      if (stats.bpEvening != null) rows.add((l10n.statsEvening, '${stats.bpEvening!.display}$unit'));
    } else if (stats.value != null) {
      final v = stats.value!;
      rows.add((l10n.statsAverage, '${_n(v.mean)}$unit'));
      rows.add((l10n.statsLowest, '${_n(v.min)}$unit'));
      rows.add((l10n.statsHighest, '${_n(v.max)}$unit'));
      if (stats.valueMorning != null) rows.add((l10n.statsMorning, '${_n(stats.valueMorning!.mean)}$unit'));
      if (stats.valueEvening != null) rows.add((l10n.statsEvening, '${_n(stats.valueEvening!.mean)}$unit'));
      if (stats.glucoseFastingOrBeforeMeal != null) {
        rows.add((l10n.statsFastingAvg, '${_n(stats.glucoseFastingOrBeforeMeal!.mean)}$unit'));
      }
      if (stats.glucoseAfterMealOrRandom != null) {
        rows.add((l10n.statsAfterMealAvg, '${_n(stats.glucoseAfterMealOrRandom!.mean)}$unit'));
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return Card(
      key: const ValueKey('stats_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            if (stats.normalShare != null) ...[
              const SizedBox(height: 6),
              Text(l10n.statsInRange((stats.normalShare! * 100).round()), style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// The 7-day home blood-pressure check (BP history only). Informational:
/// it compares the protocol average with the guideline home threshold and
/// points the user to their doctor; it never diagnoses.
class HomeBpCheckCard extends StatelessWidget {
  final HomeBpCheck check;

  const HomeBpCheckCard({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final check = this.check;

    final (String message, Color? accent) = switch (check) {
      HomeBpNeedsMore(:final readings, :final days) => (l10n.homeBpNeedsMore(readings, days), null),
      HomeBpResult(:final average, atOrAboveThreshold: true) => (l10n.homeBpAbove(average.display), AppTheme.flagAlert),
      HomeBpResult(:final average) => (l10n.homeBpBelow(average.display), AppTheme.flagNormal),
    };

    return Card(
      key: const ValueKey('home_bp_check'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent ?? const Color(0xFFE2E8E5), width: accent == null ? 1 : 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_repeat, color: accent ?? theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.homeBpTitle, style: theme.textTheme.titleSmall)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: accent)),
            const SizedBox(height: 8),
            Text(l10n.homeBpHow, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
