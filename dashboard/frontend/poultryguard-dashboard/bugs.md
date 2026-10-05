# bugs.md — Known errors & solutions

Short log of errors hit during development and how they were fixed.
Format: **Error → Cause → Fix**. Most recent first.

---

| Date | Error | Cause | Fix |
|---|---|---|---|
| 2026-08-08 | **`ReferenceError: cx is not defined` when `Skeleton` renders** | `Skeleton.jsx` called `cx()` (a `tailwind-merge` helper) but never imported it — the build passed because Rollup treats `cx` as a global, only failing at runtime | Replaced `cx(...)` with plain template-string concatenation and removed the now-unused `tailwind-merge` dependency |
| 2026-08-08 | **`Firebase config incomplete: missing VITE_FIREBASE_*`** thrown at app load | No `.env` file existed, so `import.meta.env` vars were `undefined`; `FirebaseConfig.js` fails loudly with this message | Copy `frontend/.env.example` → `frontend/poultryguard-dashboard/.env` and fill in values. Done for the scaffold. |
| 2026-08-08 | **Login fails with `auth/invalid-api-key`** | `.env` currently holds placeholder keys (`your_firebase_api_key`, etc.) until a real Firebase project is created | Replace the placeholder values in `.env` with real Firebase Web app config (same project as the Flutter app). App itself runs fine. |
| 2026-08-08 | **Vite dev server keeps port 5173 open after stopping** (Windows) | Killing the `npm run dev` parent doesn't kill the child `node`/`vite` process | Find the PID with `netstat -ano \| findstr :5173` and `Stop-Process -Id <pid> -Force`, or run Vite with `--strictPort` handling. |

## Notes

- **Missing backend:** `ProtectedRoute` fetches role from `GET /api/v1/me`. If the
  FastAPI backend isn't running, the role check errors and a signed-in user is
  redirected to `/unauthorized`. Start uvicorn (`uvicorn main:app --reload` in
  `backend/`) and confirm `/me` exists before testing the route guard.
- **Auth is UX-only:** the React `ProtectedRoute` is a convenience; the backend
  must enforce role checks (`require_role("admin")`) as the real security boundary.
- **Layout responsiveness:** the sidebar collapses on mobile and shows a backdrop.
  The top bar shows a compact user label on mobile and full info on desktop.
  Future work: add a footer and help modal.
- **DashboardOverview:** the KPI cards fetch from `/admin/farms`, `/admin/analytics/diagnoses`, and `/admin/users`. If the backend isn't running, the page shows an error with a retry button.
- **useRealtimeSensors / live status:** the hook subscribes to
  `sensors/{farmId}/latest` in Firebase RTDB. With placeholder Firebase keys it
  subscribes but receives no data (`status: 'unknown'`). Live status only works
  once real RTDB rules/keys are configured and the ESP32→MQTT bridge writes data.
  `deriveSensorStatus` uses scope-doc Section 5.1 thresholds
  (temp >32°C, NH3 >25 ppm, humidity >80% ⇒ critical).
- **Sensor history charts:** `getSensorHistory` hits
  `GET /admin/sensors/{farm_id}/history`. Backend must be running and the DB
  seeded (see `backend/guide.md` → `scripts/seed_demo.py`) or the endpoint
  returns an empty readings array.
- **FarmsMapView:** uses `react-leaflet` (OpenStreetMap tiles) — needs internet
  to load tiles. The map renders as gray with markers if offline. Popups read
  `farm.owner_name`; the backend mock doesn't include an owner, so it shows
  `—` until the mock is extended. `useRealtimeSensorsBatch` opens ONE listener on
  the `sensors` root (debounced 400 ms, capped at 30 farms) instead of N
  per-farm listeners — farms beyond the cap show `No live data`.
- **SensorLogsView:** Recharts line charts with dual Y-axes (temp left, hum/NH₃
  right). Reference lines use scope-doc §5.1 thresholds. The chart uses a
  single combined `<LineChart>` with multiple `<Line>` series to keep axes
  aligned; swapping to three separate charts would break the shared time axis.
  Empty/loading/error states handled via TanStack Query states.
- **react-leaflet + React StrictMode:** the map container is guarded by
  react-leaflet v5, but if you see `Map container is already initialized` in
  dev, it's the StrictMode double-mount — the fix is a version bump or removing
  `<StrictMode>` in `main.jsx` (not recommended).
- **UserManagement / VeterinaryVerification:** `axiosClient.patch` to
  `/admin/users/{id}/verify` or `/deactivate` requires `require_role("admin")`
  on backend. If the backend isn't seeded with an admin user, the endpoint
  returns `403`. Run `seed_demo.py` to create the admin user in PostgreSQL.
- **UserManagement pagination:** client-side pagination implemented with
  `ITEMS_PER_PAGE = 10`. Server-side filtering via query params (`role`,
  `search`) also works. The `totalPages` calculation uses the filtered array
  length, not the raw API response — safe because the API returns all users
  (mock) but will need server-side pagination when scaling beyond ~500 users.
- **VeterinaryVerification optimistic updates:** `queryClient.invalidateQueries`
  on mutation success refreshes the user list. The confirm dialog prevents
  accidental approve/reject. If the backend returns an error, the UI re-fetches
  and shows the true state — no stale optimistic data persists.
- **OutbreakHeatmap:** Uses `react-leaflet` with OpenStreetMap tiles — needs
  internet for basemap. Renders 15km radius circles (`<Circle radius={radius_km * 1000}>`)
  around each outbreak location with severity-based colors. Popups show disease,
  farm, birds affected, and date. PostGIS `ST_DWithin` on backend for geofencing;
  Haversine fallback for SQLite/dev. If no outbreaks, shows "No active outbreaks"
  placeholder.
- **ModelAnalytics:** Recharts BarChart (diagnoses by disease, accuracy by disease)
  and PieChart (inference distribution). Data from `/admin/analytics/diagnoses/summary`
  and `/admin/analytics/model/summary`. Summary cards show per-disease accuracy,
  total inferences, correct predictions, and avg confidence. If no data, shows
  "No data available" placeholder.
