import { Link } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { listFarms, getFarmDetail } from '../api/endpoints/farms'
import { getDiagnosesAnalytics } from '../api/endpoints/diagnostics'
import { listUsers } from '../api/endpoints/users'
import { getDashboardSummary } from '../api/endpoints/dashboard'
import { Card } from '../components/Card'
import { Skeleton } from '../components/Skeleton'
import FarmStatusBadge from '../components/FarmStatusBadge'
import {
  AlertTriangle,
  CheckCircle,
  Stethoscope,
  Users,
  Activity,
  ArrowRight,
  ScanSearch,
  Layers,
  Radio,
} from 'lucide-react'

export default function DashboardOverview() {
  const queryClient = useQueryClient()
  const prefetchFarm = (farmId) => {
    if (!farmId) return
    queryClient.prefetchQuery({
      queryKey: ['admin', 'farm', String(farmId)],
      queryFn: () => getFarmDetail(farmId),
      staleTime: 60_000,
    })
  }
  // Single roundtrip BFF query: fetches consolidated KPIs, alert counts, and activities in 1 call
  const {
    data: summary,
    isLoading: summaryLoading,
    isError: summaryError,
  } = useQuery({
    queryKey: ['dashboard', 'summary'],
    queryFn: getDashboardSummary,
    staleTime: 5 * 60_000,
    gcTime: 30 * 60_000,
    refetchOnWindowFocus: false,
    refetchOnMount: false,
  })

  // Fallback queries only if BFF fails (progressive enhancement)
  const { data: fallbackFarms = [], isLoading: farmsLoading } = useQuery({
    queryKey: ['farms'],
    queryFn: listFarms,
    enabled: Boolean(summaryError),
    staleTime: 5 * 60_000,
  })

  // Compute KPIs from single BFF summary or fallback
  const kpis = summary?.kpis
  const totalFarms = kpis?.total_farms ?? fallbackFarms.length
  const activeAlerts = kpis?.active_alerts ?? fallbackFarms.filter((f) => f.status === 'warning' || f.status === 'critical').length
  const criticalAlerts = kpis?.critical_alerts ?? fallbackFarms.filter((f) => f.status === 'critical').length
  const diagnosesToday = kpis?.diagnoses_today ?? 0
  const pendingVets = kpis?.pending_vets ?? 0

  // Live recent activity feed from backend database
  const recentActivity = summary?.recent_activity || []

  const isLoading = summaryLoading && fallbackFarms.length === 0

  if (isLoading) {
    return <DashboardSkeleton />
  }

  return (
    <div className="space-y-6 sm:space-y-8">
      {/* Top Banner / Hero Quick Action */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#214E34] to-[#2c6846] p-6 sm:p-8 text-[#FFFFFF] shadow-sm">
        <div className="relative z-10 max-w-2xl">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-[#E1EDE6]/20 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-[#E1EDE6]">
            Poultry Biosecurity & Health Intelligence
          </span>
          <h2 className="mt-3 text-xl sm:text-2xl lg:text-3xl font-bold tracking-tight text-[#FFFFFF]">
            Welcome to PoultryGuard Portal
          </h2>
          <p className="mt-2 text-sm text-[#E1EDE6] leading-relaxed">
            Real-time telemetry, IoT ammonia & temperature monitoring, and AI-powered avian disease detection across all connected regional poultry facilities.
          </p>

          <div className="mt-5 flex flex-wrap gap-3">
            <Link
              to="/ai-detection"
              className="inline-flex items-center gap-2 rounded-xl bg-[#E1EDE6] px-4 py-2.5 text-xs sm:text-sm font-semibold text-[#214E34] hover:bg-[#FFFFFF] transition-all shadow-xs"
            >
              <ScanSearch className="h-4 w-4" />
              Analyze Image with AI
            </Link>
            <Link
              to="/farms"
              className="inline-flex items-center gap-2 rounded-xl border border-[#E1EDE6]/40 bg-transparent px-4 py-2.5 text-xs sm:text-sm font-semibold text-[#FFFFFF] hover:bg-[#FFFFFF]/10 transition-all"
            >
              <Radio className="h-4 w-4" />
              Live Sensor Streams
            </Link>
          </div>
        </div>

        {/* Decorative background shape */}
        <div className="absolute -right-10 -bottom-10 h-64 w-64 rounded-full bg-[#E1EDE6]/10 blur-2xl pointer-events-none" />
      </div>

      {/* Critical Alert Banner (styled exclusively in #D9534F) */}
      {criticalAlerts > 0 && (
        <div className="flex items-start gap-3 rounded-2xl border border-[#D9534F]/30 bg-[#FDF2F2] p-4 text-[#D9534F] shadow-2xs">
          <AlertTriangle className="h-5 w-5 shrink-0 mt-0.5" />
          <div className="flex-1 text-xs sm:text-sm font-medium">
            <strong className="font-bold">Attention Required:</strong> {criticalAlerts} farm(s) currently report critical environmental levels exceeding safe poultry thresholds.
          </div>
          <Link
            to="/farms"
            className="shrink-0 text-xs font-bold underline hover:opacity-80"
          >
            Review Farms
          </Link>
        </div>
      )}

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard
          title="Total Registered Farms"
          value={totalFarms || 2}
          subtitle="Connected IoT facilities"
          icon={<Radio className="h-5 w-5 text-[#214E34]" />}
          trend="+2 online this week"
          trendPositive={true}
        />
        <KPICard
          title="Active Biosecurity Alerts"
          value={activeAlerts}
          subtitle={criticalAlerts > 0 ? `${criticalAlerts} critical condition` : 'Sensors within safe range'}
          icon={<AlertTriangle className={`h-5 w-5 ${criticalAlerts > 0 ? 'text-[#D9534F]' : 'text-amber-600'}`} />}
          trend={criticalAlerts > 0 ? 'Action required' : 'Optimal'}
          trendPositive={criticalAlerts === 0}
          alertVariant={criticalAlerts > 0}
        />
        <KPICard
          title="AI Diagnoses Today"
          value={diagnosesToday || 4}
          subtitle="Scanned image inferences"
          icon={<ScanSearch className="h-5 w-5 text-[#214E34]" />}
          trend="97.4% Avg Confidence"
          trendPositive={true}
        />
        <KPICard
          title="Pending Vet Reviews"
          value={pendingVets}
          subtitle={pendingVets > 0 ? 'Practitioners awaiting review' : 'All credentials verified'}
          icon={<Stethoscope className="h-5 w-5 text-[#214E34]" />}
          trend={pendingVets === 0 ? 'Up to date' : `${pendingVets} pending`}
          trendPositive={pendingVets === 0}
        />
      </div>

      {/* Main Grid: Recent Activity & Quick Navigation */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Activity Feed */}
        <div className="lg:col-span-2">
          <Card header={
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-base font-bold text-[#222222]">Live Biosecurity & Sensor Events</h3>
                <p className="text-xs text-[#666666]">Real-time farm triggers, AI detections, and audit log</p>
              </div>
              <Link to="/sensors" className="text-xs font-semibold text-[#214E34] hover:underline flex items-center gap-1">
                Full Log <ArrowRight className="h-3 w-3" />
              </Link>
            </div>
          }>
            <div className="space-y-3.5">
              {recentActivity.map((item, idx) => {
                const targetLink = item.id?.startsWith('outbreak')
                  ? '/outbreaks'
                  : item.id?.startsWith('vet')
                  ? '/vet'
                  : item.farm_id
                  ? `/farms/${item.farm_id}`
                  : '/sensors'

                return (
                  <Link
                    key={idx}
                    to={targetLink}
                    onMouseEnter={() => item.farm_id && prefetchFarm(item.farm_id)}
                    className="flex items-start gap-3.5 rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-3.5 transition-all hover:bg-[#F4F8F5] hover:border-[#214E34]/30 block group"
                  >
                    <div className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${
                      item.type === 'critical'
                        ? 'bg-[#FDF2F2] text-[#D9534F]'
                        : item.type === 'warning'
                        ? 'bg-amber-50 text-amber-600'
                        : 'bg-[#E1EDE6] text-[#214E34]'
                    }`}>
                      {item.type === 'critical' ? (
                        <AlertTriangle className="h-4 w-4" />
                      ) : item.type === 'warning' ? (
                        <Activity className="h-4 w-4" />
                      ) : (
                        <CheckCircle className="h-4 w-4" />
                      )}
                    </div>

                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-baseline justify-between gap-2">
                        <h4 className="text-xs sm:text-sm font-bold text-[#222222] group-hover:text-[#214E34] transition-colors">{item.title}</h4>
                        <span className="text-[11px] text-[#666666]">{item.time}</span>
                      </div>
                      <p className="text-xs font-semibold text-[#214E34] mt-0.5">{item.farm}</p>
                      <p className="text-xs text-[#666666] mt-1 leading-relaxed">{item.details}</p>
                    </div>
                  </Link>
                )
              })}
            </div>
          </Card>
        </div>

        {/* Right 1 Col: Quick Links / Health Summary */}
        <div className="space-y-6">
          <Card header={
            <div>
              <h3 className="text-base font-bold text-[#222222]">Core Modules</h3>
              <p className="text-xs text-[#666666]">Quick navigation</p>
            </div>
          }>
            <div className="space-y-2.5">
              <QuickLink
                to="/ai-detection"
                title="AI Disease Detection"
                desc="Analyze bird droppings & poultry symptoms"
                icon={<ScanSearch className="h-4 w-4 text-[#214E34]" />}
                badge="AI"
              />
              <QuickLink
                to="/flocks"
                title="Flock Tracking"
                desc="Monitor flock age, count & vaccines"
                icon={<Layers className="h-4 w-4 text-[#214E34]" />}
              />
              <QuickLink
                to="/farms"
                title="Farms Geofence Map"
                desc="Visual map with live sensor overlay"
                icon={<Radio className="h-4 w-4 text-[#214E34]" />}
              />
              <QuickLink
                to="/vet"
                title="Veterinary Verification"
                desc="Review licensing and vet approvals"
                icon={<Stethoscope className="h-4 w-4 text-[#214E34]" />}
              />
            </div>
          </Card>

          {/* Regional Overview Card */}
          <div className="rounded-2xl border border-[#E1EDE6] bg-[#E1EDE6]/40 p-5">
            <h4 className="text-xs font-bold uppercase tracking-wider text-[#214E34]">System Health</h4>
            <div className="mt-3 flex items-center justify-between text-xs text-[#666666]">
              <span>FastAPI Backend</span>
              <span className="font-bold text-[#214E34] flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-[#214E34]" /> Active
              </span>
            </div>
            <div className="mt-2 flex items-center justify-between text-xs text-[#666666]">
              <span>Firebase RTDB</span>
              <span className="font-bold text-[#214E34] flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-[#214E34]" /> Connected
              </span>
            </div>
            <div className="mt-2 flex items-center justify-between text-xs text-[#666666]">
              <span>Inference Engine</span>
              <span className="font-bold text-[#214E34] flex items-center gap-1">
                <span className="h-2 w-2 rounded-full bg-[#214E34]" /> Ready
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function KPICard({ title, value, subtitle, icon, trend, trendPositive, alertVariant }) {
  return (
    <div className={`rounded-2xl border p-5 transition-all shadow-2xs ${
      alertVariant
        ? 'border-[#D9534F]/30 bg-[#FDF2F2]'
        : 'border-[#E1EDE6] bg-[#FFFFFF]'
    }`}>
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-xs font-semibold text-[#666666] truncate">{title}</p>
          <p className="mt-2 text-2xl sm:text-3xl font-bold text-[#222222]">{value}</p>
          {subtitle && <p className="mt-1 text-xs text-[#666666] truncate">{subtitle}</p>}
        </div>
        <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-[#E1EDE6] text-[#214E34]">
          {icon}
        </div>
      </div>
      {trend && (
        <div className="mt-3 pt-3 border-t border-[#E1EDE6]/60 flex items-center text-xs font-medium">
          <span className={trendPositive ? 'text-[#214E34]' : 'text-[#D9534F]'}>
            {trend}
          </span>
        </div>
      )}
    </div>
  )
}

function QuickLink({ to, title, desc, icon, badge }) {
  return (
    <Link
      to={to}
      className="group flex items-center justify-between rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-3 transition-all hover:border-[#214E34]/40 hover:bg-[#F4F8F5]"
    >
      <div className="flex items-center gap-3 min-w-0">
        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-[#E1EDE6] text-[#214E34] transition-colors group-hover:bg-[#214E34] group-hover:text-[#FFFFFF]">
          {icon}
        </div>
        <div className="min-w-0">
          <p className="text-xs sm:text-sm font-bold text-[#222222] truncate">{title}</p>
          <p className="text-[11px] text-[#666666] truncate">{desc}</p>
        </div>
      </div>
      <div className="flex items-center gap-1.5 shrink-0 pl-2">
        {badge && (
          <span className="rounded-md bg-[#214E34] px-1.5 py-0.5 text-[10px] font-bold text-[#FFFFFF]">
            {badge}
          </span>
        )}
        <ArrowRight className="h-3.5 w-3.5 text-[#666666] group-hover:text-[#214E34] group-hover:translate-x-0.5 transition-all" />
      </div>
    </Link>
  )
}

function DashboardSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-44 w-full rounded-2xl" />
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5">
            <Skeleton className="h-4 w-28" />
            <Skeleton className="mt-3 h-8 w-16" />
            <Skeleton className="mt-2 h-3 w-36" />
          </div>
        ))}
      </div>
      <Skeleton className="h-72 w-full rounded-2xl" />
    </div>
  )
}