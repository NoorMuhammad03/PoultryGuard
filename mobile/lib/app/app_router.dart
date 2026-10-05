import 'package:flutter/material.dart';
import '../features/authentication/otp_screen.dart';
import '../features/language/language_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/profile/role_selection_screen.dart';
import '../features/profile/profile_setup_screen.dart';
import '../features/farm/farm_registration_screen.dart';
import '../features/dashboard/farmer_dashboard_screen.dart';
import '../features/authentication/create_password_screen.dart';
import '../features/authentication/registration_screen.dart';
import '../features/authentication/change_password_screen.dart';
import '../features/dashboard/veterinarian_dashboard_screen.dart';
import '../features/authentication/forgot_password_screen.dart';
import '../features/authentication/forgot_password_otp_screen.dart';
import '../features/authentication/reset_password_screen.dart';
import '../features/flock/add_flock_screen.dart';
import '../features/flock/flock_list_screen.dart';
import '../features/flock/flock_details_screen.dart';
import '../features/flock/edit_flock_screen.dart';
import '../features/flock/models/flock.dart';
import '../features/diagnosis/disease_detection_screen.dart';
import '../features/diagnosis/diagnosis_history_screen.dart';
import '../features/settings/language_settings_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String language = '/language';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String roleSelection = '/role-selection';
  static const String profileSetup = '/profile-setup';
  static const String farmRegistration = '/farm-registration';
  static const String farmerDashboard = '/farmer-dashboard';
  static const String registration = '/registration';
  static const String createPassword = '/create-password';
  static const String changePassword = '/change-password';
  static const String veterinarianDashboard = '/veterinarian-dashboard';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordOtp = '/forgot-password-otp';
  static const String resetPassword = '/reset-password';
  static const String flockList = '/flocks';
  static const String addFlock = '/flocks/add';
  static const String flockDetails = '/flocks/details';
  static const String editFlock = '/flocks/edit';
  static const String diseaseDetection = '/disease-detection';
  static const String diagnosisHistory = '/diagnosis-history';
  static const String languageSettings = '/settings/language';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());

      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case language:
        return MaterialPageRoute(builder: (_) => const LanguageScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case farmRegistration:
        return MaterialPageRoute(
          builder: (_) => const FarmRegistrationScreen(),
        );

      case farmerDashboard:
        return MaterialPageRoute(builder: (_) => const FarmerDashboardScreen());

      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case registration:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case createPassword:
        return MaterialPageRoute(builder: (_) => const CreatePasswordScreen());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case veterinarianDashboard:
        return MaterialPageRoute(
          builder: (_) => const VeterinarianDashboardScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case forgotPasswordOtp:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordOtpScreen(),
        );

      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case flockList:
        return MaterialPageRoute(builder: (_) => const FlockListScreen());

      case addFlock:
        return MaterialPageRoute(builder: (_) => const AddFlockScreen());

      case flockDetails:
        final flockId = settings.arguments as String?;

        if (flockId == null || flockId.isEmpty) {
          return MaterialPageRoute(builder: (_) => const FlockListScreen());
        }

        return MaterialPageRoute(
          builder: (_) => FlockDetailsScreen(flockId: flockId),
        );

      case editFlock:
        final flock = settings.arguments as Flock?;

        if (flock == null) {
          return MaterialPageRoute(builder: (_) => const FlockListScreen());
        }

        return MaterialPageRoute(builder: (_) => EditFlockScreen(flock: flock));

      case diseaseDetection:
        return MaterialPageRoute(
          builder: (_) => const DiseaseDetectionScreen(),
        );

      case diagnosisHistory:
        return MaterialPageRoute(
          builder: (_) => const DiagnosisHistoryScreen(),
        );

      case languageSettings:
        return MaterialPageRoute(
          builder: (_) => const LanguageSettingsScreen(),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
