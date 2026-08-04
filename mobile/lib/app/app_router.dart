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
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
