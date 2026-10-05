import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preferences_service.dart';
import '../authentication/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideNextScreen();
    });
  }

  Future<void> _decideNextScreen() async {
    // Keep the splash visible briefly.
    await Future<void>.delayed(const Duration(seconds: 2));

    final user = await AuthService.restoreSession();

    if (!mounted) return;

    if (user != null) {
      final role = user['role'] as String?;
      final onboardingCompleted =
          user['onboarding_completed'] as bool? ?? false;

      if (!onboardingCompleted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.profileSetup,
          (route) => false,
        );
      } else if (role == 'veterinarian') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.veterinarianDashboard,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.farmerDashboard,
          (route) => false,
        );
      }

      return;
    }

    final savedLanguage = await PreferencesService.getLanguage();

    if (!mounted) return;

    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: AppColors.primaryLight,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'PoultryGuard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Smart Poultry Protection',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'پولٹری گارڈ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 19,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 34),

                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
