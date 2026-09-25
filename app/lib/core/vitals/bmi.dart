/// BMI = weight (kg) / height (m)². Height is captured once per patient
/// profile (design doc §4); weight comes from the reading.
class Bmi {
  Bmi._();

  /// Returns null when either input is missing or not physically sensible,
  /// so callers show "add height" instead of a meaningless number.
  static double? calculate({required double? weightKg, required double? heightCm}) {
    if (weightKg == null || heightCm == null) return null;
    if (weightKg <= 0 || heightCm <= 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// One decimal place, the way BMI is conventionally shown.
  static String format(double bmi) => bmi.toStringAsFixed(1);
}
