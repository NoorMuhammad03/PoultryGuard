import { Link } from 'react-router-dom'

function UnauthorizedPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-50 px-4">
      <h1 className="text-3xl font-bold text-slate-800">403 · Unauthorized</h1>
      <p className="mt-2 text-slate-500">
        This dashboard is restricted to admin accounts.
      </p>
      <Link
        to="/login"
        className="mt-6 rounded-lg bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
      >
        Back to sign in
      </Link>
    </div>
  )
}

export default UnauthorizedPage
