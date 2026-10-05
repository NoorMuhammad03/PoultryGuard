import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../l10n/app_localizations.dart';
import 'models/diagnosis_result.dart';
import '../medication/medication_guidance_screen.dart';

class DiagnosisResultScreen extends StatelessWidget {
  const DiagnosisResultScreen({super.key, required this.result});

  final DiagnosisResult result;

  String _localizedLabel(AppLocalizations l10n) {
    switch (result.label) {
      case 'Healthy':
        return l10n.diagnosisHealthy;
      case 'Coccidiosis':
        return l10n.diagnosisCoccidiosis;
      case 'Newcastle Disease':
        return l10n.diagnosisNewcastle;
      case 'Salmonellosis':
        return l10n.diagnosisSalmonellosis;
      default:
        return result.label;
    }
  }

  String _description(AppLocalizations l10n) {
    switch (result.label) {
      case 'Healthy':
        return l10n.diagnosisHealthyDescription;
      case 'Coccidiosis':
        return l10n.diagnosisCoccidiosisDescription;
      case 'Newcastle Disease':
        return l10n.diagnosisNewcastleDescription;
      case 'Salmonellosis':
        return l10n.diagnosisSalmonellosisDescription;
      default:
        return l10n.diagnosisUnknownDescription;
    }
  }

  String _recommendation(AppLocalizations l10n) {
    switch (result.label) {
      case 'Healthy':
        return l10n.diagnosisHealthyRecommendation;
      case 'Coccidiosis':
        return l10n.diagnosisCoccidiosisRecommendation;
      case 'Newcastle Disease':
        return l10n.diagnosisNewcastleRecommendation;
      case 'Salmonellosis':
        return l10n.diagnosisSalmonellosisRecommendation;
      default:
        return l10n.diagnosisUnknownRecommendation;
    }
  }

  String? get _medicationDisease {
    switch (result.label) {
      case 'Coccidiosis':
        return 'coccidiosis';
      case 'Newcastle Disease':
        return 'newcastle';
      case 'Salmonellosis':
        return 'salmonellosis';
      default:
        return null;
    }
  }

  Color get _statusColor {
    if (result.label == 'Healthy') {
      return AppColors.success;
    }

    return AppColors.danger;
  }

  Widget _buildImage() {
    if (kIsWeb) {
      return Image.network(
        result.imagePath,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(result.imagePath),
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lowConfidence = result.confidence < 0.70;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.diagnosisResultTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _buildImage(),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.diagnosisPredictedResult,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _localizedLabel(l10n),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            result.confidencePercentage,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: result.confidence,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
              ),

              if (lowConfidence) ...[
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.diagnosisLowConfidence,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              _InformationCard(
                title: l10n.diagnosisMayIndicate,
                icon: Icons.biotech_outlined,
                text: _description(l10n),
              ),

              const SizedBox(height: 14),

              _InformationCard(
                title: l10n.diagnosisRecommendedNextStep,
                icon: Icons.health_and_safety_outlined,
                text: _recommendation(l10n),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.diagnosisDisclaimer,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 24),

              if (_medicationDisease != null) ...[
                AppButton(
                  text: 'View Medication Guidance',
                  icon: Icons.medication_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicationGuidanceScreen(
                          disease: _medicationDisease!,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
              ],

              AppButton(
                text: l10n.diagnosisAnalyzeAnother,
                icon: Icons.refresh,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.title,
    required this.icon,
    required this.text,
  });

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
