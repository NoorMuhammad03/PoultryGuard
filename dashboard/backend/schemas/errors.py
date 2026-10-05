# Consistent error response schemas for the API.
# Used across all routers to ensure uniform error handling.

from pydantic import BaseModel
from typing import Optional, List


class ErrorResponse(BaseModel):
    """
    Standard error response schema.
    Used for 4xx and 5xx responses across all endpoints.
    """
    detail: str
    code: Optional[str] = None
    status_code: Optional[int] = None
    errors: Optional[List[str]] = None


class ValidationErrorResponse(BaseModel):
    """
    Validation error response schema.
    Used when Pydantic validation fails on request bodies/query params.
    """
    detail: str = "Validation error"
    errors: List[dict]


class NotFoundErrorResponse(BaseModel):
    """
    Not found error response schema.
    Used for 404 responses.
    """
    detail: str
    resource: Optional[str] = None
    resource_id: Optional[str] = None


class UnauthorizedErrorResponse(BaseModel):
    """
    Unauthorized error response schema.
    Used for 401 responses (missing/invalid auth).
    """
    detail: str = "Missing Authorization header"
    auth_type: str = "Bearer"


class ForbiddenErrorResponse(BaseModel):
    """
    Forbidden error response schema.
    Used for 403 responses (insufficient permissions).
    """
    detail: str
    required_role: Optional[str] = None


# Helper functions to create consistent error responses
def create_error_response(
    detail: str,
    code: Optional[str] = None,
    status_code: Optional[int] = None,
    errors: Optional[List[str]] = None,
) -> dict:
    """Create a standard error response dictionary."""
    return {
        "detail": detail,
        "code": code,
        "status_code": status_code,
        "errors": errors,
    }


def create_validation_error_response(errors: List[dict]) -> dict:
    """Create a validation error response dictionary."""
    return {
        "detail": "Validation error",
        "errors": errors,
    }


def create_not_found_response(resource: str, resource_id: Optional[str] = None) -> dict:
    """Create a not found error response dictionary."""
    return {
        "detail": f"{resource} not found",
        "resource": resource,
        "resource_id": resource_id,
    }


def create_forbidden_response(required_role: Optional[str] = None) -> dict:
    """Create a forbidden error response dictionary."""
    return {
        "detail": "Insufficient permissions",
        "required_role": required_role,
    }
