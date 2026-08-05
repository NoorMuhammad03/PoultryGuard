import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../authentication/services/auth_service.dart';
import '../authentication/services/registration_draft.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'farmer';
  bool _isLoading = false;

  Future<void> continueToProfile() async {
    if (!RegistrationDraft.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration information is incomplete.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      RegistrationDraft.role = selectedRole;

      await AuthService.register(
        phoneNumber: RegistrationDraft.phoneNumber!,
        password: RegistrationDraft.password!,
        preferredLanguage: RegistrationDraft.preferredLanguage,
        role: RegistrationDraft.role,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRouter.profileSetup);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),

              const Text(
                'Who are you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Select your role to continue',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 26),

              _RoleCard(
                title: 'Farmer',
                urduTitle: 'کسان',
                icon: Icons.agriculture_outlined,
                isSelected: selectedRole == 'farmer',
                onTap: () {
                  if (_isLoading) return;

                  setState(() {
                    selectedRole = 'farmer';
                  });
                },
              ),

              const SizedBox(height: 14),

              _RoleCard(
                title: 'Veterinarian',
                urduTitle: 'ڈاکٹر',
                icon: Icons.medical_services_outlined,
                isSelected: selectedRole == 'veterinarian',
                onTap: () {
                  if (_isLoading) return;

                  setState(() {
                    selectedRole = 'veterinarian';
                  });
                },
              ),

              const Spacer(),

              AppButton(
                text: 'Continue',
                icon: Icons.arrow_forward,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : continueToProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.urduTitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String urduTitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 42,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                urduTitle,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
