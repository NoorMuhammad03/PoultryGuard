# PoultryGuard Backend Architecture

## 1. Design Principles

1. **Firebase = identity, PostgreSQL = system of record.** Firebase Authentication issues ID tokens and manages login. PostgreSQL owns all structured business data (users, farms, flocks, diagnoses, outbreaks, reports).
2. **One shared backend.** Both the React dashboard and the Flutter app talk to the *same* FastAPI service and the *same* Firebase project. No forked logic, no duplicate auth systems.
3. **Server-side authorization, always.** Role checks (`farmer` / `vet` / `admin`) are enforced in FastAPI on every request — the React route guard is a UX convenience, not a security boundary.

## 2. High-Level System Diagram

```
┌───────────────────────┐            ┌───────────────────────┐
│   React Admin           │            │   Flutter App            │
│   Dashboard               │            │   (teammate — farmer/vet)│
└───────────┬─────────────┘            └───────────┬─────────────┘
            │  Firebase ID Token (Authorization header)         │
            ▼                                        ▼
   ┌─────────────────────────────────────────────────────────┐
   │                Firebase Authentication                     │
   │   Single shared project — email/phone login, issues ID tokens │
   └─────────────────────────────────────────────────────────┘
                            │ verified by backend on every call
                            ▼
   ┌─────────────────────────────────────────────────────────┐
   │                     FastAPI Backend                        │
   │  • Verifies Firebase ID token (firebase-admin SDK)          │
   │  • Maps firebase_uid → PostgreSQL user row + role           │
   │  • Role-guarded routers: /admin /farmer /vet /shared         │
   │  • Runs ML inference (MobileNetV2, Random Forest)             │
   │  • Aggregates Firebase RTDB → PostgreSQL periodically          │
   └───────────┬─────────────────────────────┬─────────────────┘
               │                               │
               ▼                               ▼
   ┌───────────────────────┐       ┌───────────────────────────┐
   │      PostgreSQL           │       │   Firebase Realtime DB       │
   │  Structured system-of-      │       │   Live IoT sensor stream       │
   │  record data (users,          │       │   (seconds-level updates)        │
   │  farms, flocks, diagnoses,     │       └───────────┬───────────────┘
   │  outbreaks, reports)             │                   ▲
   └───────────────────────┘                   │ MQTT → Firebase bridge
                                                  │
                                        ┌───────────────────┐
                                        │   ESP32 + Sensors     │
                                        │  DHT22 / MQ135 / MQ-2   │
                                        └───────────────────┘
```

## 3. Authentication & Authorization Flow

**Login sequence (dashboard):**

1. Admin enters credentials → Firebase Web SDK authenticates → returns Firebase ID token (JWT).
2. React stores the token in memory (via `AuthContext`), attaches it as `Authorization: Bearer <token>` on every API call.
3. FastAPI dependency `verify_firebase_token` validates the token using the `firebase-admin` SDK on every incoming request.
4. Backend looks up `firebase_uid` in PostgreSQL `users` table to resolve `role`.
5. Route-level dependency `require_role("admin")` rejects the request (`403`) if the resolved role isn't `admin`.

**First-time login / registration completion:**

- If no PostgreSQL row exists for a `firebase_uid`, the backend creates one and returns a "complete your profile" flag — this is shared logic between dashboard admin onboarding and the Flutter farmer/vet registration flow.

## 4. Backend Architecture (FastAPI)

```
backend/
├── main.py                    # FastAPI app entry + router includes
├── auth/
│   ├── firebase_verify.py     # Verify Firebase ID token dependency
│   └── role_guard.py          # Role-based access control dependency (factory)
├── models/                    # All models import shared Base (models/base.py)
│   ├── base.py                # Shared SQLAlchemy DeclarativeBase
│   ├── user.py                # users table — profile + role
│   ├── farm.py                # farms table — owner, coords, status
│   ├── flock.py               # flocks table — bird type/count/vaccinations
│   ├── sensor_reading.py      # sensor_readings — aggregated history
│   ├── diagnosis.py           # diagnoses + model_inference_logs (analytics)
│   ├── outbreak_alert.py      # outbreak_alerts with PostGIS support
│   └── __init__.py            # Imports every model (Alembic autogenerate)
├── routers/
│   ├── admin/
│   │   ├── farms.py           # GET /admin/farms, /admin/farms/map (mock)
│   │   ├── analytics.py       # GET /admin/analytics/diagnoses, /model (real DB)
│   │   ├── sensors.py         # GET /admin/sensors/{farm_id}/history (real DB)
│   │   ├── users.py           # GET /admin/users, PATCH verify/deactivate
│   │   └── outbreaks.py       # GET /admin/outbreaks, /geofence, /nearby-farms
│   ├── farmer/                # Endpoints the Flutter app calls
│   ├── vet/
│   └── shared/
│       └── me.py              # GET /me — current user profile (role resolution)
├── scripts/
│   └── seed_demo.py           # Seeds admin, farms, flocks, sensor readings
├── services/
│   ├── firebase_rtdb_sync.py  # RTDB→Postgres aggregation job (scaffold/TODO)
│   ├── ml_inference.py        # MobileNetV2 (image) + Random Forest (future)
│   └── notification_service.py# FCM push + SMS gateway (future)
└── db/
    └── postgres.py            # SQLAlchemy engine + session factory
```

