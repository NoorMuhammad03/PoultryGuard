// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PoultryGuard';

  @override
  String get continueButton => 'Continue';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get saveButton => 'Save';

  @override
  String get retryButton => 'Try again';

  @override
  String get logoutButton => 'Log out';

  @override
  String get loading => 'Loading...';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in using your phone number and password.';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => '3XX XXXXXXX';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Log in';

  @override
  String get newToPoultryGuard => 'New to PoultryGuard?';

  @override
  String get createAccount => 'Create account';

  @override
  String get enterPhoneNumber => 'Please enter your phone number';

  @override
  String get invalidPhoneNumber => 'Enter a valid Pakistani mobile number';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMinimum => 'Password must contain at least 8 characters';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Verify your phone number once before creating your account.';

  @override
  String get sendVerificationCode => 'Send verification code';

  @override
  String get registrationPhoneInfo =>
      'Your phone number is verified only once during registration.';

  @override
  String get otpTitle => 'Verify phone number';

  @override
  String otpSubtitle(String phoneNumber) {
    return 'Enter the 6-digit code sent to $phoneNumber.';
  }

  @override
  String get otpFallbackPhone => 'your phone number';

  @override
  String get otpIncompleteCode => 'Enter the complete 6-digit code.';

  @override
  String get otpVerificationFailed => 'Could not confirm phone verification.';

  @override
  String get otpPhoneMissing =>
      'Phone number is missing. Please go back and try again.';

  @override
  String get otpCodeSent => 'A new verification code has been sent.';

  @override
  String get otpVerifyButton => 'Verify OTP';

  @override
  String otpResendIn(int seconds) {
    return 'Resend code in $seconds seconds';
  }

  @override
  String get otpResendCode => 'Resend code';

  @override
  String get createPasswordTitle => 'Create a password';

  @override
  String get createPasswordSubtitle => 'Use this password for future logins.';

  @override
  String get createPasswordHint => 'Minimum 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Enter the password again';

  @override
  String get createPasswordRequired => 'Please create a password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordRequirementsTitle => 'Your password should contain:';

  @override
  String get passwordRequirementsBody =>
      '• At least 8 characters\n• A combination of letters and numbers';

  @override
  String get roleTitle => 'Who are you?';

  @override
  String get roleSubtitle => 'Select your role to continue';

  @override
  String get roleFarmer => 'Farmer';

  @override
  String get roleVeterinarian => 'Veterinarian';

  @override
  String get roleRegistrationIncomplete =>
      'Registration information is incomplete.';

  @override
  String get profileTitle => 'Set up your profile';

  @override
  String get profileSubtitle => 'Enter your basic information to continue.';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get fullNameRequired => 'Please enter your full name';

  @override
  String get fullNameTooShort => 'Name must contain at least 2 characters';

  @override
  String get profilePhoneHint => '+92 3XX XXXXXXX';

  @override
  String get farmRegistrationTitle => 'Register your farm';

  @override
  String get farmRegistrationSubtitle =>
      'Add the basic information for your poultry farm.';

  @override
  String get farmName => 'Farm name';

  @override
  String get farmNameHint => 'Example: Ali Poultry Farm';

  @override
  String get farmNameRequired => 'Please enter the farm name';

  @override
  String get farmNameTooShort => 'Farm name is too short';

  @override
  String get birdCapacity => 'Maximum bird capacity';

  @override
  String get birdCapacityHint => 'Example: 5000';

  @override
  String get birdCapacityInvalid => 'Enter a valid bird capacity';

  @override
  String get farmAddress => 'Farm address';

  @override
  String get farmAddressHint => 'Village, city or nearby landmark';

  @override
  String get farmAddressRequired => 'Please enter the farm address';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get sensorAlerts => 'Sensor alerts';

  @override
  String get sensorAlertsSubtitle =>
      'Temperature, humidity, ammonia and smoke warnings';

  @override
  String get diseaseAlerts => 'Disease alerts';

  @override
  String get diseaseAlertsSubtitle =>
      'AI diagnosis results and disease-risk notifications';

  @override
  String get communityAlerts => 'Community alerts';

  @override
  String get communityAlertsSubtitle =>
      'Warnings about nearby poultry disease outbreaks';

  @override
  String get saveFarm => 'Save farm';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordResetTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your registered phone number. We will send a verification code.';

  @override
  String get forgotOtpAppBarTitle => 'Verify code';

  @override
  String get forgotOtpTitle => 'Verify your phone number';

  @override
  String get resetPasswordAppBarTitle => 'Reset password';

  @override
  String get resetPasswordTitle => 'Create a new password';

  @override
  String get resetPasswordSubtitle =>
      'Choose a secure password containing letters and numbers.';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordHint => 'Minimum 8 characters';

  @override
  String get confirmNewPasswordHint => 'Enter the new password again';

  @override
  String get passwordLettersNumbers =>
      'Password must contain letters and numbers';

  @override
  String get phoneVerificationMissing =>
      'Phone verification is missing. Please start again.';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully. You can now log in.';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get diagnosisTitle => 'Disease detection';

  @override
  String get diagnosisAnalyzeTitle => 'Analyze poultry droppings';

  @override
  String get diagnosisAnalyzeSubtitle =>
      'Upload a clear image of poultry droppings for an offline AI prediction.';

  @override
  String get diagnosisNoImage => 'No image selected';

  @override
  String get diagnosisNoImageSubtitle =>
      'Take a clear photo or select one from your gallery.';

  @override
  String get diagnosisCamera => 'Camera';

  @override
  String get diagnosisGallery => 'Gallery';

  @override
  String get diagnosisAnalyzeButton => 'Analyze image';

  @override
  String get diagnosisSelectImageFirst =>
      'Select an image before starting the analysis.';

  @override
  String get diagnosisAnalysisFailed =>
      'Image analysis failed. Please try again.';

  @override
  String get diagnosisDisclaimer =>
      'This result is an AI prediction only and is not a confirmed veterinary diagnosis. Consult a qualified veterinarian before treatment.';

  @override
  String get diagnosisHistoryTooltip => 'Diagnosis history';

  @override
  String get diagnosisResultTitle => 'Analysis result';

  @override
  String get diagnosisPredictedResult => 'Predicted result';

  @override
  String get diagnosisLowConfidence =>
      'Confidence is low. Retake the photo in better lighting and ensure the droppings are clearly visible.';

  @override
  String get diagnosisMayIndicate => 'What this may indicate';

  @override
  String get diagnosisRecommendedNextStep => 'Recommended next step';

  @override
  String get diagnosisAnalyzeAnother => 'Analyze another image';

  @override
  String get diagnosisDemoResult => 'DEMO RESULT';

  @override
  String get diagnosisHealthy => 'Healthy';

  @override
  String get diagnosisCoccidiosis => 'Coccidiosis';

  @override
  String get diagnosisNewcastle => 'Newcastle Disease';

  @override
  String get diagnosisSalmonellosis => 'Salmonellosis';

  @override
  String get diagnosisHealthyDescription =>
      'The image does not show a strong disease indication.';

  @override
  String get diagnosisCoccidiosisDescription =>
      'The image may contain signs associated with coccidiosis.';

  @override
  String get diagnosisNewcastleDescription =>
      'The image may contain signs associated with Newcastle disease.';

  @override
  String get diagnosisSalmonellosisDescription =>
      'The image may contain signs associated with salmonellosis.';

  @override
  String get diagnosisHealthyRecommendation =>
      'Continue routine monitoring, hygiene, clean water, and proper feed management.';

  @override
  String get diagnosisCoccidiosisRecommendation =>
      'Isolate affected birds where possible and consult a veterinarian for confirmation and treatment guidance.';

  @override
  String get diagnosisNewcastleRecommendation =>
      'Treat this as a potentially serious condition. Restrict movement and contact a veterinarian immediately.';

  @override
  String get diagnosisSalmonellosisRecommendation =>
      'Improve sanitation, isolate suspected birds, and consult a veterinarian before treatment.';

  @override
  String get diagnosisUnknownDescription =>
      'The model produced an unknown classification.';

  @override
  String get diagnosisUnknownRecommendation =>
      'Consult a qualified veterinarian for further assessment.';

  @override
  String get diagnosisHistoryTitle => 'Diagnosis history';

  @override
  String get diagnosisHistoryClearTooltip => 'Clear history';

  @override
  String get diagnosisHistoryClearTitle => 'Clear diagnosis history';

  @override
  String get diagnosisHistoryClearMessage =>
      'Are you sure you want to remove all saved diagnoses?';

  @override
  String get diagnosisHistoryClearAll => 'Clear all';

  @override
  String get diagnosisHistoryCleared => 'Diagnosis history cleared.';

  @override
  String get diagnosisHistoryRemoved => 'Diagnosis removed from history.';

  @override
  String get diagnosisHistoryDeleteTitle => 'Delete diagnosis';

  @override
  String get diagnosisHistoryDeleteMessage =>
      'Remove this diagnosis from history?';

  @override
  String get diagnosisHistoryEmptyTitle => 'No diagnosis history';

  @override
  String get diagnosisHistoryEmptySubtitle =>
      'Analyzed images will appear here.';

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get chooseAppLanguage => 'Choose app language';

  @override
  String get changeLanguageAnytime =>
      'You can change the language at any time.';

  @override
  String get englishLanguage => 'English';

  @override
  String get urduLanguage => 'Urdu';

  @override
  String get languageChangedSuccessfully =>
      'Language preference updated successfully.';
}
