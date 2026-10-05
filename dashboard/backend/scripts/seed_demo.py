# Seed demo data for local development.
#
# Inserts an admin user, 2 farms, flocks, and a week of sensor readings so the
# /admin/* endpoints return real data from PostgreSQL during local testing.
# Idempotent: skips inserts if a farm with the same name already exists.
#
# Usage:
#   .venv/Scripts/python.exe scripts/seed_demo.py

import random
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from db.postgres import SessionLocal
from models.farm import Farm, FarmStatus
from models.flock import BirdType, Flock
from models.sensor_reading import SensorReading
from models.user import User, UserRole

CITIES = [
    (31.5204, 74.3587, "Lahore"),
    (33.6844, 73.0479, "Islamabad"),
    (24.8607, 67.0011, "Karachi"),
    (30.1798, 71.4433, "Multan"),
]


def seed():
    db = SessionLocal()
    try:
        # --- Admin user (matches a placeholder firebase_uid) ---
        admin = db.query(User).filter(User.email == "admin@poultryguard.pk").first()
        if not admin:
            admin = User(
                firebase_uid="seed-admin-uid",
                role=UserRole.ADMIN,
                name="Admin Seed",
                email="admin@poultryguard.pk",
                language_pref="en",
                is_active=True,
            )
            db.add(admin)
            db.flush()
            print(f"+ user admin (id={admin.id})")

        # --- Farms + flocks + sensor readings ---
        for i in range(2):
            lat, lng, city = CITIES[i]
            farm = db.query(Farm).filter(Farm.name == f"Seed Farm {i + 1}").first()
            if not farm:
                farm = Farm(
                    owner_id=admin.id,
                    name=f"Seed Farm {i + 1}",
                    city=city,
                    location_lat=lat,
                    location_lng=lng,
                    status=FarmStatus.SAFE,
                )
                db.add(farm)
                db.flush()
                print(f"+ farm (id={farm.id}, {farm.name})")

                flock = Flock(
                    farm_id=farm.id,
                    bird_type=BirdType.BROILER,
                    bird_count=12000,
                    age_days=25,
                    placement_date=datetime.now().date() - timedelta(days=25),
                    vaccination_history=[
                        {"vaccine": "Newcastle", "date": (datetime.now() - timedelta(days=10)).date().isoformat()},
                    ],
                )
                db.add(flock)
                print(f"  + flock (id={flock.id}, {flock.bird_count} birds)")

                # 7 days of 2-hourly readings
                base = datetime.now(timezone.utc) - timedelta(days=7)
                for h in range(0, 7 * 24, 2):
                    ts = base + timedelta(hours=h)
                    db.add(
                        SensorReading(
                            farm_id=farm.id,
                            timestamp=ts,
                            temperature=round(random.uniform(22, 35), 2),
                            humidity=round(random.uniform(40, 85), 2),
                            ammonia=round(random.uniform(0, 30), 2),
                        )
                    )
                print(f"  + {7 * 12} sensor readings")

        db.commit()
        print("Seeding complete.")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
