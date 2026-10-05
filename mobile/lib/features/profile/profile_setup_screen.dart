import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../authentication/services/auth_service.dart';
import '../authentication/services/registration_draft.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> continueProfileSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.updateProfile(fullName: _nameController.text);

      if (!mounted) return;

      if (RegistrationDraft.role == 'veterinarian') {
        RegistrationDraft.clear();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.veterinarianDashboard,
          (route) => false,
        );
      } else {
        Navigator.pushNamed(context, AppRouter.farmRegistration);
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  l10n.profileTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.profileSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 46,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField(
                  controller: _nameController,
                  label: l10n.fullName,
                  hint: l10n.fullNameHint,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) {
                      return l10n.fullNameRequired;
                    }

                    if (name.length < 2) {
                      return l10n.fullNameTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: l10n.phoneNumber,
                  hint: l10n.profilePhoneHint,
                  prefixIcon: Icons.phone_outlined,
                  enabled: false,
                ),

                const Spacer(),

                AppButton(
                  text: l10n.continueButton,
                  icon: Icons.arrow_forward,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : continueProfileSetup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
