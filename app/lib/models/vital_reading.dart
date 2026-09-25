import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/vitals/bmi.dart';
import '../core/vitals/reference_ranges.dart';
import '../core/vitals/vital_type.dart';

/// One logged reading, stored at patients/{patientId}/vitalReadings/{id}.
///
/// Blood pressure uses [systolic]/[diastolic]; every other vital uses
/// [value]. Glucose readings always carry a [glucoseContext].
class VitalReading {
  final String id;
  final VitalType type;
  final double? systolic;
  final double? diastolic;
  final double? value;
  final GlucoseContext? glucoseContext;
  final DateTime measuredAt;
  final String note;
  final String createdByUid;
  final DateTime? createdAt;

  const VitalReading({
    required this.id,
    required this.type,
    this.systolic,
    this.diastolic,
    this.value,
    this.glucoseContext,
    required this.measuredAt,
    this.note = '',
    required this.createdByUid,
    this.createdAt,
  });

  /// Returns null for documents that aren't a recognisable reading (unknown
  /// type from a future app version, or missing values), so one bad doc can
  /// never break a whole list.
  static VitalReading? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data();
    if (map == null) return null;
    final type = VitalType.fromKey(map['type'] as String?);
    final measuredAt = (map['measuredAt'] as Timestamp?)?.toDate();
    if (type == null || measuredAt == null) return null;

    final reading = VitalReading(
      id: doc.id,
      type: type,
      systolic: (map['systolic'] as num?)?.toDouble(),
      diastolic: (map['diastolic'] as num?)?.toDouble(),
      value: (map['value'] as num?)?.toDouble(),
      glucoseContext: GlucoseContext.fromKey(map['glucoseContext'] as String?),
      measuredAt: measuredAt,
      note: (map['note'] as String?) ?? '',
      createdByUid: (map['createdByUid'] as String?) ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
    return reading.isComplete ? reading : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.key,
      if (type.isDual) 'systolic': systolic,
      if (type.isDual) 'diastolic': diastolic,
      if (!type.isDual) 'value': value,
      if (type == VitalType.glucose) 'glucoseContext': glucoseContext?.key,
      'measuredAt': Timestamp.fromDate(measuredAt),
      'note': note,
      'createdByUid': createdByUid,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
    };
  }

  bool get isComplete {
    if (type.isDual) return systolic != null && diastolic != null;
    if (value == null) return false;
    if (type == VitalType.glucose) return glucoseContext != null;
    return true;
  }

  /// The reference-range flag for this reading. Weight has no flag of its
  /// own — its BMI is flagged instead via [bmiRange].
  RangeResult? get range {
    switch (type) {
      case VitalType.bloodPressure:
        return ReferenceRanges.bloodPressure(systolic!, diastolic!);
      case VitalType.spo2:
        return ReferenceRanges.spo2(value!);
      case VitalType.pulse:
        return ReferenceRanges.pulse(value!);
      case VitalType.glucose:
        return ReferenceRanges.glucose(value!, glucoseContext!);
      case VitalType.weight:
        return null;
    }
  }

  double? bmi(double? heightCm) => type == VitalType.weight ? Bmi.calculate(weightKg: value, heightCm: heightCm) : null;

  RangeResult? bmiRange(double? heightCm) {
    final computed = bmi(heightCm);
    return computed == null ? null : ReferenceRanges.bmi(computed);
  }

  /// Display string without unit, e.g. "128/82", "97", "72.4".
  String get displayValue {
    if (type.isDual) return '${formatNumber(systolic!)}/${formatNumber(diastolic!)}';
    return formatNumber(value!);
  }

  static String formatNumber(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
