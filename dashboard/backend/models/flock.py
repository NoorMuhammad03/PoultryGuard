# SQLAlchemy Flock model — PostgreSQL system of record.
# Flock composition, bird type, count, and vaccination history.

from datetime import date, datetime
from enum import Enum
from typing import Optional
from sqlalchemy import JSON, Date, DateTime, Enum as SQLEnum, ForeignKey, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import Base


class BirdType(str, Enum):
    """Flock bird type enum."""
    BROILER = "broiler"
    LAYER = "layer"


class Flock(Base):
    """
    PostgreSQL flocks table.

    Each farm can register multiple flocks over time (e.g. successive batches).
    vaccination_history is a JSON list of {vaccine: str, date: str} entries.
    """
    __tablename__ = "flocks"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    farm_id: Mapped[int] = mapped_column(ForeignKey("farms.id"), nullable=False, index=True)
    bird_type: Mapped[BirdType] = mapped_column(SQLEnum(BirdType), nullable=False)
    bird_count: Mapped[int] = mapped_column(Integer, nullable=False)
    age_days: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    placement_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    vaccination_history: Mapped[Optional[list]] = mapped_column(
        JSON, nullable=True, default=list
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    farm = relationship("Farm", back_populates="flocks")

    def __repr__(self) -> str:
        return (
            f"<Flock(id={self.id}, farm_id={self.farm_id}, "
            f"type={self.bird_type.value}, birds={self.bird_count})>"
        )
