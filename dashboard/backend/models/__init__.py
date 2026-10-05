# Model package — importing each module registers its tables on Base.metadata
# (required for Alembic autogenerate to see all tables).

from models.base import Base
from models.user import User, UserRole, LanguagePref
from models.farm import Farm, FarmStatus
from models.flock import Flock, BirdType
from models.sensor_reading import SensorReading
from models.diagnosis import Diagnosis, DiseaseType, DiseaseCategory, ModelInferenceLog
from models.outbreak_alert import OutbreakAlert, OutbreakSeverity

__all__ = [
    "Base",
    "User",
    "UserRole",
    "LanguagePref",
    "Farm",
    "FarmStatus",
    "Flock",
    "BirdType",
    "SensorReading",
    "Diagnosis",
    "DiseaseType",
    "DiseaseCategory",
    "ModelInferenceLog",
    "OutbreakAlert",
    "OutbreakSeverity",
]
