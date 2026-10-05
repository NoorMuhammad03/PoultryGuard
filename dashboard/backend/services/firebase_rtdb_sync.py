# RTDB → PostgreSQL sync job.
#
# Per PoultryGuard_Dashboard_Architecture.md: the raw, seconds-level ESP32 sensor
# stream lives in Firebase Realtime DB. This backend service pulls that stream and
# aggregates it into the PostgreSQL `sensor_readings` table so the dashboard charts
# (7/30-day trends) and reports query PostgreSQL — never RTDB directly.
#
# Scheduling: intended to run every 5–15 min. Can be launched as:
#   - an APScheduler BackgroundScheduler started inside FastAPI lifespan, or
#   - a standalone process:  python -m services.firebase_rtdb_sync
#
# The actual Firebase read + aggregation is deliberately a documented TODO — this
# file establishes the job's interface and scaffolding.

import logging
import os
import time
from datetime import datetime, timedelta, timezone
from typing import List, Optional

from firebase_admin import db as firebase_db
from sqlalchemy.orm import Session

from db.postgres import SessionLocal
from models.farm import Farm
from models.sensor_reading import SensorReading

logger = logging.getLogger(__name__)

# Firebase RTDB paths (adjust to match the real IoT schema when the bridge is built)
RTDB_FARM_SENSORS_PATH = "sensors"  # e.g. /sensors/{farm_rtdb_key}/latest

# Aggregation window: each SensorReading row covers N minutes of raw stream
AGGREGATION_MINUTES = 15
# How far back to look for un-aggregated raw data on each run
LOOKBACK_HOURS = 1


class RTDBSyncJob:
    """
    Scheduled job that reads raw sensor data from Firebase RTDB and writes
    aggregated rows into the PostgreSQL `sensor_readings` table.

    The job is intentionally stateless per run: call run_once() every N minutes.
    """

    def __init__(
        self,
        session_factory=SessionLocal,
        rtdb_client=None,
        aggregation_minutes: int = AGGREGATION_MINUTES,
    ):
        # Allow injecting a mock RTDB client for tests.
        self._session_factory = session_factory
        self._rtdb = rtdb_client or self._default_rtdb_client()
        self.aggregation_minutes = aggregation_minutes

    # ------------------------------------------------------------------ #
    # Public interface
    # ------------------------------------------------------------------ #
    def run_once(self) -> int:
        """
        Execute a single sync pass: read raw RTDB sensor data, aggregate it,
        and insert new SensorReading rows. Returns the number of rows written.

        TODO(implementation): the real bridge is not built yet. Stub the flow:
          1. For each farm with a matching RTDB key, read the raw stream since
             the last aggregated timestamp (LOOKBACK_HOURS window).
          2. Bucket the raw readings into AGGREGATION_MINUTES windows and average
             temperature / humidity / ammonia per bucket.
          3. Upsert one SensorReading per (farm_id, bucket_start) — skip buckets
             already present (check by farm_id + timestamp).
          4. Optionally update the farm's derived status from the newest bucket.
        """
        logger.info("RTDBSyncJob.run_once() — implementation pending")
        logger.info(
            "Would read %s from RTDB, aggregate every %s min, write to sensor_readings",
            RTDB_FARM_SENSORS_PATH,
            self.aggregation_minutes,
        )
        return 0

    def run_scheduled(self, interval_seconds: int = 900) -> None:
        """
        Blocking loop that calls run_once() every `interval_seconds`.
        Intended for a standalone worker process; for embedding in FastAPI,
        prefer APScheduler instead (see module docstring).
        """
        logger.info("Starting RTDBSyncJob loop (interval=%ss)", interval_seconds)
        while True:
            try:
                self.run_once()
            except Exception:
                logger.exception("RTDBSyncJob iteration failed")
            time.sleep(interval_seconds)

    # ------------------------------------------------------------------ #
    # Helpers (used by the TODO implementation)
    # ------------------------------------------------------------------ #
    def _load_farm_rtdb_keys(self, db: Session) -> List[tuple]:
        """Return [(farm_id, rtdb_key)] for every farm. TODO: add a rtdb_key column."""
        # TODO: Farm model needs a `rtdb_key` column so we know which RTDB path
        # belongs to which farm. Until then, fall back to str(farm.id).
        farms = db.query(Farm).all()
        return [(f.id, str(f.id)) for f in farms]

    def _aggregate(self, raw_readings: List[dict]) -> Optional[SensorReading]:
        """
        Average raw readings into one SensorReading row.
        TODO: bucket by AGGREGATION_MINUTES windows before calling this.
        """
        if not raw_readings:
            return None
        n = len(raw_readings)
        avg = lambda key: sum(r.get(key) or 0.0 for r in raw_readings) / n
        return SensorReading(
            farm_id=raw_readings[0].get("farm_id"),
            timestamp=datetime.now(timezone.utc) - timedelta(minutes=self.aggregation_minutes),
            temperature=round(avg("temperature"), 2),
            humidity=round(avg("humidity"), 2),
            ammonia=round(avg("ammonia"), 2),
            raw={"sample_count": n, "bucket_minutes": self.aggregation_minutes},
        )

    @staticmethod
    def _default_rtdb_client():
        """Lazy Firebase RTDB client. Requires FIREBASE_CREDENTIALS_PATH env."""
        credentials_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
        if not credentials_path:
            logger.warning(
                "FIREBASE_CREDENTIALS_PATH not set — RTDB client unavailable. "
                "run_once() will no-op."
            )
            return None
        # TODO: firebase_admin.initialize_app once at module level with the
        # service-account credentials, then return firebase_db.reference(...).
        return None


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    RTDBSyncJob().run_scheduled(interval_seconds=900)
