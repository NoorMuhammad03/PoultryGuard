/**
 * Skeleton loading state component.
 * Uses a shimmering animation to indicate loading.
 */
export function Skeleton({ width, height, className = '', variant = 'default' }) {
  const baseClasses = 'rounded bg-slate-100 animate-pulse'
  const variantClasses = {
    default: '',
    text: 'h-4',
    title: 'h-6 w-2/3',
    avatar: 'h-10 w-10 rounded-full',
    button: 'h-10 w-full',
  }

  return (
    <div
      className={`${baseClasses} ${variantClasses[variant] || ''} ${className}`}
      style={{ width, height }}
    />
  )
}
