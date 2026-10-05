# PoultryGuard — Admin Web Dashboard Architecture

**Component:** React.js Admin Web Dashboard
**Stack:** React.js + Tailwind CSS · Firebase Authentication · FastAPI · PostgreSQL · Firebase Realtime DB
**Related components:** Flutter Farmer/Vet App (built by teammate, final integration on teammate's PC), ESP32 IoT layer

---

## 1. Design Principles

1. **Firebase = identity, PostgreSQL = system of record.** Firebase Authentication issues ID tokens and manages login. PostgreSQL owns all structured business data (users, farms, flocks, diagnoses, outbreaks, reports).
2. **One shared backend.** Both the React dashboard and the teammate's Flutter app talk to the *same* FastAPI service and the *same* Firebase project. No forked logic, no duplicate auth systems — this is what makes integration on his machine a config change, not a merge conflict.
3. **Live data vs. historical data are split.** Raw, high-frequency ESP32 sensor streams live in Firebase Realtime DB. Aggregated/historical data used for dashboard charts and reports lives in PostgreSQL.
4. **Server-side authorization, always.** Role checks (`farmer` / `vet` / `admin`) are enforced in FastAPI on every request — the React route guard is a UX convenience, not a security boundary.

---

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
   └───────────────────────────┬─────────────────────────────┘
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

---

## 3. Authentication & Authorization Flow

**Login sequence (dashboard):**

1. Admin enters credentials → Firebase Web SDK authenticates → returns Firebase ID token (JWT).
2. React stores the token in memory (via `AuthContext`), attaches it as `Authorization: Bearer <token>` on every API call.
3. FastAPI dependency `verify_firebase_token` validates the token using the `firebase-admin` SDK on every incoming request.
4. Backend looks up `firebase_uid` in PostgreSQL `users` table to resolve `role`.
5. Route-level dependency `require_role("admin")` rejects the request (`403`) if the resolved role isn't `admin`.

**First-time login / registration completion:**

- If no PostgreSQL row exists for a `firebase_uid`, the backend creates one and returns a "complete your profile" flag — this is shared logic between dashboard admin onboarding and the Flutter farmer/vet registration flow.

**Why this matters for integration:** Since Flutter and React both authenticate against the *same* Firebase project and the *same* FastAPI role logic, your teammate doesn't need to reimplement auth — he just needs the same Firebase config values and the same base API URL.

```
users (PostgreSQL)
├── id                PK
├── firebase_uid       unique, indexed
├── role                enum: farmer | vet | admin
├── name, phone, email
├── language_pref       enum: en | ur
├── is_active            boolean
├── created_at
```

---

## 4. Admin Dashboard — Frontend Architecture (React.js)

```
src/
├── auth/
│   ├── FirebaseConfig.js       # Firebase init — SAME config values as Flutter app
│   ├── AuthContext.jsx         # holds current user, role, token refresh
│   └── ProtectedRoute.jsx      # redirects non-admins
│
├── api/
│   ├── axiosClient.js          # attaches Firebase ID token to every request
│   └── endpoints/
│       ├── farms.js
│       ├── users.js
│       ├── diagnoses.js
│       ├── outbreaks.js
│       └── sensors.js
│
├── pages/
│   ├── LoginPage.jsx
│   ├── DashboardOverview.jsx    # KPI cards: total farms, active alerts, diagnoses today
│   ├── FarmsMapView.jsx         # live map, farm status pins (green/yellow/red)
│   ├── VetVerification.jsx      # approve/reject vet registrations & license checks
│   ├── OutbreakHeatmap.jsx      # geographic outbreak tracking, 15km radius overlays
│   ├── SensorLogsView.jsx       # per-farm historical sensor trend charts
│   ├── UserManagement.jsx       # view/deactivate farmer & vet accounts
│   └── ModelAnalytics.jsx       # AI accuracy metrics, diagnosis counts by disease type
│
├── components/
│   ├── charts/                  # Recharts — temp / humidity / ammonia trend lines
│   ├── FarmStatusBadge.jsx
│   └── DataTable.jsx
│
└── hooks/
    ├── useRealtimeSensors.js    # subscribes directly to Firebase RTDB for live status
    └── usePostgresData.js       # React Query wrapper around FastAPI calls
```

**Key libraries:**

| Purpose | Library |
|---|---|
| Styling | Tailwind CSS |
| Charts | Recharts |
| Auth state | `react-firebase-hooks` |
| Data fetching/caching | TanStack Query (React Query) |
| Maps (outbreak radius, farm pins) | Leaflet or Google Maps React |

---

## 5. Backend Architecture (FastAPI — shared by dashboard & Flutter app)

```
backend/
├── main.py
│
├── auth/
│   ├── firebase_verify.py       # dependency: verifies token, returns user object
│   └── role_guard.py            # require_role("admin" | "vet" | "farmer")
│
├── models/                      # SQLAlchemy ORM models
│   ├── user.py
│   ├── farm.py
│   ├── flock.py
│   ├── diagnosis.py
│   ├── sensor_reading.py        # aggregated/historical only — raw stream stays in RTDB
│   ├── outbreak_alert.py
│   └── vet_consultation.py
│
├── routers/
│   ├── admin/
│   │   ├── farms.py             # GET /admin/farms — all farms, dashboard view
│   │   ├── users.py             # verify vets, deactivate accounts
│   │   ├── outbreaks.py         # outbreak heatmap data
│   │   └── analytics.py         # model accuracy, diagnosis counts
│   ├── farmer/                  # endpoints the Flutter app calls
│   ├── vet/
│   └── shared/                  # diagnosis submission, sensor sync, shared reads
│
├── services/
│   ├── firebase_rtdb_sync.py    # pulls raw sensor stream, aggregates into PostgreSQL
│   ├── ml_inference.py          # MobileNetV2 (image) + Random Forest (risk forecast)
│   └── notification_service.py  # FCM push + SMS gateway triggers
│
└── db/
    └── postgres.py
```

API is versioned (`/api/v1/...`) so both frontends stay in sync against one contract, and FastAPI's auto-generated OpenAPI schema doubles as the integration reference for the Flutter side.

---

## 6. Data Placement — PostgreSQL vs. Firebase Realtime DB

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

---

## 7. Core Admin Dashboard Modules (maps to Section 6.14 of scope doc)

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

---

## 8. Integration Checklist (for merge on teammate's PC)

- [ ] **Single Firebase project** — same `google-services.json` (Flutter) and Firebase Web config (React) so both apps share one user pool and one set of ID tokens.
- [ ] **Single FastAPI backend**, versioned (`/api/v1/...`) — no separate "admin API" vs "farmer API" services.
- [ ] **`.env`-driven config** on both sides — Firebase keys, PostgreSQL connection string, backend base URL, MQTT broker address — so switching machines/environments is a config swap, not a code change.
- [ ] **Shared OpenAPI schema** (auto-generated by FastAPI at `/docs` and `/openapi.json`) — the reference both the dashboard and Flutter app build their API calls against.
- [ ] **PostgreSQL migrations version-controlled** (Alembic recommended) so the schema is reproducible on the teammate's machine.
- [ ] **RTDB → PostgreSQL sync job** runs as a backend service, not duplicated per-client — both apps read *aggregated* history from PostgreSQL, only live/instant status from RTDB directly.

---

## 9. Tools & Technologies Summary

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
