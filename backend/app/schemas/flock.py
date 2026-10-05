from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.core.enums import FlockStatus


class FlockCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    breed: str = Field(min_length=2, max_length=120)
    start_date: date
    initial_bird_count: int = Field(gt=0)
    current_bird_count: int = Field(gt=0)
    notes: str | None = None
    average_weight_kg: float | None = Field(default=None, gt=0)


class FlockUpdate(BaseModel):
    name: str | None = None
    breed: str | None = None
    start_date: date | None = None
    current_bird_count: int | None = Field(default=None, gt=0)
    status: FlockStatus | None = None
    notes: str | None = None
    average_weight_kg: float | None = Field(default=None, gt=0)


class FlockResponse(BaseModel):
    id: UUID
    farm_id: UUID
    name: str
    breed: str
    start_date: date
    initial_bird_count: int
    current_bird_count: int
    status: FlockStatus
    notes: str | None
    created_at: datetime
    updated_at: datetime
    average_weight_kg: float | None

    model_config = {
        "from_attributes": True,
    }