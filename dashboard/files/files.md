# PoultryGuard — Codebase File Inventory & Functional Reference

This document details the exact purpose, exported symbols, and operational functions of every file across the PoultryGuard repository.

---

## 1. Directory Tree Overview

```
Poultry-Guard/Dashboard/
├── backend/
│   ├── .env                      # Backend local environment secrets & configuration
│   ├── .env.example              # Environment variables template
│   ├── .gitignore                # Git exclusion list for Python/virtualenv artifacts
│   ├── alembic.ini               # Alembic database migration tool configuration
│   ├── main.py                   # FastAPI application initialization & middleware setup
│   ├── requirements.txt          # Pinned Python package dependencies
│   ├── poultryguard.db           # SQLite local development database
│   │
│   ├── alembic/
│   │   ├── env.py                # Alembic runtime environment loader
│   │   └── versions/             # Database migration script versions
│   │       ├── be00a17305e1_initial_users_table.py
│   │       └── 76def4169d56_add_farm_flock_sensor_reading_tables.py
│   │
│   ├── auth/
│   │   ├── __init__.py           # Auth package marker
│   │   ├── firebase_verify.py    # Firebase ID Token verification & decoding
│   │   └── role_guard.py         # Role-Based Access Control (RBAC) dependency
│   │
│   ├── db/
│   │   ├── __init__.py           # DB package marker
│   │   └── postgres.py           # SQLAlchemy database engine & session dependency
│   │
│   ├── models/
│   │   ├── __init__.py           # Central entity exporter for Alembic & SQLAlchemy
│   │   ├── base.py               # Shared DeclarativeBase model class
│   │   ├── user.py               # User SQL model (admins, vets, farmers)
│   │   ├── farm.py               # Farm entity model (coordinates, license, owner)
│   │   ├── flock.py              # Flock batch model (species, count, zone)
│   │   ├── sensor_reading.py     # Aggregated IoT telemetry history model
│   │   ├── diagnosis.py          # AI diagnostic inference records model
│   │   └── outbreak_alert.py     # Outbreak zone & quarantine model
│   │
│   ├── routers/
│   │   ├── __init__.py           # Routers package marker
│   │   ├── admin/
│   │   │   ├── __init__.py
│   │   │   ├── analytics.py      # Diagnostic KPIs & model accuracy endpoints
│   │   │   ├── farms.py          # Farm registry, CRUD, and map endpoints
│   │   │   ├── outbreaks.py      # Outbreak detection & geofencing endpoints
│   │   │   ├── sensors.py        # Farm sensor history endpoints
│   │   │   └── users.py          # User management & vet verification endpoints
│   │   ├── farmer/
│   │   │   └── __init__.py       # Farmer-specific router module
│   │   ├── vet/
│   │   │   └── __init__.py       # Veterinary verification router module
│   │   └── shared/
│   │       ├── __init__.py
│   │       └── me.py             # Authenticated user profile (/api/v1/me)
│   │
│   ├── schemas/
│   │   ├── __init__.py           # Schemas package marker
│   │   ├── errors.py             # Standardized error response schemas
│   │   └── validation.py         # Pydantic v2 request/response validation schemas
│   │
│   ├── scripts/
│   │   └── seed_demo.py          # Database seeding script (admin user & demo farms)
│   │
│   └── services/
│       ├── __init__.py
│       └── firebase_rtdb_sync.py # Firebase Realtime Database telemetry sync service
│
├── frontend/poultryguard-dashboard/
│   ├── .env                      # Frontend environment variables (Firebase + Gemini)
│   ├── .gitignore                # Git exclusion list for Node/Vite build artifacts
│   ├── .oxlintrc.json            # Oxlint JavaScript linter configuration
│   ├── index.html                # Single Page Application HTML entrypoint
│   ├── package.json              # NPM dependencies and script commands
│   ├── package-lock.json         # Dependency tree version lockfile
│   ├── vite.config.js            # Vite build tool and dev server configuration
│   │
│   └── src/
│       ├── App.jsx               # Application route definitions & route guards
│       ├── main.jsx              # React DOM render root & React Query provider
│       ├── index.css             # Tailwind CSS v4 design system, colors & animations
│       │
│       ├── api/
│       │   ├── axiosClient.js    # Preconfigured Axios instance with auth interceptor
│       │   └── endpoints/
│       │       ├── diagnostics.js # Diagnostic inference API calls
│       │       ├── farms.js       # Farm list, details, and map API calls
│       │       ├── outbreaks.js   # Outbreak alert and geofence API calls
│       │       ├── sensors.js     # Sensor history telemetry API calls
│       │       └── users.js       # User list, role update, and vet approvals
│       │
│       ├── auth/
│       │   ├── AuthContext.jsx   # React Auth context & provider (login, signup, logout)
│       │   ├── FirebaseConfig.js # Firebase App & Auth SDK initialization
│       │   └── ProtectedRoute.jsx # Route protection component with role enforcement
│       │
│       ├── components/
│       │   ├── Card.jsx          # Reusable container card with header & footer slots
│       │   ├── DashboardLayout.jsx # Main shell with sidebar, topbar, and screen transitions
│       │   ├── ErrorBoundary.jsx # React error boundary component for catching crashes
│       │   ├── FarmStatusBadge.jsx # Status pill badge (safe, warning, critical)
│       │   ├── LoadingSkeleton.jsx # Full-page skeleton placeholder layouts
│       │   ├── Sidebar.jsx       # Left navigation drawer with active route highlighting
│       │   ├── Skeleton.jsx      # Atomic animated placeholder primitive
│       │   ├── Toast.jsx         # Non-blocking notification banner component
│       │   └── TopBar.jsx        # Top header with mobile menu trigger and user menu
│       │
│       ├── hooks/
│       │   ├── useRealtimeSensors.js # Hook for subscribing to live sensor streams
│       │   └── useToast.js       # Hook for dispatching notification toasts
│       │
│       ├── pages/
│       │   ├── AIDiseaseDetection.jsx # Gemini Vision poultry pathology diagnosis view
│       │   ├── Analytics.jsx     # High-level operational analytics dashboard
│       │   ├── DashboardOverview.jsx # Main KPI summary, alert overview, and recent activity
│       │   ├── FarmDetailPage.jsx # Individual farm deep-dive (flocks, sensors, map)
│       │   ├── FarmsMapView.jsx  # Interactive Leaflet map of all monitored farms
│       │   ├── FlocksView.jsx    # Flock inventory, batch ages, and mortality rates
│       │   ├── LoginPage.jsx     # Admin/user authentication with remember-me toggle
│       │   ├── ModelAnalytics.jsx # AI model accuracy, confusion matrices, and ROC metrics
│       │   ├── OutbreakHeatmap.jsx # Geospatial infection clusters and quarantine zones
│       │   ├── SensorLogsView.jsx # 7/30-day sensor charts & Gemini climate directives
│       │   ├── UnauthorizedPage.jsx # 403 Forbidden access denial screen
│       │   ├── UserManagement.jsx # User administration and role assignment table
│       │   └── VeterinaryVerification.jsx # DVM digital credential validation portal
│       │
│       └── services/
│           └── geminiService.js  # Live Google Gemini Multimodal Vision & Climate Service
│
└── files/
    ├── architecture.md           # System architecture, dataflows & diagrams
    ├── files.md                  # Comprehensive per-file functional breakdown
    └── guide.md                  # Complete local installation & run guide
```

