// Firebase init — SAME config values as the Flutter app (see architecture doc).
// Values come from Vite env vars defined in frontend/.env.example → .env.
import { initializeApp, getApps, getApp } from 'firebase/app'
import {
  getAuth,
  initializeAuth,
  browserSessionPersistence,
  inMemoryPersistence,
} from 'firebase/auth'
import { getDatabase } from 'firebase/database'
import { getAnalytics, isSupported } from 'firebase/analytics'

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID,
  databaseURL:
    import.meta.env.VITE_FIREBASE_DATABASE_URL ||
    `https://${import.meta.env.VITE_FIREBASE_PROJECT_ID}-default-rtdb.firebaseio.com`,
}

// Fail loudly with an actionable message instead of a cryptic Firebase error
// when the dev forgot to copy .env.example → .env.
const requiredKeys = ['apiKey', 'authDomain', 'projectId', 'appId']
const missing = requiredKeys.filter((key) => !firebaseConfig[key])
if (missing.length > 0) {
  throw new Error(
    `Firebase config incomplete: missing ${missing.join(', ')}. Copy frontend/.env.example to .env and fill in real values.`
  )
}

// Safe app initialization (guards against duplicate calls during Vite HMR)
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp()

// Explicit session persistence strategy:
// Uses browserSessionPersistence (sessionStorage) and inMemoryPersistence to prevent
// long-term credential leakage via localStorage while keeping active tab sessions valid.
let authInstance
try {
  authInstance = initializeAuth(app, {
    persistence: [browserSessionPersistence, inMemoryPersistence],
  })
} catch {
  // If already initialized (e.g. during Vite HMR re-evaluations)
  authInstance = getAuth(app)
}

export const auth = authInstance

// Live IoT sensor streams (ESP32 → MQTT → Firebase RTDB)
export const database = getDatabase(app)

// Firebase Analytics (runs in supported browser environments)
export let analytics = null
if (typeof window !== 'undefined') {
  isSupported()
    .then((supported) => {
      if (supported) {
        analytics = getAnalytics(app)
      }
    })
    .catch(() => {
      // Analytics not supported or blocked in this environment
    })
}

export default app
