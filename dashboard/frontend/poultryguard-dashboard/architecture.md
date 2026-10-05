# PoultryGuard Frontend Architecture

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

## 4. Frontend Architecture (React.js)

```
src/
├── main.jsx              # App entry — providers, root render
├── App.jsx               # Route table for all pages
├── index.css             # Tailwind v4 + Leaflet global styles
│
├── auth/
│   ├── FirebaseConfig.js # Firebase init from Vite env vars
│   ├── AuthContext.jsx   # Auth provider — user, login, logout
│   └── ProtectedRoute.jsx# Gate routes to authenticated admins
│
├── api/
│   ├── axiosClient.js    # Axios with request + logout-on-401 interceptors
│   └── endpoints/
│       ├── farms.js      # GET farms, GET map, GET sensor history
│       ├── users.js      # GET users, PATCH verify, PATCH deactivate
│       ├── diagnoses.js  # GET diagnoses analytics
│       ├── outbreaks.js  # GET outbreak heatmap
│       └── sensors.js    # GET model accuracy metrics
│
├── pages/
│   ├── LoginPage.jsx         # Admin email/password sign-in form
│   ├── FarmDetailPage.jsx    # Placeholder farm detail (per-farm route)
    │   ├── UnauthorizedPage.jsx  # 403 view for non-admin users
│   ├── DashboardOverview.jsx # KPI cards + recent activity feed
│   ├── FarmsMapView.jsx      # react-leaflet map, live-status markers
│   ├── VeterinaryVerification.jsx # Vet approval/deactivation UI
│   ├── OutbreakHeatmap.jsx   # Geographic outbreak view
│   ├── UserManagement.jsx    # Admin user list with actions
│   └── Analytics.jsx         # Diagnosis + model accuracy charts
│
├── components/
│   ├── Card.jsx             # Reusable card container component
│   ├── Skeleton.jsx         # Loading skeleton component
│   ├── FarmStatusBadge.jsx  # Colored safe/warning/critical badge
│   ├── Sidebar.jsx           # Collapsible persistent navigation
│   ├── TopBar.jsx            # Top header with user info/logout
│   ├── DashboardLayout.jsx   # Layout wrapper for protected routes
│   └── charts/               # Recharts trend chart components
│
└── hooks/
    ├── useRealtimeSensors.js # Live RTDB hook + batched multi-farm variant
    ├── Feedback.js           # Toast notification system
    └── (custom hooks)        # usePostgresData (future)
```

## 5. Live Sensor Data Flow (frontend)

The dashboard needs two complementary views of sensor data:

```
Live status (map pins, badge):
  Firebase RTDB /sensors/{farmId}/latest
        │  useRealtimeSensors(farmId)          — single farm (detail page)
        │  useRealtimeSensorsBatch(farmIds)    — N farms, ONE listener (map)
        │      · subscribes to the `sensors` root once
        │      · derives each farm's { temp, humidity, ammonia } client-side
        │      · trailing-debounced (400 ms) → bursts coalesce into one render
        │      · capped at maxSubscriptions (30) → extra farms report unknown
        ▼
  { temperature, humidity, ammonia } + deriveSensorStatus()
        │   thresholds: temp>32°C | NH3>25ppm | RH>80% ⇒ critical
        ▼
  marker color / FarmStatusBadge(status) → green / yellow / red pill
        └─ FarmsMapView: CircleMarker fill color = live status
           (falls back to farm.status from the DB while RTDB is empty)

Historical trends (7/30-day charts):
  GET /api/v1/admin/sensors/{farm_id}/history?days=7|30
        │  TanStack Query via api/endpoints/farms.js getSensorHistory
        ▼
  Recharts line chart (temperature / humidity / ammonia)

SensorLogsView:
  1. listFarms()  ──► farm selector dropdown
  2. user picks farm + 7/30-day window
  3. getSensorHistory(farmId, { days })  ──► TanStack Query
  4. LineChart with:
     - shared time axis (X)
     - dual Y-axes: temp (left) / hum & NH₃ (right)
     - ReferenceLine for warning/critical thresholds (scope §5.1)
```

- `useRealtimeSensors(farmId)` subscribes to `sensors/{farmId}/latest` (path
  overridable), normalizes field aliases (`temp`/`t`, `nh3`, …), and derives
  `status` via `deriveSensorStatus` using scope-doc Section 5.1 thresholds.
- `useRealtimeSensorsBatch(farmIds)` opens ONE listener on the `sensors` root
  and fans out to N farms — avoids N WebSocket listeners on the map. Updates are
  trailing-debounced (default 400 ms) and subscriptions capped at 30 farms.
- `FarmStatusBadge` is a pure presentational component driven by `status`
  (`safe` | `warning` | `critical` | `unknown`).

### FarmsMapView (react-leaflet)

```
listFarms()  ──►  farms[]  { id, name, location:{lat,lng}, status, … }
                       │
                       └─► farmIds ──► useRealtimeSensorsBatch(farmIds)
                                          │  live status per farm
                                          ▼
   resolved farm = { ...farm, status: liveStatus || farm.status }
                                          │
                                          ▼
   MapContainer ─► TileLayer (OSM) ─► FitBounds(positions)
                   └─ CircleMarker per farm, fill = STATUS_COLORS[status]
                      └─ Popup: name, id, owner, live readings, FarmStatusBadge,
                                 Link → /farms/{id}  (FarmDetailPage)
   Overlay: Legend (Safe / Warning / Critical / No live data)
```