---

## 2. Backend Files Detailed Specification

### `backend/main.py`
* **Purpose:** Core entrypoint for the FastAPI application.
* **Key Functions & Logic:**
  * Creates the FastAPI instance with API metadata and Swagger/OpenAPI endpoints (`/docs`, `/redoc`).
  * Registers `CORSMiddleware` with configurable allowed origins, methods, headers, and credential support to permit frontend communication on `http://localhost:5173`.
  * Mounts application routers under `/api/v1/`: `admin/farms`, `admin/sensors`, `admin/outbreaks`, `admin/analytics`, `admin/users`, and `shared/me`.
  * Defines root health-check endpoint `GET /` and `GET /health`.

### `backend/requirements.txt`
* **Purpose:** Python dependency manifest with pinned package versions.
* **Key Packages:** `fastapi`, `uvicorn`, `sqlalchemy`, `pydantic`, `alembic`, `firebase-admin`, `python-dotenv`, `psycopg2-binary`.

### `backend/.env` & `backend/.env.example`
* **Purpose:** Defines environment configurations and secrets for the backend.
* **Key Variables:**
  * `DATABASE_URL`: Connection string (`sqlite:///./poultryguard.db` or PostgreSQL URI).
  * `FIREBASE_PROJECT_ID`: Target Firebase project identifier.
  * `USE_SQLITE`: Boolean flag enabling local development SQLite database.
  * `GEMINI_API_KEY`: Google Gemini API key for server-side operations.

