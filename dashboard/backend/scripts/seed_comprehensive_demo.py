"""
PoultryGuard Comprehensive Demo Seeder
Seeds rich, interconnected demo data for EVERY page in the dashboard:
- Users (Admins, Farmers, Verified Vets, and Pending Vets)
- 12 Farms across Pakistan with GPS coordinates and live statuses
- Housed Flocks with vaccination records
- 7 days of 2-hourly time-series SensorReadings
- OutbreakAlerts for Outbreak Heatmap
- Diagnoses and ModelInferenceLogs for Model Analytics
"""

import sys
import random
from pathlib import Path
from datetime import datetime, timedelta, timezone, date

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from db.postgres import SessionLocal
from models.user import User, UserRole, LanguagePref
from models.farm import Farm, FarmStatus
from models.flock import Flock, BirdType
from models.sensor_reading import SensorReading
from models.outbreak_alert import OutbreakAlert, OutbreakSeverity
from models.diagnosis import Diagnosis, DiseaseType, DiseaseCategory, ModelInferenceLog


PAKISTAN_REGIONS = [
    {"name": "Lahore Broiler Complex 1", "city": "Lahore", "lat": 31.5204, "lng": 74.3587, "status": FarmStatus.SAFE},
    {"name": "Sheikhupura Grand Layer 2", "city": "Sheikhupura", "lat": 31.7131, "lng": 73.9783, "status": FarmStatus.SAFE},
    {"name": "Faisalabad Prime Poultry 3", "city": "Faisalabad", "lat": 31.4504, "lng": 73.1350, "status": FarmStatus.WARNING},
    {"name": "Sahiwal Green Valley 4", "city": "Sahiwal", "lat": 30.6682, "lng": 73.1114, "status": FarmStatus.SAFE},
    {"name": "Kasur Model Aviary 5", "city": "Kasur", "lat": 31.1156, "lng": 74.4467, "status": FarmStatus.SAFE},
    {"name": "Gujranwala Breeder Farm 6", "city": "Gujranwala", "lat": 32.1877, "lng": 74.1945, "status": FarmStatus.SAFE},
    {"name": "Rawalpindi Ridge Farm 7", "city": "Rawalpindi", "lat": 33.5800, "lng": 73.0500, "status": FarmStatus.CRITICAL},
    {"name": "Multan Valley Broilers 8", "city": "Multan", "lat": 30.2200, "lng": 71.4900, "status": FarmStatus.SAFE},
    {"name": "Jhang Poultry Complex 9", "city": "Jhang", "lat": 31.2800, "lng": 72.3300, "status": FarmStatus.SAFE},
    {"name": "Sargodha Layer Farm 10", "city": "Sargodha", "lat": 32.0800, "lng": 72.6700, "status": FarmStatus.SAFE},
    {"name": "Bahawalpur Desert Farm 11", "city": "Bahawalpur", "lat": 29.3900, "lng": 71.6800, "status": FarmStatus.SAFE},
    {"name": "Karachi Coastal Broilers 12", "city": "Karachi", "lat": 24.8900, "lng": 67.0800, "status": FarmStatus.SAFE},
]


