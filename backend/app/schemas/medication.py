from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.core.enums import DiseaseType, DosageCalculationType

class MedicationGuidanceCreate(BaseModel):
    disease: DiseaseType
    medication_name: str = Field(min_length=2, max_length=150)
    active_ingredient: str | None = None
    indication: str
    dosage_calculation_type: DosageCalculationType = (
    DosageCalculationType.NOT_APPLICABLE
    )
    dosage_value: float | None = Field(default=None, gt=0)
    dosage_unit: str | None = None
    administration_method: str | None = None
    treatment_duration_days: int | None = Field(default=None, gt=0)
    withdrawal_period_days: int | None = Field(default=None, ge=0)
    precautions: str | None = None
    source_name: str | None = None
    source_reference: str | None = None
    product_formulation: str | None = None
    veterinarian_required: bool = True


class MedicationGuidanceUpdate(BaseModel):
    disease: DiseaseType | None = None
    medication_name: str | None = Field(
        default=None,
        min_length=2,
        max_length=150,
    )
    active_ingredient: str | None = None
    indication: str | None = None
    dosage_calculation_type: DosageCalculationType | None = None
    dosage_value: float | None = Field(default=None, gt=0)
    dosage_unit: str | None = None
    administration_method: str | None = None
    treatment_duration_days: int | None = Field(default=None, gt=0)
    withdrawal_period_days: int | None = Field(default=None, ge=0)
    precautions: str | None = None
    source_name: str | None = None
    source_reference: str | None = None
    product_formulation: str | None = None
    veterinarian_required: bool | None = None


class MedicationGuidanceResponse(BaseModel):
    id: UUID
    disease: DiseaseType
    medication_name: str
    active_ingredient: str | None
    indication: str
    dosage_calculation_type: DosageCalculationType
    dosage_value: float | None
    dosage_unit: str | None
    administration_method: str | None
    treatment_duration_days: int | None
    withdrawal_period_days: int | None
    precautions: str | None
    source_name: str | None
    source_reference: str | None
    product_formulation: str | None
    veterinarian_required: bool
    created_at: datetime
    updated_at: datetime


class DosageCalculationRequest(BaseModel):
    bird_count: int = Field(gt=0)
    average_weight_kg: float = Field(gt=0)


class DosageCalculationResponse(BaseModel):
    medication_id: UUID
    medication_name: str
    calculation_type: DosageCalculationType

    bird_count: int
    average_weight_kg: float
    total_flock_weight_kg: float

    calculated_dose: float | None = None
    calculated_dose_unit: str | None = None

    treatment_duration_days: int | None = None
    message: str

    model_config = {
        "from_attributes": True,
    }