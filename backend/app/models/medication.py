from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, Enum, Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.enums import DiseaseType, DosageCalculationType
from app.db.database import Base


class MedicationGuidance(Base):
    __tablename__ = "medication_guidance"

    id: Mapped[UUID] = mapped_column(
        primary_key=True,
        default=uuid4,
    )

    disease: Mapped[DiseaseType] = mapped_column(
        Enum(DiseaseType, name="disease_type"),
        nullable=False,
        index=True,
    )

    medication_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    active_ingredient: Mapped[str | None] = mapped_column(
        String(150),
        nullable=True,
    )

    indication: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    dosage_calculation_type: Mapped[DosageCalculationType] = mapped_column(
    Enum(
        DosageCalculationType,
        name="dosage_calculation_type",
    ),
    default=DosageCalculationType.NOT_APPLICABLE,
    nullable=False,
    )
    
    dosage_value: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    dosage_unit: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    administration_method: Mapped[str | None] = mapped_column(
    Text,
    nullable=True,
    )

    treatment_duration_days: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )

    withdrawal_period_days: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )

    precautions: Mapped[str | None] = mapped_column(
    Text,
    nullable=True,
    )

    source_name: Mapped[str | None] = mapped_column(
    String(200),
    nullable=True,
    ) 

    source_reference: Mapped[str | None] = mapped_column(
    Text,
    nullable=True,
    )

    product_formulation: Mapped[str | None] = mapped_column(
    String(200),
    nullable=True,
    )

    veterinarian_required: Mapped[bool] = mapped_column(
    Boolean,
    default=True,
    nullable=False,
    )

    veterinarian_required: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False,
    )