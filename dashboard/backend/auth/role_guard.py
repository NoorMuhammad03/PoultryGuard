# Role-based authorization dependency.
# Looks up the user in PostgreSQL by firebase_uid, creates a placeholder row
# on first login if none exists, and enforces role checks.

from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Annotated, Union

from auth.firebase_verify import verify_firebase_token
from db.postgres import get_db
from models.user import User, UserRole


async def _get_current_user(
    token: dict = Depends(verify_firebase_token),
    db: Session = Depends(get_db),
) -> User:
    """
    Internal dependency: gets the current user from the database.
    Creates a placeholder row on first login if none exists.
    """
    firebase_uid = token.get("sub")
    if not firebase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token missing 'sub' claim",
        )

    # Look up user by firebase_uid
    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()

    # First-time login: create a placeholder row
    if not user:
        email = token.get("email")
        name = token.get("name", email.split("@")[0] if email else firebase_uid)
        user = User(
            firebase_uid=firebase_uid,
            role=UserRole.FARMER,  # default role for new users
            name=name,
            email=email or "",
            language_pref="en",
            is_active=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    return user


# Export public dependency alias
get_current_user = _get_current_user


def require_role(*allowed_roles: UserRole):
    """
    Dependency factory that enforces role-based access control.

    Usage:
      @router.get("/admin/...", dependencies=[Depends(require_role(UserRole.ADMIN))])
      async def admin_endpoint(user: User = Depends(require_role(UserRole.ADMIN))):
          ...
    """
    async def role_checker(user: User = Depends(_get_current_user)) -> User:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{user.role.value}' not allowed. Requires one of: {[r.value for r in allowed_roles]}",
            )
        return user

    return role_checker


async def require_admin(user: User = Depends(_get_current_user)) -> User:
    """
    Dependency enforcing administrative access across all /admin endpoints.
    Raises HTTP 403 Forbidden if user is not an administrator.
    """
    if user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Administrator privileges required. Role '{user.role.value}' is unauthorized.",
        )
    return user