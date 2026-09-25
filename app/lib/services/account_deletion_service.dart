import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/firestore_paths.dart';

/// Backs the account-deletion path required by Google Play's User Data
/// policy.
///
/// The LiveHealthy account is SHARED across the suite, so deleting it here
/// removes the account everywhere. It therefore cleans up everything the
/// account owns in every LiveHealthy app — vitals readings AND Pill
/// Reminder's medicines/schedules/doseEvents/purchases — rather than
/// leaving orphaned data nobody can reach.
///
/// For a patient the user solely owns, the whole patient record is
/// deleted. For a patient shared with other caregivers, the user is only
/// removed from memberUids — the household's data stays with them.
class AccountDeletionService {
  final FirebaseFirestore _db;

  AccountDeletionService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  /// Deletes everything this account owns, then the Firebase Auth user.
  /// Throws [FirebaseAuthException] with code 'requires-recent-login' if the
  /// caller needs to reauthenticate first.
  Future<void> deleteAccount(User firebaseUser) async {
    await deleteAccountData(firebaseUser.uid);
    // Must be last: once the Auth user is gone it can no longer
    // authenticate the Firestore deletes above.
    await firebaseUser.delete();
  }

  /// The Firestore half of [deleteAccount], separated so it can be tested
  /// without a real Auth user.
  Future<void> deleteAccountData(String uid) async {
    final patients = await _db.collection(FirestorePaths.patients).where('memberUids', arrayContains: uid).get();

    for (final patientDoc in patients.docs) {
      if (patientDoc.data()['ownerUid'] == uid) {
        await _deletePatientCascade(patientDoc.reference);
      } else {
        await patientDoc.reference.update({
          'memberUids': FieldValue.arrayRemove([uid]),
        });
      }
    }

    final userRef = _db.collection(FirestorePaths.users).doc(uid);
    await _deleteCollection(userRef.collection(FirestorePaths.vitalReminders));
    await userRef.delete();
  }

  Future<void> _deletePatientCascade(DocumentReference<Map<String, dynamic>> patientRef) async {
    final medicines = await patientRef.collection(FirestorePaths.medicines).get();
    for (final medicineDoc in medicines.docs) {
      await _deleteCollection(medicineDoc.reference.collection(FirestorePaths.schedules));
      await medicineDoc.reference.delete();
    }
    await _deleteCollection(patientRef.collection(FirestorePaths.doseEvents));
    await _deleteCollection(patientRef.collection(FirestorePaths.purchases));
    await _deleteCollection(patientRef.collection(FirestorePaths.vitalReadings));
    await patientRef.delete();
  }

  /// Batched (Firestore caps a batch at 500 writes) — years of daily
  /// readings would otherwise mean thousands of sequential round trips.
  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> collection) async {
    const batchSize = 400;
    while (true) {
      final snap = await collection.limit(batchSize).get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < batchSize) return;
    }
  }
}
