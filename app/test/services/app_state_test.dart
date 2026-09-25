import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';
import 'package:livehealthy_vitals/models/vital_reminder.dart';

import '../helpers.dart';

Future<void> flush() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('signed out: not loading, no user', () async {
    final h = await TestHarness.create(signedIn: false);
    h.appState; // start listening
    await flush();
    expect(h.appState.isLoading, isFalse);
    expect(h.appState.isSignedIn, isFalse);
  });

  test('signed in: loads profile, patients and the preferred active patient', () async {
    final h = await TestHarness.create(withFamily: true);
    h.appState;
    await flush();
    expect(h.appState.isLoading, isFalse);
    expect(h.appState.currentUser!.displayName, 'Alice');
    expect(h.appState.patients.map((p) => p.id), ['p_self', 'p_mum']);
    expect(h.appState.activePatient!.id, 'p_self');
  });

  test('setActivePatient persists to the shared user profile', () async {
    final h = await TestHarness.create(withFamily: true);
    h.appState;
    await flush();
    await h.appState.setActivePatient(h.appState.patientById('p_mum')!);
    await flush();
    expect(h.appState.activePatient!.id, 'p_mum');
    expect((await h.db.doc('users/alice').get())['activePatientId'], 'p_mum');
  });

  test('enabled reminders are scheduled with localized, patient-specific text', () async {
    final h = await TestHarness.create(withFamily: true);
    h.appState;
    await flush();
    await h.appState.saveReminder(
      const VitalReminder(patientId: 'p_mum', type: VitalType.bloodPressure, enabled: true, hour: 9, minute: 15),
    );
    await h.appState.saveReminder(
      const VitalReminder(patientId: 'p_self', type: VitalType.glucose, enabled: false, hour: 7, minute: 0),
    );
    await flush();
    final s = h.scheduler.scheduled.single;
    expect(s.patientId, 'p_mum');
    expect(s.hour, 9);
    expect(s.minute, 15);
    expect(s.title, 'Time to check Blood pressure');
    expect(s.body, contains('Ammi'));
  });

  test('reminder text follows the user language (Urdu)', () async {
    final h = await TestHarness.create(language: 'ur');
    h.appState;
    await flush();
    await h.appState.saveReminder(
      const VitalReminder(patientId: 'p_self', type: VitalType.pulse, enabled: true, hour: 9, minute: 0),
    );
    await flush();
    expect(h.scheduler.scheduled.single.title, contains('نبض'));
  });

  test('reminders for a patient no longer visible are not scheduled', () async {
    final h = await TestHarness.create();
    await h.db
        .doc('users/alice/vitalReminders/gone_pulse')
        .set(const VitalReminder(patientId: 'gone', type: VitalType.pulse, enabled: true, hour: 9, minute: 0).toMap());
    h.appState;
    await flush();
    expect(h.scheduler.scheduled, isEmpty);
  });

  test('sign out cancels this device\'s reminders and clears state', () async {
    final h = await TestHarness.create();
    h.appState;
    await flush();
    await h.appState.signOut();
    await flush();
    expect(h.scheduler.cancelAllCalls, 1);
    expect(h.appState.isSignedIn, isFalse);
    expect(h.appState.patients, isEmpty);
  });

  test('missing profile doc is recreated (interrupted sign-up)', () async {
    final h = await TestHarness.create();
    await h.db.doc('users/alice').delete();
    h.appState;
    await flush();
    final doc = await h.db.doc('users/alice').get();
    expect(doc.exists, isTrue);
    expect(doc['email'], 'alice@example.com');
  });
}
