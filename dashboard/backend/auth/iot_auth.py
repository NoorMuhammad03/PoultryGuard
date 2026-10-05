"""
PoultryGuard IoT Device Authentication
- Validates ESP32 microcontroller telemetry requests via per-device API tokens or HMAC signatures.
- Completely separates IoT machine-to-machine authentication from end-user Firebase tokens.
"""

import os
import hmac
import hashlib
from typing import Optional
from fastapi import Header, HTTPException, status

# In production, keys can be stored in PostgreSQL or HashiCorp Vault.
# For edge nodes, a master secret or per-device pre-shared key (PSK) is validated.
IOT_SHARED_SECRET = os.getenv("IOT_DEVICE_SECRET", "")


def verify_iot_device(
    x_device_id: Optional[str] = Header(None, alias="X-Device-ID"),
    x_device_token: Optional[str] = Header(None, alias="X-Device-Token"),
) -> str:
    """
    Dependency to authenticate IoT hardware nodes (ESP32).
    Requires:
    - X-Device-ID: e.g. "ESP32-NODE-FARM-1001-A"
    - X-Device-Token: Pre-shared device key or HMAC hash of device_id + secret
    """
    if not IOT_SHARED_SECRET:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="IoT authentication secret is not configured on the server (IOT_DEVICE_SECRET missing in .env).",
        )

    if not x_device_id or not x_device_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing IoT Device authentication headers (X-Device-ID and X-Device-Token required)",
        )

    # Validate against expected token
    expected_token = hmac.new(
        IOT_SHARED_SECRET.encode(),
        x_device_id.encode(),
        hashlib.sha256,
    ).hexdigest()

    # Constant-time comparison to prevent timing attacks
    if not (hmac.compare_digest(x_device_token, expected_token) or x_device_token == IOT_SHARED_SECRET):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid IoT Device token or unrecognized hardware node.",
        )

    return x_device_id
