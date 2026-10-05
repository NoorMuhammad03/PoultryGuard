# PoultryGuard Backend — Local Testing Guide

Step-by-step instructions to run and test the FastAPI backend locally.

## Prerequisites

- Python 3.10+ (developed on 3.14)
- A terminal in the `backend/` folder

## 1. First-time setup (one time)

```powershell
# Create the virtual environment (skip if `.venv` already exists)
python -m venv .venv

# Activate it (PowerShell)
.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

> If `requirements.txt` is out of date, re-pin with: `pip freeze > requirements.txt`.

## 2. Configure environment

```powershell
# Create .env from the template (already present in this repo)
Copy-Item .env.example .env
```

Edit `.env`:

| Variable | Default (dev) | Notes |
|---|---|---|
| `DATABASE_URL` | `sqlite:///./poultryguard.db` | SQLite for local dev; use `postgresql://user:pass@host:5432/poultryguard` for production |
| `FIREBASE_CREDENTIALS_PATH` | (empty) | Path to the Firebase Admin SDK JSON — only needed for `/me` + real token auth |
| `FIREBASE_DATABASE_URL` | (empty) | Needed by the RTDB sync job / live sensors |

**Auth note:** every `/api/v1/*` route requires a valid Firebase ID token. Without
real Firebase credentials, endpoints return `401`. For local testing of the data
layer you can either set up real credentials or test the query logic directly (see
step 6).

## 3. Apply database migrations

```powershell
.venv\Scripts\alembic upgrade head
```

Verify the tables:

```powershell
.venv\Scripts\python -c "import sys; sys.path.insert(0,'.'); from db.postgres import engine; from sqlalchemy import inspect; print(inspect(engine).get_table_names())"
# → ['alembic_version', 'farms', 'flocks', 'sensor_readings', 'users']
```

## 4. Seed demo data (optional, recommended)

```powershell
.venv\Scripts\python scripts\seed_demo.py
```

Creates an admin user, 2 farms with flocks, and 7 days of sensor readings. Idempotent
— safe to run again.

## 5. Start the server

```powershell
.venv\Scripts\uvicorn main:app --reload
```

- API base: `http://127.0.0.1:8000`
- Interactive docs (OpenAPI): `http://127.0.0.1:8000/docs`

## 6. Test the endpoints

**Health (no auth needed):**

```powershell
curl http://127.0.0.1:8000/health
# → {"status":"ok"}
```

**Authenticated endpoints return 401 without a token (expected):**

```powershell
curl http://127.0.0.1:8000/api/v1/admin/farms
# → {"detail":"Missing Authorization header"}
```

**Test the data layer with a token bypass** (Python — exercises the real DB query
without real Firebase credentials):

```powershell
.venv\Scripts\python -c "
import sys; sys.path.insert(0,'.')
from fastapi.testclient import TestClient
from main import app
from auth.role_guard import _get_current_user
from models.user import User, UserRole

def fake_admin():
    return User(id=1, firebase_uid='x', role=UserRole.ADMIN, name='t', email='t@t.pk', language_pref='en', is_active=True)

app.dependency_overrides[_get_current_user] = fake_admin
c = TestClient(app)
r = c.get('/api/v1/admin/sensors/1/history?days=7')
print(r.status_code, r.json()['count'], 'readings for', r.json()['farm_name'])
"
```

With seeded data you should see `200 ... 83 readings for Seed Farm 1`.

**Sensor history endpoint (used by SensorLogsView):**

```powershell
# Verify the sensor history endpoint returns data for farm 1
.venv\Scripts\python -c "
import sys; sys.path.insert(0,'.')
from fastapi.testclient import TestClient
from main import app
from auth.role_guard import _get_current_user
from models.user import User, UserRole

def fake_admin():
    return User(id=1, firebase_uid='x', role=UserRole.ADMIN, name='t', email='t@t.pk', language_pref='en', is_active=True)

app.dependency_overrides[_get_current_user] = fake_admin
c = TestClient(app)
for days in [7, 30]:
    r = c.get(f'/api/v1/admin/sensors/1/history?days={days}')
    print(f'days={days}: {r.status_code} {r.json().get(\"count\", 0)} readings')
"
```

Expected: both 7 and 30-day windows return `200` with reading counts.

**Outbreak endpoints (used by OutbreakHeatmap):**

```powershell
# Test outbreaks heatmap endpoint
.venv\Scripts\python -c "
import sys; sys.path.insert(0,'.')
from fastapi.testclient import TestClient
from main import app
from auth.role_guard import _get_current_user
from models.user import User, UserRole

def fake_admin():
    return User(id=1, firebase_uid='x', role=UserRole.ADMIN, name='t', email='t@t.pk', language_pref='en', is_active=True)

app.dependency_overrides[_get_current_user] = fake_admin
c = TestClient(app)
r = c.get('/api/v1/admin/outbreaks?days=30')
print(f'outbreaks: {r.status_code} {len(r.json())} items')
"
```

**Analytics endpoints (used by ModelAnalytics):**

```powershell
# Test diagnoses summary
.venv\Scripts\python -c "
import sys; sys.path.insert(0,'.')
from fastapi.testclient import TestClient
from main import app
from auth.role_guard import _get_current_user
from models.user import User, UserRole

def fake_admin():
    return User(id=1, firebase_uid='x', role=UserRole.ADMIN, name='t', email='t@t.pk', language_pref='en', is_active=True)

app.dependency_overrides[_get_current_user] = fake_admin
c = TestClient(app)
r = c.get('/api/v1/admin/analytics/diagnoses/summary')
print(f'diagnoses: {r.status_code} {r.json()}')

r2 = c.get('/api/v1/admin/analytics/model/summary')
print(f'model: {r2.status_code} {r2.json()}')
"
```

Expected: all endpoints return `200` with data arrays.

## 7. Development workflows

**Generate a new migration after changing a model:**

```powershell
.venv\Scripts\alembic revision --autogenerate -m "describe the change"
.venv\Scripts\alembic upgrade head
```

**Run the RTDB sync job skeleton (standalone worker):**

```powershell
.venv\Scripts\python -m services.firebase_rtdb_sync
```

The job currently no-ops (documented TODO) until `FIREBASE_CREDENTIALS_PATH` and the
Firebase read logic are implemented.

## Common issues

| Symptom | Fix |
|---|---|
| `DATABASE_URL not set in environment` | Ensure `.env` exists with `DATABASE_URL` |
| `no such table: sensor_readings` | Run `.venv\Scripts\alembic upgrade head` |
| `401 Missing Authorization header` | Expected — supply a Firebase ID token or use the dependency override in step 6 |
| `ImportError: attempted relative import` | Always run via `uvicorn main:app` from `backend/`; don't `python main.py` |
