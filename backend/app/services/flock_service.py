from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.farm import Farm
from app.models.flock import Flock
from app.models.user import User
from app.schemas.flock import FlockCreate, FlockUpdate


class FlockService:
    @staticmethod
    def get_user_farm(
        db: Session,
        user: User,
    ) -> Farm:
        farm = db.scalar(
            select(Farm).where(
                Farm.user_id == user.id,
            ),
        )

        if farm is None:
            raise ValueError(
                "No farm is registered for this user",
            )

        return farm

    @staticmethod
    def create_flock(
        db: Session,
        user: User,
        request: FlockCreate,
    ) -> Flock:
        farm = FlockService.get_user_farm(
            db=db,
            user=user,
        )

        flock = Flock(
            farm_id=farm.id,
            name=request.name.strip(),
            breed=request.breed.strip(),
            start_date=request.start_date,
            initial_bird_count=request.initial_bird_count,
            current_bird_count=request.current_bird_count,
            notes=request.notes.strip()
            if request.notes
            else None,
        )

        db.add(flock)
        db.commit()
        db.refresh(flock)

        return flock

    @staticmethod
    def list_flocks(
        db: Session,
        user: User,
    ) -> list[Flock]:
        farm = FlockService.get_user_farm(
            db=db,
            user=user,
        )

        return list(
            db.scalars(
                select(Flock)
                .where(Flock.farm_id == farm.id)
                .order_by(Flock.created_at.desc()),
            ).all(),
        )

    @staticmethod
    def get_flock(
        db: Session,
        user: User,
        flock_id: UUID,
    ) -> Flock:
        farm = FlockService.get_user_farm(
            db=db,
            user=user,
        )

        flock = db.scalar(
            select(Flock).where(
                Flock.id == flock_id,
                Flock.farm_id == farm.id,
            ),
        )

        if flock is None:
            raise ValueError("Flock not found")

        return flock

    @staticmethod
    def update_flock(
        db: Session,
        user: User,
        flock_id: UUID,
        request: FlockUpdate,
    ) -> Flock:
        flock = FlockService.get_flock(
            db=db,
            user=user,
            flock_id=flock_id,
        )

        update_data = request.model_dump(
            exclude_unset=True,
        )

        for field, value in update_data.items():
            if isinstance(value, str):
                value = value.strip()

            setattr(flock, field, value)

        db.add(flock)
        db.commit()
        db.refresh(flock)

        return flock

    @staticmethod
    def delete_flock(
        db: Session,
        user: User,
        flock_id: UUID,
    ) -> None:
        flock = FlockService.get_flock(
            db=db,
            user=user,
            flock_id=flock_id,
        )

        db.delete(flock)
        db.commit()