import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void continueProfileSetup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pushNamed(context, AppRouter.farmRegistration);
  }

  @override
  Widget build(BuildContext context) {
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
                  alignment: Alignment.centerLeft,
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

                const Text(
                  'Set up your profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your basic information to continue.',
                  style: TextStyle(
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
                  label: 'Full name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) {
                      return 'Please enter your full name';
                    }

                    if (name.length < 2) {
                      return 'Name must contain at least 2 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                const AppTextField(
                  label: 'Phone number',
                  hint: '+92 3XX XXXXXXX',
                  prefixIcon: Icons.phone_outlined,
                  enabled: false,
                ),

                const Spacer(),

                AppButton(
                  text: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: continueProfileSetup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
