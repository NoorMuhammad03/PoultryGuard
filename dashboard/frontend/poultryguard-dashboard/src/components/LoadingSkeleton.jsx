import { Skeleton } from './Skeleton'

/**
 * Full-page loading skeleton with consistent layout across pages.
 * Used as a fallback while data is loading.
 */
export function LoadingSkeleton() {
  return (
    <div className="mx-auto max-w-7xl space-y-6">
      {/* Header skeleton */}
      <div className="flex items-center justify-between">
        <div className="space-y-2">
          <Skeleton variant="title" className="w-64" />
          <Skeleton variant="text" className="w-96" />
        </div>
        <div className="flex gap-2">
          <Skeleton className="h-10 w-48" />
          <Skeleton className="h-10 w-32" />
        </div>
      </div>

      {/* Card skeleton */}
      <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
        <Skeleton variant="title" className="w-48 mb-4" />
        <div className="space-y-3">
          <Skeleton variant="text" className="w-full" />
          <Skeleton variant="text" className="w-3/4" />
          <Skeleton variant="text" className="w-1/2" />
        </div>
      </div>

      {/* Chart/table skeleton */}
      <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
        <Skeleton variant="title" className="w-40 mb-4" />
        <div className="space-y-2">
          <Skeleton className="h-4 w-full" />
          <Skeleton className="h-4 w-full" />
          <Skeleton className="h-4 w-full" />
          <Skeleton className="h-4 w-full" />
          <Skeleton className="h-4 w-full" />
        </div>
      </div>
    </div>
  )
}

/**
 * Table row loading skeleton for paginated tables.
 */
export function TableRowSkeleton({ cols = 4 }) {
  return (
    <tr className="hover:bg-slate-50">
      {Array.from({ length: cols }).map((_, i) => (
        <td key={i} className="px-4 py-3">
          <Skeleton variant="text" className="w-full" />
        </td>
      ))}
    </tr>
  )
}

/**
 * Card loading skeleton for grid layouts.
 */
export function CardSkeleton() {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
      <Skeleton variant="title" className="w-48 mb-4" />
      <div className="space-y-3">
        <Skeleton variant="text" className="w-full" />
        <Skeleton variant="text" className="w-3/4" />
        <Skeleton variant="text" className="w-1/2" />
      </div>
    </div>
  )
}

/**
 * Empty state component for tables/charts with no data.
 */
export function EmptyState({ title, description, icon: Icon }) {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-12 text-center">
      {Icon && <Icon className="mx-auto h-12 w-12 text-slate-400" />}
      <h2 className="mt-3 text-lg font-semibold text-slate-800">{title}</h2>
      <p className="mt-1 text-sm text-slate-500">{description}</p>
    </div>
  )
}

/**
 * Error state component for failed data fetches.
 */
export function ErrorState({ title, description, onRetry, icon: Icon }) {
  return (
    <div className="rounded-lg border border-red-200 bg-red-50 p-12 text-center">
      {Icon && <Icon className="mx-auto h-12 w-12 text-red-600" />}
      <h2 className="mt-3 text-lg font-semibold text-slate-800">{title}</h2>
      <p className="mt-1 text-sm text-slate-600">{description}</p>
      {onRetry && (
        <button
          type="button"
          onClick={onRetry}
          className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
        >
          <Icon className="h-4 w-4" />
          Retry
        </button>
      )}
    </div>
  )
}

/**
 * Graceful degradation component when backend is unreachable.
 */
export function BackendUnreachable() {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-12 text-center">
      <AlertTriangle className="mx-auto h-12 w-12 text-slate-400" />
      <h2 className="mt-3 text-lg font-semibold text-slate-800">
        Backend service unavailable
      </h2>
      <p className="mt-1 text-sm text-slate-500">
        Could not connect to the API server. Please check if the backend is running.
      </p>
      <p className="mt-2 text-xs text-slate-400">
        If you're running locally, start the FastAPI server with:
      </p>
      <code className="mt-2 inline-block rounded bg-slate-100 px-2 py-1 text-xs font-mono text-slate-600">
        uvicorn main:app --reload
      </code>
    </div>
  )
}

// Import AlertTriangle for BackendUnreachable
import { AlertTriangle } from 'lucide-react'