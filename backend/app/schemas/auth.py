from pydantic import BaseModel, Field, field_validator


class RegisterRequest(BaseModel):
    phone_number: str = Field(
        min_length=10,
        max_length=20,
        examples=["+923001234567"],
    )
    password: str = Field(
        min_length=8,
        max_length=128,
    )
    preferred_language: str = Field(
        default="en",
        pattern="^(en|ur)$",
    )
    role: str = Field(
        default="farmer",
        pattern="^(farmer|veterinarian)$",
    )

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, value: str) -> str:
        cleaned = value.replace(" ", "").replace("-", "")

        if cleaned.startswith("03") and len(cleaned) == 11:
            return f"+92{cleaned[1:]}"

        if cleaned.startswith("3") and len(cleaned) == 10:
            return f"+92{cleaned}"

        if cleaned.startswith("+923") and len(cleaned) == 13:
            return cleaned

        raise ValueError("Enter a valid Pakistani mobile number")


class LoginRequest(BaseModel):
    phone_number: str
    password: str = Field(
        min_length=8,
        max_length=128,
    )
    remember_me: bool = False

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, value: str) -> str:
        cleaned = value.replace(" ", "").replace("-", "")

        if cleaned.startswith("03") and len(cleaned) == 11:
            return f"+92{cleaned[1:]}"

        if cleaned.startswith("3") and len(cleaned) == 10:
            return f"+92{cleaned}"

        if cleaned.startswith("+923") and len(cleaned) == 13:
            return cleaned

        raise ValueError("Enter a valid Pakistani mobile number")


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshTokenRequest(BaseModel):
    refresh_token: str

class ChangePasswordRequest(BaseModel):
    current_password: str = Field(
        min_length=8,
        max_length=128,
    )
    new_password: str = Field(
        min_length=8,
        max_length=128,
    )

    @field_validator("new_password")
    @classmethod
    def validate_new_password(cls, value: str) -> str:
        has_letter = any(character.isalpha() for character in value)
        has_number = any(character.isdigit() for character in value)

        if not has_letter or not has_number:
            raise ValueError(
                "New password must contain letters and numbers",
            )

        return value