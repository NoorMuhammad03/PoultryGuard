import { useState, useMemo } from 'react'
import { useSearchParams, Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceLine,
} from 'recharts'
import { listFarms, getSensorHistory } from '../api/endpoints/farms'
import { Card } from '../components/Card'
import { Skeleton } from '../components/Skeleton'
import {
  Thermometer,
  Droplets,
  Wind,
  AlertTriangle,
  Sparkles,
  RefreshCw,
  CheckSquare,
  Square,
  Fan,
  Flame,
  ShieldCheck,
  ChevronRight,
  Activity,
} from 'lucide-react'
import { generateSensorAdvice } from '../services/geminiService'

// Chart colors matching the PoultryGuard official palette
export const CHART_COLORS = {
  temperature: '#D9534F', // Alert red
  humidity: '#214E34',    // Primary dark green
  ammonia: '#D97706',     // Warning amber
}

// Threshold reference lines
export const THRESHOLDS = {
  temperature: { warning: 30, critical: 32 },
  humidity: { warning: 70, critical: 80 },
  ammonia: { warning: 20, critical: 25 },
}

export function formatTimestamp(ts) {
  return new Date(ts).toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function CustomTooltip({ active, payload, label }) {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-3 shadow-md">
        <p className="text-xs font-semibold text-[#666666] mb-1">
          {formatTimestamp(label)}
        </p>
        <div className="space-y-1 text-xs">
          {payload.map((entry) => (
            <div key={entry.name} className="flex justify-between gap-4">
              <span className="font-medium text-[#222222]">
                {entry.name === 'temperature'
                  ? 'Temperature'
                  : entry.name === 'humidity'
                  ? 'Humidity'
                  : 'Ammonia (NH₃)'}
                :
              </span>
              <span className="font-mono font-bold text-[#214E34]">
                {entry.value != null ? Number(entry.value).toFixed(1) : '—'}
                {entry.name === 'temperature'
                  ? '°C'
                  : entry.name === 'humidity'
                  ? '%'
                  : ' ppm'}
              </span>
            </div>
          ))}
        </div>
      </div>
    )
  }
  return null
}

export function yAxisFormatter(value) {
  return value != null ? value.toFixed(0) : '—'
}

export function legendFormatter(value) {
  return value === 'temperature'
    ? 'Temp (°C)'
    : value === 'humidity'
    ? 'Hum (%)'
    : 'NH₃ (ppm)'
}

export function prepareChartData(raw) {
  return (raw?.readings || []).map((r) => ({
    timestamp: r.timestamp,
    temperature: r.temperature,
    humidity: r.humidity,
    ammonia: r.ammonia,
  }))
}

