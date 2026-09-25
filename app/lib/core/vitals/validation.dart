import 'vital_type.dart';

/// Why an entered value was rejected. Mapped to a localized message in the
/// UI layer.
enum ValidationError { required, outOfRange, diastolicNotBelowSystolic }

/// Plausibility bounds for manual entry. These are NOT reference ranges —
/// they only catch typos (e.g. "1200" for pulse, or a missing digit) before
/// a reading is saved. Anything a home device can realistically display is
/// accepted.
class VitalLimits {
  final double min;
  final double max;

  const VitalLimits(this.min, this.max);

  bool contains(double value) => value >= min && value <= max;
}

class VitalValidation {
  VitalValidation._();

  static const systolic = VitalLimits(50, 300);
  static const diastolic = VitalLimits(30, 200);
  static const spo2 = VitalLimits(50, 100);
  static const pulse = VitalLimits(20, 250);
  static const weight = VitalLimits(1, 400);
  static const glucose = VitalLimits(10, 1000);
  static const heightCm = VitalLimits(30, 250);

  static VitalLimits limitsFor(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return systolic;
      case VitalType.spo2:
        return spo2;
      case VitalType.pulse:
        return pulse;
      case VitalType.weight:
        return weight;
      case VitalType.glucose:
        return glucose;
    }
  }

  /// Parses keypad text ("", "120", "72.", "72.4") into a number.
  static double? parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == '.') return null;
    return double.tryParse(trimmed);
  }

  static ValidationError? validateSingle(VitalType type, String text) => _check(parse(text), limitsFor(type));

  static ValidationError? validateSystolic(String text) => _check(parse(text), systolic);

  static ValidationError? validateDiastolic(String diastolicText, String systolicText) {
    final error = _check(parse(diastolicText), diastolic);
    if (error != null) return error;
    final sys = parse(systolicText);
    final dia = parse(diastolicText)!;
    if (sys != null && dia >= sys) return ValidationError.diastolicNotBelowSystolic;
    return null;
  }

  static ValidationError? validateHeight(String text) => _check(parse(text), heightCm);

  static ValidationError? _check(double? value, VitalLimits limits) {
    if (value == null) return ValidationError.required;
    if (!limits.contains(value)) return ValidationError.outOfRange;
    return null;
  }
}
