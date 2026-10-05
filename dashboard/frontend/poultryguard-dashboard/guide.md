# PoultryGuard Frontend — Local Testing Guide

Step-by-step instructions to run and test the React admin dashboard locally.

## Prerequisites

- Node.js 18+ (developed on v26)
- A terminal in the `frontend/poultryguard-dashboard/` folder

## 1. First-time setup (one time)

```powershell
# Install dependencies
npm install
```

## 2. Configure environment

```powershell
# Create .env from the template (already present in this repo)
Copy-Item ..\.env.example .env
```

Edit `.env`:

| Variable | Default | Notes |
|---|---|---|
| `VITE_FIREBASE_API_KEY` | placeholder | Real key from the Firebase Web app (same project as Flutter) |
| `VITE_FIREBASE_AUTH_DOMAIN` | placeholder | e.g. `your-project.firebaseapp.com` |
| `VITE_FIREBASE_PROJECT_ID` | placeholder | Firebase project id |
| `VITE_FIREBASE_DATABASE_URL` | placeholder | e.g. `https://your-project-default-rtdb.firebaseio.com` |
| `VITE_FIREBASE_APP_ID` | placeholder | Firebase web app id |
| `VITE_API_BASE_URL` | `http://localhost:8000/api/v1` | Backend base URL |

> With placeholder Firebase values the app loads and the login page renders, but
> real sign-in and live RTDB sensors won't work until real keys are in place.

## 3. Start the backend first

The dashboard fetches data from FastAPI. Start it in a second terminal (see
`backend/guide.md`), then seed data:

```powershell
# (in backend/)
.venv\Scripts\alembic upgrade head
.venv\Scripts\python scripts\seed_demo.py
.venv\Scripts\uvicorn main:app --reload
```

## 4. Start the dev server

```powershell
npm run dev
```

Vite prints the local URL, e.g. `http://localhost:5173/`. Open it in a browser.

## 5. What you should see

| Route | Expected |
|---|---|
| `/` | Redirects to `/login` (not authenticated) |
| `/login` | PoultryGuard sign-in form |
| `/overview` | Only after login — otherwise redirected to `/login` or `/unauthorized` |

### Test without Firebase login (dev shortcut)

Auth is required to enter the dashboard, but you can preview pages by
temporarily short-circuiting `ProtectedRoute`. Do **not** commit this change:

```js
// src/auth/ProtectedRoute.jsx — TEMPORARY local-only tweak
const { user, initializing } = useAuth()
if (initializing) return <LoadingScreen label="Checking session…" />
if (!user) return <Outlet />   // was: <Navigate to="/login" replace />
```

With that in place, `/overview` will render the KPI cards and call the backend.
The DashboardOverview will show an error + Retry if the backend isn't running.

## 6. Verify data integration

- **Backend running + seeded:** `/overview` shows KPI cards (Total Farms, Active
  Alerts, Diagnoses Today, Pending Vet Verifications) and a Recent Activity feed.
- **Farms Map (`/farms`):** with the dev-shortcut above, the map renders with
  OSM tiles and one `CircleMarker` per farm (fill = live status color). Click a
  marker to open a popup with farm name, readings, and a "View farm details →"
  link to `/farms/{id}`. Without real RTDB data every pin falls back to the
  stored farm status (legend shows "No live data" only when the DB status is
  missing too).
- **Live sensors:** with real RTDB data at `sensors/{farmId}/latest`,
  `useRealtimeSensors` returns temp/humidity/ammonia and a derived
  safe/warning/critical status → `FarmStatusBadge` renders the color pill.
- **Sensor history charts:** `GET /api/v1/admin/sensors/{farm_id}/history?days=7`
  (verify in the browser at `http://localhost:8000/api/v1/admin/sensors/1/history`
  — you'll get `401` without a token; that's expected).
- **Sensor Logs (`/sensors`):** with the dev-shortcut above and backend seeded,
  select a farm from the dropdown and choose 7 or 30 days. A Recharts line chart
  renders temperature (left axis), humidity + ammonia (right axis), with dashed
  warning and dotted critical reference lines per scope §5.1. Empty/loading/error
  states handled by TanStack Query.
- **Outbreak Heatmap (`/outbreaks`):** with the dev-shortcut, the map renders
  OSM tiles with 15km radius circles around each outbreak location. Color indicates
  severity (green=low, amber=medium, red=high/critical). Click circles for popup
  details. Legend panel shows counts per severity.
- **Model Analytics (`/model`):** with the dev-shortcut, shows BarChart for
  diagnoses by disease, BarChart for model accuracy by disease, PieChart for
  inference distribution, and summary cards with per-disease metrics.

> **Map offline:** the map uses OpenStreetMap tiles, so it needs internet to show
> the basemap. Markers still render on a gray background when offline.

## 7. Production build & lint

```powershell
npm run build        # type-checks + bundles (must pass before merging)
npm run lint         # oxlint
```

`npm run build` should finish with `✓ built in …s`. A "chunk larger than 500 kB"
warning is expected (Firebase/Recharts/Leaflet are heavy) and non-blocking.

## Common issues

| Symptom | Fix |
|---|---|
| `Firebase config incomplete: missing VITE_FIREBASE_*` | Copy `..\.env.example` → `.env` |
| Login fails `auth/invalid-api-key` | Real Firebase keys still needed in `.env` |
| Dashboard shows error + Retry | Backend not running — start uvicorn (step 3) |
| Redirected to `/unauthorized` | Role from `/me` isn't `admin` — check backend seed admin |
| Port 5173 already in use | Vite auto-picks 5174; or kill the stray process (`netstat -ano \| findstr :5173`) |
| Map shows gray background / no tiles | No internet — OSM tiles can't load; markers still appear |
| `Map container is already initialized` | react-leaflet v5 + React StrictMode double-mount in dev; usually harmless, refresh or bump react-leaflet |
