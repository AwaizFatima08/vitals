import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_state.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/entry/vital_entry_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/patients/edit_patient_screen.dart';
import 'services/account_deletion_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/patient_service.dart';
import 'services/reminder_service.dart';
import 'services/vital_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _useEmulatorsIfRequested();
  final launchPayload = await NotificationService.instance.initialize();

  final authService = AuthService();
  final patientService = PatientService();
  final reminderService = ReminderService();

  runApp(
    LiveHealthyVitalsApp(
      authService: authService,
      patientService: patientService,
      vitalService: VitalService(),
      reminderService: reminderService,
      accountDeletionService: AccountDeletionService(),
      appState: AppState(
        authService: authService,
        patientService: patientService,
        reminderService: reminderService,
        scheduler: NotificationService.instance,
      ),
      reminderTaps: NotificationService.instance.onReminderTapped,
      launchPayload: launchPayload,
    ),
  );
}

/// Debug-only: `flutter run --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2`
/// points Auth + Firestore at local emulators (firebase emulators:start),
/// so testing never touches production data. Ignored in release builds.
Future<void> _useEmulatorsIfRequested() async {
  const host = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
  if (host.isEmpty || kReleaseMode) return;
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8085);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  debugPrint('Using Firebase emulators at $host');
}

/// All dependencies are passed in, so tests can build the whole app on
/// fake Firebase instances.
class LiveHealthyVitalsApp extends StatelessWidget {
  final AuthService authService;
  final PatientService patientService;
  final VitalService vitalService;
  final ReminderService reminderService;
  final AccountDeletionService accountDeletionService;
  final AppState appState;
  final Stream<ReminderPayload>? reminderTaps;
  final ReminderPayload? launchPayload;

  const LiveHealthyVitalsApp({
    super.key,
    required this.authService,
    required this.patientService,
    required this.vitalService,
    required this.reminderService,
    required this.accountDeletionService,
    required this.appState,
    this.reminderTaps,
    this.launchPayload,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<PatientService>.value(value: patientService),
        Provider<VitalService>.value(value: vitalService),
        Provider<ReminderService>.value(value: reminderService),
        Provider<AccountDeletionService>.value(value: accountDeletionService),
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: Selector<AppState, String>(
        selector: (_, s) => s.languageCode,
        builder: (context, languageCode, _) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: Locale(languageCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: RootRouter(reminderTaps: reminderTaps, launchPayload: launchPayload),
          );
        },
      ),
    );
  }
}

/// Picks the top-level screen from auth/patient state, and routes tapped
/// reminders to the right entry screen.
class RootRouter extends StatefulWidget {
  final Stream<ReminderPayload>? reminderTaps;
  final ReminderPayload? launchPayload;

  const RootRouter({super.key, this.reminderTaps, this.launchPayload});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  StreamSubscription<ReminderPayload>? _tapSub;
  ReminderPayload? _pending;

  @override
  void initState() {
    super.initState();
    _pending = widget.launchPayload;
    _tapSub = widget.reminderTaps?.listen((payload) {
      _pending = payload;
      _tryOpenPending();
    });
  }

  @override
  void dispose() {
    _tapSub?.cancel();
    super.dispose();
  }

  /// A reminder can arrive before sign-in/patients have loaded (cold start),
  /// so it's held until the target patient is actually available.
  void _tryOpenPending() {
    final payload = _pending;
    if (payload == null) return;
    final appState = context.read<AppState>();
    if (appState.isLoading || !appState.isSignedIn) return;
    _pending = null;
    final patient = appState.patientById(payload.patientId);
    if (patient == null) return;
    appState.setActivePatient(patient);
    rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => VitalEntryScreen(patient: patient, type: payload.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!appState.isSignedIn) {
      return const WelcomeScreen();
    }
    if (_pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenPending());
    }
    if (appState.patients.isEmpty) {
      // Normally sign-up creates a "self" patient; this covers a sign-up
      // interrupted before that step.
      return const EditPatientScreen(isFirstPatient: true);
    }
    return const HomeShell();
  }
}
