import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../l10n/app_localizations.dart';
import 'diagnosis_result_screen.dart';
import 'models/diagnosis_history.dart';
import 'services/diagnosis_history_service.dart';
import 'services/disease_classifier_service.dart';
import 'services/image_selection_service.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  XFile? _selectedImage;
  bool _isAnalyzing = false;

  Future<void> _pickFromCamera() async {
    final image = await ImageSelectionService.pickFromCamera();

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _pickFromGallery() async {
    final image = await ImageSelectionService.pickFromGallery();

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _analyzeImage() async {
    final l10n = AppLocalizations.of(context);
    final image = _selectedImage;

    if (image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.diagnosisSelectImageFirst)));
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await DiseaseClassifierService.classifyImage(image.path);

      await DiagnosisHistoryService.saveDiagnosis(
        DiagnosisHistory(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          imagePath: result.imagePath,
          label: result.label,
          confidence: result.confidence,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosisResultScreen(result: result),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.diagnosisAnalysisFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Widget _buildImagePreview(AppLocalizations l10n) {
    final image = _selectedImage;

    if (image == null) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_search_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.diagnosisNoImage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.diagnosisNoImageSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: kIsWeb
          ? Image.network(
              image.path,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(image.path),
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.diagnosisTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.diagnosisHistory);
            },
            tooltip: l10n.diagnosisHistoryTooltip,
            icon: const Icon(Icons.history_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.diagnosisAnalyzeTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.diagnosisAnalyzeSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              _buildImagePreview(l10n),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(l10n.diagnosisCamera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.diagnosisGallery),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              AppButton(
                text: l10n.diagnosisAnalyzeButton,
                icon: Icons.analytics_outlined,
                isLoading: _isAnalyzing,
                onPressed: _isAnalyzing ? null : _analyzeImage,
              ),

              const SizedBox(height: 20),

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
            ],
          ),
        ),
      ),
    );
  }
}