### `backend/auth/firebase_verify.py`
* **Purpose:** Extracts, verifies, and decodes Firebase JWT ID tokens from incoming HTTP `Authorization: Bearer <token>` headers.
* **Key Functions:**
  * `get_current_user()`: FastAPI dependency that decodes token claims, queries or provisions the database `User` record, and returns the authenticated user.
  * Implements development fallback token decoding when running offline without service account JSON credentials.

### `backend/auth/role_guard.py`
* **Purpose:** Role-Based Access Control (RBAC) authorization dependency.
* **Key Functions:**
  * `RoleGuard(allowed_roles)`: Callable dependency class that inspects `current_user.role`.
  * Raises `HTTPException(403, "Forbidden")` if user's role is not within the permitted whitelist (e.g., `["admin"]`).

### `backend/db/postgres.py`
* **Purpose:** Manages database connectivity, engine configuration, and session lifecycle.
* **Key Functions:**
  * `engine`: SQLAlchemy engine instance initialized from `DATABASE_URL`.
  * `SessionLocal`: Session factory with `autocommit=False, autoflush=False`.
  * `get_db()`: Generator dependency yielding a database session per request and closing it upon completion.

### `backend/models/base.py`
* **Purpose:** Defines the root declarative base class for all SQLAlchemy ORM models.
* **Key Symbols:** `Base = declarative_base()`.

### `backend/models/user.py`
* **Purpose:** Defines the `users` table schema in the database.
* **Attributes:** `id`, `firebase_uid`, `email`, `role` (`admin`, `vet`, `farmer`), `is_active`, `is_verified`, `created_at`, `updated_at`.

### `backend/models/farm.py`
* **Purpose:** Defines the `farms` table schema representing monitored agricultural facilities.
* **Attributes:** `id`, `name`, `owner_id`, `latitude`, `longitude`, `status` (`safe`, `warning`, `critical`), `address`, `created_at`. Relationships to `flocks` and `sensor_readings`.

### `backend/models/flock.py`
* **Purpose:** Defines the `flocks` table schema for bird populations within a farm.
* **Attributes:** `id`, `farm_id`, `breed`, `bird_count`, `placement_date`, `house_number`, `status`.

### `backend/models/sensor_reading.py`
* **Purpose:** Defines the `sensor_readings` table storing periodic environmental telemetry.
* **Attributes:** `id`, `farm_id`, `timestamp`, `temperature` (°C), `humidity` (%), `ammonia` (ppm), `smoke` (ppm).

### `backend/models/diagnosis.py`
* **Purpose:** Defines the `diagnoses` table logging AI computer vision and veterinary classifications.
* **Attributes:** `id`, `farm_id`, `flock_id`, `image_url`, `predicted_disease`, `confidence_score`, `severity`, `is_verified_by_vet`, `created_at`.

### `backend/models/outbreak_alert.py`
* **Purpose:** Defines the `outbreak_alerts` table tracking geospatial disease spread.
* **Attributes:** `id`, `disease_name`, `center_lat`, `center_lng`, `radius_km`, `severity`, `affected_farms_count`, `status`, `created_at`.

### `backend/models/__init__.py`
* **Purpose:** Central entity module importing all models so Alembic autogenerate discovers all metadata tables.

### `backend/routers/shared/me.py`
* **Purpose:** Provides user self-identification endpoint.
* **Endpoints:** `GET /api/v1/me` — returns authenticated profile, role, verification status, and farm association.

### `backend/routers/admin/farms.py`
* **Purpose:** Admin operations on farm entities.
* **Endpoints:**
  * `GET /api/v1/admin/farms`: List all farms with status, bird counts, and latest sensor metrics.
  * `GET /api/v1/admin/farms/map`: Lightweight endpoint returning farm coordinates and status for Leaflet map markers.
  * `GET /api/v1/admin/farms/{id}`: Detailed view of a single farm including flock batches and recent readings.

### `backend/routers/admin/sensors.py`
* **Purpose:** Historical telemetry queries for chart rendering.
* **Endpoints:**
  * `GET /api/v1/admin/sensors/{farm_id}/history`: Returns time-series temperature, humidity, and ammonia readings filtered by day range (7 or 30 days).

