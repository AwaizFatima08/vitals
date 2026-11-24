import '../../models/vital_reading.dart';
import 'reference_ranges.dart';
import 'vital_type.dart';

/// Simple summary of one series of numbers.
class SeriesStats {
  final int count;
  final double mean;
  final double min;
  final double max;

  const SeriesStats({required this.count, required this.mean, required this.min, required this.max});

  static SeriesStats? of(Iterable<double> values) {
    final list = values.toList();
    if (list.isEmpty) return null;
    var sum = 0.0;
    var lo = list.first;
    var hi = list.first;
    for (final v in list) {
      sum += v;
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    return SeriesStats(count: list.length, mean: sum / list.length, min: lo, max: hi);
  }
}

/// Averages for a blood-pressure series (systolic and diastolic together).
class BpAverage {
  final int count;
  final double systolic;
  final double diastolic;

  const BpAverage({required this.count, required this.systolic, required this.diastolic});

  static BpAverage? of(Iterable<VitalReading> readings) {
    final list = readings.where((r) => r.type == VitalType.bloodPressure).toList();
    if (list.isEmpty) return null;
    final sys = list.map((r) => r.systolic!).reduce((a, b) => a + b) / list.length;
    final dia = list.map((r) => r.diastolic!).reduce((a, b) => a + b) / list.length;
    return BpAverage(count: list.length, systolic: sys, diastolic: dia);
  }

  /// Rounded the way readings are shown, e.g. "128/82".
  String get display => '${systolic.round()}/${diastolic.round()}';
}

/// Statistics shown under a vital's chart for the selected period.
class VitalStats {
  final VitalType type;
  final int count;

  /// Single-value vitals (SpO2, pulse, weight, glucose).
  final SeriesStats? value;

  /// Blood pressure.
  final SeriesStats? systolic;
  final SeriesStats? diastolic;
  final BpAverage? bpAverage;

  /// Morning (04:00–11:59) and evening (16:00–23:59) averages, the two
  /// times home-monitoring guidelines ask for. BP uses [bpMorning] /
  /// [bpEvening]; pulse uses [valueMorning] / [valueEvening].
  final BpAverage? bpMorning;
  final BpAverage? bpEvening;
  final SeriesStats? valueMorning;
  final SeriesStats? valueEvening;

  /// Glucose split by context, since the ranges differ.
  final SeriesStats? glucoseFastingOrBeforeMeal;
  final SeriesStats? glucoseAfterMealOrRandom;

  /// Share (0–1) of readings whose flag is "normal". Null for weight, which
  /// has no flag of its own (and none for its BMI without a height).
  final double? normalShare;

  const VitalStats({
    required this.type,
    required this.count,
    this.value,
    this.systolic,
    this.diastolic,
    this.bpAverage,
    this.bpMorning,
    this.bpEvening,
    this.valueMorning,
    this.valueEvening,
    this.glucoseFastingOrBeforeMeal,
    this.glucoseAfterMealOrRandom,
    this.normalShare,
  });

  static bool isMorning(DateTime t) => t.hour >= 4 && t.hour < 12;
  static bool isEvening(DateTime t) => t.hour >= 16;

  static VitalStats compute(VitalType type, List<VitalReading> all, {double? heightCm}) {
    final readings = all.where((r) => r.type == type).toList();
    final flags = readings
        .map((r) => type == VitalType.weight ? r.bmiRange(heightCm) : r.range)
        .whereType<RangeResult>()
        .toList();
    final normalShare = flags.isEmpty ? null : flags.where((f) => f.level == FlagLevel.normal).length / flags.length;

    if (type.isDual) {
      return VitalStats(
        type: type,
        count: readings.length,
        systolic: SeriesStats.of(readings.map((r) => r.systolic!)),
        diastolic: SeriesStats.of(readings.map((r) => r.diastolic!)),
        bpAverage: BpAverage.of(readings),
        bpMorning: BpAverage.of(readings.where((r) => isMorning(r.measuredAt))),
        bpEvening: BpAverage.of(readings.where((r) => isEvening(r.measuredAt))),
        normalShare: normalShare,
      );
    }

    return VitalStats(
      type: type,
      count: readings.length,
      value: SeriesStats.of(readings.map((r) => r.value!)),
      valueMorning: type == VitalType.pulse
          ? SeriesStats.of(readings.where((r) => isMorning(r.measuredAt)).map((r) => r.value!))
          : null,
      valueEvening: type == VitalType.pulse
          ? SeriesStats.of(readings.where((r) => isEvening(r.measuredAt)).map((r) => r.value!))
          : null,
      glucoseFastingOrBeforeMeal: type == VitalType.glucose
          ? SeriesStats.of(readings.where((r) => r.glucoseContext!.usesFastingRange).map((r) => r.value!))
          : null,
      glucoseAfterMealOrRandom: type == VitalType.glucose
          ? SeriesStats.of(readings.where((r) => !r.glucoseContext!.usesFastingRange).map((r) => r.value!))
          : null,
      normalShare: normalShare,
    );
  }
}

/// Outcome of the 7-day home blood-pressure check.
sealed class HomeBpCheck {
  const HomeBpCheck();
}

/// Not enough readings yet for a meaningful average.
class HomeBpNeedsMore extends HomeBpCheck {
  final int readings; // counted after dropping day 1
  final int days;

  const HomeBpNeedsMore({required this.readings, required this.days});
}

class HomeBpResult extends HomeBpCheck {
  final BpAverage average;
  final int days;

  /// At or above the 135/85 home threshold that guidelines use to suggest
  /// high blood pressure measured at home.
  final bool atOrAboveThreshold;

  const HomeBpResult({required this.average, required this.days, required this.atOrAboveThreshold});
}

/// Home BP monitoring protocol (ESH 2021, AHA/ACC 2025): measure for up to
/// 7 days (morning and evening, two readings each), discard the first day,
/// and average the rest. Home average >= 135/85 suggests high BP.
///
/// Requires at least [minDays] days and [minReadings] readings after
/// dropping day 1 — below that the average isn't shown.
class HomeBpProtocol {
  HomeBpProtocol._();

  static const int windowDays = 7;
  static const int minDays = 3;
  static const int minReadings = 12;
  static const int systolicThreshold = 135;
  static const int diastolicThreshold = 85;

  static HomeBpCheck evaluate(List<VitalReading> all, {required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: windowDays - 1));
    final inWindow = all
        .where((r) => r.type == VitalType.bloodPressure)
        .where((r) => !r.measuredAt.isBefore(start) && !r.measuredAt.isAfter(now))
        .toList();

    DateTime dayOf(VitalReading r) => DateTime(r.measuredAt.year, r.measuredAt.month, r.measuredAt.day);
    final days = inWindow.map(dayOf).toSet().toList()..sort();

    // Discard the first day of the series (readings are typically higher
    // while people get used to measuring).
    final kept = days.length >= 2 ? inWindow.where((r) => dayOf(r) != days.first).toList() : inWindow;
    final keptDays = kept.map(dayOf).toSet().length;

    if (keptDays < minDays || kept.length < minReadings) {
      return HomeBpNeedsMore(readings: kept.length, days: keptDays);
    }
    final avg = BpAverage.of(kept)!;
    return HomeBpResult(
      average: avg,
      days: keptDays,
      atOrAboveThreshold: avg.systolic.round() >= systolicThreshold || avg.diastolic.round() >= diastolicThreshold,
    );
  }
}