## 5. Sensor Data Workflow (RTDB → PostgreSQL)

The dashboard never reads the live sensor stream from RTDB for history charts.
A scheduled backend job owns the aggregation:

```
ESP32 sensors (DHT22/MQ135/MQ-2)
        │  MQTT
        ▼
Firebase Realtime DB  (raw, seconds-level stream: /sensors/{farm}/latest)
        │  services/firebase_rtdb_sync.py  (every 5–15 min, AGGREGATION_MINUTES buckets)
        ▼
PostgreSQL sensor_readings  (averaged temp/humidity/ammonia per farm per bucket)
        │  GET /api/v1/admin/sensors/{farm_id}/history?days=7|30
        ▼
React Dashboard → Recharts trend charts
```

- **Live status** (map pins green/yellow/red) → frontend `useRealtimeSensorsBatch(farmIds[])`
  subscribes ONCE to `/sensors` root in RTDB (debounced 400 ms, capped at 30 farms),
  derives each farm's status client-side.
- **Historical trends** (7/30-day charts) → `GET /admin/sensors/{farm_id}/history`
  reads the aggregated `sensor_readings` table.
- **`firebase_rtdb_sync.py`** is currently a scaffold: `run_once()` / `run_scheduled()`
  define the job's interface; the Firebase read + bucketing is a documented TODO.
- Until the sync job is implemented, `scripts/seed_demo.py` populates
  `sensor_readings` so the history endpoint returns real data locally.

## 6. API Endpoints (Admin Dashboard)

| Module | Backend endpoint(s) | Data source |
|---|---|---|
| Farm & sensor status overview | `GET /admin/farms` | PostgreSQL + RTDB live status |
| Live map (green/yellow/red status) | `GET /admin/farms/map` | PostgreSQL (farm coords) + RTDB (live status) |
| Vet credential verification | `PATCH /admin/users/{id}/verify` | PostgreSQL |
| Account deactivation | `PATCH /admin/users/{id}/deactivate` | PostgreSQL |
| User listing & search | `GET /admin/users` | PostgreSQL |
| Outbreak heatmap | `GET /admin/outbreaks` | PostgreSQL (PostGIS) |
| Diagnoses analytics | `GET /admin/analytics/diagnoses` | PostgreSQL |
| Model accuracy metrics | `GET /admin/analytics/model` | PostgreSQL (logged inference results) |
| Sensor history charts | `GET /admin/sensors/{farm_id}/history` | PostgreSQL (aggregated) |

### 6.1 User Management Workflow (Admin)

```
GET /api/v1/admin/users?role=vet&status=pending&search=ahmed
    │  Filters: role (vet/farmer/admin), status (verified/pending/active/inactive), search (name/email)
    ▼
PostgreSQL `users` table
    │  Returns: [{id, firebase_uid, role, name, email, is_verified, is_active, created_at, ...}]
    ▼
Frontend (UserManagement.jsx / VeterinaryVerification.jsx)
    │  Table with search, role filter, pagination
    ▼
Actions:
    │
    ├─► PATCH /admin/users/{id}/verify {is_verified: true|false}
    │       │  Requires: role == "vet", admin role
    │       ▼
    │   Updates users.is_verified + updated_at
    │
    └─► PATCH /admin/users/{id}/deactivate {is_active: true|false}
            │  Requires: admin role
            ▼
        Updates users.is_active + updated_at
```

### 6.2 Outbreak Heatmap Workflow (Admin)

```
GET /api/v1/admin/outbreaks?days=30&severity=high&disease=coccidiosis
    │  Filters: days (lookback), severity, disease
    ▼
PostgreSQL `outbreak_alerts` JOIN `farms` (location + farm name)
    │  Returns: [{id, farm_id, farm_name, disease, severity, lat, lng, radius_km, ...}]
    ▼
Frontend (OutbreakHeatmap.jsx)
    │  react-leaflet MapContainer + OSM tiles
    │  <Circle> radius=radius_km*1000 for each outbreak
    │  <Popup> with disease, severity, affected birds, date
    ▼
Actions:
    │
    ├─► GET /admin/outbreaks/geofence?lat=...&lng=...&radius_km=15
    │       │  PostGIS ST_DWithin (prod) / Haversine fallback (dev)
    │       ▼
    │   Returns outbreaks within radius for map filtering
    │
    └─► GET /admin/outbreaks/nearby-farms?outbreak_id=X&radius_km=15
            │  Same geofence logic, returns farms for notification
            ▼
        FCM push + SMS broadcast to nearby farmers (Section 6.8)
```

