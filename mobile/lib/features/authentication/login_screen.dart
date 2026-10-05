import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../l10n/app_localizations.dart';
import 'services/auth_service.dart';
import 'services/password_reset_draft.dart';
import '../../core/utils/preferences_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phoneNumber = '+92${_phoneController.text.trim()}';

      await AuthService.login(
        phoneNumber: phoneNumber,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      final user = await AuthService.getCurrentUser();
      final preferredLanguage = user['preferred_language'] as String?;

      if (preferredLanguage == 'en' || preferredLanguage == 'ur') {
        await PreferencesService.saveLanguage(preferredLanguage!);
      }

      if (!mounted) return;

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
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.unexpectedError)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void openRegistration() {
    Navigator.pushNamed(context, AppRouter.registration);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),

                Text(
                  l10n.welcomeBack,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.loginSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        '+92',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: AppTextField(
                        controller: _phoneController,
                        label: l10n.phoneNumber,
                        hint: l10n.phoneHint,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          final phone =
                              value?.replaceAll(' ', '').replaceAll('-', '') ??
                              '';

                          if (phone.isEmpty) {
                            return l10n.enterPhoneNumber;
                          }

                          if (phone.length != 10 || !phone.startsWith('3')) {
                            return l10n.invalidPhoneNumber;
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  hint: l10n.passwordHint,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return l10n.enterPassword;
                    }

                    if ((value ?? '').length < 8) {
                      return l10n.passwordMinimum;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),

                    Expanded(
                      child: Text(
                        l10n.rememberMe,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              PasswordResetDraft.clear();

                              Navigator.pushNamed(
                                context,
                                AppRouter.forgotPassword,
                              );
                            },
                      child: Text(l10n.forgotPassword),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: l10n.loginButton,
                  icon: Icons.login,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : login,
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.newToPoultryGuard,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),

                    TextButton(
                      onPressed: openRegistration,
                      child: Text(
                        l10n.createAccount,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
