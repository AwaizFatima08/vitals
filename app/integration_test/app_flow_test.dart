// End-to-end run of the real app on a device/emulator against LOCAL
// Firebase emulators (never production). Also captures the Play Store
// screenshots. Run via scripts/run_e2e.sh.
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:livehealthy_vitals/main.dart' as app;

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> waitFor(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 20)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> tapKeys(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.byKey(ValueKey('key_$d')));
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Scrolls the home list (first Scrollable; other tabs are kept alive too)
/// until [finder] is built — needed on shorter phone screens.
Future<void> scrollHomeTo(WidgetTester tester, Finder finder, {double delta = 250}) async {
  await tester.scrollUntilVisible(finder, delta, scrollable: find.byType(Scrollable).first);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Realistic-looking history for screenshots: ~5 weeks of readings.
Future<void> seedHistory(String patientId, String uid) async {
  final col = FirebaseFirestore.instance.collection('patients/$patientId/vitalReadings');
  final rnd = Random(7);
  final now = DateTime.now();
  final batch = FirebaseFirestore.instance.batch();
  for (var day = 34; day >= 1; day--) {
    final morning = DateTime(now.year, now.month, now.day, 8, rnd.nextInt(40)).subtract(Duration(days: day));
    final base = {'note': '', 'createdByUid': uid, 'createdAt': Timestamp.now()};
    batch.set(col.doc(), {
      ...base,
      'type': 'bloodPressure',
      'systolic': 124 + rnd.nextInt(18) - (day < 12 ? 6 : 0),
      'diastolic': 78 + rnd.nextInt(10) - (day < 12 ? 3 : 0),
      'measuredAt': Timestamp.fromDate(morning),
    });
    batch.set(col.doc(), {
      ...base,
      'type': 'pulse',
      'value': 66 + rnd.nextInt(18),
      'measuredAt': Timestamp.fromDate(morning),
    });
    batch.set(col.doc(), {
      ...base,
      'type': 'spo2',
      'value': 95 + rnd.nextInt(4),
      'measuredAt': Timestamp.fromDate(morning),
    });
    batch.set(col.doc(), {
      ...base,
      'type': 'glucose',
      'value': 92 + rnd.nextInt(22),
      'glucoseContext': 'fasting',
      'measuredAt': Timestamp.fromDate(morning.subtract(const Duration(minutes: 30))),
    });
    if (day % 3 == 0) {
      batch.set(col.doc(), {
        ...base,
        'type': 'weight',
        'value': 78.0 - (34 - day) * 0.06 + rnd.nextDouble() * 0.4,
        'measuredAt': Timestamp.fromDate(morning),
      });
    }
  }
  await batch.commit();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full journey on device', (tester) async {
    var converted = false;
    Future<void> shot(String name) async {
      await pumpFor(tester, const Duration(milliseconds: 800));
      if (!converted) {
        // Android needs this once per run before screenshots work.
        await binding.convertFlutterSurfaceToImage();
        converted = true;
      }
      await tester.pump();
      await binding.takeScreenshot(name);
    }

    app.main();
    await waitFor(tester, find.text('Who is this app for?'));
    await shot('01_welcome');

    // --- Sign up ("just me").
    await tester.tap(find.byKey(const ValueKey('choice_just_me')));
    await waitFor(tester, find.byKey(const ValueKey('signup_name')));
    final email = 'e2e_${DateTime.now().millisecondsSinceEpoch}@example.com';
    await tester.enterText(find.byKey(const ValueKey('signup_name')), 'Humayun');
    await tester.enterText(find.byKey(const ValueKey('signup_email')), email);
    await tester.enterText(find.byKey(const ValueKey('signup_password')), 'test1234');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.byKey(const ValueKey('signup_submit')));
    await waitFor(tester, find.byKey(const ValueKey('tile_bloodPressure')), timeout: const Duration(seconds: 30));

    // Nav labels must not wrap mid-word (seen at 1.3x font on a 720px phone).
    expect(
      tester.getSize(find.text('Reminders')).height,
      closeTo(tester.getSize(find.text('Vitals').last).height, 1),
      reason: '"Reminders" label wrapped',
    );

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final selfPatient =
        (await FirebaseFirestore.instance.collection('patients').where('memberUids', arrayContains: uid).get())
            .docs
            .single;
    expect(selfPatient['relationship'], 'self');

    // --- Log a blood pressure reading with the keypad.
    await tester.tap(find.byKey(const ValueKey('add_bloodPressure')));
    await waitFor(tester, find.byKey(const ValueKey('key_1')));
    await tapKeys(tester, '13886');
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.text('High (Stage 1)'), findsOneWidget);
    await shot('03_bp_entry');
    await tester.tap(find.byKey(const ValueKey('save_reading')));
    await waitFor(tester, find.textContaining('138/86', findRichText: true));

    // Stored in Firestore (emulator) with the right shape.
    final stored = await FirebaseFirestore.instance
        .collection('patients/${selfPatient.id}/vitalReadings')
        .where('type', isEqualTo: 'bloodPressure')
        .get();
    expect(stored.docs.single['systolic'], 138);
    expect(stored.docs.single['createdByUid'], uid);

    // --- Glucose needs a context; log a fasting reading.
    await scrollHomeTo(tester, find.byKey(const ValueKey('add_glucose')));
    await tester.tap(find.byKey(const ValueKey('add_glucose')));
    await waitFor(tester, find.byKey(const ValueKey('ctx_fasting')));
    // Real-font layout check (large-font phones): the required context chips
    // must be visible above the keypad, not hidden behind it.
    final keypadTop = tester.getRect(find.byKey(const ValueKey('key_1'))).top;
    for (final ctx in ['fasting', 'beforeMeal', 'afterMeal', 'random']) {
      expect(
        tester.getRect(find.byKey(ValueKey('ctx_$ctx'))).bottom,
        lessThanOrEqualTo(keypadTop),
        reason: '$ctx chip is hidden behind the keypad',
      );
    }
    await tapKeys(tester, '104');
    await tester.tap(find.byKey(const ValueKey('ctx_fasting')));
    await pumpFor(tester, const Duration(milliseconds: 300));
    await shot('04_glucose_entry');
    await tester.tap(find.byKey(const ValueKey('save_reading')));
    await waitFor(tester, find.textContaining('104', findRichText: true));

    // --- Height for BMI, via the BMI card.
    await scrollHomeTo(tester, find.byKey(const ValueKey('bmi_add_height')));
    await tester.tap(find.byKey(const ValueKey('bmi_add_height')));
    await waitFor(tester, find.byKey(const ValueKey('patient_height')));
    await tester.enterText(find.byKey(const ValueKey('patient_height')), '172');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.byKey(const ValueKey('patient_save')));
    await pumpFor(tester, const Duration(seconds: 2));

    // --- Seed a month of history, then screenshot home + charts.
    await seedHistory(selfPatient.id, uid);
    await pumpFor(tester, const Duration(seconds: 2));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('tile_bloodPressure')),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await shot('02_home');

    await scrollHomeTo(tester, find.byKey(const ValueKey('tile_bloodPressure')), delta: -250);
    await tester.tap(find.byKey(const ValueKey('tile_bloodPressure')));
    await waitFor(tester, find.text('30 days'));
    await pumpFor(tester, const Duration(seconds: 1));
    await shot('05_bp_history');
    await tester.pageBack();
    await pumpFor(tester, const Duration(seconds: 1));

    await scrollHomeTo(tester, find.byKey(const ValueKey('tile_glucose')));
    await tester.tap(find.byKey(const ValueKey('tile_glucose')));
    await waitFor(tester, find.text('30 days'));
    await pumpFor(tester, const Duration(seconds: 1));
    await shot('06_glucose_history');
    await tester.pageBack();
    await pumpFor(tester, const Duration(seconds: 1));

    // --- Reminders: switch one on (permission dialog may appear on the
    // device; the test grants it via adb beforehand).
    await tester.tap(find.text('Reminders'));
    await pumpFor(tester, const Duration(seconds: 1));
    // Scroll within the reminders list (not the home list) on short screens.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('reminder_switch_glucose')),
      200,
      scrollable: find
          .ancestor(of: find.byKey(const ValueKey('reminder_switch_bloodPressure')), matching: find.byType(Scrollable))
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('reminder_switch_glucose')));
    await pumpFor(tester, const Duration(seconds: 2));
    expect(find.textContaining('Daily at'), findsOneWidget);
    await shot('07_reminders');

    // --- Add a family member.
    await tester.tap(find.text('Patients'));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('patients_add')));
    await waitFor(tester, find.byKey(const ValueKey('patient_name')));
    await tester.enterText(find.byKey(const ValueKey('patient_name')), 'Ammi');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.byKey(const ValueKey('patient_save')));
    await pumpFor(tester, const Duration(seconds: 2));
    await shot('08_patients');

    // --- Urdu.
    await tester.tap(find.text('Settings'));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('settings_language')));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.text('اردو (Urdu)').last);
    await pumpFor(tester, const Duration(seconds: 2));
    await tester.tap(find.text('وائٹلز').last);
    await pumpFor(tester, const Duration(seconds: 1));
    // switch back to self so the Urdu screenshot has data
    final appState = find.byType(Scaffold);
    expect(appState, findsWidgets);
    await shot('09_urdu');

    // Back to English, then sign out.
    await tester.tap(find.text('ترتیبات'));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('settings_language')));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.text('English').last);
    await pumpFor(tester, const Duration(seconds: 2));
    await tester.tap(find.byKey(const ValueKey('settings_sign_out')));
    await waitFor(tester, find.text('Who is this app for?'));

    // --- Sign back in with the same account: data is still there.
    await tester.tap(find.byKey(const ValueKey('welcome_sign_in')));
    await waitFor(tester, find.byKey(const ValueKey('signin_email')));
    await tester.enterText(find.byKey(const ValueKey('signin_email')), email);
    await tester.enterText(find.byKey(const ValueKey('signin_password')), 'test1234');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.byKey(const ValueKey('signin_submit')));
    await waitFor(tester, find.byKey(const ValueKey('tile_bloodPressure')), timeout: const Duration(seconds: 30));
  });
}
