from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.schemas.flock import (
    FlockCreate,
    FlockResponse,
    FlockUpdate,
)
from app.services.flock_service import FlockService

router = APIRouter(
    prefix="/api/v1/flocks",
    tags=["Flocks"],
)


@router.post(
    "",
    response_model=FlockResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_flock(
    request: FlockCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> FlockResponse:
    try:
        return FlockService.create_flock(
            db=db,
            user=current_user,
            request=request,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(error),
        ) from error


@router.get(
    "",
    response_model=list[FlockResponse],
)
def list_flocks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[FlockResponse]:
    try:
        return FlockService.list_flocks(
            db=db,
            user=current_user,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        ) from error


@router.get(
    "/{flock_id}",
    response_model=FlockResponse,
)
def get_flock(
    flock_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> FlockResponse:
    try:
        return FlockService.get_flock(
            db=db,
            user=current_user,
            flock_id=flock_id,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        ) from error


@router.patch(
    "/{flock_id}",
    response_model=FlockResponse,
)
def update_flock(
    flock_id: UUID,
    request: FlockUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> FlockResponse:
    try:
        return FlockService.update_flock(
            db=db,
            user=current_user,
            flock_id=flock_id,
            request=request,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        ) from error


@router.delete(
    "/{flock_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_flock(
    flock_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    try:
        FlockService.delete_flock(
            db=db,
            user=current_user,
            flock_id=flock_id,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(error),
        ) from error