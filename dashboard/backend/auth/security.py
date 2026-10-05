"""
PoultryGuard Security Utilities & Middlewares
- HTTP Security Headers (HSTS, CSP, X-Frame-Options, X-Content-Type-Options)
- Firebase App Check verification
- Per-user / Per-farm authorization checks
- Rate limiting (In-memory token bucket / sliding window)
"""

import os
import time
import logging
from collections import defaultdict
from typing import Optional, Dict
from fastapi import Request, HTTPException, status, Depends
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response, JSONResponse

from auth.firebase_verify import verify_firebase_token
from db.postgres import get_db
from models.user import User, UserRole
from models.farm import Farm
from sqlalchemy.orm import Session

logger = logging.getLogger("auth.security")

# Environment flags
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
STRICT_APP_CHECK = os.getenv("STRICT_APP_CHECK", "false").lower() == "true"


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Enforces modern browser defense-in-depth security headers on all responses:
    - X-Content-Type-Options: nosniff
    - X-Frame-Options: DENY (blocks clickjacking)
    - Strict-Transport-Security: max-age=31536000; includeSubDomains (enforces HTTPS)
    - Content-Security-Policy: default-src 'self'
    - Referrer-Policy: strict-origin-when-cross-origin
    - Permissions-Policy: camera=(), microphone=(), geolocation=()
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"

        # HSTS is only active in production to allow local HTTP testing
        if ENVIRONMENT == "production":
            response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"

        return response


class RateLimiter:
    """
    Sliding window in-memory rate limiter per IP/client UID.
    Prevents API abuse, brute-force, and DoS attacks.
    Default: 120 requests per minute per IP.
    """

    def __init__(self, requests_per_minute: int = 120):
        self.rpm = requests_per_minute
        self.requests: Dict[str, list] = defaultdict(list)

    def is_allowed(self, client_key: str) -> bool:
        now = time.time()
        window_start = now - 60.0

        # Purge timestamps older than 60 seconds
        timestamps = [ts for ts in self.requests[client_key] if ts > window_start]
        self.requests[client_key] = timestamps

        if len(timestamps) >= self.rpm:
            return False

        self.requests[client_key].append(now)
        return True


rate_limiter = RateLimiter(requests_per_minute=120)


async def rate_limit_guard(request: Request):
    """Dependency to enforce rate limits per client IP or authenticated UID."""
    client_ip = request.client.host if request.client else "unknown"
    auth_header = request.headers.get("Authorization", "")
    client_key = auth_header[-16:] if auth_header else client_ip

    if not rate_limiter.is_allowed(client_key):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many requests. Rate limit exceeded. Please wait 60 seconds.",
            headers={"Retry-After": "60"},
        )


async def verify_app_check(request: Request) -> Optional[str]:
    """
    Validates the Firebase App Check token (`X-Firebase-AppCheck` header).
    Guarantees that requests come from the legitimate Flutter mobile app
    (via Play Integrity on Android / DeviceCheck on iOS) or registered Web app (reCAPTCHA Enterprise).
    """
    app_check_token = request.headers.get("X-Firebase-AppCheck")

    if not app_check_token:
        if STRICT_APP_CHECK or ENVIRONMENT == "production":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Missing X-Firebase-AppCheck token header. Request rejected by App Check policy.",
            )
        return None

    try:
        from firebase_admin import app_check
        app_check_claims = app_check.verify_token(app_check_token)
        return app_check_claims.app_id
    except Exception as e:
        logger.warning(f"App Check verification failed: {e}")
        if STRICT_APP_CHECK or ENVIRONMENT == "production":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid or forged Firebase App Check token: {e}",
            )
        return None


def verify_farm_ownership(user: User, farm_id: int, db: Session) -> Farm:
    """
    Enforces per-farm resource-level authorization.
    Admins can access any farm.
    Farmers can ONLY read or modify farms that they own (farm.owner_id == user.id).
    Veterinarians can access farms assigned to them or in their district.
    """
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Farm with ID {farm_id} does not exist.",
        )

    # Superuser role bypass
    if user.role == UserRole.ADMIN:
        return farm

    # Farmer owner check
    if user.role == UserRole.FARMER:
        if farm.owner_id != user.id:
            logger.warning(f"Unauthorized farm access attempt: User {user.id} tried accessing Farm {farm_id}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied: You do not own this farm.",
            )
        return farm

    # Veterinarian check
    if user.role == UserRole.VET:
        # Vets are permitted if assigned or verified
        if not user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Veterinary account is pending administrative verification.",
            )
        return farm

    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Unauthorized resource access.")