### 6.3 Model Analytics Workflow (Admin)

```
GET /api/v1/admin/analytics/diagnoses?days=7&disease=coccidiosis
    │  Filters: days (lookback), disease, farm_id
    ▼
PostgreSQL `diagnoses` table
    │  GROUP BY date, disease_type → COUNT(*)
    ▼
Frontend (ModelAnalytics.jsx) → BarChart: diagnoses by disease

GET /api/v1/admin/analytics/model?days=7
    │  Filters: days, disease
    ▼
PostgreSQL `model_inference_logs` table (WHERE is_correct IS NOT NULL)
    │  GROUP BY date, disease_type → accuracy = SUM(is_correct)/COUNT(*)
    ▼
Frontend (ModelAnalytics.jsx) → BarChart: accuracy over time + PieChart: inference distribution

GET /api/v1/admin/analytics/diagnoses/summary
GET /api/v1/admin/analytics/model/summary
    │  Aggregate totals for KPI cards and PieChart
    ▼
    Returns: [{disease_type, total, avg_confidence}] + [{disease, accuracy, total_inferences, correct_predictions, avg_confidence}]
```

## 7. Data Placement — PostgreSQL vs. Firebase Realtime DB

| Data | Store | Rationale |
|---|---|---|
| User identity (login) | Firebase Auth | Firebase owns credentials/tokens |
| User profile & role | PostgreSQL `users` | Needs joins with farms, diagnoses, roles |
| Farm & flock records | PostgreSQL | Relational; vaccination history, bird counts |
| Diagnosis history | PostgreSQL | Joins with farm, flock, vet consultation |
| **Live** sensor stream (seconds-level) | Firebase Realtime DB | ESP32 → MQTT → RTDB is built for this pattern |
| **Historical** sensor trends (7/30-day charts) | PostgreSQL | Backend job aggregates RTDB → Postgres every 5–15 min so dashboard queries don't hit RTDB directly |
| Outbreak alerts (15km geofencing) | PostgreSQL (PostGIS) | Geospatial radius queries are cleaner with PostGIS than app-level math |
| Reports (PDF exports) | Generated on-demand from PostgreSQL | Time-stamped, attributable to farm/flock |

## 8. Core Admin Dashboard Modules (maps to Section 6.14 of scope doc)

| Module | Backend endpoint(s) | Data source |
|---|---|---|
| Farm & sensor status overview | `GET /admin/farms` | PostgreSQL + RTDB live status |
| Live map (green/yellow/red status) | `GET /admin/farms/map` | PostgreSQL (farm coords) + RTDB (live status) |
| Vet credential verification | `PATCH /admin/users/{id}/verify` | PostgreSQL |
| Account deactivation | `PATCH /admin/users/{id}/deactivate` | PostgreSQL |
| Outbreak heatmap | `GET /admin/outbreaks` | PostgreSQL (PostGIS) |
| Diagnoses analytics | `GET /admin/analytics/diagnoses` | PostgreSQL |
| Model accuracy metrics | `GET /admin/analytics/model` | PostgreSQL (logged inference results) |
| Sensor history charts | `GET /admin/sensors/{farm_id}/history` | PostgreSQL (aggregated) |

## 9. Integration Checklist (for merge on teammate's PC)

- [ ] **Single Firebase project** — same `google-services.json` (Flutter) and Firebase Web config (React) so both apps share one user pool and one set of ID tokens.
- [ ] **Single FastAPI backend**, versioned (`/api/v1/...`) — no separate "admin API" vs "farmer API" services.
- [ ] **`.env`-driven config** on both sides — Firebase keys, PostgreSQL connection string, backend base URL, MQTT broker address — so switching machines/environments is a config swap, not a code change.
- [ ] **Shared OpenAPI schema** (auto-generated by FastAPI at `/docs` and `/openapi.json`) — the reference both the dashboard and Flutter app build their API calls against.
- [ ] **PostgreSQL migrations version-controlled** (Alembic recommended) so the schema is reproducible on the teammate's machine.
- [ ] **RTDB → PostgreSQL sync job** runs as a backend service, not duplicated per-client — both apps read *aggregated* history from PostgreSQL, only live/instant status from RTDB directly.

## 10. Tools & Technologies Summary

| Layer | Technology |
|---|---|
| Admin frontend | React.js, Tailwind CSS, Recharts, React Query |
| Mobile frontend (teammate) | Flutter (Dart) |
| Backend API | Python FastAPI |
| Authentication | Firebase Authentication (shared project) |
| Structured database | PostgreSQL (+ PostGIS for geofencing) |
| Live sensor database | Firebase Realtime Database |
| IoT transport | MQTT (ESP32 → Firebase bridge) |
| ML/AI | TensorFlow/Keras (MobileNetV2), TFLite, Scikit-learn (Random Forest) |
| Notifications | Firebase Cloud Messaging (push), GSM/SMS gateway |
