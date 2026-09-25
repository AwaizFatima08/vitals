import 'vital_type.dart';

/// Colour of the informational flag shown next to a reading.
enum FlagLevel { normal, caution, alert }

/// Which band a reading falls into. Each maps to one localized label; the
/// labels intentionally describe ranges ("Above typical range"), never a
/// diagnosis.
enum RangeCategory {
  // Blood pressure
  bpNormal,
  bpElevated,
  bpStage1,
  bpStage2,
  bpVeryHigh,
  // SpO2
  spo2Normal,
  spo2Low,
  spo2Critical,
  // Pulse
  pulseLow,
  pulseNormal,
  pulseHigh,
  // Glucose
  glucoseLow,
  glucoseNormal,
  glucosePrediabetic,
  glucoseDiabetic,
  // BMI
  bmiUnderweight,
  bmiNormal,
  bmiOverweight,
  bmiObese,
}

class RangeResult {
  final RangeCategory category;
  final FlagLevel level;

  /// True when the app should show the "seek medical care" notice on top
  /// of the colour flag (very high BP, critically low SpO2).
  final bool urgent;

  const RangeResult(this.category, this.level, {this.urgent = false});

  @override
  bool operator ==(Object other) =>
      other is RangeResult && other.category == category && other.level == level && other.urgent == urgent;

  @override
  int get hashCode => Object.hash(category, level, urgent);

  @override
  String toString() => 'RangeResult($category, $level, urgent: $urgent)';
}

/// General adult reference ranges, exactly as locked in design doc §6.
/// Informational only. One default set in V1 — no pediatric/pregnancy
/// profiles and no per-patient overrides yet.
class ReferenceRanges {
  ReferenceRanges._();

  /// AHA-style: the higher of the systolic/diastolic category wins.
  static RangeResult bloodPressure(num systolic, num diastolic) {
    if (systolic > 180 || diastolic > 120) {
      return const RangeResult(RangeCategory.bpVeryHigh, FlagLevel.alert, urgent: true);
    }
    if (systolic >= 140 || diastolic >= 90) {
      return const RangeResult(RangeCategory.bpStage2, FlagLevel.alert);
    }
    if (systolic >= 130 || diastolic >= 80) {
      return const RangeResult(RangeCategory.bpStage1, FlagLevel.caution);
    }
    if (systolic >= 120) {
      return const RangeResult(RangeCategory.bpElevated, FlagLevel.caution);
    }
    return const RangeResult(RangeCategory.bpNormal, FlagLevel.normal);
  }

  static RangeResult spo2(num percent) {
    if (percent >= 95) return const RangeResult(RangeCategory.spo2Normal, FlagLevel.normal);
    if (percent >= 90) return const RangeResult(RangeCategory.spo2Low, FlagLevel.caution);
    return const RangeResult(RangeCategory.spo2Critical, FlagLevel.alert, urgent: true);
  }

  static RangeResult pulse(num bpm) {
    if (bpm < 60) return const RangeResult(RangeCategory.pulseLow, FlagLevel.caution);
    if (bpm <= 100) return const RangeResult(RangeCategory.pulseNormal, FlagLevel.normal);
    return const RangeResult(RangeCategory.pulseHigh, FlagLevel.caution);
  }

  static RangeResult glucose(num mgDl, GlucoseContext context) {
    if (mgDl < 70) return const RangeResult(RangeCategory.glucoseLow, FlagLevel.alert);
    final normalBelow = context.usesFastingRange ? 100 : 140;
    final prediabeticBelow = context.usesFastingRange ? 126 : 200;
    if (mgDl < normalBelow) return const RangeResult(RangeCategory.glucoseNormal, FlagLevel.normal);
    if (mgDl < prediabeticBelow) return const RangeResult(RangeCategory.glucosePrediabetic, FlagLevel.caution);
    return const RangeResult(RangeCategory.glucoseDiabetic, FlagLevel.alert);
  }

  static RangeResult bmi(num bmi) {
    if (bmi < 18.5) return const RangeResult(RangeCategory.bmiUnderweight, FlagLevel.caution);
    if (bmi < 25) return const RangeResult(RangeCategory.bmiNormal, FlagLevel.normal);
    if (bmi < 30) return const RangeResult(RangeCategory.bmiOverweight, FlagLevel.caution);
    return const RangeResult(RangeCategory.bmiObese, FlagLevel.alert);
  }
}