### `backend/routers/admin/analytics.py`
* **Purpose:** Provides aggregated analytical data for diagnostic trends and model accuracy.
* **Endpoints:**
  * `GET /api/v1/admin/analytics/diagnoses`: Aggregates diagnosis counts grouped by day and pathogen.
  * `GET /api/v1/admin/analytics/model`: Returns AI model performance metrics (accuracy, confusion matrix, precision, recall).

### `backend/routers/admin/users.py`
* **Purpose:** Administrative user control and credential verification.
* **Endpoints:**
  * `GET /api/v1/admin/users`: Lists registered system users.
  * `PATCH /api/v1/admin/users/{id}/verify`: Approves veterinary practitioner license credentials.
  * `PATCH /api/v1/admin/users/{id}/role`: Updates user access role.

### `backend/routers/admin/outbreaks.py`
* **Purpose:** Outbreak tracking, geofence radius calculations, and nearby farm alerts.
* **Endpoints:**
  * `GET /api/v1/admin/outbreaks`: Returns active quarantine zones and pathogen clusters.
  * `GET /api/v1/admin/outbreaks/nearby-farms`: Haversine calculation finding farms within an infection radius.

### `backend/schemas/validation.py`
* **Purpose:** Pydantic v2 schemas defining input validation and serialization contracts.
* **Key Schemas:** `UserResponse`, `FarmCreate`, `FarmResponse`, `SensorReadingSchema`, `DiagnosisResponse`, `OutbreakAlertSchema`.

### `backend/schemas/errors.py`
* **Purpose:** Standardized error models matching RFC 7807 problem details.
* **Key Schemas:** `ErrorResponse`, `ValidationErrorDetail`.

### `backend/scripts/seed_demo.py`
* **Purpose:** Automated database initialization script.
* **Actions:**
  * Creates all database tables using `Base.metadata.create_all()`.
  * Seeds the default administrator user (`admin@poultryguard.pk`).
  * Seeds representative poultry farms across Pakistan (Seed Farm 1, Seed Farm 2, Multan Valley Farm) with simulated flocks and 7 days of sensor readings.

### `backend/services/firebase_rtdb_sync.py`
* **Purpose:** Background worker skeleton for syncing IoT data from Firebase Realtime Database into the relational database.

---

## 3. Frontend Files Detailed Specification

### `frontend/poultryguard-dashboard/src/App.jsx`
* **Purpose:** Top-level React routing component.
* **Key Functions:**
  * Configures `react-router-dom` `Routes`.
  * Declares public routes (`/login`, `/unauthorized`).
  * Encloses protected application views within `ProtectedRoute` and `DashboardLayout`.
  * Directs paths (`/overview`, `/farms`, `/flocks`, `/ai-detection`, `/sensors`, `/outbreaks`, `/users`, `/analytics`, `/model`, `/vet`).

### `frontend/poultryguard-dashboard/src/main.jsx`
* **Purpose:** Client entrypoint that mounts React into `#root`.
* **Key Functions:**
  * Wraps application in `BrowserRouter`, `QueryClientProvider` (TanStack React Query), and `AuthProvider`.

### `frontend/poultryguard-dashboard/src/index.css`
* **Purpose:** Global styling, design system tokens, and CSS animations.
* **Key Styles:**
  * Official color variables (`--color-primary: #214E34`, `--color-sage: #E1EDE6`, `--color-alert-red: #D9534F`).
  * Micro-interaction tactile scale-down: `button:active:not(:disabled) { transform: scale(0.97); }`.
  * Route slide-and-fade animation (`.screen-enter`).
  * AI scanning laser beam animation (`.laser-scanner`).
  * Radar pulsing circle animation (`.radar-pulse`).

### `frontend/poultryguard-dashboard/src/services/geminiService.js`
* **Purpose:** Live Google Gemini Multimodal Vision and Text API client.
* **Key Functions:**
  * `optimizeImage(fileOrUrl, maxWidth=1024, quality=0.8)`: Uses HTML5 canvas to downscale and compress images to JPEG base64 before upload, saving network bandwidth.
  * `diagnosePoultryImage(imageFile, symptoms, onProgress)`: Sends image base64 and avian vet pathology system prompt to candidate Gemini models (`gemini-flash-latest`, `gemini-2.5-flash-lite`), parsing output into structured diagnostic JSON (`predicted_disease`, `confidence_score`, `description`, `recommended_steps`).
  * `generateSensorAdvice(telemetry)`: Evaluates temperature, humidity, ammonia, and smoke telemetry using Gemini to produce operational fan directives, cooling actions, and operator checklists.
  * `callGeminiWithRetry(endpoint, payload, maxRetries=2)`: Wraps requests in a 15-second `AbortController` timeout with exponential backoff retry cycles.

