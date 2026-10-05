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
/// import 'l10n/app_localizations.dart';
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PoultryGuard'**
  String get appName;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in using your phone number and password.'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'3XX XXXXXXX'**
  String get phoneHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @newToPoultryGuard.
  ///
  /// In en, this message translates to:
  /// **'New to PoultryGuard?'**
  String get newToPoultryGuard;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Pakistani mobile number'**
  String get invalidPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMinimum.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 8 characters'**
  String get passwordMinimum;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number once before creating your account.'**
  String get registerSubtitle;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @registrationPhoneInfo.
  ///
  /// In en, this message translates to:
  /// **'Your phone number is verified only once during registration.'**
  String get registrationPhoneInfo;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify phone number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phoneNumber}.'**
  String otpSubtitle(String phoneNumber);

  /// No description provided for @otpFallbackPhone.
  ///
  /// In en, this message translates to:
  /// **'your phone number'**
  String get otpFallbackPhone;

  /// No description provided for @otpIncompleteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete 6-digit code.'**
  String get otpIncompleteCode;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm phone verification.'**
  String get otpVerificationFailed;

  /// No description provided for @otpPhoneMissing.
  ///
  /// In en, this message translates to:
  /// **'Phone number is missing. Please go back and try again.'**
  String get otpPhoneMissing;

  /// No description provided for @otpCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent.'**
  String get otpCodeSent;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpVerifyButton;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} seconds'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendCode;

  /// No description provided for @createPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPasswordTitle;

  /// No description provided for @createPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use this password for future logins.'**
  String get createPasswordSubtitle;

  /// No description provided for @createPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get createPasswordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the password again'**
  String get confirmPasswordHint;

  /// No description provided for @createPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please create a password'**
  String get createPasswordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your password should contain:'**
  String get passwordRequirementsTitle;

  /// No description provided for @passwordRequirementsBody.
  ///
  /// In en, this message translates to:
  /// **'• At least 8 characters\n• A combination of letters and numbers'**
  String get passwordRequirementsBody;

  /// No description provided for @roleTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your role to continue'**
  String get roleSubtitle;

  /// No description provided for @roleFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get roleFarmer;

  /// No description provided for @roleVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get roleVeterinarian;

  /// No description provided for @roleRegistrationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Registration information is incomplete.'**
  String get roleRegistrationIncomplete;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your basic information to continue.'**
  String get profileSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get fullNameRequired;

  /// No description provided for @fullNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must contain at least 2 characters'**
  String get fullNameTooShort;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+92 3XX XXXXXXX'**
  String get profilePhoneHint;

  /// No description provided for @farmRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Register your farm'**
  String get farmRegistrationTitle;

  /// No description provided for @farmRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the basic information for your poultry farm.'**
  String get farmRegistrationSubtitle;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get farmName;

  /// No description provided for @farmNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Ali Poultry Farm'**
  String get farmNameHint;

  /// No description provided for @farmNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the farm name'**
  String get farmNameRequired;

  /// No description provided for @farmNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Farm name is too short'**
  String get farmNameTooShort;

  /// No description provided for @birdCapacity.
  ///
  /// In en, this message translates to:
  /// **'Maximum bird capacity'**
  String get birdCapacity;

  /// No description provided for @birdCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 5000'**
  String get birdCapacityHint;

  /// No description provided for @birdCapacityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid bird capacity'**
  String get birdCapacityInvalid;

  /// No description provided for @farmAddress.
  ///
  /// In en, this message translates to:
  /// **'Farm address'**
  String get farmAddress;

  /// No description provided for @farmAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Village, city or nearby landmark'**
  String get farmAddressHint;

  /// No description provided for @farmAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the farm address'**
  String get farmAddressRequired;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @sensorAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sensor alerts'**
  String get sensorAlerts;

  /// No description provided for @sensorAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature, humidity, ammonia and smoke warnings'**
  String get sensorAlertsSubtitle;

  /// No description provided for @diseaseAlerts.
  ///
  /// In en, this message translates to:
  /// **'Disease alerts'**
  String get diseaseAlerts;

  /// No description provided for @diseaseAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI diagnosis results and disease-risk notifications'**
  String get diseaseAlertsSubtitle;

  /// No description provided for @communityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Community alerts'**
  String get communityAlerts;

  /// No description provided for @communityAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warnings about nearby poultry disease outbreaks'**
  String get communityAlertsSubtitle;

  /// No description provided for @saveFarm.
  ///
  /// In en, this message translates to:
  /// **'Save farm'**
  String get saveFarm;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordResetTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered phone number. We will send a verification code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotOtpAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get forgotOtpAppBarTitle;

  /// No description provided for @forgotOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get forgotOtpTitle;

  /// No description provided for @resetPasswordAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordAppBarTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a secure password containing letters and numbers.'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again'**
  String get confirmNewPasswordHint;

  /// No description provided for @passwordLettersNumbers.
  ///
  /// In en, this message translates to:
  /// **'Password must contain letters and numbers'**
  String get passwordLettersNumbers;

  /// No description provided for @phoneVerificationMissing.
  ///
  /// In en, this message translates to:
  /// **'Phone verification is missing. Please start again.'**
  String get phoneVerificationMissing;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. You can now log in.'**
  String get passwordResetSuccess;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @diagnosisTitle.
  ///
  /// In en, this message translates to:
  /// **'Disease detection'**
  String get diagnosisTitle;

  /// No description provided for @diagnosisAnalyzeTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze poultry droppings'**
  String get diagnosisAnalyzeTitle;

  /// No description provided for @diagnosisAnalyzeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear image of poultry droppings for an offline AI prediction.'**
  String get diagnosisAnalyzeSubtitle;

  /// No description provided for @diagnosisNoImage.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get diagnosisNoImage;

  /// No description provided for @diagnosisNoImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo or select one from your gallery.'**
  String get diagnosisNoImageSubtitle;

  /// No description provided for @diagnosisCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get diagnosisCamera;

  /// No description provided for @diagnosisGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get diagnosisGallery;

  /// No description provided for @diagnosisAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze image'**
  String get diagnosisAnalyzeButton;

  /// No description provided for @diagnosisSelectImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an image before starting the analysis.'**
  String get diagnosisSelectImageFirst;

  /// No description provided for @diagnosisAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Image analysis failed. Please try again.'**
  String get diagnosisAnalysisFailed;

  /// No description provided for @diagnosisDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This result is an AI prediction only and is not a confirmed veterinary diagnosis. Consult a qualified veterinarian before treatment.'**
  String get diagnosisDisclaimer;

  /// No description provided for @diagnosisHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis history'**
  String get diagnosisHistoryTooltip;

  /// No description provided for @diagnosisResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis result'**
  String get diagnosisResultTitle;

  /// No description provided for @diagnosisPredictedResult.
  ///
  /// In en, this message translates to:
  /// **'Predicted result'**
  String get diagnosisPredictedResult;

  /// No description provided for @diagnosisLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence is low. Retake the photo in better lighting and ensure the droppings are clearly visible.'**
  String get diagnosisLowConfidence;

  /// No description provided for @diagnosisMayIndicate.
  ///
  /// In en, this message translates to:
  /// **'What this may indicate'**
  String get diagnosisMayIndicate;

  /// No description provided for @diagnosisRecommendedNextStep.
  ///
  /// In en, this message translates to:
  /// **'Recommended next step'**
  String get diagnosisRecommendedNextStep;

  /// No description provided for @diagnosisAnalyzeAnother.
  ///
  /// In en, this message translates to:
  /// **'Analyze another image'**
  String get diagnosisAnalyzeAnother;

  /// No description provided for @diagnosisDemoResult.
  ///
  /// In en, this message translates to:
  /// **'DEMO RESULT'**
  String get diagnosisDemoResult;

  /// No description provided for @diagnosisHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get diagnosisHealthy;

  /// No description provided for @diagnosisCoccidiosis.
  ///
  /// In en, this message translates to:
  /// **'Coccidiosis'**
  String get diagnosisCoccidiosis;

  /// No description provided for @diagnosisNewcastle.
  ///
  /// In en, this message translates to:
  /// **'Newcastle Disease'**
  String get diagnosisNewcastle;

  /// No description provided for @diagnosisSalmonellosis.
  ///
  /// In en, this message translates to:
  /// **'Salmonellosis'**
  String get diagnosisSalmonellosis;

  /// No description provided for @diagnosisHealthyDescription.
  ///
  /// In en, this message translates to:
  /// **'The image does not show a strong disease indication.'**
  String get diagnosisHealthyDescription;

  /// No description provided for @diagnosisCoccidiosisDescription.
  ///
  /// In en, this message translates to:
  /// **'The image may contain signs associated with coccidiosis.'**
  String get diagnosisCoccidiosisDescription;

  /// No description provided for @diagnosisNewcastleDescription.
  ///
  /// In en, this message translates to:
  /// **'The image may contain signs associated with Newcastle disease.'**
  String get diagnosisNewcastleDescription;

  /// No description provided for @diagnosisSalmonellosisDescription.
  ///
  /// In en, this message translates to:
  /// **'The image may contain signs associated with salmonellosis.'**
  String get diagnosisSalmonellosisDescription;

  /// No description provided for @diagnosisHealthyRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Continue routine monitoring, hygiene, clean water, and proper feed management.'**
  String get diagnosisHealthyRecommendation;

  /// No description provided for @diagnosisCoccidiosisRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Isolate affected birds where possible and consult a veterinarian for confirmation and treatment guidance.'**
  String get diagnosisCoccidiosisRecommendation;

  /// No description provided for @diagnosisNewcastleRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Treat this as a potentially serious condition. Restrict movement and contact a veterinarian immediately.'**
  String get diagnosisNewcastleRecommendation;

  /// No description provided for @diagnosisSalmonellosisRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Improve sanitation, isolate suspected birds, and consult a veterinarian before treatment.'**
  String get diagnosisSalmonellosisRecommendation;

  /// No description provided for @diagnosisUnknownDescription.
  ///
  /// In en, this message translates to:
  /// **'The model produced an unknown classification.'**
  String get diagnosisUnknownDescription;

  /// No description provided for @diagnosisUnknownRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Consult a qualified veterinarian for further assessment.'**
  String get diagnosisUnknownRecommendation;

  /// No description provided for @diagnosisHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis history'**
  String get diagnosisHistoryTitle;

  /// No description provided for @diagnosisHistoryClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get diagnosisHistoryClearTooltip;

  /// No description provided for @diagnosisHistoryClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear diagnosis history'**
  String get diagnosisHistoryClearTitle;

  /// No description provided for @diagnosisHistoryClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all saved diagnoses?'**
  String get diagnosisHistoryClearMessage;

  /// No description provided for @diagnosisHistoryClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get diagnosisHistoryClearAll;

  /// No description provided for @diagnosisHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis history cleared.'**
  String get diagnosisHistoryCleared;

  /// No description provided for @diagnosisHistoryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis removed from history.'**
  String get diagnosisHistoryRemoved;

  /// No description provided for @diagnosisHistoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete diagnosis'**
  String get diagnosisHistoryDeleteTitle;

  /// No description provided for @diagnosisHistoryDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this diagnosis from history?'**
  String get diagnosisHistoryDeleteMessage;

  /// No description provided for @diagnosisHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis history'**
  String get diagnosisHistoryEmptyTitle;

  /// No description provided for @diagnosisHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzed images will appear here.'**
  String get diagnosisHistoryEmptySubtitle;

  /// No description provided for @languageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingsTitle;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get chooseAppLanguage;

  /// No description provided for @changeLanguageAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change the language at any time.'**
  String get changeLanguageAnytime;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @urduLanguage.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urduLanguage;

  /// No description provided for @languageChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language preference updated successfully.'**
  String get languageChangedSuccessfully;
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
