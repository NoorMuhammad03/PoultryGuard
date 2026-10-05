class DosageCalculation {
  final String medicationId;
  final String medicationName;
  final String calculationType;

  final int birdCount;
  final double averageWeightKg;
  final double totalFlockWeightKg;

  final double? calculatedDose;
  final String? calculatedDoseUnit;
  final int? treatmentDurationDays;

  final String message;

  const DosageCalculation({
    required this.medicationId,
    required this.medicationName,
    required this.calculationType,
    required this.birdCount,
    required this.averageWeightKg,
    required this.totalFlockWeightKg,
    required this.calculatedDose,
    required this.calculatedDoseUnit,
    required this.treatmentDurationDays,
    required this.message,
  });

  factory DosageCalculation.fromJson(Map<String, dynamic> json) {
    return DosageCalculation(
      medicationId: json['medication_id'] as String,
      medicationName: json['medication_name'] as String,
      calculationType: json['calculation_type'] as String,
      birdCount: json['bird_count'] as int,
      averageWeightKg: (json['average_weight_kg'] as num).toDouble(),
      totalFlockWeightKg: (json['total_flock_weight_kg'] as num).toDouble(),
      calculatedDose: (json['calculated_dose'] as num?)?.toDouble(),
      calculatedDoseUnit: json['calculated_dose_unit'] as String?,
      treatmentDurationDays: json['treatment_duration_days'] as int?,
      message: json['message'] as String,
    );
  }
}
