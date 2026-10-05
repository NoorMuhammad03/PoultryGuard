from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from routers.shared import me
from routers.admin import farms, analytics, sensors, users, outbreaks

import os
from starlette.middleware.gzip import GZipMiddleware
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from auth.security import SecurityHeadersMiddleware, rate_limit_guard
from routers.admin import dashboard_summary

limiter = Limiter(key_func=get_remote_address, default_limits=["120/minute"])

app = FastAPI(
    title="PoultryGuard API",
    description=(
        "Shared FastAPI backend for the PoultryGuard admin dashboard and "
        "Flutter mobile app. Versioned under /api/v1."
    ),
    version="0.1.0",
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# 1. Performance: Response GZip compression for payloads > 500 bytes (reduces bandwidth by 70%)
app.add_middleware(GZipMiddleware, minimum_size=500)

# 2. Security: Enforce defense-in-depth HTTP security headers (HSTS, CSP, X-Frame-Options)
app.add_middleware(SecurityHeadersMiddleware)

# 3. Security: Strict CORS allowlist (disables wildcard origin with credentials)
cors_origins_env = os.getenv("CORS_ALLOWED_ORIGINS", "")
allowed_origins = [
    origin.strip()
    for origin in cors_origins_env.split(",")
    if origin.strip()
] or [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Firebase-AppCheck", "X-Device-ID", "X-Device-Token"],
)


# Exception handlers for consistent error responses
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Handle HTTP exceptions with consistent error schema."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "code": "HTTP_ERROR",
            "status_code": exc.status_code,
        },
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle Pydantic validation errors with consistent error schema."""
    return JSONResponse(
        status_code=422,
        content={
            "detail": "Validation error",
            "code": "VALIDATION_ERROR",
            "status_code": 422,
            "errors": exc.errors(),
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle unexpected errors with consistent error schema."""
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "code": "INTERNAL_ERROR",
            "status_code": 500,
        },
    )


from routers.admin import farms, analytics, sensors, users, outbreaks, flocks

# Include routers
app.include_router(dashboard_summary.router)
app.include_router(me.router)
app.include_router(farms.router)
app.include_router(flocks.router)
app.include_router(analytics.router)
app.include_router(sensors.router)
app.include_router(users.router)
app.include_router(outbreaks.router)


@app.get("/health")
def health_check():
    """Minimal health-check route used for uptime monitoring."""
    return {"status": "ok"}
