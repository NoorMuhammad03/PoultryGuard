# files.md — PoultryGuard frontend file map

One-line function per file (≈7–8 words) with the folder architecture.

```
frontend/poultryguard-dashboard/
│
├── .env                      # Local Firebase + API secrets (git-ignored)
├── .env.example              # Template of env vars to copy
├── .gitignore                # Excludes node_modules, dist, .env
├── .oxlintrc.json            # Oxlint lint configuration file
├── index.html                # Vite HTML entry, mounts root div
├── package.json              # Scripts and dependency manifest
├── package-lock.json         # Pinned dependency versions lockfile
├── README.md                 # Vite scaffold readme (default)
├── vite.config.js            # Vite plugins: React, Tailwind
├── public/
│   ├── favicon.svg           # Browser tab favicon asset
│   └── icons.svg             # Vite demo icon sprite
│
└── src/
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
    │   ├── UnauthorizedPage.jsx  # 403 view for non-admin users
    │   ├── DashboardOverview.jsx # KPI cards + recent activity feed
    │   ├── FarmsMapView.jsx      # react-leaflet map, live-status markers
    │   ├── FarmDetailPage.jsx    # Placeholder farm detail (per-farm route)
    │   ├── SensorLogsView.jsx    # Farm selector + Recharts sensor trends
    │   ├── VeterinaryVerification.jsx # Pending vets table, approve/reject
    │   ├── OutbreakHeatmap.jsx   # Geographic outbreak view
    │   ├── UserManagement.jsx    # Searchable user table, deactivate toggle
    │   ├── Analytics.jsx         # Diagnosis + model accuracy charts
    │   └── ModelAnalytics.jsx    # Model accuracy bar/pie charts
    │
    ├── components/
    │   ├── Card.jsx             # Reusable card container component
    │   ├── Skeleton.jsx         # Loading skeleton component
    │   ├── FarmStatusBadge.jsx  # Colored safe/warning/critical badge
    │   ├── Sidebar.jsx           # Collapsible persistent navigation
    │   ├── TopBar.jsx            # Top header with user info/logout
    │   ├── DashboardLayout.jsx   # Layout wrapper for protected routes
    │   ├── charts/               # Recharts trend chart components
    │   └── (shared UI)           # Reusable UI components (future)
    │
    └── hooks/
        ├── useRealtimeSensors.js # Live RTDB hook + batched multi-farm variant
        ├── Feedback.js           # Toast notification system
        └── (custom hooks)        # usePostgresData (future)
```

> `src/api/endpoints/`, `src/components/charts/` are scaffolded empty folders
> (kept via `.gitkeep`) ready for the modules named in
> `PoultryGuard_Dashboard_Architecture.md`.