export function Toast({ message, type, onClose }) {
  const bgColor = type === 'success' ? 'bg-green-100 text-green-800 border-green-300' :
                  type === 'error' ? 'bg-red-100 text-red-800 border-red-300' :
                  'bg-blue-100 text-blue-800 border-blue-300'

  return (
    <div className={`fixed top-4 right-4 z-50 rounded-lg border px-4 py-3 shadow-lg ${bgColor}`}
         role="alert"
         aria-live="polite">
      <p className="text-sm font-medium">{message}</p>
      <button
        type="button"
        onClick={onClose}
        className="absolute top-2 right-2 text-xs font-bold text-current opacity-60 hover:opacity-100"
      >
        ✕
      </button>
    </div>
  )
}