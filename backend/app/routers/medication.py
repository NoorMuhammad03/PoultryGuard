from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.enums import DiseaseType
from app.db.database import get_db
from app.models.user import User
from app.schemas.medication import (
    DosageCalculationRequest,
    DosageCalculationResponse,
    MedicationGuidanceCreate,
    MedicationGuidanceResponse,
    MedicationGuidanceUpdate,
)
from app.services.medication_service import (
    calculate_dosage,
    create_medication_guidance,
    delete_medication_guidance,
    get_all_medication_guidance,
    get_guidance_by_disease,
    get_medication_guidance,
    update_medication_guidance,
)


router = APIRouter(
    prefix="/api/v1/medications",
    tags=["Medication Guidance"],
)


@router.get(
    "",
    response_model=list[MedicationGuidanceResponse],
)
def list_medication_guidance(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[MedicationGuidanceResponse]:
    return get_all_medication_guidance(db)


@router.get(
    "/disease/{disease}",
    response_model=list[MedicationGuidanceResponse],
)
def list_guidance_by_disease(
    disease: DiseaseType,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[MedicationGuidanceResponse]:
    return get_guidance_by_disease(
        db=db,
        disease=disease,
    )

@router.post(
    "/{guidance_id}/calculate",
    response_model=DosageCalculationResponse,
)
def calculate_medication_dosage(
    guidance_id: UUID,
    request: DosageCalculationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> DosageCalculationResponse:
    guidance = get_medication_guidance(
        db=db,
        guidance_id=guidance_id,
    )

    if guidance is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication guidance not found.",
        )

    return calculate_dosage(
        guidance=guidance,
        bird_count=request.bird_count,
        average_weight_kg=request.average_weight_kg,
    )

@router.get(
    "/{guidance_id}",
    response_model=MedicationGuidanceResponse,
)
def get_guidance(
    guidance_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MedicationGuidanceResponse:
    guidance = get_medication_guidance(
        db=db,
        guidance_id=guidance_id,
    )

    if guidance is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication guidance not found.",
        )

    return guidance


@router.post(
    "",
    response_model=MedicationGuidanceResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_guidance(
    request: MedicationGuidanceCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MedicationGuidanceResponse:
    return create_medication_guidance(
        db=db,
        data=request,
    )


@router.patch(
    "/{guidance_id}",
    response_model=MedicationGuidanceResponse,
)
def update_guidance(
    guidance_id: UUID,
    request: MedicationGuidanceUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MedicationGuidanceResponse:
    guidance = get_medication_guidance(
        db=db,
        guidance_id=guidance_id,
    )

    if guidance is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication guidance not found.",
        )

    return update_medication_guidance(
        db=db,
        guidance=guidance,
        data=request,
    )


@router.delete(
    "/{guidance_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_guidance(
    guidance_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    guidance = get_medication_guidance(
        db=db,
        guidance_id=guidance_id,
    )

    if guidance is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Medication guidance not found.",
        )

    delete_medication_guidance(
        db=db,
        guidance=guidance,
    )