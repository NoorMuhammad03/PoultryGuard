import { Outlet, useLocation } from 'react-router-dom'
import { useState } from 'react'
import Sidebar from './Sidebar.jsx'
import TopBar from './TopBar.jsx'

export default function DashboardLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [mobileOpen, setMobileOpen] = useState(false)
  const location = useLocation()

  const handleToggleSidebar = () => {
    if (window.innerWidth >= 1024) {
      setSidebarOpen((prev) => !prev)
    } else {
      setMobileOpen((prev) => !prev)
    }
  }

  return (
    <div className="min-h-screen bg-[#FFFFFF] flex">
      {/* Global Synchronized Sidebar / Drawer */}
      <Sidebar
        sidebarOpen={sidebarOpen}
        setSidebarOpen={setSidebarOpen}
        mobileOpen={mobileOpen}
        setMobileOpen={setMobileOpen}
      />

      {/* Main desktop offset container with smooth collapse/expand transition */}
      <div
        className={`flex flex-col min-h-screen flex-1 min-w-0 bg-[#FFFFFF] transition-all duration-300 ease-in-out ${
          sidebarOpen ? 'lg:pl-64' : 'lg:pl-0'
        }`}
      >
        {/* Top bar header with notifications and universal sidebar toggle trigger */}
        <TopBar
          onToggleSidebar={handleToggleSidebar}
          sidebarOpen={sidebarOpen}
          mobileOpen={mobileOpen}
          setMobileOpen={setMobileOpen}
        />

        {/* Responsive main scrollable view with smooth slide/fade screen transition */}
        <main
          key={location.pathname}
          className="screen-enter flex-1 w-full max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8 pb-16"
        >
          <Outlet />
        </main>
      </div>
    </div>
  )
}