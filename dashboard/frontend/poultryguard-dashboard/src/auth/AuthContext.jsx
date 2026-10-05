import { createContext, useCallback, useContext, useMemo, useState } from 'react'
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  getIdToken,
} from 'firebase/auth'
import { useAuthState } from 'react-firebase-hooks/auth'
import { auth } from './FirebaseConfig'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  // Tracks the current Firebase user and the initial session restore state
  const [user, initializing] = useAuthState(auth)

  // loading/error are for the login/logout operations specifically
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const login = useCallback(async (email, password) => {
    setLoading(true)
    setError(null)
    try {
      await signInWithEmailAndPassword(auth, email, password)
    } catch (err) {
      setError(err)
      throw err
    } finally {
      setLoading(false)
    }
  }, [])

  const signup = useCallback(async (email, password) => {
    setLoading(true)
    setError(null)
    try {
      await createUserWithEmailAndPassword(auth, email, password)
    } catch (err) {
      setError(err)
      throw err
    } finally {
      setLoading(false)
    }
  }, [])

  const logout = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      await signOut(auth)
    } catch (err) {
      setError(err)
      throw err
    } finally {
      setLoading(false)
    }
  }, [])

  // Fetch a fresh Firebase ID token on demand (used as Bearer token on API calls)
  const fetchIdToken = useCallback(async () => {
    const currentUser = auth.currentUser
    return currentUser ? getIdToken(currentUser, true) : null
  }, [])

  const value = useMemo(
    () => ({
      user,
      initializing,
      loading,
      error,
      login,
      signup,
      logout,
      getIdToken: fetchIdToken,
    }),
    [user, initializing, loading, error, login, signup, logout, fetchIdToken]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return ctx
}
