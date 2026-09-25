import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';
import 'package:livehealthy_vitals/models/vital_reading.dart';
import 'package:livehealthy_vitals/models/vital_reminder.dart';
import 'package:livehealthy_vitals/services/account_deletion_service.dart';
import 'package:livehealthy_vitals/services/patient_service.dart';
import 'package:livehealthy_vitals/services/reminder_service.dart';
import 'package:livehealthy_vitals/services/vital_service.dart';

VitalReading bp(double s, double d, DateTime at, {String uid = 'alice'}) =>
    VitalReading(id: '', type: VitalType.bloodPressure, systolic: s, diastolic: d, measuredAt: at, createdByUid: uid);

VitalReading single(VitalType type, double v, DateTime at, {GlucoseContext? ctx}) =>
    VitalReading(id: '', type: type, value: v, glucoseContext: ctx, measuredAt: at, createdByUid: 'alice');

void main() {
  late FakeFirebaseFirestore db;
  late VitalService vitals;
  final now = DateTime(2026, 9, 25, 9);

  setUp(() {
    db = FakeFirebaseFirestore();
    vitals = VitalService(firestore: db);
  });

  group('VitalService', () {
    test('add + watchReadings filters by type, newest first', () async {
      await vitals.addReading('p1', bp(120, 80, now.subtract(const Duration(days: 2))));
      await vitals.addReading('p1', bp(130, 85, now));
      await vitals.addReading('p1', single(VitalType.pulse, 72, now));

      final readings = await vitals.watchReadings('p1', VitalType.bloodPressure).first;
      expect(readings.map((r) => r.systolic), [130, 120]);
      expect(readings.every((r) => r.type == VitalType.bloodPressure), isTrue);
    });

    test('since limits the date range (7/30/90-day views)', () async {
      await vitals.addReading('p1', single(VitalType.weight, 70, now.subtract(const Duration(days: 40))));
      await vitals.addReading('p1', single(VitalType.weight, 71, now.subtract(const Duration(days: 20))));
      await vitals.addReading('p1', single(VitalType.weight, 72, now));

      final last30 = await vitals
          .watchReadings('p1', VitalType.weight, since: now.subtract(const Duration(days: 30)))
          .first;
      expect(last30.map((r) => r.value), [72, 71]);
      final last90 = await vitals
          .watchReadings('p1', VitalType.weight, since: now.subtract(const Duration(days: 90)))
          .first;
      expect(last90, hasLength(3));
    });

    test('watchLatest returns the most recent reading by measuredAt, not insertion order', () async {
      await vitals.addReading('p1', single(VitalType.spo2, 97, now));
      // Back-dated reading entered later must not become "latest".
      await vitals.addReading('p1', single(VitalType.spo2, 91, now.subtract(const Duration(hours: 5))));
      final latest = await vitals.watchLatest('p1', VitalType.spo2).first;
      expect(latest!.value, 97);
      expect(await vitals.watchLatest('p1', VitalType.glucose).first, isNull);
    });

    test('readings are scoped per patient', () async {
      await vitals.addReading('p1', single(VitalType.pulse, 70, now));
      await vitals.addReading('p2', single(VitalType.pulse, 90, now));
      final p2 = await vitals.watchReadings('p2', VitalType.pulse).first;
      expect(p2.single.value, 90);
    });

    test('update keeps the original author; delete removes', () async {
      final id = await vitals.addReading('p1', bp(120, 80, now, uid: 'alice'));
      final edited = VitalReading(
        id: id,
        type: VitalType.bloodPressure,
        systolic: 125,
        diastolic: 82,
        measuredAt: now,
        note: 'after walk',
        createdByUid: 'bob', // must be ignored
      );
      await vitals.updateReading('p1', edited);
      final doc = await db.doc('patients/p1/vitalReadings/$id').get();
      expect(doc['systolic'], 125);
      expect(doc['note'], 'after walk');
      expect(doc['createdByUid'], 'alice');
      expect(doc.data()!.containsKey('updatedAt'), isTrue);

      await vitals.deleteReading('p1', id);
      expect((await db.doc('patients/p1/vitalReadings/$id').get()).exists, isFalse);
    });

    test('malformed docs are skipped instead of breaking the list', () async {
      await db.collection('patients/p1/vitalReadings').add({
        'type': 'glucose',
        'value': 100,
        'measuredAt': Timestamp.fromDate(now),
      });
      await vitals.addReading('p1', single(VitalType.glucose, 110, now, ctx: GlucoseContext.fasting));
      final readings = await vitals.watchReadings('p1', VitalType.glucose).first;
      expect(readings.single.value, 110);
    });
  });

  group('PatientService', () {
    late PatientService patients;
    setUp(() => patients = PatientService(firestore: db));

    test('addPatient creates a Pill-Reminder-compatible doc with optional height', () async {
      final id = await patients.addPatient(name: 'Ammi', ownerUid: 'alice', relationship: 'mother', heightCm: 158);
      final doc = (await db.doc('patients/$id').get()).data()!;
      expect(doc['ownerUid'], 'alice');
      expect(doc['memberUids'], ['alice']);
      expect(doc['relationship'], 'mother');
      expect(doc['heightCm'], 158);
    });

    test('watchPatientsForUser: only member patients, self first then A–Z', () async {
      await patients.addPatient(name: 'Zara', ownerUid: 'alice', relationship: 'child');
      await patients.addPatient(name: 'Abba', ownerUid: 'alice', relationship: 'father');
      await patients.addPatient(name: 'Alice', ownerUid: 'alice', relationship: 'self');
      await patients.addPatient(name: 'Someone else', ownerUid: 'eve', relationship: 'self');
      final list = await patients.watchPatientsForUser('alice').first;
      expect(list.map((p) => p.name), ['Alice', 'Abba', 'Zara']);
    });

    test('updatePatient touches only given fields and can clear height', () async {
      await db.doc('patients/p1').set({
        'name': 'Ammi',
        'ownerUid': 'alice',
        'memberUids': ['alice'],
        'relationship': 'mother',
        'pillReminderOnlyField': 'keep me',
      });
      await patients.updatePatient('p1', heightCm: 160);
      var doc = (await db.doc('patients/p1').get()).data()!;
      expect(doc['heightCm'], 160);
      expect(doc['pillReminderOnlyField'], 'keep me');
      await patients.updatePatient('p1', clearHeight: true);
      doc = (await db.doc('patients/p1').get()).data()!;
      expect(doc.containsKey('heightCm'), isFalse);
    });
  });

  group('ReminderService', () {
    test('save + watch', () async {
      final service = ReminderService(firestore: db);
      await service.saveReminder(
        'alice',
        const VitalReminder(patientId: 'p1', type: VitalType.glucose, enabled: true, hour: 7, minute: 0),
      );
      final list = await service.watchReminders('alice').first;
      expect(list.single.docId, 'p1_glucose');
      expect((await db.doc('users/alice/vitalReminders/p1_glucose').get()).exists, isTrue);
    });
  });

  group('AccountDeletionService', () {
    test('deletes owned patients across BOTH apps, leaves shared/other data', () async {
      // Alice owns p_own (with vitals + Pill Reminder data); shares p_shared
      // owned by Bob; Bob also owns p_bob.
      await db.doc('users/alice').set({'displayName': 'Alice'});
      await db.doc('users/alice/vitalReminders/p_own_pulse').set({'enabled': true});
      await db.doc('users/bob').set({'displayName': 'Bob'});
      await db.doc('patients/p_own').set({
        'ownerUid': 'alice',
        'memberUids': ['alice'],
      });
      await db.doc('patients/p_own/vitalReadings/r1').set({'type': 'pulse'});
      await db.doc('patients/p_own/medicines/m1').set({'name': 'X'});
      await db.doc('patients/p_own/medicines/m1/schedules/s1').set({'time': '08:00'});
      await db.doc('patients/p_own/doseEvents/e1').set({'status': 'taken'});
      await db.doc('patients/p_own/purchases/pu1').set({'qty': 30});
      await db.doc('patients/p_shared').set({
        'ownerUid': 'bob',
        'memberUids': ['bob', 'alice'],
      });
      await db.doc('patients/p_shared/vitalReadings/r2').set({'type': 'pulse'});
      await db.doc('patients/p_bob').set({
        'ownerUid': 'bob',
        'memberUids': ['bob'],
      });

      await AccountDeletionService(firestore: db).deleteAccountData('alice');

      Future<bool> exists(String path) async => (await db.doc(path).get()).exists;
      expect(await exists('patients/p_own'), isFalse);
      expect(await exists('patients/p_own/vitalReadings/r1'), isFalse);
      expect(await exists('patients/p_own/medicines/m1'), isFalse);
      expect(await exists('patients/p_own/medicines/m1/schedules/s1'), isFalse);
      expect(await exists('patients/p_own/doseEvents/e1'), isFalse);
      expect(await exists('patients/p_own/purchases/pu1'), isFalse);
      expect(await exists('users/alice'), isFalse);
      expect(await exists('users/alice/vitalReminders/p_own_pulse'), isFalse);

      // Shared patient survives, Alice just loses access.
      final shared = (await db.doc('patients/p_shared').get()).data()!;
      expect(shared['memberUids'], ['bob']);
      expect(await exists('patients/p_shared/vitalReadings/r2'), isTrue);
      expect(await exists('patients/p_bob'), isTrue);
      expect(await exists('users/bob'), isTrue);
    });

    test('handles more readings than one batch', () async {
      await db.doc('patients/p_own').set({
        'ownerUid': 'alice',
        'memberUids': ['alice'],
      });
      for (var i = 0; i < 450; i++) {
        await db.collection('patients/p_own/vitalReadings').add({'type': 'pulse', 'i': i});
      }
      await AccountDeletionService(firestore: db).deleteAccountData('alice');
      final left = await db.collection('patients/p_own/vitalReadings').get();
      expect(left.docs, isEmpty);
    });
  });
}
