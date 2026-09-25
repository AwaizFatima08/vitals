/// The five vitals covered in V1 (design doc §4). Stored in Firestore by
/// [VitalType.key] — never rename a key once readings exist.
enum VitalType {
  bloodPressure('bloodPressure', 'mmHg'),
  spo2('spo2', '%'),
  pulse('pulse', 'bpm'),
  weight('weight', 'kg'),
  glucose('glucose', 'mg/dL');

  final String key;
  final String unit;

  const VitalType(this.key, this.unit);

  static VitalType? fromKey(String? key) {
    for (final type in VitalType.values) {
      if (type.key == key) return type;
    }
    return null;
  }

  /// Unit for display after a number. A normal space before it (so at large
  /// fonts the whole unit moves to the next line) and a word-joiner after "/"
  /// (so "mg/dL" is never split into "mg/" + "dL"). A non-breaking space
  /// here glued number+unit into one over-long word, which Flutter then
  /// broke mid-word ("mm|Hg") on a 1.3x-font phone.
  String get displayUnit => ' ${unit.replaceAll('/', '/\u2060')}';

  /// Blood pressure is the only vital entered as two numbers.
  bool get isDual => this == VitalType.bloodPressure;

  /// Weight is the only vital commonly read with a decimal (e.g. 72.4 kg).
  /// Everything else is read as a whole number off home devices.
  bool get allowsDecimal => this == VitalType.weight;
}

/// When a glucose reading was taken. Determines which reference range
/// applies (design doc §6 has separate fasting and after-meal ranges).
enum GlucoseContext {
  fasting('fasting'),
  beforeMeal('beforeMeal'),
  afterMeal('afterMeal'),
  random('random');

  final String key;

  const GlucoseContext(this.key);

  static GlucoseContext? fromKey(String? key) {
    for (final context in GlucoseContext.values) {
      if (context.key == key) return context;
    }
    return null;
  }

  /// Fasting and before-meal share the stricter range; after-meal and
  /// random share the looser one.
  bool get usesFastingRange => this == GlucoseContext.fasting || this == GlucoseContext.beforeMeal;
}
