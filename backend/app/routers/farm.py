from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.farm import Farm
from app.models.user import User
from app.schemas.farm import FarmCreate, FarmResponse

router = APIRouter(
    prefix="/api/v1/farms",
    tags=["Farms"],
)


@router.post(
    "",
    response_model=FarmResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_farm(
    request: FarmCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Farm:
    existing_farm = db.scalar(
        select(Farm).where(
            Farm.user_id == current_user.id,
        ),
    )

    if existing_farm is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A farm is already registered for this user",
        )

    farm = Farm(
        user_id=current_user.id,
        farm_name=request.farm_name,
        address=request.address,
        bird_capacity=request.bird_capacity,
        latitude=request.latitude,
        longitude=request.longitude,
        sensor_alerts=request.sensor_alerts,
        disease_alerts=request.disease_alerts,
        community_alerts=request.community_alerts,
    )

    current_user.onboarding_completed = True

    db.add(farm)
    db.commit()
    db.refresh(farm)

    return farm


@router.get(
    "/me",
    response_model=FarmResponse,
)
def get_my_farm(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Farm:
    farm = db.scalar(
        select(Farm).where(
            Farm.user_id == current_user.id,
        ),
    )

    if farm is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found",
        )

    return farm