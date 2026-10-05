import { Suspense, lazy } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import ProtectedRoute from './auth/ProtectedRoute'
import DashboardLayout from './components/DashboardLayout'

// Lazy-loaded route views for code splitting
const LoginPage = lazy(() => import('./pages/LoginPage'))
const UnauthorizedPage = lazy(() => import('./pages/UnauthorizedPage'))
const DashboardOverview = lazy(() => import('./pages/DashboardOverview'))
const FarmsMapView = lazy(() => import('./pages/FarmsMapView'))
const FarmDetailPage = lazy(() => import('./pages/FarmDetailPage'))
const FlocksView = lazy(() => import('./pages/FlocksView'))
const AIDiseaseDetection = lazy(() => import('./pages/AIDiseaseDetection'))
const VeterinaryVerification = lazy(() => import('./pages/VeterinaryVerification'))
const OutbreakHeatmap = lazy(() => import('./pages/OutbreakHeatmap'))
const UserManagement = lazy(() => import('./pages/UserManagement'))
const Analytics = lazy(() => import('./pages/Analytics'))
const SensorLogsView = lazy(() => import('./pages/SensorLogsView'))
const ModelAnalytics = lazy(() => import('./pages/ModelAnalytics'))

function PageFallback() {
  return (
    <div className="flex min-h-[50vh] w-full items-center justify-center p-6">
      <div className="flex flex-col items-center gap-2.5">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-[#214E34]/20 border-t-[#214E34]" />
        <span className="text-xs font-medium text-slate-500">Loading view…</span>
      </div>
    </div>
  )
}

function App() {
  return (
    <Suspense fallback={<PageFallback />}>
      <Routes>
        {/* Public routes */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/unauthorized" element={<UnauthorizedPage />} />

        {/* Protected admin dashboard wrapped in DashboardLayout + ProtectedRoute */}
        <Route element={<ProtectedRoute />}>
          <Route element={<DashboardLayout />}>
            <Route path="/overview" element={<DashboardOverview />} />
            <Route path="/farms" element={<FarmsMapView />} />
            <Route path="/farms/:id" element={<FarmDetailPage />} />
            <Route path="/flocks" element={<FlocksView />} />
            <Route path="/ai-detection" element={<AIDiseaseDetection />} />
            <Route path="/model" element={<ModelAnalytics />} />
            <Route path="/sensors" element={<SensorLogsView />} />
            <Route path="/outbreaks" element={<OutbreakHeatmap />} />
            <Route path="/vet" element={<VeterinaryVerification />} />
            <Route path="/users" element={<UserManagement />} />
            <Route path="/analytics" element={<Analytics />} />
            {/* Root redirects to overview */}
            <Route path="/" element={<Navigate to="/overview" replace />} />
          </Route>
        </Route>

        {/* Fallback */}
        <Route path="*" element={<Navigate to="/overview" replace />} />
      </Routes>
    </Suspense>
  )
}

export default App