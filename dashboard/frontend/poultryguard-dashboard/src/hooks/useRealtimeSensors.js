// useRealtimeSensors — subscribes to a farm's live path in Firebase RTDB.
// Returns temperature (°C), humidity (%), ammonia (ppm) plus a derived status
// (safe | warning | critical) using the thresholds from
// PoultryGuard_Scope Document-1.md Section 5.1.

import { useEffect, useMemo, useState } from 'react'
import { off, onValue, ref } from 'firebase/database'
import { database } from '../auth/FirebaseConfig'

// RTDB root node that holds every farm's live sensor data:
//   sensors/{farmId}/latest  → { temperature, humidity, ammonia, ... }
export const SENSORS_ROOT = 'sensors'

const EMPTY_READING = { temperature: null, humidity: null, ammonia: null }

// Thresholds from scope doc Section 5.1.
//   Temp   >32°C             → Fan ON (critical)
//   Humid  >80%              → Ventilation (critical)
//   NH3    >25 ppm           → Exhaust fan + alert (critical)
//   MQ-2   >400 ppm          → Buzzer + relay cut (fire gas — not tracked here yet)
// Warning levels are intermediate bands below the critical thresholds.
export const SENSOR_THRESHOLDS = {
  temperature: { warning: 30, critical: 32 },  // °C
  humidity: { warning: 70, critical: 80 },     // % RH
  ammonia: { warning: 20, critical: 25 },      // ppm
}

// Normalize the RTDB snapshot into { temperature, humidity, ammonia }.
// Accepts common field aliases so it tolerates different IoT bridge schemas.
function normalizeReading(data) {
  if (!data || typeof data !== 'object') return null
  return {
    temperature: data.temperature ?? data.temp ?? data.t ?? null,
    humidity: data.humidity ?? data.hum ?? data.h ?? null,
    ammonia: data.ammonia ?? data.nh3 ?? data.nh3_ppm ?? null,
  }
}

// Derive overall status from the latest reading using the threshold table.
// Any single sensor crossing its critical threshold ⇒ critical; any crossing
// warning ⇒ warning; otherwise safe. Unknown if we have no data yet.
export function deriveSensorStatus(sensors) {
  if (!sensors) return 'unknown'
  const vals = [
    sensors.temperature,
    sensors.humidity,
    sensors.ammonia,
  ]
  if (vals.every((v) => v === null || v === undefined)) return 'unknown'

  const crossing = (key) => {
    const value = sensors[key]
    if (value === null || value === undefined) return null
    if (value > SENSOR_THRESHOLDS[key].critical) return 'critical'
    if (value > SENSOR_THRESHOLDS[key].warning) return 'warning'
    return 'safe'
  }

  const statuses = ['temperature', 'humidity', 'ammonia'].map(crossing)
  if (statuses.includes('critical')) return 'critical'
  if (statuses.includes('warning')) return 'warning'
  return 'safe'
}

/**
 * Subscribe to a farm's live sensor node in Firebase RTDB.
 *
 * @param {string} farmId - farm identifier used to build the RTDB path
 *   (`/sensors/{farmId}/latest` by default; override with `path`).
 * @param {Object} [options]
 * @param {string} [options.path] - custom RTDB path, defaults to `sensors/${farmId}/latest`.
 * @returns {{ sensors: {temperature:number|null,humidity:number|null,ammonia:number|null},
 *             status: 'safe'|'warning'|'critical'|'unknown', loading: boolean }}
 */
export function useRealtimeSensors(farmId, options = {}) {
  const { path } = options
  const dbPath = path || (farmId ? `sensors/${farmId}/latest` : null)

  const [sensors, setSensors] = useState({
    temperature: null,
    humidity: null,
    ammonia: null,
  })

  useEffect(() => {
    if (!dbPath) return undefined

    const dbRef = ref(database, dbPath)
    const unsubscribe = onValue(
      dbRef,
      (snapshot) => {
        const data = snapshot.val()
        setSensors(normalizeReading(data) ?? { temperature: null, humidity: null, ammonia: null })
      },
      (error) => {
        // RTDB permission errors surface here; keep last-known values.
        console.error(`useRealtimeSensors: error reading ${dbPath}`, error)
      }
    )

    return () => {
      // `unsubscribe` returned by onValue detaches the listener.
      off(dbRef)
      if (typeof unsubscribe === 'function') unsubscribe()
    }
  }, [dbPath])

  const status = useMemo(() => deriveSensorStatus(sensors), [sensors])
  const loading = sensors.temperature === null && sensors.humidity === null && sensors.ammonia === null

  return { sensors, status, loading }
}

/**
 * Subscribe to MANY farms' live sensor nodes with ONE RTDB listener.
 *
 * Instead of opening N listeners (one per farm), this hook attaches a single
 * `onValue` listener on the `sensors` root and derives each requested farm's
 * reading client-side. Updates are trailing-debounced so a burst of writes from
 * several ESP32s coalesces into a single render. Subscriptions are capped at
 * `maxSubscriptions` farms so the map never opens unbounded listeners — farms
 * beyond the cap report `status: 'unknown'` (no live data).
 *
 * @param {string[]} farmIds - farm identifiers to track.
 * @param {Object} [options]
 * @param {number} [options.debounceMs=400] - trailing debounce before re-rendering.
 * @param {number} [options.maxSubscriptions=30] - cap on live-subscribed farms.
 * @returns {Record<string, {sensors: {temperature:number|null,humidity:number|null,ammonia:number|null},
 *   status:'safe'|'warning'|'critical'|'unknown', loading:boolean}>}
 */
export function useRealtimeSensorsBatch(farmIds = [], options = {}) {
  const { debounceMs = 400, maxSubscriptions = 30 } = options
  const ids = useMemo(
    () => Array.from(new Set(farmIds.filter(Boolean).map(String))),
    [farmIds]
  )
  const subscribedIds = useMemo(
    () => ids.slice(0, maxSubscriptions),
    [ids, maxSubscriptions]
  )
  const subscribedKey = subscribedIds.join('|')

  const [byFarm, setByFarm] = useState({})

  useEffect(() => {
    if (subscribedIds.length === 0) return undefined

    const rootRef = ref(database, SENSORS_ROOT)
    let latestSnapshot = null
    let debounceTimer = null

    const apply = () => {
      const all = latestSnapshot?.val() || {}
      const next = {}
      for (const id of subscribedIds) {
        // Each farm node is { latest: {…} }; tolerate a flat {…} too.
        const node = all[id]
        next[id] = normalizeReading(node?.latest ?? node) ?? EMPTY_READING
      }
      setByFarm(next)
    }

    // Debounce: keep the most recent snapshot, apply it after a quiet period.
    const scheduleApply = (snapshot) => {
      latestSnapshot = snapshot
      clearTimeout(debounceTimer)
      debounceTimer = setTimeout(apply, debounceMs)
    }

    const unsubscribe = onValue(rootRef, scheduleApply, (error) => {
      console.error(`useRealtimeSensorsBatch: error reading ${SENSORS_ROOT}`, error)
    })

    return () => {
      clearTimeout(debounceTimer)
      off(rootRef)
      if (typeof unsubscribe === 'function') unsubscribe()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [subscribedKey, debounceMs])

  return useMemo(() => {
    const map = {}
    for (const id of ids) {
      const sensors = byFarm[id] ?? EMPTY_READING
      map[id] = {
        sensors,
        status: deriveSensorStatus(sensors),
        loading: subscribedIds.includes(id) && !byFarm[id],
      }
    }
    return map
  }, [ids, subscribedIds, byFarm])
}

export default useRealtimeSensors
