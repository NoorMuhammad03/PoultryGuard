# SQLAlchemy SensorReading model — aggregated/historical sensor data.
# Per architecture doc: raw seconds-level stream stays in Firebase RTDB;
# this table holds the *aggregated* history the dashboard charts query.

from datetime import datetime
from typing import Optional
from sqlalchemy import JSON, DateTime, Float, ForeignKey, Integer, func, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import Base


class SensorReading(Base):
    """
    PostgreSQL sensor_readings table.

    One row per (farm, aggregation bucket) written by the RTDB sync job
    (services/firebase_rtdb_sync.py). Temperature in °C, humidity in %,
    ammonia in ppm — the three params the dashboard trends chart.
    """
    __tablename__ = "sensor_readings"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    farm_id: Mapped[int] = mapped_column(ForeignKey("farms.id"), nullable=False, index=True)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, index=True
    )
    temperature: Mapped[Optional[float]] = mapped_column(Float, nullable=True)  # °C
    humidity: Mapped[Optional[float]] = mapped_column(Float, nullable=True)     # % RH
    ammonia: Mapped[Optional[float]] = mapped_column(Float, nullable=True)      # ppm NH3
    # Raw JSON snapshot from RTDB (optional — keeps a trace of the source)
    raw: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)

    farm = relationship("Farm", back_populates="sensor_readings")

    __table_args__ = (
        Index("ix_sensor_readings_farm_timestamp", "farm_id", "timestamp"),
    )

    def __repr__(self) -> str:
        return (
            f"<SensorReading(id={self.id}, farm_id={self.farm_id}, "
            f"ts={self.timestamp.isoformat() if self.timestamp else None})>"
        )
