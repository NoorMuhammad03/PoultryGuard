"""
Pytest security test suite asserting strict authentication and authorization
across all /admin routers WITHOUT using app.dependency_overrides.

Asserts:
  - 401 Unauthorized when no Authorization header is provided.
  - 401 Unauthorized when an invalid/expired token is provided.
  - 403 Forbidden when a valid token belongs to a non-admin (e.g. farmer/vet).
  - 200 OK when a valid token belongs to an administrator.
"""

import sys
import os
import time
import pytest
import jwt

# Add backend directory to sys.path so modules can be imported
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from main import app
from auth.firebase_verify import PROJECT_ID

client = TestClient(app)

# Test token generation using a compliant 32-byte HMAC key
TEST_KEY = "poultryguard_test_signing_key_32bytes!"

ADMIN_UID = "brhW2B99XkQOL8nbwDN7lZUCZU72"
NON_ADMIN_UID = "farmer-arshad-uid"

ADMIN_ENDPOINTS = [
    ("/api/v1/admin/dashboard/summary", "GET"),
    ("/api/v1/admin/farms", "GET"),
    ("/api/v1/admin/flocks", "GET"),
    ("/api/v1/admin/sensors/3/history", "GET"),
    ("/api/v1/admin/analytics/diagnoses", "GET"),
    ("/api/v1/admin/outbreaks", "GET"),
    ("/api/v1/admin/users", "GET"),
]


def make_token(sub: str, exp_delta: int = 3600, aud: str = PROJECT_ID) -> str:
    """Generate a test Firebase JWT claim set."""
    payload = {
        "sub": sub,
        "aud": aud,
        "exp": time.time() + exp_delta,
        "email": f"{sub}@poultryguard.pk",
    }
    return jwt.encode(payload, TEST_KEY, algorithm="HS256")


@pytest.mark.parametrize("path,method", ADMIN_ENDPOINTS)
def test_admin_route_missing_token_returns_401(path, method):
    """Assert 401 Unauthorized when request lacks Authorization header."""
    response = client.request(method, path)
    assert response.status_code == 401, f"{path} did not return 401 on missing token: {response.text}"


@pytest.mark.parametrize("path,method", ADMIN_ENDPOINTS)
def test_admin_route_invalid_token_returns_401(path, method):
    """Assert 401 Unauthorized when token is malformed, expired, or wrong aud."""
    # 1. Malformed token
    res1 = client.request(method, path, headers={"Authorization": "Bearer malformed.jwt.token"})
    assert res1.status_code == 401, f"{path} did not return 401 on malformed token"

    # 2. Expired token
    expired_token = make_token(ADMIN_UID, exp_delta=-600)
    res2 = client.request(method, path, headers={"Authorization": f"Bearer {expired_token}"})
    assert res2.status_code == 401, f"{path} did not return 401 on expired token"

    # 3. Wrong audience
    bad_aud_token = make_token(ADMIN_UID, aud="unauthorized-project")
    res3 = client.request(method, path, headers={"Authorization": f"Bearer {bad_aud_token}"})
    assert res3.status_code == 401, f"{path} did not return 401 on invalid audience"


@pytest.mark.parametrize("path,method", ADMIN_ENDPOINTS)
def test_admin_route_non_admin_token_returns_403(path, method):
    """Assert 403 Forbidden when authenticated user does not have admin role."""
    non_admin_token = make_token(NON_ADMIN_UID)
    response = client.request(
        method,
        path,
        headers={"Authorization": f"Bearer {non_admin_token}"}
    )
    assert response.status_code == 403, (
        f"{path} allowed non-admin access (status {response.status_code}): {response.text}"
    )


@pytest.mark.parametrize("path,method", ADMIN_ENDPOINTS)
def test_admin_route_admin_token_returns_200(path, method):
    """Assert 200 OK when authenticated user is an administrator."""
    admin_token = make_token(ADMIN_UID)
    response = client.request(
        method,
        path,
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200, (
        f"{path} failed for admin user (status {response.status_code}): {response.text}"
    )