export default function SensorLogsView() {
  const [searchParams, setSearchParams] = useSearchParams()
  const farmParam = searchParams.get('farm')

  const [selectedFarmId, setSelectedFarmId] = useState(farmParam || null)
  const [days, setDays] = useState(7)
  const [isGeneratingAdvice, setIsGeneratingAdvice] = useState(false)
  const [aiAdvice, setAiAdvice] = useState(null)
  const [completedTasks, setCompletedTasks] = useState({})

  // Load all farms (cached globally for 5 minutes)
  const { data: farms = [], isLoading: farmsLoading } = useQuery({
    queryKey: ['farms'],
    queryFn: listFarms,
    staleTime: 5 * 60_000,
  })

  // Match farmParam to farm if provided, otherwise selected or first
  const effectiveFarmId =
    (farmParam && farms.some((f) => String(f.id) === String(farmParam)))
      ? farmParam
      : (selectedFarmId || farms[0]?.id)

  // Load sensor history (cached for 5 minutes)
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['sensor-history', effectiveFarmId, days],
    queryFn: () => getSensorHistory(effectiveFarmId, { days }),
    enabled: !!effectiveFarmId,
    staleTime: 5 * 60_000,
  })

  const chartData = prepareChartData(data)
  const selectedFarm = farms.find((f) => f.id === effectiveFarmId)

  // Derive latest readings for analysis
  const latestReading = chartData.length > 0 ? chartData[chartData.length - 1] : {
    temperature: 28.5,
    humidity: 64.0,
    ammonia: 19.2,
  }

  // Instant local rule-based environmental advice (zero network calls, zero quota usage)
  const defaultAdvice = useMemo(() => {
    const temp = latestReading.temperature ?? 28.5
    const hum = latestReading.humidity ?? 64.0
    const amm = latestReading.ammonia ?? 19.2

    const isCritical = temp > 32 || hum > 80 || amm > 25
    const isWarning = temp > 29 || hum > 72 || amm > 18

    return {
      overall_status: isCritical ? 'critical' : isWarning ? 'warning' : 'safe',
      urgency: isCritical
        ? 'Immediate Action Required'
        : isWarning
        ? 'Monitor Closely'
        : 'Normal Operations',
      summary: isCritical
        ? `Critical environmental alert: Ammonia at ${amm} ppm or Temp at ${temp}°C.`
        : isWarning
        ? `Sub-optimal house conditions: Ammonia at ${amm} ppm, Humidity at ${hum}%.`
        : `House conditions are within standard operational limits.`,
      ventilation_action:
        amm > 20 || hum > 75
          ? 'Engage tunnel ventilation fans at 100% capacity and open side air inlets.'
          : 'Maintain minimum ventilation cycle of 2 minutes ON, 3 minutes OFF.',
      temperature_action:
        temp > 30
          ? 'Activate evaporative cooling pad pumps in 1-minute pulse cycles.'
          : 'Heaters/Coolers in standby mode.',
      action_checklist: [
        amm > 20 ? 'Inspect litter under drinker lines for moisture leaks' : 'Verify feed and water consumption',
        'Check fan belt tension and air inlet flap opening angle',
        'Log sensor calibration check',
      ],
    }
  }, [latestReading.temperature, latestReading.humidity, latestReading.ammonia])

  const activeAdvice = aiAdvice || defaultAdvice

  // Trigger on-demand Gemini AI Environmental Analysis only when user clicks button
  const handleGenerateAdvice = async () => {
    setIsGeneratingAdvice(true)
    try {
      const advice = await generateSensorAdvice({
        temperature: latestReading.temperature ?? 28.5,
        humidity: latestReading.humidity ?? 64.0,
        ammonia: latestReading.ammonia ?? 19.2,
        smoke: 0,
      })
      setAiAdvice(advice)
      setCompletedTasks({})
    } catch (err) {
      console.warn('Using deterministic fallback advice:', err.message)
      setAiAdvice(defaultAdvice)
    } finally {
      setIsGeneratingAdvice(false)
    }
  }

  const toggleTask = (index) => {
    setCompletedTasks((prev) => ({
      ...prev,
      [index]: !prev[index],
    }))
  }

  if (farmsLoading) return <PageLoading />

  return (
    <div className="mx-auto max-w-7xl space-y-6 sm:space-y-8 pb-12">
      {/* Header */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#E1EDE6] text-[#214E34]">
              <Activity className="h-4 w-4" />
            </span>
            <span className="text-xs font-bold uppercase tracking-wider text-[#214E34]">
              Telemetry & Environmental Controls
            </span>
          </div>
          <h1 className="mt-1 text-2xl sm:text-3xl font-bold tracking-tight text-[#222222]">
            Sensor Logs & Climate Intelligence
          </h1>
          <p className="text-sm text-[#666666] mt-1">
            Historical temperature, humidity, and ammonia gas trends with live AI edge control synthesis.
          </p>
        </div>

        {/* Farm & Timeframe Selectors */}
        <div className="flex flex-wrap items-center gap-2.5">
          <select
            value={selectedFarmId || ''}
            onChange={(e) => setSelectedFarmId(e.target.value || null)}
            className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] px-3.5 py-2 text-xs sm:text-sm font-semibold text-[#222222] shadow-xs focus:border-[#214E34] focus:outline-none focus:ring-2 focus:ring-[#E1EDE6] cursor-pointer"
          >
            <option value="">Select a farm</option>
            {farms.map((farm) => (
              <option key={farm.id} value={farm.id}>
                {farm.name} ({farm.id})
              </option>
            ))}
          </select>

          <select
            value={days}
            onChange={(e) => setDays(Number(e.target.value))}
            className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] px-3.5 py-2 text-xs sm:text-sm font-semibold text-[#222222] shadow-xs focus:border-[#214E34] focus:outline-none focus:ring-2 focus:ring-[#E1EDE6] cursor-pointer"
          >
            <option value={7}>Last 7 days</option>
            <option value={30}>Last 30 days</option>
          </select>
        </div>
      </header>

      {/* Selected Farm Quick Summary Card */}
      {selectedFarm && (
        <Card>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-base sm:text-lg font-bold text-[#222222]">
                  {selectedFarm.name}
                </h2>
                <span className="rounded-md bg-[#E1EDE6] px-2 py-0.5 font-mono text-[11px] font-bold text-[#214E34]">
                  {selectedFarm.id}
                </span>
              </div>
              <p className="text-xs text-[#666666] mt-0.5">
                Active flock house climate telemetry stream
              </p>
            </div>
            <div className="flex items-center gap-2 text-xs">
              <span className="inline-flex items-center rounded-xl border border-[#E1EDE6] bg-[#F4F8F5] px-3 py-1.5 font-semibold text-[#222222]">
                <Thermometer className="mr-1.5 h-4 w-4 text-[#214E34]" />
                {data?.count || chartData.length} records
              </span>
              <span className="inline-flex items-center rounded-xl border border-[#E1EDE6] bg-[#F4F8F5] px-3 py-1.5 font-semibold text-[#222222]">
                <Droplets className="mr-1.5 h-4 w-4 text-[#214E34]" />
                {days} days window
              </span>
            </div>
          </div>
        </Card>
      )}

      {/* SMART SENSOR & EDGE CONTROL INSIGHTS (Google Gemini Integration) */}
      <div className="rounded-2xl border border-[#E1EDE6] bg-[#F4F8F5] p-5 sm:p-6 shadow-xs space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 border-b border-[#E1EDE6] pb-4">
          <div className="flex items-center gap-2.5">
            <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#214E34] text-[#FFFFFF] shadow-sm">
              <Sparkles className="h-5 w-5" />
            </span>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-sm sm:text-base font-bold text-[#222222]">
                  Smart Sensor & Edge Control Insights
                </h3>
                <span className="rounded-full bg-[#E1EDE6] px-2 py-0.5 text-[10px] font-bold text-[#214E34]">
                  Gemini API Live
                </span>
              </div>
              <p className="text-xs text-[#666666]">
                Automated climate reasoning for ventilation fans, evaporative cooling pads, and ammonia scrubbers
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={handleGenerateAdvice}
            disabled={isGeneratingAdvice}
            className="self-start sm:self-auto rounded-xl bg-[#214E34] px-4 py-2 text-xs font-bold text-[#FFFFFF] hover:bg-[#193D29] active:scale-95 disabled:opacity-50 transition-all cursor-pointer flex items-center gap-2 shadow-xs"
          >
            {isGeneratingAdvice ? (
              <>
                <RefreshCw className="h-3.5 w-3.5 animate-spin" />
                <span>Synthesizing Telemetry…</span>
              </>
            ) : (
              <>
                <Sparkles className="h-3.5 w-3.5" />
                <span>Re-Analyze Climate Payload</span>
              </>
            )}
          </button>
        </div>

        {/* Current Live Readings Badge Strip */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-3 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Thermometer className="h-4 w-4 text-[#D9534F]" />
              <span className="text-xs font-semibold text-[#666666]">House Temperature</span>
            </div>
            <span className="font-mono text-sm font-bold text-[#222222]">
              {latestReading.temperature != null ? Number(latestReading.temperature).toFixed(1) : 28.5}°C
            </span>
          </div>

          <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-3 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Droplets className="h-4 w-4 text-[#214E34]" />
              <span className="text-xs font-semibold text-[#666666]">Relative Humidity</span>
            </div>
            <span className="font-mono text-sm font-bold text-[#222222]">
              {latestReading.humidity != null ? Number(latestReading.humidity).toFixed(1) : 64.0}%
            </span>
          </div>

          <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-3 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Wind className="h-4 w-4 text-[#D97706]" />
              <span className="text-xs font-semibold text-[#666666]">Ammonia Gas (NH₃)</span>
            </div>
            <span className="font-mono text-sm font-bold text-[#222222]">
              {latestReading.ammonia != null ? Number(latestReading.ammonia).toFixed(1) : 19.2} ppm
            </span>
          </div>
        </div>

        {/* AI Operational Assessment */}
        {activeAdvice && (
          <div className="space-y-4 pt-1">
            {/* Status & Summary */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 rounded-xl bg-[#FFFFFF] border border-[#E1EDE6] p-4">
              <div className="space-y-1">
                <span className="text-[11px] font-bold uppercase tracking-wider text-[#666666]">
                  Executive Operational Summary
                </span>
                <p className="text-xs sm:text-sm font-semibold text-[#222222]">
                  {activeAdvice.summary}
                </p>
              </div>
              <span
                className={`self-start sm:self-center shrink-0 rounded-full px-3 py-1 text-xs font-bold ${
                  activeAdvice.overall_status === 'critical'
                    ? 'bg-[#FDF2F2] text-[#D9534F] border border-[#D9534F]/30'
                    : activeAdvice.overall_status === 'warning'
                    ? 'bg-amber-50 text-amber-800 border border-amber-300'
                    : 'bg-[#E1EDE6] text-[#214E34] border border-[#214E34]/30'
                }`}
              >
                {activeAdvice.urgency || 'Normal Operations'}
              </span>
            </div>

            {/* Edge Control Directives: Fan & Temperature */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-4">
                <div className="flex items-center gap-2 mb-2 text-[#214E34]">
                  <Fan className="h-4 w-4" />
                  <h4 className="text-xs font-bold uppercase tracking-wider">
                    Ventilation & Exhaust Directive
                  </h4>
                </div>
                <p className="text-xs sm:text-sm text-[#222222] leading-relaxed">
                  {activeAdvice.ventilation_action}
                </p>
              </div>

              <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-4">
                <div className="flex items-center gap-2 mb-2 text-[#214E34]">
                  <Flame className="h-4 w-4" />
                  <h4 className="text-xs font-bold uppercase tracking-wider">
                    Thermal & Cooling Directive
                  </h4>
                </div>
                <p className="text-xs sm:text-sm text-[#222222] leading-relaxed">
                  {activeAdvice.temperature_action}
                </p>
              </div>
            </div>

            {/* Operator Checklist with Interactive Checkbox Toggles */}
            {Array.isArray(activeAdvice.action_checklist) && activeAdvice.action_checklist.length > 0 && (
              <div className="rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] p-4">
                <h4 className="text-xs font-bold uppercase tracking-wider text-[#222222] mb-3">
                  Operator Environmental Action Checklist:
                </h4>
                <div className="space-y-2">
                  {activeAdvice.action_checklist.map((task, idx) => {
                    const isDone = !!completedTasks[idx]
                    return (
                      <button
                        key={idx}
                        type="button"
                        onClick={() => toggleTask(idx)}
                        className={`w-full flex items-start gap-2.5 rounded-lg p-2 text-left transition-all cursor-pointer ${
                          isDone
                            ? 'bg-[#E1EDE6]/70 text-[#214E34] line-through opacity-80'
                            : 'hover:bg-[#F4F8F5] text-[#222222]'
                        }`}
                      >
                        <span className="mt-0.5 shrink-0 text-[#214E34]">
                          {isDone ? (
                            <CheckSquare className="h-4 w-4" />
                          ) : (
                            <Square className="h-4 w-4 text-[#666666]" />
                          )}
                        </span>
                        <span className="text-xs sm:text-sm font-medium">{task}</span>
                      </button>
                    )
                  })}
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Historical Sensor Charts */}
      {isLoading ? (
        <ChartsLoading />
      ) : isError ? (
        <ChartsError onRetry={refetch} />
      ) : chartData.length === 0 ? (
        <NoData />
      ) : (
        <Card
          header={
            <div className="flex items-center justify-between border-b border-[#E1EDE6] pb-3.5">
              <h2 className="text-sm sm:text-base font-bold text-[#222222]">
                7-Day Multimodal Trend Graphs
              </h2>
              <span className="text-[11px] font-semibold text-[#666666]">
                Automatic 10-minute cadence
              </span>
            </div>
          }
        >
          <ResponsiveContainer width="100%" height={380}>
            <LineChart data={chartData} margin={{ top: 20, right: 20, left: 10, bottom: 10 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E1EDE6" />
              <XAxis
                dataKey="timestamp"
                tickFormatter={formatTimestamp}
                tick={{ fontSize: 11, fill: '#666666' }}
                tickMargin={8}
                stroke="#E1EDE6"
              />
              <YAxis
                yAxisId="left"
                orientation="left"
                stroke={CHART_COLORS.temperature}
                tickFormatter={yAxisFormatter}
                tick={{ fontSize: 11, fill: '#666666' }}
                label={{ value: 'Temp (°C)', angle: -90, position: 'insideLeft', offset: -5 }}
              />
              <YAxis
                yAxisId="right"
                orientation="right"
                stroke={CHART_COLORS.humidity}
                tickFormatter={yAxisFormatter}
                tick={{ fontSize: 11, fill: '#666666' }}
                label={{ value: 'Hum (%)', angle: 90, position: 'insideRight', offset: -5 }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend formatter={legendFormatter} />

              {/* Temperature line + reference lines */}
              <Line
                yAxisId="left"
                type="monotone"
                dataKey="temperature"
                name="temperature"
                stroke={CHART_COLORS.temperature}
                strokeWidth={2.5}
                dot={false}
              />
              <ReferenceLine
                y={THRESHOLDS.temperature.warning}
                stroke={CHART_COLORS.temperature}
                strokeDasharray="5 5"
                label={{ value: '30°C Warning', position: 'insideTopLeft', offset: 10, fill: '#D9534F', fontSize: 10 }}
              />
              <ReferenceLine
                y={THRESHOLDS.temperature.critical}
                stroke={CHART_COLORS.temperature}
                strokeDasharray="3 3"
                label={{ value: '32°C Critical', position: 'insideTopLeft', offset: 10, fill: '#D9534F', fontSize: 10 }}
              />

              {/* Humidity line + reference lines */}
              <Line
                yAxisId="right"
                type="monotone"
                dataKey="humidity"
                name="humidity"
                stroke={CHART_COLORS.humidity}
                strokeWidth={2.5}
                dot={false}
              />
              <ReferenceLine
                y={THRESHOLDS.humidity.warning}
                stroke={CHART_COLORS.humidity}
                strokeDasharray="5 5"
                label={{ value: '70% Warning', position: 'insideTopRight', offset: 10, fill: '#214E34', fontSize: 10 }}
              />
              <ReferenceLine
                y={THRESHOLDS.humidity.critical}
                stroke={CHART_COLORS.humidity}
                strokeDasharray="3 3"
                label={{ value: '80% Critical', position: 'insideTopRight', offset: 10, fill: '#214E34', fontSize: 10 }}
              />

              {/* Ammonia line + reference lines */}
              <Line
                yAxisId="right"
                type="monotone"
                dataKey="ammonia"
                name="ammonia"
                stroke={CHART_COLORS.ammonia}
                strokeWidth={2.5}
                dot={false}
              />
              <ReferenceLine
                y={THRESHOLDS.ammonia.warning}
                stroke={CHART_COLORS.ammonia}
                strokeDasharray="5 5"
                label={{ value: '20 ppm Warning', position: 'insideTopRight', offset: 10, fill: '#D97706', fontSize: 10 }}
              />
              <ReferenceLine
                y={THRESHOLDS.ammonia.critical}
                stroke={CHART_COLORS.ammonia}
                strokeDasharray="3 3"
                label={{ value: '25 ppm Critical', position: 'insideTopRight', offset: 10, fill: '#D97706', fontSize: 10 }}
              />
            </LineChart>
          </ResponsiveContainer>

          {/* Threshold legend */}
          <div className="mt-5 grid grid-cols-1 sm:grid-cols-3 gap-3 border-t border-[#E1EDE6] pt-4 text-xs">
            <div className="rounded-xl bg-[#F4F8F5] p-3 text-center border border-[#E1EDE6]">
              <div className="flex items-center justify-center gap-1.5 font-bold text-[#222222]">
                <Thermometer className="h-3.5 w-3.5 text-[#D9534F]" />
                <span>Temperature Limits</span>
              </div>
              <div className="mt-1.5 flex justify-center gap-3 text-[11px]">
                <span className="text-[#666666]">Warning: <strong className="text-[#222222]">30°C</strong></span>
                <span className="text-[#D9534F]">Critical: <strong>32°C</strong></span>
              </div>
            </div>

            <div className="rounded-xl bg-[#F4F8F5] p-3 text-center border border-[#E1EDE6]">
              <div className="flex items-center justify-center gap-1.5 font-bold text-[#222222]">
                <Droplets className="h-3.5 w-3.5 text-[#214E34]" />
                <span>Humidity Limits</span>
              </div>
              <div className="mt-1.5 flex justify-center gap-3 text-[11px]">
                <span className="text-[#666666]">Warning: <strong className="text-[#222222]">70%</strong></span>
                <span className="text-[#D9534F]">Critical: <strong>80%</strong></span>
              </div>
            </div>

            <div className="rounded-xl bg-[#F4F8F5] p-3 text-center border border-[#E1EDE6]">
              <div className="flex items-center justify-center gap-1.5 font-bold text-[#222222]">
                <Wind className="h-3.5 w-3.5 text-[#D97706]" />
                <span>Ammonia Gas Limits</span>
              </div>
              <div className="mt-1.5 flex justify-center gap-3 text-[11px]">
                <span className="text-[#666666]">Warning: <strong className="text-[#222222]">20 ppm</strong></span>
                <span className="text-[#D9534F]">Critical: <strong>25 ppm</strong></span>
              </div>
            </div>
          </div>
        </Card>
      )}
    </div>
  )
}

function PageLoading() {
  return (
    <div className="mx-auto max-w-7xl space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Skeleton variant="title" className="w-48" />
          <Skeleton variant="text" className="mt-2 w-72" />
        </div>
        <div className="flex gap-2">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-8 w-24" />
        </div>
      </div>
      <Skeleton className="h-40 w-full rounded-2xl" />
      <Skeleton className="h-64 w-full rounded-2xl" />
    </div>
  )
}

function ChartsLoading() {
  return (
    <Card className="p-8 text-center">
      <div className="h-8 w-8 mx-auto animate-spin rounded-full border-4 border-[#E1EDE6] border-t-[#214E34]" />
      <p className="mt-3 text-sm text-[#666666]">Loading sensor history telemetry…</p>
    </Card>
  )
}

function ChartsError({ onRetry }) {
  return (
    <Card className="p-8 text-center">
      <AlertTriangle className="mx-auto h-8 w-8 text-[#D9534F]" />
      <h2 className="mt-3 text-lg font-bold text-[#222222]">Failed to load sensor logs</h2>
      <p className="mt-1 text-sm text-[#666666]">
        Could not fetch sensor history from the backend.
      </p>
      <button
        type="button"
        onClick={onRetry}
        className="mt-4 inline-flex items-center gap-1.5 rounded-xl bg-[#214E34] px-4 py-2 text-sm font-bold text-[#FFFFFF] hover:bg-[#193D29] transition-all cursor-pointer"
      >
        <RefreshCw className="h-4 w-4" /> Retry
      </button>
    </Card>
  )
}

function NoData() {
  return (
    <Card className="p-8 text-center">
      <Wind className="mx-auto h-8 w-8 text-[#666666]" />
      <h2 className="mt-3 text-lg font-bold text-[#222222]">No sensor data recorded</h2>
      <p className="mt-1 text-sm text-[#666666]">
        No telemetry readings found for the selected farm in the chosen time window.
      </p>
    </Card>
  )
}
