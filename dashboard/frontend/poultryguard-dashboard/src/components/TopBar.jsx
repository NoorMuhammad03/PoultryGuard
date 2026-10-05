import { useState, useRef, useEffect } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { useQuery } from '@tanstack/react-query'
import axiosClient from '../api/axiosClient'
import {
  Menu,
  Bell,
  LogOut,
  ChevronRight,
  ArrowLeft,
  AlertTriangle,
  CheckCircle,
  Activity,
  ShieldAlert,
} from 'lucide-react'

export default function TopBar({ onToggleSidebar, sidebarOpen, mobileOpen, setMobileOpen }) {
  const { user, logout } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()
  const [showNotifications, setShowNotifications] = useState(false)
  const notifRef = useRef(null)

  // Fetch /me
  const { data: me } = useQuery({
    queryKey: ['me'],
    queryFn: async () => {
      const res = await axiosClient.get('/me')
      return res.data
    },
    staleTime: 15 * 60_000,
    gcTime: 60 * 60_000,
  })

  // Close notifications on click outside
  useEffect(() => {
    function handleClickOutside(event) {
      if (notifRef.current && !notifRef.current.contains(event.target)) {
        setShowNotifications(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const handleLogout = async () => {
    try {
      await logout()
    } catch {
      // Surfaced in context
    }
  }

  const displayName = user?.email?.split('@')[0] || 'Admin'

  // Route labels and back navigation logic
  const path = location.pathname
  const isNested = path.startsWith('/farms/') && path !== '/farms'

  const getPageTitle = () => {
    if (path === '/overview') return 'Dashboard Overview'
    if (path === '/farms') return 'Farms Management'
    if (isNested) return 'Farm Detail & Telemetry'
    if (path === '/flocks') return 'Flock Tracking'
    if (path === '/ai-detection') return 'AI Disease Detection & Analysis'
    if (path === '/model') return 'Model Analytics'
    if (path === '/sensors') return 'Sensor Monitoring Logs'
    if (path === '/outbreaks') return 'Outbreak Surveillance'
    if (path === '/vet') return 'Veterinary Verification'
    if (path === '/users') return 'User Management'
    if (path === '/analytics') return 'System Analytics'
    return 'PoultryGuard'
  }

  // Active notifications (high priority alerts use #D9534F)
  const notifications = [
    {
      id: 1,
      title: 'High Ammonia Alert (28.4 ppm)',
      farm: 'Seed Farm 1',
      time: '10m ago',
      critical: true,
    },
    {
      id: 2,
      title: 'Coccidiosis Suspected via AI Detection',
      farm: 'Broiler House B',
      time: '32m ago',
      critical: true,
    },
    {
      id: 3,
      title: 'Flock #102 Vaccination Completed',
      farm: 'Seed Farm 2',
      time: '2h ago',
      critical: false,
    },
  ]

  return (
    <header className="sticky top-0 z-20 flex h-16 w-full items-center justify-between border-b border-[#E1EDE6] bg-[#FFFFFF] px-4 sm:px-6 lg:px-8 shadow-2xs">
      {/* Left section: Universal Sidebar Toggle & Page Title / Breadcrumbs */}
      <div className="flex items-center gap-3 min-w-0">
        <button
          type="button"
          onClick={onToggleSidebar || (() => setMobileOpen?.(true))}
          className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[#E1EDE6] text-[#214E34] hover:bg-[#C8DDD1] transition-all cursor-pointer active:scale-95 shadow-2xs"
          title={sidebarOpen ? 'Collapse side menu' : 'Open side menu'}
          aria-label="Toggle side menu"
        >
          <Menu className="h-5 w-5" />
        </button>

        {isNested && (
          <button
            type="button"
            onClick={() => navigate('/farms')}
            className="flex h-9 w-9 items-center justify-center rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] text-[#214E34] hover:bg-[#E1EDE6] transition-colors"
            title="Back to farms"
            aria-label="Back to farms"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
        )}

        <div className="min-w-0 flex items-center gap-2">
          <span className="text-sm font-medium text-[#666666]">PoultryGuard</span>
          <ChevronRight className="h-4 w-4 text-[#666666]/60 shrink-0" />
          <h1 className="text-base sm:text-lg font-bold text-[#214E34] truncate">
            {getPageTitle()}
          </h1>
        </div>
      </div>

      {/* Right section: Notifications & User profile */}
      <div className="flex items-center gap-2 sm:gap-4">
        {/* Notifications Popover */}
        <div className="relative" ref={notifRef}>
          <button
            type="button"
            onClick={() => setShowNotifications(!showNotifications)}
            className="relative flex h-10 w-10 items-center justify-center rounded-xl bg-[#E1EDE6]/60 text-[#214E34] hover:bg-[#E1EDE6] transition-colors"
            aria-label="Notifications"
          >
            <Bell className="h-5 w-5" />
            <span className="absolute top-2 right-2 h-2.5 w-2.5 rounded-full bg-[#D9534F] ring-2 ring-[#FFFFFF]" />
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 sm:w-96 rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-4 shadow-xl z-50 animate-in fade-in slide-in-from-top-2 duration-150">
              <div className="flex items-center justify-between pb-3 border-b border-[#E1EDE6]">
                <div className="flex items-center gap-2">
                  <ShieldAlert className="h-4 w-4 text-[#D9534F]" />
                  <h3 className="text-sm font-bold text-[#222222]">System Alerts</h3>
                </div>
                <span className="rounded-full bg-[#D9534F]/10 px-2 py-0.5 text-xs font-semibold text-[#D9534F]">
                  2 Critical
                </span>
              </div>

              <div className="mt-3 space-y-2.5 max-h-72 overflow-y-auto">
                {notifications.map((n) => (
                  <div
                    key={n.id}
                    className={`flex items-start gap-3 rounded-xl p-2.5 transition-colors ${
                      n.critical
                        ? 'bg-[#FDF2F2] border border-[#D9534F]/20'
                        : 'bg-[#F4F8F5] border border-[#E1EDE6]'
                    }`}
                  >
                    <div className="mt-0.5 shrink-0">
                      {n.critical ? (
                        <AlertTriangle className="h-4 w-4 text-[#D9534F]" />
                      ) : (
                        <CheckCircle className="h-4 w-4 text-[#214E34]" />
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-semibold text-[#222222]">{n.title}</p>
                      <p className="text-[11px] text-[#666666]">{n.farm}</p>
                      <span className="text-[10px] text-[#666666]/70">{n.time}</span>
                    </div>
                  </div>
                ))}
              </div>

              <Link
                to="/sensors"
                onClick={() => setShowNotifications(false)}
                className="mt-3 block text-center text-xs font-semibold text-[#214E34] hover:underline"
              >
                View all telemetric sensor logs
              </Link>
            </div>
          )}
        </div>

        {/* User profile dropdown / status */}
        <div className="flex items-center gap-2 sm:gap-3 pl-2 sm:pl-3 border-l border-[#E1EDE6]">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[#214E34] text-[#FFFFFF] font-bold text-sm shadow-xs">
            {displayName.charAt(0).toUpperCase()}
          </div>

          <div className="hidden md:block text-left">
            <p className="text-sm font-semibold text-[#222222] leading-tight truncate max-w-[140px]">
              {displayName}
            </p>
            <p className="text-xs font-medium text-[#666666] capitalize">
              {me?.role || 'Admin'}
            </p>
          </div>

          <button
            type="button"
            onClick={handleLogout}
            className="flex h-9 w-9 items-center justify-center rounded-xl text-[#666666] hover:bg-[#FDF2F2] hover:text-[#D9534F] transition-colors"
            title="Sign out"
            aria-label="Sign out"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </div>
    </header>
  )
}