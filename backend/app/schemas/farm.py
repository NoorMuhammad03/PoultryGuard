from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class FarmCreate(BaseModel):
    farm_name: str = Field(min_length=2, max_length=150)
    address: str = Field(min_length=2, max_length=255)
    bird_capacity: int = Field(gt=0)
    latitude: str | None = None
    longitude: str | None = None
    sensor_alerts: bool = True
    disease_alerts: bool = True
    community_alerts: bool = True


class FarmResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    farm_name: str
    address: str
    bird_capacity: int
    latitude: str | None
    longitude: str | None
    sensor_alerts: bool
    disease_alerts: bool
    community_alerts: bool
    created_at: datetime
    updated_at: datetime