- Marker color resolves live RTDB status first; when RTDB has no data yet the
  stored `farm.status` is used so the map still shows a meaningful color.
- Popups link to `/farms/{farm.id}` → `FarmDetailPage` (placeholder today).

### SensorLogsView (Recharts)

```
listFarms()  ──► farms[]  ──► farm selector dropdown
                       │
                       └─► user picks farm + 7/30-day window
                       │
                       └─► getSensorHistory(farmId, { days })
                                          │
                                          ▼
                    LineChart (Recharts) with dual Y-axes:
                      X = time, Y-left = temp, Y-right = hum + NH₃
                      <Line> for temp/hum/NH₃
                      <ReferenceLine> for warning/critical thresholds
```

- Dual Y-axes keep temperature on the left and humidity/ammonia on the right,
  sharing the same time axis for easy visual correlation.
- Threshold reference lines (warning: dashed, critical: dotted) use scope-doc
  §5.1 values: temp 30/32°C, humidity 70/80%, ammonia 20/25 ppm.
- Empty/loading/error states handled via TanStack Query's `isLoading`,
  `isError`, and empty-data checks.

### VeterinaryVerification (Admin)

```
GET /api/v1/admin/users  ──► users[]  ──► filter role=vet, is_verified=false
                                          │
                                          ▼
                        Table of pending vets with Approve/Reject
                                          │
                                          ├─► PATCH /admin/users/{id}/verify {is_verified: true}
                                          └─► PATCH /admin/users/{id}/verify {is_verified: false}
```

- Optimistic UI: `useMutation` invalidates `['users']` query on success.
- Confirmation dialog before each action prevents accidental clicks.
- Badge shows "Pending review" until admin action.

### UserManagement (Admin)

```
GET /api/v1/admin/users?role=farmer&search=ali
    │  Filters: role (vet/farmer/admin), status, search (name/email)
    ▼
users[]  ──► paginated table (10 per page) with search + role filter
    │
    ├─► Pending vet → Verify button (PATCH /admin/users/{id}/verify)
    ├─► Active user → Deactivate button (PATCH /admin/users/{id}/deactivate {is_active: false})
    └─► Inactive user → Reactivate button (PATCH /admin/users/{id}/deactivate {is_active: true})
```

- Server-side filtering via query params (`role`, `search`) reduces payload.
- Client-side search also available for instant feedback.
- Confirmation dialog for deactivate/reactivate actions.
- Role badges (admin=purple, vet=blue, farmer=green) for quick scanning.
- Status badges: Active (green), Pending (amber), Inactive (red).

### OutbreakHeatmap (Admin)

```
GET /api/v1/admin/outbreaks?days=30
    │  Filters: days, severity, disease
    ▼
outbreaks[]  ──► react-leaflet MapContainer + OSM tiles
    │
    ├─► <Circle> for each outbreak: center=[lat,lng], radius=radius_km*1000
    │     color = severity (green/amber/red), fillOpacity=0.15
    │     <Popup> with disease, farm, severity, birds affected, date
    └─► Legend panel: severity counts (low/medium/high/critical)
```

- PostGIS ST_DWithin on backend for geofencing (falls back to Haversine in dev).
- 15km radius circles match scope-doc Section 6.8 community notification.
- Click any circle to see details; map auto-centers on first outbreak.

### ModelAnalytics (Admin)

```
GET /api/v1/admin/analytics/diagnoses/summary
    │  → BarChart: diagnoses by disease (coccidiosis, newcastle, salmonellosis)
    ▼
GET /api/v1/admin/analytics/model/summary
    │  → BarChart: accuracy by disease
    │  → PieChart: inference distribution
    │  → Summary cards: accuracy %, total inferences, correct, avg confidence
    ▼
GET /api/v1/admin/analytics/diagnoses?days=7
GET /api/v1/admin/analytics/model?days=7
    │  → Time-series charts (future: trend lines over 7/30 days)
```

- Recharts BarChart, PieChart with consistent color palette.
- Summary cards show per-disease accuracy + inference counts.
- Data from `diagnoses` and `model_inference_logs` tables.

## 6. Key Libraries

| Purpose | Library |
|---|---|
| Styling | Tailwind CSS |
| Charts | Recharts |
| Auth state | `react-firebase-hooks` |
| Data fetching/caching | TanStack Query (React Query) |
| Maps (outbreak radius, farm pins) | Leaflet or Google Maps React |

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

## 8. Integration Checklist (for merge on teammate's PC)

- [ ] **Single Firebase project** — same `google-services.json` (Flutter) and Firebase Web config (React) so both apps share one user pool and one set of ID tokens.
- [ ] **Single FastAPI backend**, versioned (`/api/v1/...`) — no separate "admin API" vs "farmer API" services.
- [ ] **`.env`-driven config** on both sides — Firebase keys, PostgreSQL connection string, backend base URL, MQTT broker address — so switching machines/environments is a config swap, not a code change.
- [ ] **Shared OpenAPI schema** (auto-generated by FastAPI at `/docs` and `/openapi.json`) — the reference both the dashboard and Flutter app build their API calls against.
- [ ] **PostgreSQL migrations version-controlled** (Alembic recommended) so the schema is reproducible on the teammate's machine.
- [ ] **RTDB → PostgreSQL sync job** runs as a backend service, not duplicated per-client — both apps read *aggregated* history from PostgreSQL, only live/instant status from RTDB directly.

## 8. Tools & Technologies Summary

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
