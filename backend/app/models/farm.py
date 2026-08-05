from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class Farm(Base):
    __tablename__ = "farms"

    id: Mapped[UUID] = mapped_column(
        primary_key=True,
        default=uuid4,
    )

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    farm_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    address: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    bird_capacity: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    latitude: Mapped[str | None] = mapped_column(
        String(50),
        nullable=True,
    )

    longitude: Mapped[str | None] = mapped_column(
        String(50),
        nullable=True,
    )

    sensor_alerts: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
    )

    disease_alerts: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
    )

    community_alerts: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )