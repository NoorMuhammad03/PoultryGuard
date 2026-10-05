# files.md — PoultryGuard backend file map

One-line function per file (≈7–8 words) with the folder architecture.

```
backend/
│
├── .env                      # Local secrets (git-ignored)
├── .env.example              # Template of env vars to copy
├── .gitignore                # Excludes .venv, __pycache__, .env
├── main.py                  # FastAPI app entry + router includes
├── requirements.txt         # Pinned dependency versions
│
├── alembic/
│   ├── env.py                # Alembic environment config
│   ├── ini                   # Alembic configuration file
│   └── versions/
│       ├── be00a17305e1_initial_users_table.py          # Initial users migration
│       └── 76def4169d56_add_farm_flock_sensor_reading_tables.py # Farm/flock/sensor migration
│
├── auth/
│   ├── firebase_verify.py    # Verify Firebase ID token dependency
│   └── role_guard.py         # Role-based access control dependency
│
├── db/
│   └── postgres.py           # SQLAlchemy engine + session factory
│
├── models/
│   ├── base.py               # Shared SQLAlchemy DeclarativeBase
│   ├── user.py               # User model (users table)
│   ├── farm.py               # Farm model (farms table, owner, coords)
│   ├── flock.py              # Flock model (flocks table, birds)
│   ├── sensor_reading.py     # Aggregated sensor history table
│   ├── diagnosis.py          # Diagnoses + model inference logs
│   ├── outbreak_alert.py     # Outbreak alerts with PostGIS support
│   └── __init__.py           # Imports all models for Alembic
│
├── routers/
│   ├── admin/
│   │   ├── farms.py          # GET /admin/farms, /admin/farms/map
│   │   ├── analytics.py      # GET /admin/analytics/diagnoses, /model
│   │   ├── sensors.py        # GET /admin/sensors/{farm_id}/history
│   │   ├── users.py          # GET /admin/users, PATCH verify/deactivate
│   │   └── outbreaks.py      # GET /admin/outbreaks, /geofence, /nearby-farms
│   ├── farmer/               # Farmer-only endpoints
│   ├── vet/                  # Vet-only endpoints
│   └── shared/
│       └── me.py             # GET /me — current user profile
│
├── scripts/
│   └── seed_demo.py          # Seeds admin, farms, sensor readings
│
├── services/
│   ├── firebase_rtdb_sync.py # RTDB→Postgres aggregation job skeleton
│   └── __init__.py
│
└── __init__.py              # Package marker
```

> `routers/farmer/`, `routers/vet/` are scaffolded empty folders (kept via
> `__init__.py`) ready for the endpoints named in
> `PoultryGuard_Dashboard_Architecture.md`.