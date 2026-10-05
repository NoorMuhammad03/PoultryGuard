import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { Eye, EyeOff, ShieldCheck, Lock, Mail } from 'lucide-react'

function formatFirebaseError(err) {
  if (!err) return null
  const code = err.code || ''
  if (code === 'auth/invalid-credential' || code === 'auth/wrong-password' || code === 'auth/user-not-found') {
    return 'Invalid email or password. If you do not have an account yet, click "Create an account" below.'
  }
  if (code === 'auth/email-already-in-use') {
    return 'This email is already registered. Please sign in instead.'
  }
  if (code === 'auth/weak-password') {
    return 'Password must be at least 6 characters long.'
  }
  if (code === 'auth/operation-not-allowed') {
    return 'Email/Password sign-in is not enabled in your Firebase Console. Enable it in Authentication > Sign-in method.'
  }
  if (code === 'auth/invalid-api-key' || code === 'auth/app-deleted') {
    return 'Invalid Firebase API Key or Project configuration. Please check your .env credentials.'
  }
  return err.message || 'Authentication failed. Please check your credentials.'
}

function LoginPage() {
  const { user, login, signup, loading, error } = useAuth()
  const navigate = useNavigate()
  const [isSignUp, setIsSignUp] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [rememberMe, setRememberMe] = useState(true)
  const [localError, setLocalError] = useState('')

  // Already signed in → go straight to the dashboard
  useEffect(() => {
    if (user) navigate('/', { replace: true })
  }, [user, navigate])

  async function handleSubmit(e) {
    e.preventDefault()
    setLocalError('')
    try {
      if (isSignUp) {
        await signup(email, password)
      } else {
        await login(email, password)
      }
      navigate('/', { replace: true })
    } catch (err) {
      setLocalError(formatFirebaseError(err))
    }
  }

  const displayedError = localError || formatFirebaseError(error)

  return (
    <div className="flex min-h-screen w-full items-center justify-center bg-[#FFFFFF] sm:bg-[#F4F8F5] px-4 py-8">
      <div className="w-full max-w-md rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-6 sm:p-8 shadow-sm">
        {/* PoultryGuard Branding Header */}
        <div className="flex flex-col items-center text-center mb-6">
          <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-[#E1EDE6] text-[#214E34] shadow-xs">
            <ShieldCheck className="h-8 w-8" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-[#222222]">PoultryGuard</h1>
          <p className="mt-1 text-sm text-[#666666]">
            {isSignUp ? 'Create new admin management account' : 'Official Administration & Health Platform'}
          </p>
        </div>

        {/* Warning / Error State in Alert Red (#D9534F) */}
        {displayedError && (
          <div
            role="alert"
            className="mb-5 rounded-xl border border-[#D9534F]/30 bg-[#FDF2F2] p-3.5 text-xs sm:text-sm font-medium text-[#D9534F]"
          >
            {displayedError}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Email field */}
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#222222] mb-1.5">
              Email Address
            </label>
            <div className="relative">
              <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-[#666666]">
                <Mail className="h-4 w-4" />
              </div>
              <input
                type="email"
                required
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@poultryguard.pk"
                className="w-full rounded-xl border border-[#666666]/30 bg-[#FFFFFF] py-2.5 pl-10 pr-3 text-sm text-[#222222] placeholder-[#666666]/60 transition-colors focus:border-[#214E34] focus:outline-none focus:ring-2 focus:ring-[#214E34]/20"
              />
            </div>
          </div>

          {/* Password field with working visibility toggle */}
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-[#222222] mb-1.5">
              Password
            </label>
            <div className="relative">
              <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-[#666666]">
                <Lock className="h-4 w-4" />
              </div>
              <input
                type={showPassword ? 'text' : 'password'}
                required
                autoComplete={isSignUp ? 'new-password' : 'current-password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full rounded-xl border border-[#666666]/30 bg-[#FFFFFF] py-2.5 pl-10 pr-11 text-sm text-[#222222] placeholder-[#666666]/60 transition-colors focus:border-[#214E34] focus:outline-none focus:ring-2 focus:ring-[#214E34]/20"
              />
              <button
                type="button"
                id="password-visibility-toggle"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute inset-y-0 right-0 flex items-center pr-3 text-[#666666] hover:text-[#214E34] focus:outline-none transition-colors cursor-pointer"
                aria-label={showPassword ? 'Hide password' : 'Show password'}
              >
                {showPassword ? (
                  <EyeOff className="h-4 w-4 text-[#214E34]" />
                ) : (
                  <Eye className="h-4 w-4 text-[#666666]" />
                )}
              </button>
            </div>
            {isSignUp && (
              <p className="mt-1.5 text-xs text-[#666666]">Must be at least 6 characters long.</p>
            )}
          </div>

          {/* Remember me & Forgot Password Row */}
          {!isSignUp && (
            <div className="flex items-center justify-between pt-1">
              <label className="flex items-center gap-2 cursor-pointer select-none group">
                <div
                  onClick={() => setRememberMe(!rememberMe)}
                  className={`flex h-4 w-4 items-center justify-center rounded-md border transition-all duration-200 ${
                    rememberMe
                      ? 'border-[#214E34] bg-[#214E34] text-[#FFFFFF]'
                      : 'border-[#666666]/40 bg-[#FFFFFF] group-hover:border-[#214E34]'
                  }`}
                >
                  {rememberMe && (
                    <svg className="h-3 w-3 stroke-current stroke-[2.5]" viewBox="0 0 24 24" fill="none">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  )}
                </div>
                <span
                  onClick={() => setRememberMe(!rememberMe)}
                  className="text-xs font-medium text-[#666666] group-hover:text-[#222222] transition-colors"
                >
                  Remember this device
                </span>
              </label>
              <a
                href="#forgot"
                onClick={(e) => {
                  e.preventDefault()
                  alert('Password reset link will be sent to your registered email.')
                }}
                className="text-xs font-semibold text-[#214E34] hover:underline"
              >
                Forgot password?
              </a>
            </div>
          )}

          {/* Primary Action Button (#214E34) */}
          <button
            type="submit"
            disabled={loading}
            className="mt-6 w-full rounded-xl bg-[#214E34] py-3 text-sm font-semibold text-[#FFFFFF] shadow-sm hover:bg-[#193D29] active:bg-[#122B1D] disabled:opacity-50 transition-all cursor-pointer flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <div className="h-4 w-4 animate-spin rounded-full border-2 border-[#FFFFFF] border-t-transparent" />
                <span>{isSignUp ? 'Creating account…' : 'Signing in…'}</span>
              </>
            ) : (
              <span>{isSignUp ? 'Create Account' : 'Log in'}</span>
            )}
          </button>
        </form>

        {/* Switch mode footer */}
        <div className="mt-6 border-t border-[#E1EDE6] pt-4 text-center text-xs text-[#666666]">
          {isSignUp ? (
            <span>
              Already have an account?{' '}
              <button
                type="button"
                onClick={() => {
                  setIsSignUp(false)
                  setLocalError('')
                }}
                className="font-semibold text-[#214E34] hover:underline cursor-pointer"
              >
                Log in
              </button>
            </span>
          ) : (
            <span>
              Need an administrator account?{' '}
              <button
                type="button"
                onClick={() => {
                  setIsSignUp(true)
                  setLocalError('')
                }}
                className="font-semibold text-[#214E34] hover:underline cursor-pointer"
              >
                Create one
              </button>
            </span>
          )}
        </div>
      </div>
    </div>
  )
}

export default LoginPage