### `frontend/poultryguard-dashboard/src/pages/AIDiseaseDetection.jsx`
* **Purpose:** Live avian pathogen diagnosis view.
* **Key Features:**
  * File upload or live camera capture input with instant preview.
  * 3 one-click high-confidence field presets (Coccidiosis, Newcastle Disease, Healthy Flock).
  * Optional symptoms context text input.
  * Laser scanning beam (`.laser-scanner`) and radar pulse animation during inference.
  * Polished skeleton loader preview.
  * Renders disease classification, confidence progress bar, pathology description, and interactive action checklist with toggleable checkboxes.
  * Expandable accordions for differential diagnosis and biosecurity protocols.
  * Prominent **Medical & AI Diagnostic Disclaimer** styled in Alert Red (`#D9534F`).

### `frontend/poultryguard-dashboard/src/pages/SensorLogsView.jsx`
* **Purpose:** Environmental climate monitoring and AI edge control dashboard.
* **Key Features:**
  * Farm selector and timeframe dropdown (7 days vs. 30 days).
  * **Smart Sensor & Edge Control Insights:** Powered by live Gemini API, analyzing house telemetry to output executive summaries, ventilation exhaust fan speeds, and cooling mist directives.
  * Interactive operator checklist with checkmark toggles.
  * Recharts dual Y-axis graph plotting Temperature, Humidity, and Ammonia against warning and critical safety thresholds.

### `frontend/poultryguard-dashboard/src/pages/DashboardOverview.jsx`
* **Purpose:** Executive operational dashboard.
* **Key Features:**
  * KPI summary cards (Total Farms, Active Alerts, AI Diagnoses Today, Pending Vet Approvals).
  * Outbreak status distribution and recent critical event feed.
  * Direct action shortcuts to AI Detection and Farm Telemetry views.

### `frontend/poultryguard-dashboard/src/pages/FarmsMapView.jsx`
* **Purpose:** Geospatial GIS surveillance view.
* **Key Features:**
  * Interactive Leaflet map centering on registered commercial poultry farms.
  * Color-coded status markers (green for safe, amber for warning, red for critical).
  * Popups displaying farm name, bird inventory, and quick link to farm detail.

### `frontend/poultryguard-dashboard/src/pages/FarmDetailPage.jsx`
* **Purpose:** Granular inspection view for a single farm.
* **Key Features:**
  * Displays farm metadata, license number, and coordinates.
  * Lists active flocks, house numbers, batch ages, and bird mortality rates.
  * Shows real-time sensor gauges for the selected facility.

### `frontend/poultryguard-dashboard/src/pages/FlocksView.jsx`
* **Purpose:** Flock batch management and health tracking.
* **Key Features:**
  * Tabular display of bird batches across all farms.
  * Filters by breed, health status, and house location.

### `frontend/poultryguard-dashboard/src/pages/LoginPage.jsx`
* **Purpose:** Authentication gateway for administrators and farm managers.
* **Key Features:**
  * Email and password sign-in / registration toggle.
  * Password visibility eye toggle (`Eye`/`EyeOff`).
  * Interactive **Remember me** checkbox toggle with custom animated SVG checkmark.
  * Primary submit button styled in Dark Green (`#214E34`) with active scale-down feedback.
  * Error alerts rendered in Alert Red (`#D9534F`).

### `frontend/poultryguard-dashboard/src/pages/OutbreakHeatmap.jsx`
* **Purpose:** Epidemic quarantine and geospatial buffer analysis.
* **Key Features:**
  * Renders infection epicenters with dynamic radial quarantine zones (3km, 5km, 10km rings).
  * Highlights at-risk adjacent farms requiring preventive vaccination or quarantine.

### `frontend/poultryguard-dashboard/src/pages/UserManagement.jsx`
* **Purpose:** Administrator control panel for managing user accounts and roles (`admin`, `vet`, `farmer`).

