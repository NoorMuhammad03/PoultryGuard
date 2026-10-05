import { Component } from 'react'
import { AlertTriangle } from 'lucide-react'

/**
 * Global error boundary that catches unhandled errors in child components.
 * Displays a user-friendly error message with a reload button.
 */
export class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  componentDidCatch(error, errorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo)
  }

  handleReload = () => {
    this.setState({ hasError: false, error: null })
    window.location.reload()
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
          <div className="rounded-lg border border-red-200 bg-white p-8 shadow-lg max-w-md w-full">
            <AlertTriangle className="mx-auto h-12 w-12 text-red-600" />
            <h2 className="mt-3 text-lg font-semibold text-slate-800">
              Something went wrong
            </h2>
            <p className="mt-2 text-sm text-slate-600">
              An unexpected error occurred. Please try reloading the page.
            </p>
            <p className="mt-2 text-xs text-slate-400 font-mono truncate">
              {this.state.error?.message || 'Unknown error'}
            </p>
            <div className="mt-4 flex gap-2 justify-end">
              <button
                type="button"
                onClick={this.handleReload}
                className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
              >
                Reload Page
              </button>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}
