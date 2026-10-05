# Shared Pydantic models for request validation across admin routers.
# Ensures consistent validation and documentation.

from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
from enum import Enum


class UserRoleEnum(str, Enum):
    FARMER = "farmer"
    VET = "vet"
    ADMIN = "admin"


class UserStatusEnum(str, Enum):
    VERIFIED = "verified"
    PENDING = "pending"
    ACTIVE = "active"
    INACTIVE = "inactive"


class OutbreakSeverityEnum(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class DiseaseTypeEnum(str, Enum):
    COCCIDIOSIS = "coccidiosis"
    NEWCASTLE = "newcastle"
    SALMONELLOSIS = "salmonellosis"


# User validation models
class UserUpdateRequest(BaseModel):
    """Request body for updating user verification/activation status."""
    is_verified: Optional[bool] = Field(None, description="Vet verification status")
    is_active: Optional[bool] = Field(None, description="User active status")

    class Config:
        schema_extra = {
            "example": {"is_verified": True, "is_active": True}
        }


class UserListQueryParams(BaseModel):
    """Query parameters for listing users."""
    role: Optional[UserRoleEnum] = Field(None, description="Filter by user role")
    status: Optional[UserStatusEnum] = Field(None, description="Filter by user status")
    search: Optional[str] = Field(None, max_length=100, description="Search by name or email")


# Farm validation models
class FarmCreateRequest(BaseModel):
    """Request body for creating a farm."""
    name: str = Field(..., min_length=1, max_length=255, description="Farm name")
    city: Optional[str] = Field(None, max_length=120, description="City name")
    location_lat: Optional[float] = Field(None, ge=-90, le=90, description="Latitude")
    location_lng: Optional[float] = Field(None, ge=-180, le=180, description="Longitude")
    owner_id: int = Field(..., gt=0, description="Owner user ID")

    @validator('location_lat')
    def validate_lat(cls, v, values):
        if v is not None and 'location_lng' in values and values['location_lng'] is None:
            raise ValueError('Both lat and lng must be provided together')
        return v

    @validator('location_lng')
    def validate_lng(cls, v, values):
        if v is not None and 'location_lat' in values and values['location_lat'] is None:
            raise ValueError('Both lat and lng must be provided together')
        return v


class FarmUpdateRequest(BaseModel):
    """Request body for updating a farm."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    city: Optional[str] = Field(None, max_length=120)
    location_lat: Optional[float] = Field(None, ge=-90, le=90)
    location_lng: Optional[float] = Field(None, ge=-180, le=180)
    status: Optional[str] = Field(None, pattern="^(safe|warning|critical)$")


# Sensor validation models
class SensorHistoryQueryParams(BaseModel):
    """Query parameters for sensor history endpoint."""
    days: int = Field(7, ge=1, le=365, description="Number of days to look back")


# Analytics validation models
class AnalyticsQueryParams(BaseModel):
    """Query parameters for analytics endpoints."""
    days: int = Field(7, ge=1, le=365, description="Number of days to look back")
    disease: Optional[DiseaseTypeEnum] = Field(None, description="Filter by disease type")
    farm_id: Optional[int] = Field(None, gt=0, description="Filter by farm ID")


# Outbreak validation models
class OutbreakQueryParams(BaseModel):
    """Query parameters for outbreak endpoints."""
    days: int = Field(30, ge=1, le=365, description="Lookback window in days")
    severity: Optional[OutbreakSeverityEnum] = Field(None, description="Filter by severity")
    disease: Optional[str] = Field(None, max_length=120, description="Filter by disease name")


class GeofenceQueryParams(BaseModel):
    """Query parameters for geofence endpoints."""
    lat: float = Field(..., ge=-90, le=90, description="Center latitude")
    lng: float = Field(..., ge=-180, le=180, description="Center longitude")
    radius_km: float = Field(15, ge=1, le=100, description="Search radius in km")
    days: int = Field(30, ge=1, le=365, description="Lookback window in days")


class NearbyFarmsQueryParams(BaseModel):
    """Query parameters for nearby farms endpoint."""
    outbreak_id: int = Field(..., gt=0, description="Outbreak ID to find nearby farms")
    radius_km: float = Field(15, ge=1, le=100, description="Search radius in km")


# Common response models
class SuccessResponse(BaseModel):
    """Standard success response."""
    success: bool = True
    message: Optional[str] = None


class PaginatedResponse(BaseModel):
    """Paginated response wrapper."""
    items: List[dict]
    total: int
    page: int
    page_size: int
    total_pages: int