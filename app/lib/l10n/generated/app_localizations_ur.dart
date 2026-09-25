// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'LiveHealthy Vitals';

  @override
  String get brandName => 'LiveHealthy';

  @override
  String get appSubtitle => 'وائٹلز';

  @override
  String get tagline =>
      'بلڈ پریشر، آکسیجن، نبض، وزن اور بلڈ شوگر — آسانی سے درج کریں۔';

  @override
  String get onboardingTitle => 'یہ ایپ کس کے لیے ہے؟';

  @override
  String get onboardingJustMe => 'صرف میرے لیے';

  @override
  String get onboardingJustMeSubtitle => 'میں اپنی ریڈنگز خود درج کروں گا/گی';

  @override
  String get onboardingFamily => 'میں گھر والوں کے وائٹلز رکھتا/رکھتی ہوں';

  @override
  String get onboardingFamilySubtitle => 'والدین، شریکِ حیات یا کسی اور کے لیے';

  @override
  String get haveAccountSignIn =>
      'پہلے سے LiveHealthy ایپ استعمال کرتے ہیں؟ سائن ان کریں';

  @override
  String get sharedAccountNote =>
      'ایک LiveHealthy اکاؤنٹ تمام LiveHealthy ایپس میں چلتا ہے، بشمول Pill Reminder۔';

  @override
  String get signIn => 'سائن ان';

  @override
  String get signUp => 'اکاؤنٹ بنائیں';

  @override
  String get email => 'ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get fullName => 'پورا نام';

  @override
  String get language => 'زبان';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get resetEmailSent =>
      'اگر اس ای میل کا اکاؤنٹ موجود ہے تو پاس ورڈ ری سیٹ کا لنک بھیج دیا گیا ہے۔';

  @override
  String get enterEmailFirst => 'پہلے اوپر اپنی ای میل درج کریں۔';

  @override
  String get enterValidEmail => 'درست ای میل درج کریں';

  @override
  String get fieldRequired => 'ضروری ہے';

  @override
  String get passwordTooShort => 'کم از کم 6 حروف';

  @override
  String get signInFailed =>
      'سائن ان نہیں ہو سکا۔ اپنی ای میل اور پاس ورڈ چیک کریں۔';

  @override
  String get errorEmailInUse =>
      'یہ ای میل پہلے سے رجسٹرڈ ہے۔ سائن ان کر کے دیکھیں۔';

  @override
  String get errorWeakPassword => 'براہ کرم زیادہ مضبوط پاس ورڈ منتخب کریں۔';

  @override
  String get errorInvalidEmail => 'یہ ای میل ایڈریس درست نہیں لگتا۔';

  @override
  String get errorNetwork => 'انٹرنیٹ کنکشن نہیں ہے۔ دوبارہ کوشش کریں۔';

  @override
  String get errorGeneric => 'کچھ غلط ہو گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get alreadyHaveAccount => 'پہلے سے اکاؤنٹ ہے؟ سائن ان کریں';

  @override
  String get noAccountCreate => 'LiveHealthy پر نئے ہیں؟ اکاؤنٹ بنائیں';

  @override
  String get navVitals => 'وائٹلز';

  @override
  String get navPatients => 'مریض';

  @override
  String get navReminders => 'یاد دہانیاں';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get vitalBloodPressure => 'بلڈ پریشر';

  @override
  String get vitalSpo2 => 'آکسیجن (SpO2)';

  @override
  String get vitalPulse => 'نبض';

  @override
  String get vitalWeight => 'وزن';

  @override
  String get vitalGlucose => 'بلڈ شوگر';

  @override
  String get bmi => 'BMI';

  @override
  String get systolic => 'اوپر والا (سسٹولک)';

  @override
  String get diastolic => 'نیچے والا (ڈائسٹولک)';

  @override
  String get glucoseFasting => 'نہار منہ';

  @override
  String get glucoseBeforeMeal => 'کھانے سے پہلے';

  @override
  String get glucoseAfterMeal => 'کھانے کے بعد';

  @override
  String get glucoseRandom => 'کسی بھی وقت';

  @override
  String get glucoseContextLabel => 'ریڈنگ کب لی گئی؟';

  @override
  String get selectGlucoseContext => 'منتخب کریں کہ ریڈنگ کب لی گئی';

  @override
  String get noReadingsYet => 'ابھی کوئی ریڈنگ نہیں';

  @override
  String get addReading => 'ریڈنگ درج کریں';

  @override
  String addVitalReading(String vital) {
    return '$vital درج کریں';
  }

  @override
  String get editReading => 'ریڈنگ میں ترمیم';

  @override
  String get measuredAt => 'وقت';

  @override
  String get change => 'تبدیل کریں';

  @override
  String get noteOptional => 'نوٹ (اختیاری)';

  @override
  String get noteHint => 'مثلاً سیر سے پہلے، چکر آ رہے تھے';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get delete => 'حذف کریں';

  @override
  String get done => 'ہو گیا';

  @override
  String get readingSaved => 'ریڈنگ محفوظ ہو گئی';

  @override
  String get readingDeleted => 'ریڈنگ حذف ہو گئی';

  @override
  String get saveFailed => 'محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get deleteReadingTitle => 'یہ ریڈنگ حذف کریں؟';

  @override
  String get deleteReadingBody =>
      'یہ ریڈنگ ہسٹری اور چارٹ سے ہٹ جائے گی۔ اسے واپس نہیں لایا جا سکتا۔';

  @override
  String get futureTimeError => 'ریڈنگ کا وقت آنے والا وقت نہیں ہو سکتا۔';

  @override
  String get validationRequired => 'قدر درج کریں';

  @override
  String validationOutOfRange(String min, String max, String unit) {
    return 'یہ قدر چیک کریں — $min سے $max $unit متوقع ہے';
  }

  @override
  String get validationDiastolic =>
      'نیچے والا نمبر اوپر والے نمبر سے کم ہونا چاہیے';

  @override
  String get rangeBpNormal => 'نارمل';

  @override
  String get rangeBpElevated => 'قدرے زیادہ';

  @override
  String get rangeBpStage1 => 'ہائی (اسٹیج 1)';

  @override
  String get rangeBpStage2 => 'ہائی (اسٹیج 2)';

  @override
  String get rangeBpVeryHigh => 'بہت زیادہ';

  @override
  String get rangeSpo2Normal => 'نارمل';

  @override
  String get rangeSpo2Low => 'کم';

  @override
  String get rangeSpo2Critical => 'تشویشناک';

  @override
  String get rangePulseLow => 'کم';

  @override
  String get rangePulseNormal => 'نارمل';

  @override
  String get rangePulseHigh => 'زیادہ';

  @override
  String get rangeGlucoseLow => 'کم';

  @override
  String get rangeGlucoseNormal => 'نارمل';

  @override
  String get rangeGlucosePrediabetic => 'پری ڈائیبیٹک رینج';

  @override
  String get rangeGlucoseDiabetic => 'ڈائیبیٹک رینج';

  @override
  String get rangeBmiUnderweight => 'کم وزن';

  @override
  String get rangeBmiNormal => 'نارمل';

  @override
  String get rangeBmiOverweight => 'زیادہ وزن';

  @override
  String get rangeBmiObese => 'موٹاپا';

  @override
  String get urgentBp =>
      'یہ ریڈنگ بہت زیادہ ہے۔ اگر یہ اسی طرح زیادہ رہے، یا سینے میں درد، سانس پھولنا، کمزوری یا نظر میں تبدیلی ہو تو فوری طبی مدد حاصل کریں۔';

  @override
  String get urgentSpo2 =>
      'آکسیجن کی یہ سطح بہت کم ہے۔ اگر ریڈنگ درست ہے (آلے کی غلطی نہیں) تو جلد طبی مدد حاصل کریں۔';

  @override
  String get disclaimerShort =>
      'رنگین نشانات بالغوں کی عمومی حدود پر مبنی ہیں۔ صرف معلومات کے لیے — یہ تشخیص نہیں۔ اپنی ریڈنگز کے بارے میں اپنے ڈاکٹر سے بات کریں۔';

  @override
  String get disclaimerLimitations =>
      'یہ حدود بالغوں کے لیے ہیں۔ یہ بچوں، حمل، کھلاڑیوں، یا ایسی دوائیں لینے والوں کے لیے موزوں نہیں ہو سکتیں جو دل کی دھڑکن، بلڈ پریشر یا بلڈ شوگر پر اثر ڈالتی ہیں۔';

  @override
  String get onboardingDisclaimer =>
      'LiveHealthy Vitals آپ کے اپنے آلات سے لی گئی ریڈنگز کا ریکارڈ رکھنے میں مدد دیتی ہے۔ یہ خود کچھ نہیں ناپتی اور طبی مشورہ نہیں دیتی۔';

  @override
  String get range7 => '7 دن';

  @override
  String get range30 => '30 دن';

  @override
  String get range90 => '90 دن';

  @override
  String get chartEmpty => 'اس مدت میں کوئی ریڈنگ نہیں';

  @override
  String get historyTitle => 'ہسٹری';

  @override
  String readingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ریڈنگز',
      one: '1 ریڈنگ',
    );
    return '$_temp0';
  }

  @override
  String get bmiNeedsHeight => 'BMI دیکھنے کے لیے قد درج کریں';

  @override
  String get bmiNeedsWeight => 'BMI دیکھنے کے لیے وزن درج کریں';

  @override
  String bmiFromLatest(String height) {
    return 'تازہ ترین وزن اور قد $height سینٹی میٹر سے';
  }

  @override
  String get addHeight => 'قد درج کریں';

  @override
  String get heightCm => 'قد (سینٹی میٹر)';

  @override
  String get heightHelp =>
      'BMI کے حساب کے لیے۔ آپ بعد میں بھی درج کر سکتے ہیں۔';

  @override
  String get patientsTitle => 'مریض';

  @override
  String get addPatient => 'مریض شامل کریں';

  @override
  String get editPatient => 'مریض میں ترمیم';

  @override
  String get patientName => 'نام';

  @override
  String get relationshipToYou => 'آپ سے رشتہ';

  @override
  String get relSelf => 'میں';

  @override
  String get relMother => 'والدہ';

  @override
  String get relFather => 'والد';

  @override
  String get relSpouse => 'شریکِ حیات';

  @override
  String get relGrandparent => 'دادا/دادی/نانا/نانی';

  @override
  String get relChild => 'بچہ';

  @override
  String get relOther => 'خاندان کا کوئی اور فرد';

  @override
  String get activePatientLabel => 'دکھایا جا رہا ہے';

  @override
  String get switchPatient => 'مریض تبدیل کریں';

  @override
  String get firstFamilyMemberPrompt =>
      'خاندان کے اس فرد کو شامل کریں جس کے وائٹلز آپ رکھیں گے۔';

  @override
  String get noPatientsPrompt => 'پہلا فرد شامل کریں جس کے وائٹلز آپ رکھیں گے۔';

  @override
  String get sharedWithCaregivers => 'دوسرے نگہداشت کرنے والوں کے ساتھ شیئرڈ';

  @override
  String get remindersTitle => 'یاد دہانیاں';

  @override
  String get remindersIntro =>
      'اختیاری۔ کسی وائٹل کو چیک کرنے کے لیے روزانہ ہلکی سی اطلاع حاصل کریں۔ جب تک آپ آن نہ کریں، ہر یاد دہانی بند رہتی ہے۔';

  @override
  String remindersFor(String patient) {
    return '$patient کے لیے';
  }

  @override
  String reminderAt(String time) {
    return 'روزانہ $time بجے';
  }

  @override
  String get reminderOff => 'بند';

  @override
  String reminderNotificationTitle(String vital) {
    return '$vital چیک کرنے کا وقت';
  }

  @override
  String reminderNotificationBody(String patient) {
    return '$patient کی ریڈنگ درج کرنے کے لیے ٹیپ کریں۔';
  }

  @override
  String get reminderNotificationBodySelf =>
      'اپنی ریڈنگ درج کرنے کے لیے ٹیپ کریں۔';

  @override
  String get notificationsBlocked =>
      'اس ایپ کی اطلاعات بند ہیں۔ یاد دہانیاں حاصل کرنے کے لیے فون کی ترتیبات میں انہیں آن کریں۔';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو (Urdu)';

  @override
  String get aboutRanges => 'رنگین نشانات کے بارے میں';

  @override
  String get privacyPolicy => 'پرائیویسی پالیسی';

  @override
  String get termsOfUse => 'شرائط و ضوابط';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get deleteAccount => 'میرا اکاؤنٹ حذف کریں';

  @override
  String get deleteAccountSubtitle =>
      'آپ کا LiveHealthy اکاؤنٹ اور آپ کا ڈیٹا مستقل طور پر حذف ہو جائے گا';

  @override
  String get deleteAccountTitle => 'اپنا LiveHealthy اکاؤنٹ حذف کریں؟';

  @override
  String get deleteAccountBody =>
      'آپ کا LiveHealthy اکاؤنٹ تمام LiveHealthy ایپس میں مشترک ہے۔ اسے حذف کرنے سے اکاؤنٹ مستقل طور پر ختم ہو جائے گا، اور جن مریضوں کو صرف آپ سنبھالتے ہیں ان کی تمام وائٹل ریڈنگز اور Pill Reminder کی دوائیں، شیڈول اور ہسٹری بھی حذف ہو جائیں گی۔ جو مریض آپ کسی اور کے ساتھ شیئر کرتے ہیں وہ ان کے پاس رہیں گے — صرف آپ کی رسائی ختم ہو گی۔ اسے واپس نہیں کیا جا سکتا۔';

  @override
  String get deleteEverything => 'سب کچھ حذف کریں';

  @override
  String get confirmPasswordTitle => 'اپنے پاس ورڈ کی تصدیق کریں';

  @override
  String get confirmPasswordBody =>
      'حفاظت کے لیے، اکاؤنٹ حذف کرنے کے لیے اپنا پاس ورڈ دوبارہ درج کریں۔';

  @override
  String get confirm => 'تصدیق کریں';

  @override
  String get passwordMismatch => 'پاس ورڈ درست نہیں۔ دوبارہ کوشش کریں۔';

  @override
  String get deleteFailed => 'اکاؤنٹ حذف نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String version(String version) {
    return 'ورژن $version';
  }

  @override
  String get ok => 'ٹھیک ہے';
}
