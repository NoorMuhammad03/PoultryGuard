import { Navigate, Outlet } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { useAuth } from './AuthContext'
import axiosClient from '../api/axiosClient'

// UX convenience only — real authorization is enforced server-side by FastAPI.
function ProtectedRoute() {
  const { user, initializing, logout } = useAuth()

  // Resolve the user's role from the backend /me endpoint (needs an ID token,
  // which the axiosClient interceptor attaches automatically).
  const {
    data: me,
    isLoading: checkingRole,
    isError: roleCheckFailed,
    error: roleError,
    refetch,
  } = useQuery({
    queryKey: ['me'],
    queryFn: async () => {
      const res = await axiosClient.get('/me')
      return res.data
    },
    enabled: !!user,
    retry: 1,
    staleTime: 15 * 60_000,
    gcTime: 60 * 60_000,
  })

  // While Firebase restores a persisted session
  if (initializing) {
    return <LoadingScreen label="Checking session…" />
  }

  // No authenticated user → send to login
  if (!user) {
    return <Navigate to="/login" replace />
  }

  // Role still being fetched from the backend
  if (checkingRole) {
    return <LoadingScreen label="Verifying role…" />
  }

  // Backend is not reachable (FastAPI not running)
  if (roleCheckFailed) {
    const isNetworkError =
      !roleError?.response ||
      roleError?.code === 'ERR_NETWORK' ||
      roleError?.message?.includes('Network Error')

    if (isNetworkError) {
      return (
        <div className="flex min-h-screen flex-col items-center justify-center bg-slate-50 px-4">
          <div className="w-full max-w-md rounded-xl border border-slate-200 bg-white p-6 shadow-sm text-center">
            <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-amber-100 text-amber-600 mb-4">
              <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            </div>
            <h2 className="text-lg font-semibold text-slate-800">Backend Server Offline</h2>
            <p className="mt-2 text-sm text-slate-500">
              Firebase authenticated successfully as <strong className="text-slate-700">{user.email}</strong>, but the backend at <code className="bg-slate-100 px-1 py-0.5 rounded text-slate-700">http://localhost:8000</code> is not running.
            </p>
            <div className="mt-4 rounded-lg bg-slate-900 p-3 text-left font-mono text-xs text-slate-200">
              <span className="text-slate-500"># Run in another terminal (Dashboard\backend):</span><br />
              .venv\Scripts\uvicorn.exe main:app --reload
            </div>
            <div className="mt-6 flex flex-col gap-2">
              <button
                type="button"
                onClick={() => refetch()}
                className="w-full rounded-lg bg-slate-800 py-2 text-sm font-medium text-white hover:bg-slate-700 transition-colors"
              >
                Retry Connection
              </button>
              <button
                type="button"
                onClick={logout}
                className="w-full rounded-lg border border-slate-300 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50 transition-colors"
              >
                Sign out
              </button>
            </div>
          </div>
        </div>
      )
    }

    return <Navigate to="/unauthorized" replace />
  }

  // Role could not be verified or isn't admin → not allowed in
  if (me?.role !== 'admin') {
    return <Navigate to="/unauthorized" replace />
  }

  return <Outlet />
}

function LoadingScreen({ label }) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-50">
      <div className="h-8 w-8 animate-spin rounded-full border-4 border-slate-300 border-t-slate-800" />
      <p className="mt-4 text-sm text-slate-500">{label}</p>
    </div>
  )
}

export default ProtectedRoute
