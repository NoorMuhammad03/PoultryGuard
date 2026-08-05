import 'package:flutter/material.dart';
import 'services/registration_draft.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void continueRegistration() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    RegistrationDraft.password = _passwordController.text;

    Navigator.pushReplacementNamed(context, AppRouter.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                const Text(
                  'Create a password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Use this password for future logins.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Minimum 8 characters',
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
                    final password = value ?? '';

                    if (password.isEmpty) {
                      return 'Please create a password';
                    }

                    if (password.length < 8) {
                      return 'Password must contain at least 8 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  hint: 'Enter the password again',
                  prefixIcon: Icons.lock_reset_outlined,
                  obscureText: _hideConfirmation,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hideConfirmation = !_hideConfirmation;
                      });
                    },
                    icon: Icon(
                      _hideConfirmation
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your password should contain:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• At least 8 characters\n'
                        '• A combination of letters and numbers',
                        style: TextStyle(
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                AppButton(
                  text: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: continueRegistration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
