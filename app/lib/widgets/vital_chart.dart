import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../core/theme/app_theme.dart';
import '../core/vitals/vital_type.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/vital_reading.dart';

/// One chart per vital (design doc §4). Blood pressure plots systolic and
/// diastolic as two lines on the same chart; every point is coloured by its
/// reference-range flag.
class VitalChart extends StatelessWidget {
  final List<VitalReading> readings; // any order
  final VitalType type;
  final DateTime from;
  final DateTime to;
  final double? heightCm;

  const VitalChart({
    super.key,
    required this.readings,
    required this.type,
    required this.from,
    required this.to,
    this.heightCm,
  });

  static const Color systolicColor = Color(0xFF0B6E4F);
  static const Color diastolicColor = Color(0xFF3F7CAC);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (readings.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.chartEmpty, style: theme.textTheme.bodyMedium)),
      );
    }

    final sorted = [...readings]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final lines = <LineChartBarData>[];
    if (type.isDual) {
      lines.add(_line(sorted, (r) => r.systolic!, systolicColor));
      lines.add(_line(sorted, (r) => r.diastolic!, diastolicColor));
    } else {
      lines.add(_line(sorted, (r) => r.value!, theme.colorScheme.primary));
    }

    final values = [
      for (final r in sorted) ...(type.isDual ? [r.systolic!, r.diastolic!] : [r.value!]),
    ];
    final bounds = axisBounds(values);
    final minX = from.millisecondsSinceEpoch.toDouble();
    final maxX = to.millisecondsSinceEpoch.toDouble();
    final spanDays = to.difference(from).inDays.clamp(1, 3650);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: Directionality(
            textDirection: TextDirection.ltr, // time runs left→right in every language
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: bounds.min,
                maxY: bounds.max,
                lineBarsData: lines,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: bounds.interval,
                  getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 0.6),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: bounds.interval,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(VitalReading.formatNumber(value), style: theme.textTheme.bodySmall),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (maxX - minX) / (spanDays <= 7 ? spanDays : 4),
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(DateFormat.Md(locale).format(date), style: theme.textTheme.bodySmall),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          VitalReading.formatNumber(s.y),
                          TextStyle(color: s.bar.color ?? Colors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (type.isDual)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 16,
              children: [
                _legend(context, systolicColor, l10n.systolic),
                _legend(context, diastolicColor, l10n.diastolic),
              ],
            ),
          ),
      ],
    );
  }

  LineChartBarData _line(List<VitalReading> sorted, double Function(VitalReading) valueOf, Color color) {
    return LineChartBarData(
      spots: [for (final r in sorted) FlSpot(r.measuredAt.millisecondsSinceEpoch.toDouble(), valueOf(r))],
      color: color,
      barWidth: 2.5,
      isCurved: false,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, _, index) {
          final reading = sorted[index];
          final flag = type == VitalType.weight ? reading.bmiRange(heightCm) : reading.range;
          return FlDotCirclePainter(
            radius: 4.5,
            color: flag == null ? color : AppTheme.flagColor(flag.level),
            strokeWidth: 1.5,
            strokeColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 4, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Round, padded y-axis bounds with ~4-5 gridlines.
  static ({double min, double max, double interval}) axisBounds(List<double> values) {
    var lo = values.reduce(math.min);
    var hi = values.reduce(math.max);
    if (hi - lo < 4) {
      lo -= 2;
      hi += 2;
    }
    final rawInterval = (hi - lo) / 4;
    final magnitude = math.pow(10, (math.log(rawInterval) / math.ln10).floor()).toDouble();
    final interval = [1, 2, 5, 10].map((m) => m * magnitude).firstWhere((i) => i >= rawInterval);
    final min = (lo / interval).floor() * interval - interval;
    final max = (hi / interval).ceil() * interval + interval;
    return (min: math.max(0, min), max: max, interval: interval);
  }
}
