from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.enums import UserRole
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.revoked_token import RevokedToken
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest

class AuthService:

    @staticmethod
    def register_user(
        db: Session,
        request: RegisterRequest,
    ) -> User:
        existing_user = db.scalar(
            select(User).where(
                User.phone_number == request.phone_number,
            ),
        )

        if existing_user is not None:
            raise ValueError(
                "An account with this phone number already exists",
            )

        user = User(
            phone_number=request.phone_number,
            password_hash=hash_password(request.password),
            role=UserRole(request.role),
            preferred_language=request.preferred_language,

            # Temporary for local testing.
            # Firebase verification will control this later.
            is_phone_verified=True,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

        return user

    @staticmethod
    def authenticate_user(
        db: Session,
        request: LoginRequest,
    ) -> tuple[User, str, str]:
        user = db.scalar(
            select(User).where(
                User.phone_number == request.phone_number,
            ),
        )

        if user is None or user.password_hash is None:
            raise ValueError("Invalid phone number or password")

        if not verify_password(
            request.password,
            user.password_hash,
        ):
            raise ValueError("Invalid phone number or password")

        if not user.is_active:
            raise ValueError("This account has been disabled")

        access_token = create_access_token(
            user_id=user.id,
            role=user.role.value,
        )

        refresh_token = create_refresh_token(
            user_id=user.id,
            remember_me=request.remember_me,
        )

        return user, access_token, refresh_token


    @staticmethod
    def refresh_session(
        db: Session,
        refresh_token: str,
    ) -> tuple[str, str]:
        payload = decode_token(refresh_token)

        if payload.get("type") != "refresh":
            raise ValueError("Invalid token type")

        jti = payload.get("jti")

        if jti is None:
            raise ValueError("Refresh token is missing identifier")

        revoked_token = db.get(RevokedToken, jti)

        if revoked_token is not None:
            raise ValueError("Refresh token has been revoked")

        subject = payload.get("sub")

        if subject is None:
            raise ValueError("Refresh token is missing subject")

        user_id = UUID(subject)

        user = db.scalar(
            select(User).where(User.id == user_id),
        )

        if user is None:
            raise ValueError("User not found")

        if not user.is_active:
            raise ValueError("This account has been disabled")

        access_token = create_access_token(
            user_id=user.id,
            role=user.role.value,
        )

        new_refresh_token = create_refresh_token(
            user_id=user.id,
            remember_me=True,
        )

        return access_token, new_refresh_token


    @staticmethod
    def logout(
        db: Session,
        refresh_token: str,
    ) -> None:
        payload = decode_token(refresh_token)

        if payload.get("type") != "refresh":
            raise ValueError("Invalid token type")

        jti = payload.get("jti")
        expiration = payload.get("exp")

        if jti is None or expiration is None:
            raise ValueError("Invalid refresh token")

        existing_revocation = db.get(RevokedToken, jti)

        if existing_revocation is not None:
            return

        revoked_token = RevokedToken(
            jti=jti,
            expires_at=datetime.fromtimestamp(
                expiration,
                tz=UTC,
            ),
        )

        db.add(revoked_token)
        db.commit()


    @staticmethod
    def change_password(
        db: Session,
        user: User,
        current_password: str,
        new_password: str,
    ) -> None:
        if user.password_hash is None:
            raise ValueError(
                "Password is not configured for this account",
            )

        if not verify_password(
            current_password,
            user.password_hash,
        ):
            raise ValueError(
                "Current password is incorrect",
            )

        if verify_password(
            new_password,
            user.password_hash,
        ):
            raise ValueError(
                "New password must be different from the current password",
            )

        user.password_hash = hash_password(new_password)

        db.add(user)
        db.commit()
        db.refresh(user)