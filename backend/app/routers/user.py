from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.schemas.user import (
    UserProfileUpdate,
    UserResponse,
)

router = APIRouter(
    prefix="/api/v1/users",
    tags=["Users"],
)


@router.get(
    "/me",
    response_model=UserResponse,
)
def get_my_profile(
    current_user: User = Depends(get_current_user),
) -> User:
    return current_user


@router.patch(
    "/me",
    response_model=UserResponse,
)
def update_my_profile(
    request: UserProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    if request.full_name is not None:
        current_user.full_name = request.full_name.strip()

    if request.preferred_language is not None:
        current_user.preferred_language = request.preferred_language

    db.add(current_user)
    db.commit()
    db.refresh(current_user)

    return current_user