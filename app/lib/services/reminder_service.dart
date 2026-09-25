import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/vital_reminder.dart';

/// Persists reminder settings at users/{uid}/vitalReminders so they survive
/// a reinstall or a new phone. Scheduling the actual notification is
/// [NotificationService]'s job — AppState keeps the two in sync.
class ReminderService {
  final FirebaseFirestore _db;

  ReminderService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _reminders(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid).collection(FirestorePaths.vitalReminders);

  Stream<List<VitalReminder>> watchReminders(String uid) {
    return _reminders(uid).snapshots().map(
      (snap) => snap.docs.map((d) => VitalReminder.fromMap(d.data())).whereType<VitalReminder>().toList(),
    );
  }

  Future<void> saveReminder(String uid, VitalReminder reminder) =>
      _reminders(uid).doc(reminder.docId).set(reminder.toMap());
}
