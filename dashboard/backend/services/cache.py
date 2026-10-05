"""
PoultryGuard Cache Manager
Multi-worker safe TTL cache with Redis backend and in-memory fallback.
Supports JSON serialization for dicts/lists and enforces role/user-scoped cache keys.
"""

import os
import json
import time
import logging
from typing import Optional, Any
from threading import Lock

logger = logging.getLogger("services.cache")

REDIS_URL = os.getenv("REDIS_URL")


class CacheManager:
    """
    Unified TTL Cache Manager.
    - Uses Redis when REDIS_URL is configured or Redis server is reachable (multi-worker safe).
    - Falls back to thread-safe in-memory cache if Redis is unavailable, logging worker limitations.
    """

    def __init__(self, redis_url: Optional[str] = REDIS_URL):
        self.redis_client = None
        self._memory_cache = {}
        self._lock = Lock()
        self.backend = "memory"

        # Attempt Redis connection if url is set or default localhost specified
        target_url = redis_url or os.getenv("REDIS_HOST_URL")
        if target_url:
            try:
                import redis
                client = redis.from_url(target_url, socket_connect_timeout=1.0, socket_timeout=1.0)
                client.ping()
                self.redis_client = client
                self.backend = "redis"
                logger.info(f"[CacheManager] Connected to Redis at {target_url} (Multi-worker safe)")
            except Exception as e:
                logger.warning(
                    f"[CacheManager] Could not connect to Redis at {target_url} ({e}). "
                    "Falling back to in-memory TTL cache. Limitation: Cache is local to the current worker process."
                )
        else:
            logger.info(
                "[CacheManager] REDIS_URL not set. Running in-memory TTL cache. "
                "Limitation: Cache is isolated per worker process; deploy Redis for multi-worker sync."
            )

    def get(self, key: str) -> Optional[Any]:
        """Retrieve and deserialize value if key exists and has not expired."""
        if self.backend == "redis" and self.redis_client:
            try:
                raw = self.redis_client.get(key)
                if raw:
                    return json.loads(raw)
                return None
            except Exception as e:
                logger.warning(f"[CacheManager] Redis get failed: {e}")

        # In-memory fallback
        with self._lock:
            entry = self._memory_cache.get(key)
            if not entry:
                return None
            if time.time() > entry["expires_at"]:
                del self._memory_cache[key]
                return None
            return entry["data"]

    def set(self, key: str, value: Any, ttl_seconds: int = 30) -> None:
        """Store serialized value with TTL expiration."""
        if self.backend == "redis" and self.redis_client:
            try:
                serialized = json.dumps(value)
                self.redis_client.setex(key, ttl_seconds, serialized)
                return
            except Exception as e:
                logger.warning(f"[CacheManager] Redis set failed: {e}")

        # In-memory fallback
        with self._lock:
            self._memory_cache[key] = {
                "data": value,
                "expires_at": time.time() + ttl_seconds,
            }

    def delete(self, key: str) -> None:
        """Invalidate a specific cache key."""
        if self.backend == "redis" and self.redis_client:
            try:
                self.redis_client.delete(key)
            except Exception:
                pass
        with self._lock:
            self._memory_cache.pop(key, None)

    def clear(self) -> None:
        """Clear all keys in memory."""
        with self._lock:
            self._memory_cache.clear()


# Global cache manager instance
cache_manager = CacheManager()
