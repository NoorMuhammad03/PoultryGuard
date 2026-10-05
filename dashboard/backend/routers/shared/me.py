# GET /me endpoint — returns the current user's profile and role.
# Called by the frontend's ProtectedRoute to resolve the admin role.

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth.firebase_verify import verify_firebase_token
from db.postgres import get_db
from models.user import User, UserRole

router = APIRouter(prefix="/api/v1", tags=["shared"])


@router.get("/me")
async def get_me(
    token: dict = Depends(verify_firebase_token),
    db: Session = Depends(get_db),
):
    """
    Return the current user's profile from SQLite/PostgreSQL.

    - Verifies the Firebase ID token (via verify_firebase_token).
    - Looks up or creates the user row.
    - Returns the user's profile and role.
    """
    firebase_uid = token.get("sub") or token.get("user_id")
    if not firebase_uid:
        return {"error": "Invalid token"}

    user = db.query(User).filter(User.firebase_uid == firebase_uid).first()

    email = token.get("email")
    if not user and email:
        # Match existing seed user by email (e.g. admin@poultryguard.pk)
        user = db.query(User).filter(User.email == email).first()
        if user:
            user.firebase_uid = firebase_uid
            db.commit()
            db.refresh(user)

    if not user:
        # First-time login to admin dashboard: create user as ADMIN
        name = token.get("name", email.split("@")[0] if email else firebase_uid)
        user = User(
            firebase_uid=firebase_uid,
            role=UserRole.ADMIN,
            name=name,
            email=email or "",
            language_pref="en",
            is_active=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    return {
        "id": user.id,
        "firebase_uid": user.firebase_uid,
        "role": user.role.value,
        "name": user.name,
        "phone": user.phone,
        "email": user.email,
        "language_pref": user.language_pref.value,
        "is_active": user.is_active,
        "created_at": user.created_at.isoformat() if user.created_at else None,
    }