from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.core.enums import UserRole

class UserProfileUpdate(BaseModel):
    full_name: str | None = Field(
        default=None,
        min_length=2,
        max_length=120,
    )

    preferred_language: str | None = Field(
        default=None,
        pattern="^(en|ur)$",
    )

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    phone_number: str
    full_name: str | None
    role: UserRole
    preferred_language: str
    is_phone_verified: bool
    is_active: bool
    onboarding_completed: bool
    created_at: datetime
    updated_at: datetime