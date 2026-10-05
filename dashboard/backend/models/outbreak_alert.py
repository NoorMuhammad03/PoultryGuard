# SQLAlchemy OutbreakAlert model with PostGIS support.
# Geofenced outbreak alerts for 15km radius geofencing (Section 6.8 of scope doc).

from datetime import datetime
from enum import Enum
from typing import Optional
from sqlalchemy import DateTime, Enum as SQLEnum, Float, ForeignKey, Integer, String, func, Index, text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import Base


class OutbreakSeverity(str, Enum):
    """Outbreak severity levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class OutbreakAlert(Base):
    """
    PostgreSQL outbreak_alerts table with PostGIS support.

    Stores disease outbreaks with geospatial location for 15km radius geofencing.
    The `location` column uses PostGIS geography type for accurate distance calculations.
    """
    __tablename__ = "outbreak_alerts"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    farm_id: Mapped[int] = mapped_column(
        ForeignKey("farms.id"), nullable=False, index=True
    )
    disease: Mapped[str] = mapped_column(String(120), nullable=False)
    severity: Mapped[OutbreakSeverity] = mapped_column(
        SQLEnum(OutbreakSeverity), nullable=False, default=OutbreakSeverity.MEDIUM
    )
    # PostGIS geography point (WGS84 SRID 4326) — stores lat/lng as geography for
    # accurate geodesic distance calculations (ST_DWithin uses meters).
    # Raw SQL: geography(POINT, 4326)
    location: Mapped[Optional[str]] = mapped_column(
        # Using String to store WKT format; actual PostGIS column is geography
        # The alembic migration will create the proper PostGIS column
        nullable=True
    )
    location_lat: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    location_lng: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    radius_km: Mapped[float] = mapped_column(Float, nullable=False, default=15.0)
    bird_count_affected: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    description: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)
    reported_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )
    resolved_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True, index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now(), nullable=True
    )

    # Relationships
    farm = relationship("Farm", backref="outbreaks")

    __table_args__ = (
        Index("ix_outbreak_alerts_farm_reported", "farm_id", "reported_at"),
    )

    def __repr__(self) -> str:
        return f"<OutbreakAlert(id={self.id}, disease={self.disease!r}, severity={self.severity.value}, farm_id={self.farm_id})>"


# SQL to add PostGIS extension and geography column (run in alembic migration)
# The migration should include:
# CREATE EXTENSION IF NOT EXISTS postgis;
# ALTER TABLE outbreak_alerts ADD COLUMN location geography(POINT, 4326);
# CREATE INDEX idx_outbreak_alerts_location ON outbreak_alerts USING GIST (location);
# For now, we store lat/lng in separate columns and compute geography in queries.