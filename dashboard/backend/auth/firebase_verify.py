# FastAPI dependency to verify Firebase ID tokens.
# Extracts the token from the Authorization header, validates it with
# firebase-admin, and returns the decoded claims.

import os
import time
import logging
from typing import Optional
import firebase_admin
from firebase_admin import auth as firebase_auth, credentials
from fastapi import Header, HTTPException, status
import jwt

logger = logging.getLogger("auth.firebase_verify")

PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID", "poultryguard-d2d7f")
CREDENTIALS_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH")

# Initialize firebase-admin app once
if not firebase_admin._apps:
    if CREDENTIALS_PATH and os.path.exists(CREDENTIALS_PATH):
        try:
            cred = credentials.Certificate(CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, options={"projectId": PROJECT_ID})
            logger.info(f"Firebase Admin initialized with service account: {CREDENTIALS_PATH}")
        except Exception as e:
            logger.warning(f"Failed to load credentials from {CREDENTIALS_PATH}: {e}")
            firebase_admin.initialize_app(options={"projectId": PROJECT_ID})
    else:
        try:
            firebase_admin.initialize_app(options={"projectId": PROJECT_ID})
            logger.info(f"Firebase Admin initialized with project ID: {PROJECT_ID}")
        except Exception as e:
            logger.warning(f"Default initialize_app failed: {e}")


async def verify_firebase_token(
    authorization: Optional[str] = Header(None),
) -> dict:
    """
    Verify the Firebase ID token from the Authorization header.

    Returns the decoded token claims (dict) on success.
    Raises HTTPException 401 if the token is missing, malformed, expired, or invalid.
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Authorization header format. Expected: Bearer <token>",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        # Full validation with Firebase Admin SDK (verifies signature, exp, and aud)
        decoded_token = firebase_auth.verify_id_token(token, check_revoked=True)
        # Validate audience matches configured Firebase Project ID
        token_aud = decoded_token.get("aud")
        if token_aud != PROJECT_ID:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid Firebase token audience '{token_aud}'. Expected '{PROJECT_ID}'.",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return decoded_token
    except firebase_auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except firebase_auth.RevokedIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token has been revoked",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except firebase_auth.InvalidIdTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Firebase ID token: {e}",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except HTTPException:
        raise
    except Exception as e:
        # In production, NEVER bypass signature verification
        environment = os.getenv("ENVIRONMENT", "development").lower()
        if environment == "production":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Firebase ID token verification failed: {e}",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Fallback strictly restricted to development/testing when serviceAccountKey is absent
        err_msg = str(e).lower()
        if "defaultcredentialserror" in type(e).__name__.lower() or "credentials were not found" in err_msg or "failed to establish a new connection" in err_msg:
            try:
                unverified_claims = jwt.decode(token, options={"verify_signature": False})
                # Verify audience
                if unverified_claims.get("aud") != PROJECT_ID:
                    raise HTTPException(
                        status_code=status.HTTP_401_UNAUTHORIZED,
                        detail="Token aud does not match project",
                        headers={"WWW-Authenticate": "Bearer"},
                    )
                # Verify expiration
                exp = unverified_claims.get("exp")
                if exp and exp < time.time():
                    raise HTTPException(
                        status_code=status.HTTP_401_UNAUTHORIZED,
                        detail="Firebase ID token has expired",
                        headers={"WWW-Authenticate": "Bearer"},
                    )
                # Verify subject
                if not unverified_claims.get("sub"):
                    raise HTTPException(
                        status_code=status.HTTP_401_UNAUTHORIZED,
                        detail="Firebase ID token missing sub claim",
                        headers={"WWW-Authenticate": "Bearer"},
                    )
                return unverified_claims
            except HTTPException:
                raise
            except Exception as decode_err:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail=f"Token verification fallback failed: {decode_err}",
                    headers={"WWW-Authenticate": "Bearer"},
                )

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {e}",
            headers={"WWW-Authenticate": "Bearer"},
        )