### `frontend/poultryguard-dashboard/src/pages/VeterinaryVerification.jsx`
* **Purpose:** Veterinary practitioner accreditation workflow where administrators verify DVM credentials and PMDC license numbers.

### `frontend/poultryguard-dashboard/src/pages/ModelAnalytics.jsx`
* **Purpose:** Machine learning evaluation metrics view (accuracy graphs, confusion matrix, false-positive rates for avian diseases).

### `frontend/poultryguard-dashboard/src/pages/Analytics.jsx`
* **Purpose:** Aggregate farm productivity, mortality rates, and seasonal disease distribution charts.

### `frontend/poultryguard-dashboard/src/pages/UnauthorizedPage.jsx`
* **Purpose:** 403 Forbidden page displayed when an authenticated user attempts to access a route restricted to a higher role.

### `frontend/poultryguard-dashboard/src/components/DashboardLayout.jsx`
* **Purpose:** Core shell wrapping all authenticated pages.
* **Key Features:**
  * Responsive sidebar with mobile slide-over drawer state.
  * Fixed desktop left offset (`lg:pl-64`).
  * Top navigation header with notifications and user profile menu.
  * Keyed `<main key={location.pathname} className="screen-enter ...">` ensuring smooth slide/fade screen transitions between route changes.

### `frontend/poultryguard-dashboard/src/components/Sidebar.jsx`
* **Purpose:** Primary navigation drawer.
* **Key Features:**
  * Displays brand logo with shield icon.
  * Lists navigation items with active path styling in `#214E34` and `#E1EDE6`.
  * Mobile backdrop blur and slide-out dismissal.

### `frontend/poultryguard-dashboard/src/components/TopBar.jsx`
* **Purpose:** Top header bar.
* **Key Features:**
  * Mobile hamburger menu button.
  * Real-time breadcrumb trail indicator.
  * Notifications dropdown trigger.
  * User profile avatar and sign-out button.

### `frontend/poultryguard-dashboard/src/components/Card.jsx`
* **Purpose:** Standard card container adhering to the PoultryGuard design system (`#FFFFFF` background, `#E1EDE6` border, rounded corners, optional header/footer slots).

### `frontend/poultryguard-dashboard/src/components/FarmStatusBadge.jsx`
* **Purpose:** Reusable pill badge mapping status (`safe`, `warning`, `critical`) to official theme colors.

### `frontend/poultryguard-dashboard/src/components/Skeleton.jsx` & `LoadingSkeleton.jsx`
* **Purpose:** Pulsing placeholder components for skeleton loading states.

### `frontend/poultryguard-dashboard/src/auth/AuthContext.jsx`
* **Purpose:** Central React context providing `user`, `login(email, password)`, `signup(email, password)`, `logout()`, and auth token getters to the component tree.

### `frontend/poultryguard-dashboard/src/auth/FirebaseConfig.js`
* **Purpose:** Initializes the Firebase Web SDK (`initializeApp`, `getAuth`) using configuration credentials from environment variables.

### `frontend/poultryguard-dashboard/src/auth/ProtectedRoute.jsx`
* **Purpose:** Navigation guard verifying user authentication and RBAC roles before rendering nested routes; redirects unauthenticated visitors to `/login`.

### `frontend/poultryguard-dashboard/src/api/axiosClient.js`
* **Purpose:** Configured Axios HTTP client instance with automatic JWT Bearer token attachment via request interceptors.

### `frontend/poultryguard-dashboard/src/api/endpoints/`
* **`farms.js`**: `listFarms()`, `getFarmMap()`, `getFarm(id)`, `getSensorHistory(farmId, params)`.
* **`diagnostics.js`**: `getDiagnosesAnalytics()`, `submitDiagnosis(payload)`.
* **`users.js`**: `listUsers()`, `verifyUser(id)`, `updateUserRole(id, role)`.
* **`outbreaks.js`**: `listOutbreaks()`, `getNearbyFarms(params)`.
* **`sensors.js`**: `getSensorLogs(params)`.

### `frontend/poultryguard-dashboard/src/hooks/useRealtimeSensors.js`
* **Purpose:** Custom React hook for connecting to real-time sensor streams and managing interval polling.

### `frontend/poultryguard-dashboard/src/hooks/useToast.js` & `Toast.jsx`
* **Purpose:** Lightweight custom notification toast system.
