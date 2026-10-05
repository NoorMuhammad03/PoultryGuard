# SQLAlchemy Diagnosis model — PostgreSQL system: The conversation has reached 30 messages.
# Stores AI diagnosis results for analytics and outbreak tracking.

from datetime import datetime
from enum import Enum
from typing import Optional
from sqlalchemy import DateTime, Enum as SQLEnum, Float, ForeignKey, Integer, String, func, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import Base


class DiseaseType(str, Enum):
    """Disease types the AI can detect."""
    COCCIDIOSIS = "coccidiosis"
    NEWCASTLE = "newcastle"
    SALMONELLOSIS = "salmonellosis"


class DiseaseCategory(str, Enum):
    """Biological category of disease."""
    PARASITIC = "parasitic"
    VIRAL = "viral"
    BACTERIAL = "bacterial"
    ENVIRONMENTAL = "environmental"


class Diagnosis(Base):
    """
    PostgreSQL diagnoses table.

    Records each AI diagnosis (from image analysis) linked to farm and flock.
    Used for analytics, outbreak detection, and model accuracy tracking.
    """
    __tablename__ = "diagnoses"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    farm_id: Mapped[int] = mapped_column(
        ForeignKey("farms.id"), nullable=False, index=True
    )
    flock_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("flocks.id"), nullable=True, index=True
    )
    disease_type: Mapped[DiseaseType] = mapped_column(
        SQLEnum(DiseaseType), nullable=False, index=True
    )
    disease_category: Mapped[DiseaseCategory] = mapped_column(
        SQLEnum(DiseaseCategory), nullable=False
    )
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    image_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    ai_model_version: Mapped[str] = mapped_column(String(50), nullable=False, default="mobilenet_v2_1.0")
    notes: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)
    is_confirmed: Mapped[bool] = mapped_column(default=False, nullable=False)
    confirmed_by_vet_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("users.id"), nullable=True, index=True
    )
    diagnosed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )
    confirmed_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True, index=True
    )

    # Relationships
    farm = relationship("Farm", backref="diagnoses")
    flock = relationship("Flock", backref="diagnoses")
    confirmed_by = relationship("User", backref="confirmed_diagnoses")

    # Composite index for analytics queries
    __table_args__ = (
        Index('ix_diagnoses_farm_date', 'farm_id', 'diagnosed_at'),
        Index('ix_diagnoses_disease_date', 'disease_type', 'diagnosed_at'),
    )

    def __repr__(self) -> str:
        return f"<Diagnosis(id={self.id}, farm_id={self.farm_id}, disease={self.disease_type.value}, conf={self.confidence:.2f})>"


class ModelInferenceLog(Base):
    """
    PostgreSQL model_inference_logs table.

    Logs every inference for model accuracy monitoring.
    Used to compute per-disease accuracy over time.
    """
    __tablename__ = "model_inference_logs"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    farm_id: Mapped[int] = mapped_column(
        ForeignKey("farms.id"), nullable=False, index=True
    )
    diagnosis_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("diagnoses.id"), nullable=True, index=True
    )
    disease_type: Mapped[DiseaseType] = mapped_column(
        SQLEnum(DiseaseType), nullable=False, index=True
    )
    predicted_disease: Mapped[DiseaseType] = mapped_column(
        SQLEnum(DiseaseType), nullable=False
    )
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    is_correct: Mapped[Optional[bool]] = mapped_column(nullable=True)
    feedback_source: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)  # "vet", "farmer", "lab"
    inferred_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

    # Relationships
    farm = relationship("Farm", backref="inference_logs")
    diagnosis = relationship("Diagnosis", backref="inference_logs")

    __table_args__ = (
        Index('ix_inference_logs_disease_date', 'disease_type', 'inferred_at'),
        Index('ix_inference_logs_farm_date', 'farm_id', 'inferred_at'),
    )

    def __repr__(self) -> str:
        return f"<ModelInferenceLog(id={self.id}, disease={self.disease_type.value}, predicted={self.predicted_disease.value}, correct={self.is_correct})>"