# Admin users endpoints — manage vet and farmer users.
# Endpoints from PoultryGuard_Dashboard_Architecture.md Section 7:
# - GET /admin/users — filterable by role/status
# - PATCH /admin/users/{id}/verify — vet approval
# - PATCH /admin/users/{id}/deactivate — user deactivation

from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from auth.role_guard import require_admin
from models.user import User, UserRole
from db.postgres import get_db
from schemas.validation import UserRoleEnum, UserStatusEnum, UserUpdateRequest, UserListQueryParams

router = APIRouter(prefix="/api/v1/admin", tags=["admin", "users"])

# Request/Response models
class UserResponse(BaseModel):
    id: str
    firebase_uid: str
    role: str
    name: str
    email: str
    is_verified: bool
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None


def format_user(user: User) -> dict:
    """Format a User model for API response."""
    updated_at = getattr(user, "updated_at", None)
    return {
        "id": str(user.id),
        "firebase_uid": user.firebase_uid,
        "role": user.role.value if hasattr(user.role, "value") else str(user.role),
        "name": user.name,
        "email": user.email,
        "is_verified": getattr(user, "is_verified", False),
        "is_active": user.is_active,
        "created_at": user.created_at.isoformat() if user.created_at else datetime.utcnow().isoformat(),
        "updated_at": updated_at.isoformat() if updated_at else None,
    }


@router.get("/users", response_model=List[UserResponse])
async def list_users(
    role: Optional[UserRoleEnum] = Query(None, description="Filter by role (vet, farmer, admin)"),
    status: Optional[UserStatusEnum] = Query(None, description="Filter by status (verified, pending, active, inactive)"),
    search: Optional[str] = Query(None, max_length=100, description="Search by name or email"),
    limit: int = Query(50, ge=1, le=100, description="Max users to return"),
    offset: int = Query(0, ge=0, description="Offset for pagination"),
    db: Session = Depends(get_db),
    user: User = Depends(require_admin),
):
    """
    Get all users with optional filters and pagination.
    - role: vet, farmer, admin
    - status: verified (is_verified=True), pending (is_verified=False),
              active (is_active=True), inactive (is_active=False)
    - search: partial match on name or email
    """
    query = db.query(User)

    # Apply filters
    if role:
        query = query.filter(User.role == UserRole(role))

    if status:
        if status == UserStatusEnum.VERIFIED:
            query = query.filter(User.is_verified == True)
        elif status == UserStatusEnum.PENDING:
            query = query.filter(User.is_verified == False)
        elif status == UserStatusEnum.ACTIVE:
            query = query.filter(User.is_active == True)
        elif status == UserStatusEnum.INACTIVE:
            query = query.filter(User.is_active == False)

    if search:
        query = query.filter(
            (User.name.ilike(f"%{search}%")) | (User.email.ilike(f"%{search}%"))
        )

    users = query.order_by(User.created_at.desc()).offset(offset).limit(limit).all()
    return [format_user(u) for u in users]


@router.patch("/users/{user_id}/verify", response_model=UserResponse)
async def verify_user(
    user_id: str,
    body: UserUpdateRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    """
    Verify a vet (set is_verified=True).
    Only applicable to users with role='vet'.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail=f"User {user_id} not found")

    if user.role != UserRole.VET:
        raise HTTPException(
            status_code=400,
            detail="Only vet users can be verified",
        )

    if body.is_verified is None:
        raise HTTPException(status_code=400, detail="is_verified must be specified")

    user.is_verified = body.is_verified
    user.updated_at = datetime.now()
    db.commit()
    db.refresh(user)

    return format_user(user)


@router.patch("/users/{user_id}/deactivate", response_model=UserResponse)
async def deactivate_user(
    user_id: str,
    body: UserUpdateRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    """
    Deactivate a user (set is_active=False).
    Can be applied to any user role.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail=f"User {user_id} not found")

    if body.is_active is None:
        raise HTTPException(status_code=400, detail="is_active must be specified")

    user.is_active = body.is_active
    user.updated_at = datetime.now()
    db.commit()
    db.refresh(user)

    return format_user(user)
