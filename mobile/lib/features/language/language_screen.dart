import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/preferences_service.dart';
import '../authentication/services/registration_draft.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'en';
  bool isLoadingLanguage = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await PreferencesService.getLanguage();

    if (!mounted) return;

    setState(() {
      if (savedLanguage == 'en' || savedLanguage == 'ur') {
        selectedLanguage = savedLanguage!;
      }

      isLoadingLanguage = false;
    });
  }

  Future<void> continueToLogin() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await PreferencesService.saveLanguage(selectedLanguage);

      RegistrationDraft.preferredLanguage = selectedLanguage;

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRouter.login);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingLanguage) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
                textAlign: TextAlign.center,
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
                textAlign: TextAlign.center,
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
                onTap: isSaving
                    ? null
                    : () {
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
                onTap: isSaving
                    ? null
                    : () {
                        setState(() {
                          selectedLanguage = 'ur';
                        });
                      },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                      : Text(isUrduSelected ? 'جاری رکھیں' : 'Continue'),
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
  final VoidCallback? onTap;
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      title,
                      textDirection: isUrdu
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      textDirection: isUrdu
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                const Padding(
                  padding: EdgeInsetsDirectional.only(start: 12),
                  child: Icon(Icons.check_circle, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
