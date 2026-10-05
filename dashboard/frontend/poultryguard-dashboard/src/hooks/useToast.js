import { createContext, useCallback, useContext, useMemo, useRef, useState } from 'react'
import { createElement } from 'react'
import { Toast } from '../components/Toast'

const ToastContext = createContext(null)

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([])

  const addToast = useCallback((message, type = 'info') => {
    const id = Date.now()
    setToasts((t) => [...t, { id, message, type }])
    setTimeout(() => removeToast(id), 5000)
  }, [])

  const removeToast = useCallback((id) => {
    setToasts((t) => t.filter((n) => n.id !== id))
  }, [])

  const value = useMemo(
    () => ({ addToast, removeToast }),
    [addToast, removeToast]
  )

  return createElement(
    ToastContext.Provider,
    { value },
    [
      children,
      ...toasts.map((toast) =>
        createElement(Toast, {
          key: toast.id,
          message: toast.message,
          type: toast.type,
          onClose: () => removeToast(toast.id)
        })
      )
    ]
  )
}

export function useToast() {
  const ctx = useContext(ToastContext)
  if (!ctx) {
    throw new Error('useToast must be used within a ToastProvider')
  }
  return ctx
}

// Convenience hooks for common message types
export const useSuccess = () => useToast((t) => t.type === 'success' && t.message)
export const useError = () => useToast((t) => t.type === 'error' && t.message)

// Use with component to auto-remove on unmount
export function ToastMessage({ message, type = 'info' }) {
  const { addToast } = useToast()
  const mountRef = useRef(null)

  if (!mountRef.current) {
    mountRef.current = true
    addToast(message, type)
  }

  return null
}