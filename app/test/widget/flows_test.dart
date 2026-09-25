import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/vitals/vital_type.dart';
import 'package:livehealthy_vitals/models/vital_reading.dart';

import '../helpers.dart';

Future<void> tapKeys(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.byKey(ValueKey('key_$d')));
    await tester.pump();
  }
}

Future<List<Map<String, dynamic>>> readings(TestHarness h, String patientId) async {
  final snap = await h.db.collection('patients/$patientId/vitalReadings').get();
  return snap.docs.map((d) => d.data()).toList();
}

Future<void> seed(TestHarness h, String patientId, VitalReading r) =>
    h.db.collection('patients/$patientId/vitalReadings').add(r.toMap());

void main() {
  group('onboarding & auth', () {
    testWidgets('signed out shows welcome with both choices and sign-in', (tester) async {
      final h = await TestHarness.create(signedIn: false);
      await h.pumpApp(tester);
      expect(find.text('Who is this app for?'), findsOneWidget);
      expect(find.text('Just me'), findsOneWidget);
      expect(find.text("I'm tracking vitals for family"), findsOneWidget);
      expect(find.byKey(const ValueKey('welcome_sign_in')), findsOneWidget);
    });

    testWidgets('sign-up validates fields', (tester) async {
      final h = await TestHarness.create(signedIn: false);
      await h.pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('choice_just_me')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('signup_submit')));
      await settle(tester);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('At least 6 characters'), findsOneWidget);
    });

    testWidgets('"just me" sign-up creates account + self patient and lands on home', (tester) async {
      final h = await TestHarness.create(signedIn: false);
      await h.pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('choice_just_me')));
      await settle(tester);
      await tester.enterText(find.byKey(const ValueKey('signup_name')), 'Alice');
      await tester.enterText(find.byKey(const ValueKey('signup_email')), 'alice@example.com');
      await tester.enterText(find.byKey(const ValueKey('signup_password')), 'secret123');
      await tester.tap(find.byKey(const ValueKey('signup_submit')));
      await settle(tester, frames: 30);

      final patients = await h.db.collection('patients').get();
      expect(patients.docs.single['relationship'], 'self');
      expect(find.byKey(const ValueKey('tile_bloodPressure')), findsOneWidget);
    });

    testWidgets('"family" sign-up asks for the family member next', (tester) async {
      final h = await TestHarness.create(signedIn: false);
      await h.pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('choice_family')));
      await settle(tester);
      await tester.enterText(find.byKey(const ValueKey('signup_name')), 'Alice');
      await tester.enterText(find.byKey(const ValueKey('signup_email')), 'alice@example.com');
      await tester.enterText(find.byKey(const ValueKey('signup_password')), 'secret123');
      await tester.tap(find.byKey(const ValueKey('signup_submit')));
      await settle(tester, frames: 30);
      expect(find.text("Add the family member whose vitals you'll be tracking."), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('patient_name')), 'Ammi');
      await tester.enterText(find.byKey(const ValueKey('patient_height')), '158');
      await tester.tap(find.byKey(const ValueKey('patient_save')));
      await settle(tester, frames: 30);

      expect(find.text('Ammi'), findsWidgets); // active patient in the header
      final mum = (await h.db.collection('patients').where('name', isEqualTo: 'Ammi').get()).docs.single;
      expect(mum['heightCm'], 158);
      expect(mum['relationship'], 'mother');
    });
  });

  group('home', () {
    testWidgets('shows one tile per vital, BMI prompt and disclaimer', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      for (final t in VitalType.values) {
        expect(find.byKey(ValueKey('tile_${t.key}')), findsOneWidget);
      }
      await tester.scrollUntilVisible(find.byKey(const ValueKey('tile_bmi')), 200);
      expect(find.text('Add height to see BMI'), findsOneWidget);
      await tester.scrollUntilVisible(find.textContaining('not a diagnosis'), 200);
      expect(find.textContaining('not a diagnosis'), findsOneWidget);
    });

    testWidgets('latest reading and flag appear on the tile', (tester) async {
      final h = await TestHarness.create();
      await seed(
        h,
        'p_self',
        VitalReading(id: '', type: VitalType.spo2, value: 92, measuredAt: DateTime.now(), createdByUid: 'alice'),
      );
      await h.pumpApp(tester);
      final tile = find.byKey(const ValueKey('tile_spo2'));
      expect(find.descendant(of: tile, matching: find.textContaining('92')), findsOneWidget);
      expect(find.descendant(of: tile, matching: find.text('Low')), findsOneWidget);
    });

    testWidgets('BMI computed from latest weight + height', (tester) async {
      final h = await TestHarness.create(selfHeight: 170);
      await seed(
        h,
        'p_self',
        VitalReading(id: '', type: VitalType.weight, value: 72.4, measuredAt: DateTime.now(), createdByUid: 'alice'),
      );
      await h.pumpApp(tester);
      await tester.scrollUntilVisible(find.byKey(const ValueKey('tile_bmi')), 200);
      expect(find.text('25.1'), findsOneWidget);
      expect(find.text('Overweight'), findsOneWidget);
    });

    testWidgets('patient switcher changes whose readings are shown', (tester) async {
      final h = await TestHarness.create(withFamily: true);
      await seed(
        h,
        'p_mum',
        VitalReading(id: '', type: VitalType.pulse, value: 88, measuredAt: DateTime.now(), createdByUid: 'alice'),
      );
      await h.pumpApp(tester);
      expect(find.textContaining('88', findRichText: true), findsNothing);
      await tester.tap(find.byKey(const ValueKey('patient_switcher')).first);
      await settle(tester);
      await tester.tap(find.text('Ammi').last);
      await settle(tester);
      expect(find.textContaining('88', findRichText: true), findsOneWidget);
      expect(h.appState.activePatient!.id, 'p_mum');
    });
  });

  group('entry', () {
    Future<void> openEntry(WidgetTester tester, VitalType type) async {
      await tester.tap(find.byKey(ValueKey('add_${type.key}')));
      await settle(tester);
    }

    testWidgets('blood pressure: six taps + save, auto-advance, live flag', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await openEntry(tester, VitalType.bloodPressure);

      await tapKeys(tester, '128'); // jumps to diastolic automatically
      await tapKeys(tester, '82');
      expect(find.text('High (Stage 1)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester, frames: 20);

      final saved = (await readings(h, 'p_self')).single;
      expect(saved['type'], 'bloodPressure');
      expect(saved['systolic'], 128);
      expect(saved['diastolic'], 82);
      expect(saved['createdByUid'], 'alice');
      expect((saved['measuredAt'] as Timestamp).toDate().difference(DateTime.now()).inMinutes.abs(), lessThan(2));
      // Back on home with the new value.
      expect(find.textContaining('128/82', findRichText: true), findsOneWidget);
    });

    testWidgets('backspace on empty diastolic returns to systolic', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await openEntry(tester, VitalType.bloodPressure);
      await tapKeys(tester, '128');
      await tester.tap(find.byKey(const ValueKey('key_backspace')));
      await tester.pump();
      await tapKeys(tester, '9');
      expect(find.text('129'), findsOneWidget);
    });

    testWidgets('empty or implausible values are rejected with a message', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await openEntry(tester, VitalType.bloodPressure);
      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester);
      expect(find.text('Enter a value'), findsNWidgets(2));

      await tapKeys(tester, '120');
      await tapKeys(tester, '130');
      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester);
      expect(find.text('The lower number must be less than the upper number'), findsOneWidget);
      expect(await readings(h, 'p_self'), isEmpty);
    });

    testWidgets('very high BP shows the seek-care notice', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await openEntry(tester, VitalType.bloodPressure);
      await tapKeys(tester, '190');
      await tapKeys(tester, '100');
      expect(find.text('Very high'), findsOneWidget);
      expect(find.textContaining('seek urgent medical care'), findsOneWidget);
    });

    testWidgets('glucose needs a context before it can be saved', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await openEntry(tester, VitalType.glucose);
      await tapKeys(tester, '110');
      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester);
      expect(find.text('Choose when the reading was taken'), findsOneWidget);
      expect(await readings(h, 'p_self'), isEmpty);

      await tester.tap(find.byKey(const ValueKey('ctx_fasting')));
      await tester.pump();
      expect(find.text('Prediabetic range'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ctx_afterMeal')));
      await tester.pump();
      expect(find.text('Normal'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester, frames: 20);
      final saved = (await readings(h, 'p_self')).single;
      expect(saved['glucoseContext'], 'afterMeal');
      expect(saved['value'], 110);
    });

    testWidgets('weight accepts one decimal place and saves a note', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await openEntry(tester, VitalType.weight);
      await tapKeys(tester, '72.45');
      expect(find.textContaining('72.4'), findsWidgets);
      await tester.enterText(find.byKey(const ValueKey('reading_note')), 'after breakfast');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester, frames: 20);
      final saved = (await readings(h, 'p_self')).single;
      expect(saved['value'], 72.4);
      expect(saved['note'], 'after breakfast');
    });
  });

  group('history', () {
    testWidgets('lists readings in range with flags; edit and delete work', (tester) async {
      final h = await TestHarness.create();
      final now = DateTime.now();
      await seed(
        h,
        'p_self',
        VitalReading(id: '', type: VitalType.pulse, value: 72, measuredAt: now, createdByUid: 'alice'),
      );
      await seed(
        h,
        'p_self',
        VitalReading(
          id: '',
          type: VitalType.pulse,
          value: 110,
          measuredAt: now.subtract(const Duration(days: 3)),
          createdByUid: 'alice',
        ),
      );
      await seed(
        h,
        'p_self',
        VitalReading(
          id: '',
          type: VitalType.pulse,
          value: 55,
          measuredAt: now.subtract(const Duration(days: 60)),
          createdByUid: 'alice',
        ),
      );
      await h.pumpApp(tester);

      await tester.tap(find.byKey(const ValueKey('tile_pulse')));
      await settle(tester);
      expect(find.text('2 readings'), findsOneWidget); // default 30 days
      expect(find.text('High'), findsOneWidget);

      await tester.tap(find.text('90 days'));
      await settle(tester);
      expect(find.text('3 readings'), findsOneWidget);

      // Edit the 110 reading down to 100.
      await tester.tap(find.textContaining('110', findRichText: true));
      await settle(tester);
      expect(find.text('Edit reading'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('key_backspace')));
      await tester.tap(find.byKey(const ValueKey('key_backspace')));
      await tapKeys(tester, '00');
      await tester.tap(find.byKey(const ValueKey('save_reading')));
      await settle(tester, frames: 20);
      expect(find.textContaining('100 bpm', findRichText: true), findsOneWidget);

      // Delete it.
      await tester.tap(find.textContaining('100 bpm', findRichText: true));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('delete_reading')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('confirm_delete_reading')));
      await settle(tester, frames: 20);
      expect(find.text('2 readings'), findsOneWidget);
      expect((await readings(h, 'p_self')).map((r) => r['value']), isNot(contains(100)));
    });
  });

  group('reminders', () {
    testWidgets('all off by default; switching one on schedules it', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await tester.tap(find.text('Reminders'));
      await settle(tester);

      for (final t in VitalType.values) {
        final sw = tester.widget<SwitchListTile>(find.byKey(ValueKey('reminder_switch_${t.key}')));
        expect(sw.value, isFalse);
      }
      expect(h.scheduler.scheduled, isEmpty);

      await tester.tap(find.byKey(const ValueKey('reminder_switch_glucose')));
      await settle(tester, frames: 20);
      final s = h.scheduler.scheduled.single;
      expect(s.type, VitalType.glucose);
      expect(s.hour, 7);
      expect((await h.db.doc('users/alice/vitalReminders/p_self_glucose').get())['enabled'], isTrue);
      expect(find.textContaining('Daily at'), findsOneWidget);
    });
  });

  group('settings & localisation', () {
    testWidgets('switching to Urdu relabels the app right-to-left', (tester) async {
      final h = await TestHarness.create(language: 'ur');
      await h.pumpApp(tester);
      expect(find.text('بلڈ پریشر'), findsOneWidget);
      final dir = Directionality.of(tester.element(find.byKey(const ValueKey('tile_bloodPressure'))));
      expect(dir, TextDirection.rtl);
    });

    testWidgets('delete account explains the shared account before doing anything', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await tester.tap(find.text('Settings'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('settings_delete_account')));
      await settle(tester);
      expect(find.textContaining('shared by all LiveHealthy apps'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect((await h.db.doc('users/alice').get()).exists, isTrue);
    });

    testWidgets('sign out returns to welcome', (tester) async {
      final h = await TestHarness.create();
      await h.pumpApp(tester);
      await tester.tap(find.text('Settings'));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('settings_sign_out')));
      await settle(tester, frames: 20);
      expect(find.text('Who is this app for?'), findsOneWidget);
    });
  });
}
