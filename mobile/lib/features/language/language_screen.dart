import 'package:flutter/material.dart';

import '../authentication/services/registration_draft.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preferences_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'en';
  bool isSaving = false;

  Future<void> continueToLogin() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    await PreferencesService.saveLanguage(selectedLanguage);

    RegistrationDraft.preferredLanguage = selectedLanguage;

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final isUrduSelected = selectedLanguage == 'ur';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Choose language',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'زبان منتخب کریں',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _LanguageCard(
                title: 'English',
                subtitle: 'Continue in English',
                isSelected: selectedLanguage == 'en',
                onTap: () {
                  setState(() {
                    selectedLanguage = 'en';
                  });
                },
              ),
              const SizedBox(height: 14),
              _LanguageCard(
                title: 'اردو',
                subtitle: 'اردو میں جاری رکھیں',
                isSelected: selectedLanguage == 'ur',
                isUrdu: true,
                onTap: () {
                  setState(() {
                    selectedLanguage = 'ur';
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isSaving ? null : continueToLogin,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isUrduSelected ? 'جاری رکھیں' : 'Continue',
                        textDirection: isUrduSelected
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isUrdu = false,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title language',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
              Text(
                title,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 13,
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
