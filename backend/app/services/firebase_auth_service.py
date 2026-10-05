from typing import Any

import firebase_admin
from firebase_admin import auth, credentials


class FirebaseAuthService:
    @staticmethod
    def initialize() -> None:
        if firebase_admin._apps:
            return

        firebase_admin.initialize_app(
            credentials.ApplicationDefault(),
        )

    @staticmethod
    def verify_id_token(
        id_token: str,
    ) -> dict[str, Any]:
        FirebaseAuthService.initialize()

        try:
            return auth.verify_id_token(id_token)
        except Exception as error:
            raise ValueError(
                "Invalid or expired Firebase ID token",
            ) from error