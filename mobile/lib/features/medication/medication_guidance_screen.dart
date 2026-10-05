import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'models/dosage_calculation.dart';
import 'models/medication_guidance.dart';
import 'services/medication_service.dart';

class MedicationGuidanceScreen extends StatefulWidget {
  const MedicationGuidanceScreen({super.key, required this.disease});

  final String disease;

  @override
  State<MedicationGuidanceScreen> createState() =>
      _MedicationGuidanceScreenState();
}

class _MedicationGuidanceScreenState extends State<MedicationGuidanceScreen> {
  late Future<List<MedicationGuidance>> _guidanceFuture;

  @override
  void initState() {
    super.initState();
    _guidanceFuture = MedicationService.getGuidanceByDisease(widget.disease);
  }

  void _retry() {
    setState(() {
      _guidanceFuture = MedicationService.getGuidanceByDisease(widget.disease);
    });
  }

  String get _diseaseName {
    switch (widget.disease) {
      case 'coccidiosis':
        return 'Coccidiosis';
      case 'newcastle':
        return 'Newcastle Disease';
      case 'salmonellosis':
        return 'Salmonellosis';
      case 'healthy':
        return 'Healthy';
      default:
        return widget.disease;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Medication Guidance')),
      body: SafeArea(
        child: FutureBuilder<List<MedicationGuidance>>(
          future: _guidanceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _retry,
              );
            }

            final guidance = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DiseaseHeader(disease: _diseaseName),
                  const SizedBox(height: 18),

                  if (guidance.isEmpty)
                    const _EmptyGuidanceCard()
                  else
                    ...guidance.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MedicationCard(guidance: item),
                      ),
                    ),

                  const SizedBox(height: 4),
                  const _VeterinaryWarning(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DiseaseHeader extends StatelessWidget {
  const _DiseaseHeader({required this.disease});

  final String disease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_information_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guidance for',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  disease,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGuidanceCard extends StatelessWidget {
  const _EmptyGuidanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 34),
          SizedBox(height: 12),
          Text(
            'No medication guidance is available for this condition yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatefulWidget {
  const _MedicationCard({required this.guidance});

  final MedicationGuidance guidance;

  @override
  State<_MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<_MedicationCard> {
  final TextEditingController _birdCountController = TextEditingController();

  final TextEditingController _averageWeightController =
      TextEditingController();

  DosageCalculation? _calculation;
  String? _calculationError;
  bool _isCalculating = false;

  MedicationGuidance get guidance => widget.guidance;

  @override
  void dispose() {
    _birdCountController.dispose();
    _averageWeightController.dispose();
    super.dispose();
  }

  Future<void> _calculateDosage() async {
    final birdCount = int.tryParse(_birdCountController.text.trim());

    final averageWeight = double.tryParse(_averageWeightController.text.trim());

    if (birdCount == null || birdCount <= 0) {
      setState(() {
        _calculationError = 'Enter a valid bird count.';
        _calculation = null;
      });
      return;
    }

    if (averageWeight == null || averageWeight <= 0) {
      setState(() {
        _calculationError = 'Enter a valid average bird weight.';
        _calculation = null;
      });
      return;
    }

    setState(() {
      _isCalculating = true;
      _calculationError = null;
      _calculation = null;
    });

    try {
      final result = await MedicationService.calculateDosage(
        medicationId: guidance.id,
        birdCount: birdCount,
        averageWeightKg: averageWeight,
      );

      if (!mounted) return;

      setState(() {
        _calculation = result;
        _isCalculating = false;
      });
    } on MedicationException catch (error) {
      if (!mounted) return;

      setState(() {
        _calculationError = error.message;
        _isCalculating = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _calculationError =
            'Something went wrong while calculating the dosage.';
        _isCalculating = false;
      });
    }
  }

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
          Text(
            guidance.medicationName,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),

          if (guidance.activeIngredient != null) ...[
            const SizedBox(height: 6),
            Text(
              'Active ingredient: '
              '${guidance.activeIngredient}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],

          const SizedBox(height: 16),

          _GuidanceRow(title: 'Indication', value: guidance.indication),

          if (guidance.dosageValue != null && guidance.dosageUnit != null)
            _GuidanceRow(
              title: 'Dosage',
              value:
                  '${guidance.dosageValue} '
                  '${guidance.dosageUnit}',
            ),

          if (guidance.administrationMethod != null)
            _GuidanceRow(
              title: 'Administration',
              value: guidance.administrationMethod!,
            ),

          if (guidance.treatmentDurationDays != null)
            _GuidanceRow(
              title: 'Treatment duration',
              value: '${guidance.treatmentDurationDays} day(s)',
            ),

          if (guidance.withdrawalPeriodDays != null)
            _GuidanceRow(
              title: 'Withdrawal period',
              value: '${guidance.withdrawalPeriodDays} day(s)',
            ),

          if (guidance.precautions != null)
            _GuidanceRow(title: 'Precautions', value: guidance.precautions!),

          if (guidance.productFormulation != null ||
              guidance.sourceName != null ||
              guidance.sourceReference != null) ...[
            const Divider(height: 28),

            const Text(
              'Source Information',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),

            const SizedBox(height: 12),

            if (guidance.productFormulation != null)
              _GuidanceRow(
                title: 'Product formulation',
                value: guidance.productFormulation!,
              ),

            if (guidance.sourceName != null)
              _GuidanceRow(title: 'Source', value: guidance.sourceName!),

            if (guidance.sourceReference != null)
              _GuidanceRow(
                title: 'Reference',
                value: guidance.sourceReference!,
              ),
          ],

          const Divider(height: 28),

          const Text(
            'Dosage Calculator',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Enter flock information to calculate applicable '
            'dosage guidance.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _birdCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Bird count',
              hintText: 'e.g. 500',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _averageWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Average bird weight (kg)',
              hintText: 'e.g. 1.5',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCalculating ? null : _calculateDosage,
              icon: _isCalculating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate_outlined),
              label: Text(
                _isCalculating ? 'Calculating...' : 'Calculate Dosage',
              ),
            ),
          ),

          if (_calculationError != null) ...[
            const SizedBox(height: 12),
            Text(
              _calculationError!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ],

          if (_calculation != null) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calculation Result',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _GuidanceRow(
                    title: 'Total flock weight',
                    value: '${_calculation!.totalFlockWeightKg} kg',
                  ),

                  if (_calculation!.calculatedDose != null &&
                      _calculation!.calculatedDoseUnit != null)
                    _GuidanceRow(
                      title: 'Calculated dose',
                      value:
                          '${_calculation!.calculatedDose} '
                          '${_calculation!.calculatedDoseUnit}',
                    ),

                  if (_calculation!.treatmentDurationDays != null)
                    _GuidanceRow(
                      title: 'Treatment duration',
                      value:
                          '${_calculation!.treatmentDurationDays} '
                          'day(s)',
                    ),

                  Text(
                    _calculation!.message,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuidanceRow extends StatelessWidget {
  const _GuidanceRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VeterinaryWarning extends StatelessWidget {
  const _VeterinaryWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, color: AppColors.danger),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This information is guidance only and is not an '
              'automatic prescription. Consult a qualified '
              'veterinarian before treatment. Check the product '
              'formulation and observe the required withdrawal '
              'period.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
