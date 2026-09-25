import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LiveHealthy Vitals'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'LiveHealthy'**
  String get brandName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get appSubtitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Log blood pressure, oxygen, pulse, weight and blood sugar — simply.'**
  String get tagline;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this app for?'**
  String get onboardingTitle;

  /// No description provided for @onboardingJustMe.
  ///
  /// In en, this message translates to:
  /// **'Just me'**
  String get onboardingJustMe;

  /// No description provided for @onboardingJustMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'ll log my own readings'**
  String get onboardingJustMeSubtitle;

  /// No description provided for @onboardingFamily.
  ///
  /// In en, this message translates to:
  /// **'I\'m tracking vitals for family'**
  String get onboardingFamily;

  /// No description provided for @onboardingFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'For a parent, spouse, or someone else'**
  String get onboardingFamilySubtitle;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already use a LiveHealthy app? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @sharedAccountNote.
  ///
  /// In en, this message translates to:
  /// **'One LiveHealthy account works across all LiveHealthy apps, including Pill Reminder.'**
  String get sharedAccountNote;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a password reset link is on its way.'**
  String get resetEmailSent;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above first.'**
  String get enterEmailFirst;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your email and password.'**
  String get signInFailed;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered. Try signing in instead.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password.'**
  String get errorWeakPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address looks invalid.'**
  String get errorInvalidEmail;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccountCreate.
  ///
  /// In en, this message translates to:
  /// **'New to LiveHealthy? Create an account'**
  String get noAccountCreate;

  /// No description provided for @navVitals.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get navVitals;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navReminders;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @vitalBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get vitalBloodPressure;

  /// No description provided for @vitalSpo2.
  ///
  /// In en, this message translates to:
  /// **'Oxygen (SpO2)'**
  String get vitalSpo2;

  /// No description provided for @vitalPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get vitalPulse;

  /// No description provided for @vitalWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get vitalWeight;

  /// No description provided for @vitalGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood glucose'**
  String get vitalGlucose;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Upper (systolic)'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Lower (diastolic)'**
  String get diastolic;

  /// No description provided for @glucoseFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get glucoseFasting;

  /// No description provided for @glucoseBeforeMeal.
  ///
  /// In en, this message translates to:
  /// **'Before meal'**
  String get glucoseBeforeMeal;

  /// No description provided for @glucoseAfterMeal.
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get glucoseAfterMeal;

  /// No description provided for @glucoseRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get glucoseRandom;

  /// No description provided for @glucoseContextLabel.
  ///
  /// In en, this message translates to:
  /// **'When was it taken?'**
  String get glucoseContextLabel;

  /// No description provided for @selectGlucoseContext.
  ///
  /// In en, this message translates to:
  /// **'Choose when the reading was taken'**
  String get selectGlucoseContext;

  /// No description provided for @noReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get noReadingsYet;

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add reading'**
  String get addReading;

  /// No description provided for @addVitalReading.
  ///
  /// In en, this message translates to:
  /// **'Add {vital}'**
  String addVitalReading(String vital);

  /// No description provided for @editReading.
  ///
  /// In en, this message translates to:
  /// **'Edit reading'**
  String get editReading;

  /// No description provided for @measuredAt.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get measuredAt;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. before walk, felt dizzy'**
  String get noteHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @readingSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved'**
  String get readingSaved;

  /// No description provided for @readingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reading deleted'**
  String get readingDeleted;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get saveFailed;

  /// No description provided for @deleteReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this reading?'**
  String get deleteReadingTitle;

  /// No description provided for @deleteReadingBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the reading from history and charts. It cannot be undone.'**
  String get deleteReadingBody;

  /// No description provided for @futureTimeError.
  ///
  /// In en, this message translates to:
  /// **'The reading time can\'t be in the future.'**
  String get futureTimeError;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a value'**
  String get validationRequired;

  /// No description provided for @validationOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Check this value — expected {min} to {max} {unit}'**
  String validationOutOfRange(String min, String max, String unit);

  /// No description provided for @validationDiastolic.
  ///
  /// In en, this message translates to:
  /// **'The lower number must be less than the upper number'**
  String get validationDiastolic;

  /// No description provided for @rangeBpNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get rangeBpNormal;

  /// No description provided for @rangeBpElevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get rangeBpElevated;

  /// No description provided for @rangeBpStage1.
  ///
  /// In en, this message translates to:
  /// **'High (Stage 1)'**
  String get rangeBpStage1;

  /// No description provided for @rangeBpStage2.
  ///
  /// In en, this message translates to:
  /// **'High (Stage 2)'**
  String get rangeBpStage2;

  /// No description provided for @rangeBpVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get rangeBpVeryHigh;

  /// No description provided for @rangeSpo2Normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get rangeSpo2Normal;

  /// No description provided for @rangeSpo2Low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get rangeSpo2Low;

  /// No description provided for @rangeSpo2Critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get rangeSpo2Critical;

  /// No description provided for @rangePulseLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get rangePulseLow;

  /// No description provided for @rangePulseNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get rangePulseNormal;

  /// No description provided for @rangePulseHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get rangePulseHigh;

  /// No description provided for @rangeGlucoseLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get rangeGlucoseLow;

  /// No description provided for @rangeGlucoseNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get rangeGlucoseNormal;

  /// No description provided for @rangeGlucosePrediabetic.
  ///
  /// In en, this message translates to:
  /// **'Prediabetic range'**
  String get rangeGlucosePrediabetic;

  /// No description provided for @rangeGlucoseDiabetic.
  ///
  /// In en, this message translates to:
  /// **'Diabetic range'**
  String get rangeGlucoseDiabetic;

  /// No description provided for @rangeBmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get rangeBmiUnderweight;

  /// No description provided for @rangeBmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get rangeBmiNormal;

  /// No description provided for @rangeBmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get rangeBmiOverweight;

  /// No description provided for @rangeBmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get rangeBmiObese;

  /// No description provided for @urgentBp.
  ///
  /// In en, this message translates to:
  /// **'This reading is very high. If it stays this high, or there is chest pain, shortness of breath, weakness, or vision changes, seek urgent medical care.'**
  String get urgentBp;

  /// No description provided for @urgentSpo2.
  ///
  /// In en, this message translates to:
  /// **'This oxygen level is very low. If the reading is correct (not a device error), seek medical care promptly.'**
  String get urgentSpo2;

  /// No description provided for @disclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'Colour flags use general adult reference ranges. For information only — not a diagnosis. Talk to your doctor about your readings.'**
  String get disclaimerShort;

  /// No description provided for @disclaimerLimitations.
  ///
  /// In en, this message translates to:
  /// **'These ranges are for adults. They may not suit children, pregnancy, athletes, or people on medicines that affect heart rate, blood pressure or blood sugar.'**
  String get disclaimerLimitations;

  /// No description provided for @onboardingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'LiveHealthy Vitals helps you keep a record of readings you take with your own devices. It does not measure anything itself and does not give medical advice.'**
  String get onboardingDisclaimer;

  /// No description provided for @range7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get range7;

  /// No description provided for @range30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get range30;

  /// No description provided for @range90.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get range90;

  /// No description provided for @chartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No readings in this period'**
  String get chartEmpty;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @readingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reading} other{{count} readings}}'**
  String readingsCount(int count);

  /// No description provided for @bmiNeedsHeight.
  ///
  /// In en, this message translates to:
  /// **'Add height to see BMI'**
  String get bmiNeedsHeight;

  /// No description provided for @bmiNeedsWeight.
  ///
  /// In en, this message translates to:
  /// **'Log a weight to see BMI'**
  String get bmiNeedsWeight;

  /// No description provided for @bmiFromLatest.
  ///
  /// In en, this message translates to:
  /// **'From latest weight and height {height} cm'**
  String bmiFromLatest(String height);

  /// No description provided for @addHeight.
  ///
  /// In en, this message translates to:
  /// **'Add height'**
  String get addHeight;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @heightHelp.
  ///
  /// In en, this message translates to:
  /// **'Used to calculate BMI. You can add it later.'**
  String get heightHelp;

  /// No description provided for @patientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsTitle;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add a patient'**
  String get addPatient;

  /// No description provided for @editPatient.
  ///
  /// In en, this message translates to:
  /// **'Edit patient'**
  String get editPatient;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get patientName;

  /// No description provided for @relationshipToYou.
  ///
  /// In en, this message translates to:
  /// **'Relationship to you'**
  String get relationshipToYou;

  /// No description provided for @relSelf.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get relSelf;

  /// No description provided for @relMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get relMother;

  /// No description provided for @relFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get relFather;

  /// No description provided for @relSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relSpouse;

  /// No description provided for @relGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relGrandparent;

  /// No description provided for @relChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get relChild;

  /// No description provided for @relOther.
  ///
  /// In en, this message translates to:
  /// **'Other family member'**
  String get relOther;

  /// No description provided for @activePatientLabel.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get activePatientLabel;

  /// No description provided for @switchPatient.
  ///
  /// In en, this message translates to:
  /// **'Switch patient'**
  String get switchPatient;

  /// No description provided for @firstFamilyMemberPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add the family member whose vitals you\'ll be tracking.'**
  String get firstFamilyMemberPrompt;

  /// No description provided for @noPatientsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add the first person whose vitals you\'ll track.'**
  String get noPatientsPrompt;

  /// No description provided for @sharedWithCaregivers.
  ///
  /// In en, this message translates to:
  /// **'Shared with other caregivers'**
  String get sharedWithCaregivers;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersIntro.
  ///
  /// In en, this message translates to:
  /// **'Optional. Get a gentle daily notification to check a vital. Every reminder is off unless you turn it on.'**
  String get remindersIntro;

  /// No description provided for @remindersFor.
  ///
  /// In en, this message translates to:
  /// **'For {patient}'**
  String remindersFor(String patient);

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String reminderAt(String time);

  /// No description provided for @reminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to check {vital}'**
  String reminderNotificationTitle(String vital);

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to log {patient}\'s reading.'**
  String reminderNotificationBody(String patient);

  /// No description provided for @reminderNotificationBodySelf.
  ///
  /// In en, this message translates to:
  /// **'Tap to log your reading.'**
  String get reminderNotificationBodySelf;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for this app. Turn them on in your phone\'s settings to get reminders.'**
  String get notificationsBlocked;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'اردو (Urdu)'**
  String get languageUrdu;

  /// No description provided for @aboutRanges.
  ///
  /// In en, this message translates to:
  /// **'About the colour flags'**
  String get aboutRanges;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get termsOfUse;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes your LiveHealthy account and the data you own'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your LiveHealthy account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your LiveHealthy account is shared by all LiveHealthy apps. Deleting it permanently removes the account and, for every patient you solely manage, all their vital readings AND any Pill Reminder medicines, schedules and history. Patients you share with another caregiver stay with them — you just lose access. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @confirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordTitle;

  /// No description provided for @confirmPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'For your security, please re-enter your password to finish deleting your account.'**
  String get confirmPasswordBody;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'That password didn\'t match. Please try again.'**
  String get passwordMismatch;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get deleteFailed;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
