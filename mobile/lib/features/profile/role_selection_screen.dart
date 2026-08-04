import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'farmer';

  void continueToProfile() {
    Navigator.pushNamed(context, AppRouter.profileSetup);
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
                  setState(() {
                    selectedRole = 'veterinarian';
                  });
                },
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: continueToProfile,
                child: const Text('Continue'),
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
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
