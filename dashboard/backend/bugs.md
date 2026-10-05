# bugs.md — Known errors & solutions

Short log of errors hit during development and how they were fixed.
Format: **Error → Cause → Fix**. Most recent first.

---

| Date | Error | Cause | Fix |
|---|---|---|---|
| 2026-08-08 | **`TypeError: <coroutine object require_role ...> is not a callable object`** when registering an admin route | `require_role` was defined as a single `async def` that both takes `*roles` and reads FastAPI `Depends()` defaults — FastAPI can't use a function with required positional `*roles` as a dependency, so `Depends(require_role(UserRole.ADMIN))` evaluated to a coroutine | Refactored to a **dependency factory**: `require_role(*roles)` returns an inner `role_checker(user=Depends(_get_current_user))`. This is the standard FastAPI pattern for parameterized dependencies |
| 2026-08-08 | **`ImportError: attempted relative import with no known parent package`** | Using relative imports (`from ..auth...`) in `main.py` which doesn't know it's a package | Changed to absolute imports in `main.py`, `role_guard.py`, `me.py` (e.g., `from auth.firebase_verify` instead of `from ..auth.firebase_verify`) |
| 2026-08-08 | **`ImportError: attempted relative import beyond top-level package`** | Using too many relative levels (`from ...auth...`) in nested routers | Reduced relative levels to single-level imports (e.g., `from auth.firebase_verify`) |
| 2026-08-08 | **`ImportError: No module named 'routers.shared'`** (when running directly) | Running `main.py` directly vs as a package; relative imports fail | Added `sys.path.insert(0, '.')` to test script, but production should run with `uvicorn main:app --reload` |
| 2026-08-08 | **FastAPI test: dependency override by string key (`app.dependency_overrides['auth.role_guard._get_current_user']`) didn't take effect** | String-key overrides only work when FastAPI can resolve the exact import path; the nested dependency wasn't matched | Override with the actual function object: `app.dependency_overrides[_get_current_user] = fake` |
| 2026-08-08 | **PostGIS column type not found in SQLite** | Outbreak model uses `geography(POINT, 4326)` but SQLite doesn't support PostGIS | Store lat/lng in separate columns for dev; use raw SQL with `ST_MakePoint` + `ST_DWithin` in production with PostGIS. Migration adds `geography` column and GIST index |

## Notes

- **Missing DATABASE_URL:** the backend needs a PostgreSQL (or SQLite) connection string. The scaffold uses SQLite (`sqlite:///./poultryguard.db`) for dev — replace with `postgresql://...` in `.env` for production.
- **Missing FIREBASE_CREDENTIALS_PATH:** Firebase Admin SDK needs a service account key. Copy your Firebase Admin SDK JSON to the path specified in `.env` or set `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
- **Alembic migration requires .env:** before running `alembic revision --autogenerate`, ensure `.env` exists with `DATABASE_URL` set, otherwise the migration generator can't connect to the database.
- **Seed data:** `scripts/seed_demo.py` creates an admin user, 2 farms, flocks, and 7 days of sensor readings so the `/admin/sensors/{farm_id}/history` endpoint returns real data locally. Idempotent — safe to re-run.

## Integration

- **Frontend `/me` endpoint:** the `ProtectedRoute.jsx` calls `GET /api/v1/me` to resolve the user's role. Ensure the backend `/me` endpoint exists (it does in `routers/shared/me.py`).
- **Role enforcement:** `require_role(*roles)` is a FastAPI dependency factory that raises 403 if the user's role isn't in the allowed list. Use it on admin-only routes: `dependencies=[Depends(require_role(UserRole.ADMIN))]`.
- **Mock data vs real data:** `farms.py` and `analytics.py` still return realistic mock JSON. `sensors.py` already reads **real** rows from the `sensor_readings` table (powered by seed data / the RTDB sync job).
- **RTDB sync job:** `services/firebase_rtdb_sync.py` is a scaffold — the Firebase read + aggregation is a documented TODO. Until it's implemented, seed data is the source of historical readings.
- **Outbreak geofencing:** `outbreaks.py` uses PostGIS `ST_DWithin` for accurate geodesic distance in production, with Haversine fallback for SQLite/dev. The `outbreak_alerts` table stores lat/lng in separate columns for SQLite compatibility; production migration adds `geography` column.
