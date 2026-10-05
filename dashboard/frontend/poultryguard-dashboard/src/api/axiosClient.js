// Shared axios instance for all FastAPI calls.
// Attaches the Firebase ID token as `Authorization: Bearer <token>` on every request.
// Redirects to /login on 401 (expired/revoked token) so the user can re-auth.
import axios from 'axios'
import { getIdToken } from 'firebase/auth'
import { auth } from '../auth/FirebaseConfig'

const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1',
  headers: { 'Content-Type': 'application/json' },
})

axiosClient.interceptors.request.use(async (config) => {
  const currentUser = auth.currentUser
  if (currentUser) {
    const token = await getIdToken(currentUser, true)
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

axiosClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config

    if (error.response?.status === 401 && originalRequest && !originalRequest._retry) {
      originalRequest._retry = true
      try {
        const currentUser = auth.currentUser
        if (currentUser) {
          // Force refresh the Firebase ID token from Google Auth servers
          const freshToken = await getIdToken(currentUser, true)
          originalRequest.headers.Authorization = `Bearer ${freshToken}`
          return axiosClient(originalRequest)
        }
      } catch (refreshErr) {
        console.warn('[axiosClient] Token refresh failed:', refreshErr)
      }

      // If refresh failed or user is not logged in, redirect to login
      if (typeof window !== 'undefined' && window.location.pathname !== '/login') {
        window.location.href = '/login'
      }
    }

    return Promise.reject(error)
  }
)

export default axiosClient
