from enum import Enum


class UserRole(str, Enum):
    FARMER = "farmer"
    VETERINARIAN = "veterinarian"
    ADMIN = "admin"


class FlockStatus(str, Enum):
    ACTIVE = "active"
    COMPLETED = "completed"


class DiseaseType(str, Enum):
    HEALTHY = "healthy"
    COCCIDIOSIS = "coccidiosis"
    NEWCASTLE = "newcastle"
    SALMONELLOSIS = "salmonellosis"

class DosageCalculationType(str, Enum):
    WATER_CONCENTRATION = "water_concentration"
    BODY_WEIGHT = "body_weight"
    FIXED = "fixed"
    NOT_APPLICABLE = "not_applicable"