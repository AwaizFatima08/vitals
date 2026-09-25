import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../core/vitals/vital_type.dart';
import '../models/vital_reading.dart';

/// CRUD for readings at patients/{patientId}/vitalReadings.
///
/// Every query filters by `type` and orders by `measuredAt` — backed by the
/// composite index in firebase/firestore.indexes.json.
class VitalService {
  final FirebaseFirestore _db;

  VitalService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _readings(String patientId) =>
      _db.collection(FirestorePaths.patients).doc(patientId).collection(FirestorePaths.vitalReadings);

  Future<String> addReading(String patientId, VitalReading reading) async {
    final doc = await _readings(patientId).add(reading.toMap());
    return doc.id;
  }

  /// Keeps the original createdAt/createdByUid; only the measurement,
  /// timestamp and note are editable.
  Future<void> updateReading(String patientId, VitalReading reading) {
    final map = reading.toMap()
      ..remove('createdAt')
      ..remove('createdByUid');
    map['updatedAt'] = FieldValue.serverTimestamp();
    return _readings(patientId).doc(reading.id).update(map);
  }

  Future<void> deleteReading(String patientId, String readingId) => _readings(patientId).doc(readingId).delete();

  /// Newest first. [since] limits to a date range (7/30/90-day views).
  Stream<List<VitalReading>> watchReadings(String patientId, VitalType type, {DateTime? since}) {
    Query<Map<String, dynamic>> query = _readings(patientId).where('type', isEqualTo: type.key);
    if (since != null) {
      query = query.where('measuredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since));
    }
    return query.orderBy('measuredAt', descending: true).snapshots().map(_toReadings);
  }

  Stream<VitalReading?> watchLatest(String patientId, VitalType type) {
    return _readings(
      patientId,
    ).where('type', isEqualTo: type.key).orderBy('measuredAt', descending: true).limit(1).snapshots().map((snap) {
      final readings = _toReadings(snap);
      return readings.isEmpty ? null : readings.first;
    });
  }

  List<VitalReading> _toReadings(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map(VitalReading.fromDoc).whereType<VitalReading>().toList();
}
