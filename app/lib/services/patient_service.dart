import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/patient.dart';

class PatientService {
  final FirebaseFirestore _db;

  PatientService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection => _db.collection(FirestorePaths.patients);

  /// Patients where the given user is the owner or a co-caregiver — the
  /// same query Pill Reminder uses, so both apps see the same people.
  Stream<List<Patient>> watchPatientsForUser(String uid) {
    return _collection.where('memberUids', arrayContains: uid).snapshots().map((snap) {
      final patients = snap.docs.map(Patient.fromDoc).toList();
      // "self" first, then alphabetical — stable order for the switcher.
      patients.sort((a, b) {
        if (a.isSelf != b.isSelf) return a.isSelf ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return patients;
    });
  }

  Future<Patient?> getPatient(String patientId) async {
    final doc = await _collection.doc(patientId).get();
    return doc.exists ? Patient.fromDoc(doc) : null;
  }

  Future<String> addPatient({
    required String name,
    required String ownerUid,
    required String relationship,
    double? heightCm,
  }) async {
    final doc = await _collection.add(
      Patient(
        id: '',
        name: name,
        ownerUid: ownerUid,
        memberUids: [ownerUid],
        photoUrl: null,
        relationship: relationship,
        heightCm: heightCm,
        createdAt: DateTime.now(),
      ).toMap(),
    );
    return doc.id;
  }

  /// Field-level update only — never rewrites the whole doc, so fields
  /// owned by Pill Reminder are left untouched. Passing [clearHeight]
  /// removes a previously set height.
  Future<void> updatePatient(
    String patientId, {
    String? name,
    String? relationship,
    double? heightCm,
    bool clearHeight = false,
  }) {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (relationship != null) updates['relationship'] = relationship;
    if (heightCm != null) updates['heightCm'] = heightCm;
    if (clearHeight) updates['heightCm'] = FieldValue.delete();
    if (updates.isEmpty) return Future.value();
    return _collection.doc(patientId).update(updates);
  }
}
