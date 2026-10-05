# SQLAlchemy User model — PostgreSQL system of record.
# Matches the schema in PoultryGuard_Dashboard_Architecture.md Section 3.

from datetime import datetime
from enum import Enum
from typing import Optional
from sqlalchemy import Boolean, DateTime, Enum as SQLEnum, String, func
from sqlalchemy.orm import Mapped, mapped_column

from models.base import Base


class UserRole(str, Enum):
    """Role enum: farmer, vet, admin."""
    FARMER = "farmer"
    VET = "vet"
    ADMIN = "admin"


class LanguagePref(str, Enum):
    """Language preference enum: en, ur."""
    EN = "en"
    UR = "ur"


class User(Base):
    """
    PostgreSQL users table — system of record for user profiles & roles.

    firebase_uid is the unique key linking to Firebase Authentication.
    role is enforced server-side on every request via require_role.
    """
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    firebase_uid: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    role: Mapped[UserRole] = mapped_column(SQLEnum(UserRole), nullable=False, default=UserRole.FARMER)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    phone: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    language_pref: Mapped[LanguagePref] = mapped_column(
        SQLEnum(LanguagePref), nullable=False, default=LanguagePref.EN
    )
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, firebase_uid={self.firebase_uid[:8]}..., role={self.role.value})>"