def seed_all():
    db = SessionLocal()
    try:
        print("[*] Seeding PoultryGuard Comprehensive Demo Data...")

        # 1. USERS
        # Admin user
        admin = db.query(User).filter(User.email == "admin@poultryguard.pk").first()
        if not admin:
            admin = User(
                firebase_uid="admin-master-uid",
                role=UserRole.ADMIN,
                name="Muhammad Subhan",
                email="admin@poultryguard.pk",
                phone="+923001234567",
                language_pref=LanguagePref.EN,
                is_active=True,
                is_verified=True,
            )
            db.add(admin)
            db.flush()

        # Farmers
        farmer1 = db.query(User).filter(User.email == "malik.arshad@poultryguard.pk").first()
        if not farmer1:
            farmer1 = User(
                firebase_uid="farmer-arshad-uid",
                role=UserRole.FARMER,
                name="Malik Arshad",
                email="malik.arshad@poultryguard.pk",
                phone="+923214567890",
                language_pref=LanguagePref.UR,
                is_active=True,
                is_verified=True,
            )
            db.add(farmer1)
            db.flush()

        farmer2 = db.query(User).filter(User.email == "rashid.mian@poultryguard.pk").first()
        if not farmer2:
            farmer2 = User(
                firebase_uid="farmer-rashid-uid",
                role=UserRole.FARMER,
                name="Mian Rashid",
                email="rashid.mian@poultryguard.pk",
                phone="+923339876543",
                language_pref=LanguagePref.EN,
                is_active=True,
                is_verified=True,
            )
            db.add(farmer2)
            db.flush()

        # Verified Veterinarians
        vet_verified = db.query(User).filter(User.email == "dr.tariq@poultryvet.pk").first()
        if not vet_verified:
            vet_verified = User(
                firebase_uid="vet-tariq-uid",
                role=UserRole.VET,
                name="Dr. Tariq Mahmood (DVM)",
                email="dr.tariq@poultryvet.pk",
                phone="+923015551234",
                language_pref=LanguagePref.EN,
                is_active=True,
                is_verified=True,
            )
            db.add(vet_verified)
            db.flush()

        # Pending Veterinarians awaiting verification (for VeterinaryVerification page!)
        pending_vets = [
            {
                "name": "Dr. Farhan Qureshi",
                "email": "dr.farhan@avianclinic.pk",
                "phone": "+923456789012",
                "uid": "vet-pending-farhan",
            },
            {
                "name": "Dr. Zainab Malik",
                "email": "dr.zainab@poultrycare.org",
                "phone": "+923123456789",
                "uid": "vet-pending-zainab",
            },
            {
                "name": "Dr. Bilal Siddiqui",
                "email": "bilal.vet@lahorelivestock.pk",
                "phone": "+923009988776",
                "uid": "vet-pending-bilal",
            },
        ]
        for pv in pending_vets:
            existing = db.query(User).filter(User.email == pv["email"]).first()
            if not existing:
                u = User(
                    firebase_uid=pv["uid"],
                    role=UserRole.VET,
                    name=pv["name"],
                    email=pv["email"],
                    phone=pv["phone"],
                    language_pref=LanguagePref.EN,
                    is_active=True,
                    is_verified=False,  # PENDING APPROVAL
                )
                db.add(u)
                print(f"  + Pending Vet: {pv['name']}")

        db.commit()

        # 2. FARMS + FLOCKS + SENSOR READINGS
        owner_id = farmer1.id if farmer1 else admin.id
        now = datetime.now(timezone.utc)

        for i, reg in enumerate(PAKISTAN_REGIONS):
            farm = db.query(Farm).filter(Farm.name == reg["name"]).first()
            if not farm:
                farm = Farm(
                    owner_id=owner_id,
                    name=reg["name"],
                    city=reg["city"],
                    location_lat=reg["lat"],
                    location_lng=reg["lng"],
                    status=reg["status"],
                )
                db.add(farm)
                db.flush()
                print(f"  + Farm {farm.id}: {farm.name} ({farm.city})")

                # Flock for this farm
                bird_count = random.choice([8000, 12000, 15000, 22000, 35000])
                age_days = random.randint(12, 45)
                btype = BirdType.LAYER if "Layer" in reg["name"] else BirdType.BROILER

                flock = Flock(
                    farm_id=farm.id,
                    bird_type=btype,
                    bird_count=bird_count,
                    age_days=age_days,
                    placement_date=date.today() - timedelta(days=age_days),
                    vaccination_history=[
                        {"name": "Newcastle Disease (NDV)", "date": "Day 7", "status": "completed"},
                        {"name": "Infectious Bursal Disease (IBD)", "date": "Day 14", "status": "completed" if age_days >= 14 else "scheduled"},
                        {"name": "Hydropericardium Syndrome", "date": "Day 21", "status": "completed" if age_days >= 21 else "scheduled"},
                    ],
                )
                db.add(flock)
                db.flush()

                # 7 days of sensor readings (every 3 hours)
                base_time = now - timedelta(days=7)
                for step in range(7 * 8):
                    t = base_time + timedelta(hours=step * 3)
                    # Create temperature wave based on time of day
                    hour = t.hour
                    day_factor = 4.0 if 11 <= hour <= 16 else (-2.0 if 0 <= hour <= 6 else 0.0)

                    if reg["status"] == FarmStatus.CRITICAL:
                        temp = round(32.8 + random.uniform(0.5, 2.0), 1)
                        hum = round(78.0 + random.uniform(2.0, 8.0), 1)
                        amm = round(26.5 + random.uniform(1.0, 5.0), 1)
                    elif reg["status"] == FarmStatus.WARNING:
                        temp = round(30.4 + day_factor * 0.3 + random.uniform(-0.5, 0.8), 1)
                        hum = round(71.0 + random.uniform(-2.0, 4.0), 1)
                        amm = round(21.2 + random.uniform(-1.0, 2.0), 1)
                    else:
                        temp = round(25.5 + day_factor + random.uniform(-1.0, 1.0), 1)
                        hum = round(62.0 + random.uniform(-3.0, 4.0), 1)
                        amm = round(13.5 + random.uniform(-2.0, 3.0), 1)

                    db.add(
                        SensorReading(
                            farm_id=farm.id,
                            timestamp=t,
                            temperature=temp,
                            humidity=hum,
                            ammonia=amm,
                        )
                    )

        db.commit()

        # 3. OUTBREAK ALERTS (for Outbreak Heatmap)
        outbreak_count = db.query(OutbreakAlert).count()
        if outbreak_count == 0:
            sample_farms = db.query(Farm).all()
            outbreaks_data = [
                {
                    "farm_index": 6,  # Rawalpindi Ridge
                    "disease": "Newcastle Disease",
                    "severity": OutbreakSeverity.CRITICAL,
                    "radius_km": 15.0,
                    "bird_count_affected": 14200,
                    "desc": "Active virulent Newcastle Disease outbreak confirmed via RT-PCR. 15km containment perimeter established.",
                    "days_ago": 1,
                },
                {
                    "farm_index": 2,  # Faisalabad
                    "disease": "Coccidiosis (Eimeria tenella)",
                    "severity": OutbreakSeverity.HIGH,
                    "radius_km": 10.0,
                    "bird_count_affected": 6800,
                    "desc": "Severe coccidiosis cluster in broiler flock with hemorrhagic enteritis.",
                    "days_ago": 3,
                },
                {
                    "farm_index": 7,  # Multan
                    "disease": "Salmonella enterica",
                    "severity": OutbreakSeverity.MEDIUM,
                    "radius_km": 8.0,
                    "bird_count_affected": 2400,
                    "desc": "Environmental salmonella contamination isolated in bedding litter.",
                    "days_ago": 6,
                },
                {
                    "farm_index": 0,  # Lahore
                    "disease": "Infectious Bronchitis (IBV)",
                    "severity": OutbreakSeverity.LOW,
                    "radius_km": 5.0,
                    "bird_count_affected": 1200,
                    "desc": "Mild respiratory rales; vaccination booster administered.",
                    "days_ago": 12,
                },
            ]
            for ob in outbreaks_data:
                target_farm = sample_farms[ob["farm_index"]] if len(sample_farms) > ob["farm_index"] else sample_farms[0]
                alert = OutbreakAlert(
                    farm_id=target_farm.id,
                    disease=ob["disease"],
                    severity=ob["severity"],
                    location=f"{target_farm.city}, Pakistan",
                    location_lat=target_farm.location_lat,
                    location_lng=target_farm.location_lng,
                    radius_km=ob["radius_km"],
                    bird_count_affected=ob["bird_count_affected"],
                    description=ob["desc"],
                    reported_at=now - timedelta(days=ob["days_ago"]),
                )
                db.add(alert)
                print(f"  + Outbreak: {ob['disease']} ({ob['severity'].value}) at {target_farm.name}")

            db.commit()

        # 4. DIAGNOSES & MODEL INFERENCE LOGS (for Model Analytics)
        diag_count = db.query(Diagnosis).count()
        if diag_count == 0:
            sample_farms = db.query(Farm).all()
            diseases_catalog = [
                (DiseaseType.COCCIDIOSIS, DiseaseCategory.PARASITIC, 0.942, True),
                (DiseaseType.NEWCASTLE, DiseaseCategory.VIRAL, 0.915, True),
                (DiseaseType.SALMONELLOSIS, DiseaseCategory.BACTERIAL, 0.887, True),
                (DiseaseType.COCCIDIOSIS, DiseaseCategory.PARASITIC, 0.963, True),
                (DiseaseType.NEWCASTLE, DiseaseCategory.VIRAL, 0.720, False),  # false positive example
                (DiseaseType.SALMONELLOSIS, DiseaseCategory.BACTERIAL, 0.931, True),
            ]

            for d in range(14):
                day_time = now - timedelta(days=d)
                for _ in range(random.randint(4, 9)):
                    chosen = random.choice(diseases_catalog)
                    dto, cat, base_conf, is_corr = chosen
                    f = random.choice(sample_farms)

                    diagnosis = Diagnosis(
                        farm_id=f.id,
                        disease_type=dto,
                        disease_category=cat,
                        confidence=round(base_conf + random.uniform(-0.04, 0.03), 3),
                        ai_model_version="mobilenet_v2_poultry_v2.4",
                        notes=f"Clinical analysis: {dto.value} pathology detected in cecal/fecal scan.",
                        is_confirmed=is_corr,
                        diagnosed_at=day_time - timedelta(hours=random.randint(1, 18)),
                    )
                    db.add(diagnosis)
                    db.flush()

                    # Model inference log
                    db.add(
                        ModelInferenceLog(
                            farm_id=f.id,
                            diagnosis_id=diagnosis.id,
                            disease_type=dto,
                            predicted_disease=dto,
                            confidence=diagnosis.confidence,
                            is_correct=is_corr,
                            feedback_source="vet",
                            inferred_at=diagnosis.diagnosed_at,
                        )
                    )

            db.commit()
            print("  + Diagnoses & ModelInferenceLogs populated.")

        print("[SUCCESS] All demo data successfully seeded into database.")

    except Exception as e:
        db.rollback()
        print("[ERROR] Seeding failed:", e)
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_all()
