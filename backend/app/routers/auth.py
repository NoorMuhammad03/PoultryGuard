from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.auth import RefreshTokenRequest

from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.auth import ChangePasswordRequest

from app.db.database import get_db
from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
)

from app.schemas.auth import (
    ChangePasswordRequest,
    LoginRequest,
    RefreshTokenRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
)

from app.schemas.user import UserResponse
from app.services.auth_service import AuthService
from app.schemas.auth import RefreshTokenRequest

router = APIRouter(
    prefix="/api/v1/auth",
    tags=["Authentication"],
)


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    request: RegisterRequest,
    db: Session = Depends(get_db),
) -> UserResponse:
    try:
        return AuthService.register_user(
            db=db,
            request=request,
        )
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(error),
        ) from error


@router.post(
    "/reset-password",
    status_code=status.HTTP_200_OK,
)
def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db),
) -> dict[str, str]:
    try:
        AuthService.reset_password(
            db=db,
            phone_number=request.phone_number,
            firebase_id_token=request.firebase_id_token,
            new_password=request.new_password,
        )

        return {
            "message": "Password reset successfully",
        }

    except ValueError as error:
        message = str(error)

        if "No account exists" in message:
            status_code = status.HTTP_404_NOT_FOUND
        elif "disabled" in message:
            status_code = status.HTTP_403_FORBIDDEN
        else:
            status_code = status.HTTP_401_UNAUTHORIZED

        raise HTTPException(
            status_code=status_code,
            detail=message,
        ) from error

    
@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
) -> TokenResponse:
    try:
        _, access_token, refresh_token = (
            AuthService.authenticate_user(
                db=db,
                request=request,
            )
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
        )

    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(error),
        ) from error

@router.post(
    "/refresh",
    response_model=TokenResponse,
)
def refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db),
) -> TokenResponse:
    try:
        access_token, new_refresh_token = AuthService.refresh_session(
            db=db,
            refresh_token=request.refresh_token,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=new_refresh_token,
        )

    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(error),
        ) from error

@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
)
def logout(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db),
) -> None:
    try:
        AuthService.logout(
            db=db,
            refresh_token=request.refresh_token,
        )

    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(error),
        ) from error


@router.post(
    "/change-password",
    status_code=status.HTTP_200_OK,
)
def change_password(
    request: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict[str, str]:
    try:
        AuthService.change_password(
            db=db,
            user=current_user,
            current_password=request.current_password,
            new_password=request.new_password,
        )

        return {
            "message": "Password changed successfully",
        }

    except ValueError as error:
     message = str(error)

     if "already exists" in message:
        status_code = status.HTTP_409_CONFLICT
     else:
        status_code = status.HTTP_401_UNAUTHORIZED

     raise HTTPException(
        status_code=status_code,
        detail=message,
     ) from error