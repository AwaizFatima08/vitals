import '../core/vitals/vital_type.dart';

/// An optional daily reminder to check one vital for one patient (design
/// doc §4 — off by default). Stored per account holder at
/// users/{uid}/vitalReminders/{patientId}_{type}, since a reminder belongs
/// to the person being reminded, not to the patient record every caregiver
/// shares.
class VitalReminder {
  final String patientId;
  final VitalType type;
  final bool enabled;
  final int hour;
  final int minute;

  const VitalReminder({
    required this.patientId,
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  static String docIdFor(String patientId, VitalType type) => '${patientId}_${type.key}';

  String get docId => docIdFor(patientId, type);

  static VitalReminder? fromMap(Map<String, dynamic> map) {
    final type = VitalType.fromKey(map['type'] as String?);
    final patientId = map['patientId'] as String?;
    final hour = (map['hour'] as num?)?.toInt();
    final minute = (map['minute'] as num?)?.toInt();
    if (type == null || patientId == null || hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return VitalReminder(
      patientId: patientId,
      type: type,
      enabled: (map['enabled'] as bool?) ?? false,
      hour: hour,
      minute: minute,
    );
  }

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'type': type.key,
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
  };

  VitalReminder copyWith({bool? enabled, int? hour, int? minute}) => VitalReminder(
    patientId: patientId,
    type: type,
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );

  /// Sensible default time per vital when a reminder is first switched on:
  /// fasting glucose/weight first thing in the morning, the rest mid-morning.
  static ({int hour, int minute}) defaultTimeFor(VitalType type) {
    switch (type) {
      case VitalType.glucose:
      case VitalType.weight:
        return (hour: 7, minute: 0);
      case VitalType.bloodPressure:
      case VitalType.spo2:
      case VitalType.pulse:
        return (hour: 9, minute: 0);
    }
  }
}
