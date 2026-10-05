import { Link, useLocation } from 'react-router-dom'
import {
  LayoutDashboard,
  Map,
  Layers,
  ScanSearch,
  Activity,
  Radio,
  AlertOctagon,
  UserCheck,
  Users,
  BarChart3,
  LogOut,
  ShieldCheck,
  X,
} from 'lucide-react'
import { useAuth } from '../auth/AuthContext'

export const NAV_LINKS = [
  { path: '/overview', label: 'Overview', icon: LayoutDashboard },
  { path: '/farms', label: 'Farms Map', icon: Map },
  { path: '/flocks', label: 'Flocks', icon: Layers },
  { path: '/ai-detection', label: 'AI Disease Detection', icon: ScanSearch, badge: 'AI' },
  { path: '/model', label: 'Model Analytics', icon: Activity },
  { path: '/sensors', label: 'Sensor Logs', icon: Radio },
  { path: '/outbreaks', label: 'Outbreak Alerts', icon: AlertOctagon },
  { path: '/vet', label: 'Vet Verification', icon: UserCheck },
  { path: '/users', label: 'User Management', icon: Users },
  { path: '/analytics', label: 'System Analytics', icon: BarChart3 },
]

export default function Sidebar({ sidebarOpen = true, setSidebarOpen, mobileOpen, setMobileOpen }) {
  const location = useLocation()
  const { user, logout } = useAuth()

  const activePath = location.pathname

  const handleLinkClick = () => {
    if (setMobileOpen) setMobileOpen(false)
  }

  const handleLogout = async () => {
    try {
      await logout()
    } catch {
      // Handled in context
    }
  }

  const displayName = user?.email?.split('@')[0] || 'Admin'

  const content = (
    <div className="flex h-full flex-col justify-between bg-[#FFFFFF] border-r border-[#E1EDE6]">
      {/* Brand Header */}
      <div>
        <div className="flex h-16 items-center justify-between border-b border-[#E1EDE6] px-5">
          <Link
            to="/overview"
            onClick={handleLinkClick}
            className="flex items-center gap-2.5 transition-opacity hover:opacity-90"
          >
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#E1EDE6] text-[#214E34]">
              <ShieldCheck className="h-6 w-6" />
            </div>
            <div>
              <span className="text-base font-bold tracking-tight text-[#214E34]">PoultryGuard</span>
              <span className="block text-[10px] font-medium tracking-wide text-[#666666] uppercase">Admin Portal</span>
            </div>
          </Link>

          {/* Close button for both mobile drawer and desktop collapse */}
          <button
            type="button"
            onClick={() => {
              if (setMobileOpen) setMobileOpen(false)
              if (setSidebarOpen && window.innerWidth >= 1024) setSidebarOpen(false)
            }}
            className="rounded-lg p-1.5 text-[#666666] hover:bg-[#E1EDE6] hover:text-[#214E34] transition-colors cursor-pointer"
            aria-label="Close navigation"
            title="Close sidebar"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Navigation links */}
        <nav className="mt-4 px-3 space-y-1 overflow-y-auto max-h-[calc(100vh-10rem)]">
          {NAV_LINKS.map(({ path, label, icon: Icon, badge }) => {
            const isActive = activePath === path || (path !== '/overview' && activePath.startsWith(path))
            return (
              <Link
                key={path}
                to={path}
                onClick={handleLinkClick}
                className={`group flex items-center justify-between rounded-xl px-3.5 py-2.5 text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-[#214E34] text-[#FFFFFF] shadow-xs'
                    : 'text-[#666666] hover:bg-[#E1EDE6]/60 hover:text-[#214E34]'
                }`}
              >
                <div className="flex items-center gap-3 min-w-0">
                  <Icon
                    className={`h-4 w-4 shrink-0 transition-colors ${
                      isActive ? 'text-[#FFFFFF]' : 'text-[#666666] group-hover:text-[#214E34]'
                    }`}
                  />
                  <span className="truncate">{label}</span>
                </div>
                {badge && (
                  <span
                    className={`rounded-md px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wider ${
                      isActive ? 'bg-[#FFFFFF]/20 text-[#FFFFFF]' : 'bg-[#E1EDE6] text-[#214E34]'
                    }`}
                  >
                    {badge}
                  </span>
                )}
              </Link>
            )
          })}
        </nav>
      </div>

      {/* Footer / User Profile */}
      <div className="border-t border-[#E1EDE6] p-4 bg-[#F4F8F5]/60">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#E1EDE6] text-[#214E34] font-bold text-xs">
              {displayName.charAt(0).toUpperCase()}
            </div>
            <div className="min-w-0">
              <p className="truncate text-xs font-semibold text-[#222222]">{displayName}</p>
              <span className="inline-block rounded-full bg-[#214E34] px-1.5 py-0.2 text-[9px] font-medium text-[#FFFFFF]">
                Admin
              </span>
            </div>
          </div>
          <button
            type="button"
            onClick={handleLogout}
            className="rounded-lg p-2 text-[#666666] hover:bg-[#FDF2F2] hover:text-[#D9534F] transition-colors"
            title="Sign out"
            aria-label="Sign out"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  )

  return (
    <>
      {/* Desktop Sidebar (fixed full height with width 64) with smooth slide in/out transition */}
      <aside
        className={`hidden lg:fixed lg:inset-y-0 lg:left-0 lg:z-30 lg:flex lg:w-64 lg:flex-col transition-transform duration-300 ease-in-out ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {content}
      </aside>

      {/* Mobile Slide-over Drawer with Backdrop */}
      <div
        className={`fixed inset-0 z-40 lg:hidden transition-opacity duration-300 ${
          mobileOpen ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'
        }`}
      >
        {/* Backdrop */}
        <div
          className="absolute inset-0 bg-[#222222]/50 backdrop-blur-xs transition-opacity"
          onClick={() => setMobileOpen(false)}
          aria-hidden="true"
        />

        {/* Drawer panel */}
        <aside
          className={`relative flex w-72 max-w-[85vw] flex-col h-full bg-[#FFFFFF] shadow-2xl transition-transform duration-300 ease-in-out ${
            mobileOpen ? 'translate-x-0' : '-translate-x-full'
          }`}
        >
          {content}
        </aside>
      </div>
    </>
  )
}