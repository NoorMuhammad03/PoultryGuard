class MedicationGuidance {
  final String id;
  final String disease;
  final String medicationName;
  final String? activeIngredient;
  final String indication;

  final String dosageCalculationType;
  final double? dosageValue;
  final String? dosageUnit;

  final String? administrationMethod;
  final int? treatmentDurationDays;
  final int? withdrawalPeriodDays;
  final String? precautions;

  final String? sourceName;
  final String? sourceReference;
  final String? productFormulation;

  final bool veterinarianRequired;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicationGuidance({
    required this.id,
    required this.disease,
    required this.medicationName,
    required this.activeIngredient,
    required this.indication,
    required this.dosageCalculationType,
    required this.dosageValue,
    required this.dosageUnit,
    required this.administrationMethod,
    required this.treatmentDurationDays,
    required this.withdrawalPeriodDays,
    required this.precautions,
    required this.sourceName,
    required this.sourceReference,
    required this.productFormulation,
    required this.veterinarianRequired,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationGuidance.fromJson(Map<String, dynamic> json) {
    return MedicationGuidance(
      id: json['id'] as String,
      disease: json['disease'] as String,
      medicationName: json['medication_name'] as String,
      activeIngredient: json['active_ingredient'] as String?,
      indication: json['indication'] as String,
      dosageCalculationType: json['dosage_calculation_type'] as String,
      dosageValue: (json['dosage_value'] as num?)?.toDouble(),
      dosageUnit: json['dosage_unit'] as String?,
      administrationMethod: json['administration_method'] as String?,
      treatmentDurationDays: json['treatment_duration_days'] as int?,
      withdrawalPeriodDays: json['withdrawal_period_days'] as int?,
      precautions: json['precautions'] as String?,
      sourceName: json['source_name'] as String?,
      sourceReference: json['source_reference'] as String?,
      productFormulation: json['product_formulation'] as String?,
      veterinarianRequired: json['veterinarian_required'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
