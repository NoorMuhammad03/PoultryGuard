from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict

from app.core.enums import UserRole


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    phone_number: str
    role: UserRole
    preferred_language: str
    is_phone_verified: bool
    is_active: bool
    onboarding_completed: bool
    created_at: datetime
    updated_at: datetime