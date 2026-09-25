import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livehealthy_vitals/core/app_state.dart';
import 'package:livehealthy_vitals/main.dart';
import 'package:livehealthy_vitals/services/account_deletion_service.dart';
import 'package:livehealthy_vitals/services/auth_service.dart';
import 'package:livehealthy_vitals/services/notification_service.dart';
import 'package:livehealthy_vitals/services/patient_service.dart';
import 'package:livehealthy_vitals/services/reminder_service.dart';
import 'package:livehealthy_vitals/services/vital_service.dart';

/// Records what AppState asks to schedule, instead of touching the
/// notifications platform channel.
class FakeScheduler implements ReminderScheduler {
  List<ScheduledReminder> scheduled = const [];
  int cancelAllCalls = 0;

  @override
  Future<void> sync(List<ScheduledReminder> reminders) async => scheduled = reminders;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled = const [];
  }
}

/// The whole app wired to in-memory Firebase fakes.
class TestHarness {
  final FakeFirebaseFirestore db;
  final MockFirebaseAuth auth;
  final FakeScheduler scheduler = FakeScheduler();
  late final AuthService authService = AuthService(auth: auth, firestore: db);
  late final PatientService patientService = PatientService(firestore: db);
  late final VitalService vitalService = VitalService(firestore: db);
  late final ReminderService reminderService = ReminderService(firestore: db);
  late final AccountDeletionService deletionService = AccountDeletionService(firestore: db);
  late final AppState appState = AppState(
    authService: authService,
    patientService: patientService,
    reminderService: reminderService,
    scheduler: scheduler,
  );

  TestHarness._(this.db, this.auth);

  /// [signedIn] seeds a user "alice" with profile + a "self" patient "p_self"
  /// (and optionally a family member "p_mum").
  static Future<TestHarness> create({
    bool signedIn = true,
    bool withFamily = false,
    String language = 'en',
    double? selfHeight,
  }) async {
    final db = FakeFirebaseFirestore();
    final user = MockUser(uid: 'alice', email: 'alice@example.com', displayName: 'Alice');
    final auth = MockFirebaseAuth(signedIn: signedIn, mockUser: user);
    if (signedIn) {
      await db.collection('users').doc('alice').set({
        'displayName': 'Alice',
        'email': 'alice@example.com',
        'preferredLanguage': language,
        'activePatientId': 'p_self',
      });
      await db.collection('patients').doc('p_self').set({
        'name': 'Alice',
        'ownerUid': 'alice',
        'memberUids': ['alice'],
        'relationship': 'self',
        'heightCm': ?selfHeight,
      });
      if (withFamily) {
        await db.collection('patients').doc('p_mum').set({
          'name': 'Ammi',
          'ownerUid': 'alice',
          'memberUids': ['alice'],
          'relationship': 'mother',
        });
      }
    }
    return TestHarness._(db, auth);
  }

  Widget app() => LiveHealthyVitalsApp(
    authService: authService,
    patientService: patientService,
    vitalService: vitalService,
    reminderService: reminderService,
    accountDeletionService: deletionService,
    appState: appState,
  );

  /// Pumps the app and lets the fake streams deliver.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await settle(tester);
  }
}

/// pumpAndSettle can hang on progress indicators; pump a fixed number of
/// frames instead while fake async streams deliver.
Future<void> settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
