from uuid import UUID
from app.core.enums import DiseaseType, DosageCalculationType
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.models.medication import MedicationGuidance
from app.schemas.medication import (
    MedicationGuidanceCreate,
    MedicationGuidanceUpdate,
)


def create_medication_guidance(
    db: Session,
    data: MedicationGuidanceCreate,
) -> MedicationGuidance:
    guidance = MedicationGuidance(**data.model_dump())

    db.add(guidance)
    db.commit()
    db.refresh(guidance)

    return guidance


def get_medication_guidance(
    db: Session,
    guidance_id: UUID,
) -> MedicationGuidance | None:
    return db.get(MedicationGuidance, guidance_id)


def get_all_medication_guidance(
    db: Session,
) -> list[MedicationGuidance]:
    statement = select(MedicationGuidance).order_by(
        MedicationGuidance.medication_name
    )

    return list(db.scalars(statement).all())


def get_guidance_by_disease(
    db: Session,
    disease: DiseaseType,
) -> list[MedicationGuidance]:
    statement = (
        select(MedicationGuidance)
        .where(MedicationGuidance.disease == disease)
        .order_by(MedicationGuidance.medication_name)
    )

    return list(db.scalars(statement).all())


def update_medication_guidance(
    db: Session,
    guidance: MedicationGuidance,
    data: MedicationGuidanceUpdate,
) -> MedicationGuidance:
    update_data = data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(guidance, field, value)

    db.commit()
    db.refresh(guidance)

    return guidance


def delete_medication_guidance(
    db: Session,
    guidance: MedicationGuidance,
) -> None:
    db.delete(guidance)
    db.commit()


def calculate_dosage(
    guidance: MedicationGuidance,
    bird_count: int,
    average_weight_kg: float,
) -> dict:
    total_flock_weight_kg = round(
        bird_count * average_weight_kg,
        2,
    )

    calculated_dose = None
    calculated_dose_unit = None

    if guidance.dosage_calculation_type == DosageCalculationType.BODY_WEIGHT:
        if guidance.dosage_value is not None:
            calculated_dose = round(
                total_flock_weight_kg * guidance.dosage_value,
                4,
            )
            calculated_dose_unit = guidance.dosage_unit

        message = (
            "The calculated amount is based on total flock body weight. "
            "Verify the product formulation and dosage instructions with "
            "a qualified veterinarian before treatment."
        )

    elif (
        guidance.dosage_calculation_type
        == DosageCalculationType.WATER_CONCENTRATION
    ):
        message = (
            "This medication uses a drinking-water concentration dosage. "
            "Bird count and body weight alone are not enough to calculate "
            "the amount of product required. Follow the specific product "
            "label and use the actual drinking-water volume."
        )

    elif guidance.dosage_calculation_type == DosageCalculationType.FIXED:
        calculated_dose = guidance.dosage_value
        calculated_dose_unit = guidance.dosage_unit

        message = (
            "This guidance uses a fixed dosage. Verify the specific product "
            "label and consult a qualified veterinarian before treatment."
        )

    else:
        message = (
            "A medication dosage calculation is not applicable for this "
            "guidance. Follow the disease-control instructions and consult "
            "a qualified veterinarian."
        )

    return {
        "medication_id": guidance.id,
        "medication_name": guidance.medication_name,
        "calculation_type": guidance.dosage_calculation_type,
        "bird_count": bird_count,
        "average_weight_kg": average_weight_kg,
        "total_flock_weight_kg": total_flock_weight_kg,
        "calculated_dose": calculated_dose,
        "calculated_dose_unit": calculated_dose_unit,
        "treatment_duration_days": guidance.treatment_duration_days,
        "message": message,
    }