# SQLAlchemy Farm model — PostgreSQL system of record.
# Farm records with location and current sensor status (green/yellow/red).

from datetime import datetime
from enum import Enum
from typing import Optional
from sqlalchemy import DateTime, Enum as SQLEnum, Float, ForeignKey, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import Base


class FarmStatus(str, Enum):
    """Current farm status derived from live sensor thresholds."""
    SAFE = "safe"          # green
    WARNING = "warning"    # yellow
    CRITICAL = "critical"  # red


class Farm(Base):
    """
    PostgreSQL farms table.

    owner_id links to the farmer who registered the farm (users.id).
    status reflects the *latest* aggregated sensor reading; the live status
    the map view uses comes from Firebase RTDB via useRealtimeSensors.
    """
    __tablename__ = "farms"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    owner_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    city: Mapped[Optional[str]] = mapped_column(String(120), nullable=True)
    location_lat: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    location_lng: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    status: Mapped[FarmStatus] = mapped_column(
        SQLEnum(FarmStatus), nullable=False, default=FarmStatus.SAFE
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships (populated lazily by SQLAlchemy)
    owner = relationship("User", backref="farms")
    flocks = relationship("Flock", back_populates="farm", cascade="all, delete-orphan")
    sensor_readings = relationship(
        "SensorReading", back_populates="farm", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Farm(id={self.id}, name={self.name!r}, status={self.status.value})>"
