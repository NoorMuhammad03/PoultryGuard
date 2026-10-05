from datetime import date, datetime
from uuid import UUID, uuid4
from sqlalchemy import Date, DateTime, Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.enums import FlockStatus
from app.db.database import Base


class Flock(Base):
    __tablename__ = "flocks"

    id: Mapped[UUID] = mapped_column(
        primary_key=True,
        default=uuid4,
    )

    farm_id: Mapped[UUID] = mapped_column(
        ForeignKey("farms.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(120),
        nullable=False,
    )

    breed: Mapped[str] = mapped_column(
        String(120),
        nullable=False,
    )

    start_date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )

    initial_bird_count: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    current_bird_count: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    average_weight_kg: Mapped[float | None] = mapped_column(
    Float,
    nullable=True,
    )

    status: Mapped[FlockStatus] = mapped_column(
        Enum(FlockStatus, name="flock_status"),
        default=FlockStatus.ACTIVE,
        nullable=False,
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
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

    farm = relationship(
        "Farm",
        back_populates="flocks",
    )