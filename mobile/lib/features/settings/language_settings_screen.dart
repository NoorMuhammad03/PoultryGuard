import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/preferences_service.dart';
import '../../l10n/app_localizations.dart';
import '../authentication/services/auth_service.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  Future<void> _changeLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    try {
      await AuthService.updatePreferredLanguage(languageCode: languageCode);

      await PreferencesService.saveLanguage(languageCode);

      if (!context.mounted) return;

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.languageChangedSuccessfully)));
    } on AuthException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Language')),
      body: ValueListenableBuilder<String>(
        valueListenable: PreferencesService.languageNotifier,
        builder: (context, currentLanguage, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.chooseAppLanguage,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.changeLanguageAnytime,
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              _LanguageCard(
                title: l10n.englishLanguage,
                subtitle: 'English',
                isSelected: currentLanguage == 'en',
                onTap: () {
                  _changeLanguage(context, 'en');
                },
              ),

              const SizedBox(height: 12),

              _LanguageCard(
                title: l10n.urduLanguage,
                subtitle: 'اردو',
                isSelected: currentLanguage == 'ur',
                onTap: () {
                  _changeLanguage(context, 'ur');
                },
              ),
            ],
          );
        },
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
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.language, color: AppColors.primary),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
