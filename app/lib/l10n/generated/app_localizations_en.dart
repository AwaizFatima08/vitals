// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LiveHealthy: Vitals';

  @override
  String get brandName => 'LiveHealthy';

  @override
  String get appSubtitle => 'Vitals';

  @override
  String get tagline =>
      'Log blood pressure, oxygen, pulse, weight and blood sugar — simply.';

  @override
  String get onboardingTitle => 'Who is this app for?';

  @override
  String get onboardingJustMe => 'Just me';

  @override
  String get onboardingJustMeSubtitle => 'I\'ll log my own readings';

  @override
  String get onboardingFamily => 'I\'m tracking vitals for family';

  @override
  String get onboardingFamilySubtitle =>
      'For a parent, spouse, or someone else';

  @override
  String get haveAccountSignIn => 'Already use a LiveHealthy app? Sign in';

  @override
  String get sharedAccountNote =>
      'One LiveHealthy account works across all LiveHealthy apps, including LiveHealthy: Medicine Reminder.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get language => 'Language';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetEmailSent =>
      'If an account exists for that email, a password reset link is on its way.';

  @override
  String get enterEmailFirst => 'Enter your email above first.';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get fieldRequired => 'Required';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get signInFailed =>
      'Could not sign in. Check your email and password.';

  @override
  String get errorEmailInUse =>
      'That email is already registered. Try signing in instead.';

  @override
  String get errorWeakPassword => 'Please choose a stronger password.';

  @override
  String get errorInvalidEmail => 'That email address looks invalid.';

  @override
  String get errorNetwork => 'No internet connection. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccountCreate => 'New to LiveHealthy? Create an account';

  @override
  String get navVitals => 'Vitals';

  @override
  String get navPatients => 'Patients';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navSettings => 'Settings';

  @override
  String get vitalBloodPressure => 'Blood pressure';

  @override
  String get vitalSpo2 => 'Oxygen (SpO2)';

  @override
  String get vitalPulse => 'Pulse';

  @override
  String get vitalWeight => 'Weight';

  @override
  String get vitalGlucose => 'Blood glucose';

  @override
  String get bmi => 'BMI';

  @override
  String get systolic => 'Upper (systolic)';

  @override
  String get diastolic => 'Lower (diastolic)';

  @override
  String get glucoseFasting => 'Fasting';

  @override
  String get glucoseBeforeMeal => 'Before meal';

  @override
  String get glucoseAfterMeal => 'After meal';

  @override
  String get glucoseRandom => 'Random';

  @override
  String get glucoseContextLabel => 'When was it taken?';

  @override
  String get selectGlucoseContext => 'Choose when the reading was taken';

  @override
  String get noReadingsYet => 'No readings yet';

  @override
  String get addReading => 'Add reading';

  @override
  String addVitalReading(String vital) {
    return 'Add $vital';
  }

  @override
  String get editReading => 'Edit reading';

  @override
  String get measuredAt => 'Taken';

  @override
  String get change => 'Change';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'e.g. before walk, felt dizzy';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get readingSaved => 'Reading saved';

  @override
  String get readingDeleted => 'Reading deleted';

  @override
  String get saveFailed => 'Could not save. Please try again.';

  @override
  String get deleteReadingTitle => 'Delete this reading?';

  @override
  String get deleteReadingBody =>
      'This removes the reading from history and charts. It cannot be undone.';

  @override
  String get futureTimeError => 'The reading time can\'t be in the future.';

  @override
  String get validationRequired => 'Enter a value';

  @override
  String validationOutOfRange(String min, String max, String unit) {
    return 'Check this value — expected $min to $max $unit';
  }

  @override
  String get validationDiastolic =>
      'The lower number must be less than the upper number';

  @override
  String get rangeBpNormal => 'Normal';

  @override
  String get rangeBpElevated => 'Elevated';

  @override
  String get rangeBpStage1 => 'High (Stage 1)';

  @override
  String get rangeBpStage2 => 'High (Stage 2)';

  @override
  String get rangeBpVeryHigh => 'Very high';

  @override
  String get rangeSpo2Normal => 'Normal';

  @override
  String get rangeSpo2Low => 'Low';

  @override
  String get rangeSpo2Critical => 'Critical';

  @override
  String get rangePulseLow => 'Low';

  @override
  String get rangePulseNormal => 'Normal';

  @override
  String get rangePulseHigh => 'High';

  @override
  String get rangeGlucoseLow => 'Low';

  @override
  String get rangeGlucoseNormal => 'Normal';

  @override
  String get rangeGlucosePrediabetic => 'Prediabetic range';

  @override
  String get rangeGlucoseDiabetic => 'Diabetic range';

  @override
  String get rangeBmiUnderweight => 'Underweight';

  @override
  String get rangeBmiNormal => 'Normal';

  @override
  String get rangeBmiOverweight => 'Overweight';

  @override
  String get rangeBmiObese => 'Obese';

  @override
  String get urgentBp =>
      'This reading is very high. If it stays this high, or there is chest pain, shortness of breath, weakness, or vision changes, seek urgent medical care.';

  @override
  String get urgentSpo2 =>
      'This oxygen level is very low. If the reading is correct (not a device error), seek medical care promptly.';

  @override
  String get disclaimerShort =>
      'Colour flags use general adult reference ranges. For information only — not a diagnosis. Talk to your doctor about your readings.';

  @override
  String get disclaimerLimitations =>
      'These ranges are for adults. They may not suit children, pregnancy, athletes, or people on medicines that affect heart rate, blood pressure or blood sugar.';

  @override
  String get onboardingDisclaimer =>
      'LiveHealthy: Vitals helps you keep a record of readings you take with your own devices. It does not measure anything itself and does not give medical advice.';

  @override
  String get range7 => '7 days';

  @override
  String get range30 => '30 days';

  @override
  String get range90 => '90 days';

  @override
  String get chartEmpty => 'No readings in this period';

  @override
  String get historyTitle => 'History';

  @override
  String readingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '1 reading',
    );
    return '$_temp0';
  }

  @override
  String get bmiNeedsHeight => 'Add height to see BMI';

  @override
  String get bmiNeedsWeight => 'Log a weight to see BMI';

  @override
  String bmiFromLatest(String height) {
    return 'From latest weight and height $height cm';
  }

  @override
  String get addHeight => 'Add height';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get heightHelp => 'Used to calculate BMI. You can add it later.';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get addPatient => 'Add a patient';

  @override
  String get editPatient => 'Edit patient';

  @override
  String get patientName => 'Name';

  @override
  String get relationshipToYou => 'Relationship to you';

  @override
  String get relSelf => 'Me';

  @override
  String get relMother => 'Mother';

  @override
  String get relFather => 'Father';

  @override
  String get relSpouse => 'Spouse';

  @override
  String get relGrandparent => 'Grandparent';

  @override
  String get relChild => 'Child';

  @override
  String get relOther => 'Other family member';

  @override
  String get activePatientLabel => 'Showing';

  @override
  String get switchPatient => 'Switch patient';

  @override
  String get firstFamilyMemberPrompt =>
      'Add the family member whose vitals you\'ll be tracking.';

  @override
  String get noPatientsPrompt =>
      'Add the first person whose vitals you\'ll track.';

  @override
  String get sharedWithCaregivers => 'Shared with other caregivers';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersIntro =>
      'Optional. Get a gentle daily notification to check a vital. Every reminder is off unless you turn it on.';

  @override
  String remindersFor(String patient) {
    return 'For $patient';
  }

  @override
  String reminderAt(String time) {
    return 'Daily at $time';
  }

  @override
  String get reminderOff => 'Off';

  @override
  String reminderNotificationTitle(String vital) {
    return 'Time to check $vital';
  }

  @override
  String reminderNotificationBody(String patient) {
    return 'Tap to log $patient\'s reading.';
  }

  @override
  String get reminderNotificationBodySelf => 'Tap to log your reading.';

  @override
  String get notificationsBlocked =>
      'Notifications are turned off for this app. Turn them on in your phone\'s settings to get reminders.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو (Urdu)';

  @override
  String get aboutRanges => 'About the colour flags';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms & conditions';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently deletes your LiveHealthy account and the data you own';

  @override
  String get deleteAccountTitle => 'Delete your LiveHealthy account?';

  @override
  String get deleteAccountBody =>
      'Your LiveHealthy account is shared by all LiveHealthy apps. Deleting it permanently removes the account and, for every patient you solely manage, all their vital readings AND any LiveHealthy: Medicine Reminder medicines, schedules and history. Patients you share with another caregiver stay with them — you just lose access. This cannot be undone.';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get confirmPasswordTitle => 'Confirm your password';

  @override
  String get confirmPasswordBody =>
      'For your security, please re-enter your password to finish deleting your account.';

  @override
  String get confirm => 'Confirm';

  @override
  String get passwordMismatch =>
      'That password didn\'t match. Please try again.';

  @override
  String get deleteFailed => 'Could not delete your account. Please try again.';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get ok => 'OK';
}
