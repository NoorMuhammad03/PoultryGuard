// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'پولٹری گارڈ';

  @override
  String get continueButton => 'جاری رکھیں';

  @override
  String get cancelButton => 'منسوخ کریں';

  @override
  String get deleteButton => 'حذف کریں';

  @override
  String get saveButton => 'محفوظ کریں';

  @override
  String get retryButton => 'دوبارہ کوشش کریں';

  @override
  String get logoutButton => 'لاگ آؤٹ';

  @override
  String get loading => 'لوڈ ہو رہا ہے...';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get loginSubtitle =>
      'اپنے فون نمبر اور پاس ورڈ کے ذریعے لاگ اِن کریں۔';

  @override
  String get phoneNumber => 'فون نمبر';

  @override
  String get phoneHint => '3XX XXXXXXX';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get passwordHint => 'اپنا پاس ورڈ درج کریں';

  @override
  String get rememberMe => 'مجھے یاد رکھیں';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get loginButton => 'لاگ اِن';

  @override
  String get newToPoultryGuard => 'پولٹری گارڈ پر نئے ہیں؟';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get enterPhoneNumber => 'براہِ کرم اپنا فون نمبر درج کریں';

  @override
  String get invalidPhoneNumber => 'درست پاکستانی موبائل نمبر درج کریں';

  @override
  String get enterPassword => 'براہِ کرم اپنا پاس ورڈ درج کریں';

  @override
  String get passwordMinimum => 'پاس ورڈ کم از کم 8 حروف پر مشتمل ہونا چاہیے';

  @override
  String get unexpectedError =>
      'ایک غیر متوقع خرابی پیش آگئی۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String get registerTitle => 'اپنا اکاؤنٹ بنائیں';

  @override
  String get registerSubtitle =>
      'اکاؤنٹ بنانے سے پہلے اپنے فون نمبر کی ایک بار تصدیق کریں۔';

  @override
  String get sendVerificationCode => 'تصدیقی کوڈ بھیجیں';

  @override
  String get registrationPhoneInfo =>
      'آپ کے فون نمبر کی تصدیق رجسٹریشن کے دوران صرف ایک بار کی جاتی ہے۔';

  @override
  String get otpTitle => 'فون نمبر کی تصدیق کریں';

  @override
  String otpSubtitle(String phoneNumber) {
    return '$phoneNumber پر بھیجا گیا 6 ہندسوں کا کوڈ درج کریں۔';
  }

  @override
  String get otpFallbackPhone => 'آپ کا فون نمبر';

  @override
  String get otpIncompleteCode => 'مکمل 6 ہندسوں کا کوڈ درج کریں۔';

  @override
  String get otpVerificationFailed => 'فون نمبر کی تصدیق مکمل نہیں ہو سکی۔';

  @override
  String get otpPhoneMissing =>
      'فون نمبر موجود نہیں ہے۔ براہِ کرم واپس جائیں اور دوبارہ کوشش کریں۔';

  @override
  String get otpCodeSent => 'نیا تصدیقی کوڈ بھیج دیا گیا ہے۔';

  @override
  String get otpVerifyButton => 'او ٹی پی کی تصدیق کریں';

  @override
  String otpResendIn(int seconds) {
    return '$seconds سیکنڈ بعد دوبارہ کوڈ بھیجیں';
  }

  @override
  String get otpResendCode => 'کوڈ دوبارہ بھیجیں';

  @override
  String get createPasswordTitle => 'پاس ورڈ بنائیں';

  @override
  String get createPasswordSubtitle =>
      'آئندہ لاگ اِن کے لیے یہی پاس ورڈ استعمال کریں۔';

  @override
  String get createPasswordHint => 'کم از کم 8 حروف';

  @override
  String get confirmPassword => 'پاس ورڈ کی تصدیق کریں';

  @override
  String get confirmPasswordHint => 'پاس ورڈ دوبارہ درج کریں';

  @override
  String get createPasswordRequired => 'براہِ کرم پاس ورڈ بنائیں';

  @override
  String get confirmPasswordRequired => 'براہِ کرم پاس ورڈ کی تصدیق کریں';

  @override
  String get passwordsDoNotMatch => 'پاس ورڈ ایک جیسے نہیں ہیں';

  @override
  String get passwordRequirementsTitle => 'آپ کے پاس ورڈ میں یہ ہونا چاہیے:';

  @override
  String get passwordRequirementsBody =>
      '• کم از کم 8 حروف\n• حروف اور اعداد کا مجموعہ';

  @override
  String get roleTitle => 'آپ کون ہیں؟';

  @override
  String get roleSubtitle => 'جاری رکھنے کے لیے اپنا کردار منتخب کریں';

  @override
  String get roleFarmer => 'کسان';

  @override
  String get roleVeterinarian => 'ویٹرنری ڈاکٹر';

  @override
  String get roleRegistrationIncomplete => 'رجسٹریشن کی معلومات نامکمل ہیں۔';

  @override
  String get profileTitle => 'اپنی پروفائل مکمل کریں';

  @override
  String get profileSubtitle =>
      'جاری رکھنے کے لیے اپنی بنیادی معلومات درج کریں۔';

  @override
  String get fullName => 'پورا نام';

  @override
  String get fullNameHint => 'اپنا پورا نام درج کریں';

  @override
  String get fullNameRequired => 'براہِ کرم اپنا پورا نام درج کریں';

  @override
  String get fullNameTooShort => 'نام کم از کم 2 حروف پر مشتمل ہونا چاہیے';

  @override
  String get profilePhoneHint => '+92 3XX XXXXXXX';

  @override
  String get farmRegistrationTitle => 'اپنا فارم رجسٹر کریں';

  @override
  String get farmRegistrationSubtitle =>
      'اپنے پولٹری فارم کی بنیادی معلومات درج کریں۔';

  @override
  String get farmName => 'فارم کا نام';

  @override
  String get farmNameHint => 'مثال: علی پولٹری فارم';

  @override
  String get farmNameRequired => 'براہِ کرم فارم کا نام درج کریں';

  @override
  String get farmNameTooShort => 'فارم کا نام بہت مختصر ہے';

  @override
  String get birdCapacity => 'زیادہ سے زیادہ پرندوں کی گنجائش';

  @override
  String get birdCapacityHint => 'مثال: 5000';

  @override
  String get birdCapacityInvalid => 'درست گنجائش درج کریں';

  @override
  String get farmAddress => 'فارم کا پتہ';

  @override
  String get farmAddressHint => 'گاؤں، شہر یا قریبی نشان';

  @override
  String get farmAddressRequired => 'براہِ کرم فارم کا پتہ درج کریں';

  @override
  String get useCurrentLocation => 'موجودہ مقام استعمال کریں';

  @override
  String get notificationPreferences => 'اطلاع کی ترجیحات';

  @override
  String get sensorAlerts => 'سینسر الرٹس';

  @override
  String get sensorAlertsSubtitle =>
      'درجہ حرارت، نمی، امونیا اور دھوئیں کی وارننگ';

  @override
  String get diseaseAlerts => 'بیماری کے الرٹس';

  @override
  String get diseaseAlertsSubtitle =>
      'اے آئی تشخیص اور بیماری کے خطرے کی اطلاع';

  @override
  String get communityAlerts => 'کمیونٹی الرٹس';

  @override
  String get communityAlertsSubtitle =>
      'قریبی پولٹری بیماری کے پھیلاؤ کی وارننگ';

  @override
  String get saveFarm => 'فارم محفوظ کریں';

  @override
  String get forgotPasswordTitle => 'پاس ورڈ بھول گئے؟';

  @override
  String get forgotPasswordResetTitle => 'اپنا پاس ورڈ ری سیٹ کریں';

  @override
  String get forgotPasswordSubtitle =>
      'اپنا رجسٹرڈ فون نمبر درج کریں۔ ہم آپ کو تصدیقی کوڈ بھیجیں گے۔';

  @override
  String get forgotOtpAppBarTitle => 'کوڈ کی تصدیق کریں';

  @override
  String get forgotOtpTitle => 'اپنے فون نمبر کی تصدیق کریں';

  @override
  String get resetPasswordAppBarTitle => 'پاس ورڈ ری سیٹ کریں';

  @override
  String get resetPasswordTitle => 'نیا پاس ورڈ بنائیں';

  @override
  String get resetPasswordSubtitle =>
      'حروف اور اعداد پر مشتمل محفوظ پاس ورڈ منتخب کریں۔';

  @override
  String get newPassword => 'نیا پاس ورڈ';

  @override
  String get newPasswordHint => 'کم از کم 8 حروف';

  @override
  String get confirmNewPasswordHint => 'نیا پاس ورڈ دوبارہ درج کریں';

  @override
  String get passwordLettersNumbers =>
      'پاس ورڈ میں حروف اور اعداد دونوں شامل ہونے چاہئیں';

  @override
  String get phoneVerificationMissing =>
      'فون کی تصدیق موجود نہیں ہے۔ براہِ کرم دوبارہ شروع کریں۔';

  @override
  String get passwordResetSuccess =>
      'پاس ورڈ کامیابی سے ری سیٹ ہو گیا۔ اب آپ لاگ اِن کر سکتے ہیں۔';

  @override
  String get resetPasswordButton => 'پاس ورڈ ری سیٹ کریں';

  @override
  String get diagnosisTitle => 'بیماری کی تشخیص';

  @override
  String get diagnosisAnalyzeTitle => 'پولٹری فضلے کا تجزیہ کریں';

  @override
  String get diagnosisAnalyzeSubtitle =>
      'آف لائن اے آئی اندازے کے لیے پولٹری فضلے کی واضح تصویر اپ لوڈ کریں۔';

  @override
  String get diagnosisNoImage => 'کوئی تصویر منتخب نہیں کی گئی';

  @override
  String get diagnosisNoImageSubtitle =>
      'واضح تصویر لیں یا گیلری سے منتخب کریں۔';

  @override
  String get diagnosisCamera => 'کیمرہ';

  @override
  String get diagnosisGallery => 'گیلری';

  @override
  String get diagnosisAnalyzeButton => 'تصویر کا تجزیہ کریں';

  @override
  String get diagnosisSelectImageFirst =>
      'تجزیہ شروع کرنے سے پہلے تصویر منتخب کریں۔';

  @override
  String get diagnosisAnalysisFailed =>
      'تصویر کا تجزیہ ناکام ہو گیا۔ براہِ کرم دوبارہ کوشش کریں۔';

  @override
  String get diagnosisDisclaimer =>
      'یہ نتیجہ صرف اے آئی کا اندازہ ہے اور ویٹرنری تشخیص کی تصدیق نہیں ہے۔ علاج سے پہلے مستند ویٹرنری ڈاکٹر سے مشورہ کریں۔';

  @override
  String get diagnosisHistoryTooltip => 'تشخیص کی تاریخ';

  @override
  String get diagnosisResultTitle => 'تجزیے کا نتیجہ';

  @override
  String get diagnosisPredictedResult => 'متوقع نتیجہ';

  @override
  String get diagnosisLowConfidence =>
      'اعتماد کم ہے۔ بہتر روشنی میں دوبارہ تصویر لیں اور یقینی بنائیں کہ فضلہ واضح نظر آ رہا ہو۔';

  @override
  String get diagnosisMayIndicate => 'یہ کیا ظاہر کر سکتا ہے';

  @override
  String get diagnosisRecommendedNextStep => 'تجویز کردہ اگلا قدم';

  @override
  String get diagnosisAnalyzeAnother => 'ایک اور تصویر کا تجزیہ کریں';

  @override
  String get diagnosisDemoResult => 'ڈیمو نتیجہ';

  @override
  String get diagnosisHealthy => 'صحت مند';

  @override
  String get diagnosisCoccidiosis => 'کوکسیڈیوسس';

  @override
  String get diagnosisNewcastle => 'نیو کاسل بیماری';

  @override
  String get diagnosisSalmonellosis => 'سالمونیلوسس';

  @override
  String get diagnosisHealthyDescription =>
      'تصویر میں بیماری کی کوئی واضح علامت نظر نہیں آتی۔';

  @override
  String get diagnosisCoccidiosisDescription =>
      'تصویر میں کوکسیڈیوسس سے وابستہ علامات موجود ہو سکتی ہیں۔';

  @override
  String get diagnosisNewcastleDescription =>
      'تصویر میں نیو کاسل بیماری سے وابستہ علامات موجود ہو سکتی ہیں۔';

  @override
  String get diagnosisSalmonellosisDescription =>
      'تصویر میں سالمونیلوسس سے وابستہ علامات موجود ہو سکتی ہیں۔';

  @override
  String get diagnosisHealthyRecommendation =>
      'معمول کی نگرانی، صفائی، صاف پانی اور مناسب خوراک جاری رکھیں۔';

  @override
  String get diagnosisCoccidiosisRecommendation =>
      'ممکن ہو تو متاثرہ پرندوں کو الگ کریں اور تصدیق و علاج کے لیے ویٹرنری ڈاکٹر سے مشورہ کریں۔';

  @override
  String get diagnosisNewcastleRecommendation =>
      'اسے ممکنہ طور پر سنگین حالت سمجھیں۔ نقل و حرکت محدود کریں اور فوراً ویٹرنری ڈاکٹر سے رابطہ کریں۔';

  @override
  String get diagnosisSalmonellosisRecommendation =>
      'صفائی بہتر کریں، مشتبہ پرندوں کو الگ کریں اور علاج سے پہلے ویٹرنری ڈاکٹر سے مشورہ کریں۔';

  @override
  String get diagnosisUnknownDescription => 'ماڈل نے نامعلوم درجہ بندی دی ہے۔';

  @override
  String get diagnosisUnknownRecommendation =>
      'مزید جانچ کے لیے مستند ویٹرنری ڈاکٹر سے مشورہ کریں۔';

  @override
  String get diagnosisHistoryTitle => 'تشخیص کی تاریخ';

  @override
  String get diagnosisHistoryClearTooltip => 'تاریخ صاف کریں';

  @override
  String get diagnosisHistoryClearTitle => 'تشخیص کی تاریخ صاف کریں';

  @override
  String get diagnosisHistoryClearMessage =>
      'کیا آپ تمام محفوظ شدہ تشخیصات حذف کرنا چاہتے ہیں؟';

  @override
  String get diagnosisHistoryClearAll => 'سب حذف کریں';

  @override
  String get diagnosisHistoryCleared => 'تشخیص کی تاریخ صاف کر دی گئی۔';

  @override
  String get diagnosisHistoryRemoved => 'تشخیص تاریخ سے حذف کر دی گئی۔';

  @override
  String get diagnosisHistoryDeleteTitle => 'تشخیص حذف کریں';

  @override
  String get diagnosisHistoryDeleteMessage =>
      'کیا اس تشخیص کو تاریخ سے حذف کرنا ہے؟';

  @override
  String get diagnosisHistoryEmptyTitle => 'تشخیص کی کوئی تاریخ موجود نہیں';

  @override
  String get diagnosisHistoryEmptySubtitle =>
      'تجزیہ کی گئی تصاویر یہاں نظر آئیں گی۔';

  @override
  String get languageSettingsTitle => 'زبان';

  @override
  String get chooseAppLanguage => 'ایپ کی زبان منتخب کریں';

  @override
  String get changeLanguageAnytime => 'آپ کسی بھی وقت زبان تبدیل کر سکتے ہیں۔';

  @override
  String get englishLanguage => 'انگریزی';

  @override
  String get urduLanguage => 'اردو';

  @override
  String get languageChangedSuccessfully =>
      'زبان کی ترجیح کامیابی سے تبدیل کر دی گئی۔';
}
