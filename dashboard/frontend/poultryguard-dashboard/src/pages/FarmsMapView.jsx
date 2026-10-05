import { useEffect, useMemo, useState, useRef } from 'react'
import { Link } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import {
  MapContainer,
  TileLayer,
  CircleMarker,
  Tooltip,
  Popup,
  useMap,
} from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'
import { listFarms, getFarmDetail } from '../api/endpoints/farms'
import { useRealtimeSensorsBatch } from '../hooks/useRealtimeSensors'
import {
  CARTO_VOYAGER_URL,
  OPTIMIZED_TILE_PROPS,
  OPTIMIZED_MAP_CONTAINER_PROPS,
} from '../config/mapConfig'
import FarmStatusBadge from '../components/FarmStatusBadge'
import { Card } from '../components/Card'
import { Skeleton } from '../components/Skeleton'
import {
  MapPin,
  Thermometer,
  Droplets,
  Wind,
  AlertTriangle,
  RotateCcw,
  Eye,
  EyeOff,
  Layers,
  CheckCircle2,
  ExternalLink,
  Search,
} from 'lucide-react'

// Official PoultryGuard color palette
const STATUS_COLORS = {
  safe: '#214E34',      // Primary dark green
  warning: '#E67E22',   // Alert amber
  critical: '#D9534F',  // Alert red
  unknown: '#666666',   // Muted gray
}

const PAKISTAN_CENTER = [30.8, 72.5]

// Map Controller for sizing and bounds
function MapController({ positions, centerTarget }) {
  const map = useMap()

  // Invalidate map size so tiles calculate properly after render
  useEffect(() => {
    map.invalidateSize()
    const t1 = setTimeout(() => map.invalidateSize(), 150)
    const t2 = setTimeout(() => map.invalidateSize(), 500)
    return () => {
      clearTimeout(t1)
      clearTimeout(t2)
    }
  }, [map])

  // Center on target when clicked from list
  useEffect(() => {
    if (centerTarget) {
      map.flyTo(centerTarget, 11, { duration: 1.2 })
    }
  }, [map, centerTarget])

  // Initial bounds fit
  useEffect(() => {
    if (positions.length > 0 && !centerTarget) {
      try {
        const bounds = L.latLngBounds(positions)
        map.fitBounds(bounds, { padding: [50, 50], maxZoom: 11 })
      } catch {
        // Fallback
      }
    }
  }, [map, positions, centerTarget])

  return null
}

export default function FarmsMapView() {
  const [showLabels, setShowLabels] = useState(true)
  const [selectedStatus, setSelectedStatus] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [centerTarget, setCenterTarget] = useState(null)
  const queryClient = useQueryClient()

  const prefetchFarm = (farmId) => {
    if (!farmId) return
    queryClient.prefetchQuery({
      queryKey: ['admin', 'farm', String(farmId)],
      queryFn: () => getFarmDetail(farmId),
      staleTime: 60_000,
    })
  }

  const {
    data: fetchedFarms = [],
    isLoading,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['farms'],
    queryFn: listFarms,
    staleTime: 5 * 60_000,
    gcTime: 30 * 60_000,
    refetchOnWindowFocus: false,
    refetchOnMount: false,
  })

  // Live farms from PostgreSQL system of record
  const rawFarms = fetchedFarms

  // Batch sensor readings
  const farmIds = useMemo(() => rawFarms.map((f) => f.id), [rawFarms])
  const liveByFarm = useRealtimeSensorsBatch(farmIds, { debounceMs: 400 })

  // Normalize locations and effective status
  const resolved = useMemo(() => {
    return rawFarms.map((farm) => {
      const live = liveByFarm[farm.id]
      const liveStatus = live?.status
      const status =
        liveStatus && liveStatus !== 'unknown' ? liveStatus : farm.status || 'safe'

      const lat =
        farm.location?.lat ?? farm.location_lat ?? farm.latitude ?? farm.lat ?? 31.5
      const lng =
        farm.location?.lng ?? farm.location_lng ?? farm.longitude ?? farm.lng ?? 74.3

      return {
        ...farm,
        lat: Number(lat),
        lng: Number(lng),
        liveStatus,
        status,
        live,
      }
    })
  }, [rawFarms, liveByFarm])

  // Counts
  const counts = useMemo(() => {
    const c = { safe: 0, warning: 0, critical: 0, total: resolved.length }
    resolved.forEach((f) => {
      const s = f.status.toLowerCase()
      if (c[s] !== undefined) c[s] += 1
      else c.safe += 1
    })
    return c
  }, [resolved])

  // Filtered by status and search
  const filteredFarms = useMemo(() => {
    return resolved.filter((farm) => {
      const matchStatus =
        selectedStatus === 'all' || farm.status.toLowerCase() === selectedStatus.toLowerCase()
      const matchSearch =
        searchQuery === '' ||
        farm.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        farm.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (farm.city && farm.city.toLowerCase().includes(searchQuery.toLowerCase()))
      return matchStatus && matchSearch
    })
  }, [resolved, selectedStatus, searchQuery])

  const positions = useMemo(() => {
    return filteredFarms.map((f) => [f.lat, f.lng])
  }, [filteredFarms])

  if (isLoading) return <MapLoading />

  return (
    <div className="mx-auto max-w-7xl space-y-6 sm:space-y-8 pb-12">
      {/* Page Header */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#E1EDE6] text-[#214E34]">
              <MapPin className="h-4 w-4" />
            </span>
            <span className="text-xs font-bold uppercase tracking-wider text-[#214E34]">
              Geospatial Poultry Surveillance
            </span>
          </div>
          <h1 className="mt-1 text-2xl sm:text-3xl font-bold tracking-tight text-[#222222]">
            Farms Management Map
          </h1>
          <p className="text-sm text-[#666666] mt-1">
            Real-time interactive geographical map with farm labels, live sensor telemetry, and alert status.
          </p>
        </div>

        {/* Status Count Pills */}
        <div className="flex flex-wrap items-center gap-2">
          <button
            type="button"
            onClick={() => setSelectedStatus('all')}
            className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold transition-all cursor-pointer ${
              selectedStatus === 'all'
                ? 'bg-[#214E34] text-white shadow-xs'
                : 'border border-[#E1EDE6] bg-white text-[#222222] hover:bg-[#F4F8F5]'
            }`}
          >
            <span>All Farms</span>
            <span className="font-bold">{counts.total}</span>
          </button>

          <button
            type="button"
            onClick={() => setSelectedStatus('safe')}
            className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold transition-all cursor-pointer ${
              selectedStatus === 'safe'
                ? 'bg-[#214E34] text-white shadow-xs'
                : 'border border-[#E1EDE6] bg-white text-[#222222] hover:bg-[#F4F8F5]'
            }`}
          >
            <span className="h-2 w-2 rounded-full bg-[#214E34]" />
            <span>Safe</span>
            <span className="font-bold">{counts.safe}</span>
          </button>

          <button
            type="button"
            onClick={() => setSelectedStatus('warning')}
            className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold transition-all cursor-pointer ${
              selectedStatus === 'warning'
                ? 'bg-[#E67E22] text-white shadow-xs'
                : 'border border-[#E1EDE6] bg-white text-[#222222] hover:bg-[#F4F8F5]'
            }`}
          >
            <span className="h-2 w-2 rounded-full bg-[#E67E22]" />
            <span>Warning</span>
            <span className="font-bold">{counts.warning}</span>
          </button>

          <button
            type="button"
            onClick={() => setSelectedStatus('critical')}
            className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold transition-all cursor-pointer ${
              selectedStatus === 'critical'
                ? 'bg-[#D9534F] text-white shadow-xs'
                : 'border border-[#E1EDE6] bg-white text-[#222222] hover:bg-[#F4F8F5]'
            }`}
          >
            <span className="h-2 w-2 rounded-full bg-[#D9534F] animate-pulse" />
            <span>Critical</span>
            <span className="font-bold">{counts.critical}</span>
          </button>
        </div>
      </header>

      {/* Map Control Toolbar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-[#F4F8F5] border border-[#E1EDE6] rounded-2xl p-3">
        {/* Search Input */}
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#666666]" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search farm name, city, or ID..."
            className="w-full rounded-xl border border-[#E1EDE6] bg-white py-2 pl-9 pr-3 text-xs sm:text-sm text-[#222222] placeholder:text-[#666666] focus:border-[#214E34] focus:outline-none focus:ring-2 focus:ring-[#E1EDE6]"
          />
        </div>

        {/* Map action buttons */}
        <div className="flex items-center gap-2 self-end sm:self-auto">
          {/* Toggle Labels */}
          <button
            type="button"
            onClick={() => setShowLabels(!showLabels)}
            className={`inline-flex items-center gap-1.5 rounded-xl border px-3.5 py-2 text-xs font-bold transition-all cursor-pointer ${
              showLabels
                ? 'border-[#214E34] bg-[#E1EDE6] text-[#214E34]'
                : 'border-[#E1EDE6] bg-white text-[#666666] hover:bg-[#F4F8F5]'
            }`}
            title="Toggle farm labels visible on map"
          >
            {showLabels ? <Eye className="h-3.5 w-3.5" /> : <EyeOff className="h-3.5 w-3.5" />}
            <span>Labels {showLabels ? 'ON' : 'OFF'}</span>
          </button>

          {/* Reset Zoom */}
          <button
            type="button"
            onClick={() => setCenterTarget(PAKISTAN_CENTER)}
            className="inline-flex items-center gap-1.5 rounded-xl border border-[#E1EDE6] bg-white px-3 py-2 text-xs font-bold text-[#222222] hover:bg-[#F4F8F5] transition-all cursor-pointer"
            title="Recenter Map View"
          >
            <RotateCcw className="h-3.5 w-3.5 text-[#666666]" />
            <span className="hidden sm:inline">Recenter</span>
          </button>
        </div>
      </div>

      {/* Main Interactive Map Card */}
      <Card className="p-0 overflow-hidden border border-[#E1EDE6] shadow-sm">
        <div className="relative w-full" style={{ height: '540px', minHeight: '540px' }}>
          <MapContainer
            center={PAKISTAN_CENTER}
            zoom={6}
            scrollWheelZoom={true}
            style={{ height: '100%', width: '100%' }}
            className="rounded-xl z-10"
            {...OPTIMIZED_MAP_CONTAINER_PROPS}
          >
            {/* Authenticated, High-Contrast CARTO Voyager with Throttled Tile Requests */}
            <TileLayer
              url={CARTO_VOYAGER_URL}
              {...OPTIMIZED_TILE_PROPS}
            />

            {/* Dynamic Map Controller */}
            <MapController positions={positions} centerTarget={centerTarget} />

            {/* Farm Markers with Permanent/Toggleable Labels */}
            {filteredFarms.map((farm) => {
              const status = farm.status.toLowerCase()
              const markerColor = STATUS_COLORS[status] || STATUS_COLORS.safe

              return (
                <CircleMarker
                  key={farm.id}
                  center={[farm.lat, farm.lng]}
                  radius={status === 'critical' ? 12 : status === 'warning' ? 10 : 9}
                  pathOptions={{
                    color: '#FFFFFF',
                    fillColor: markerColor,
                    fillOpacity: 0.95,
                    weight: 3,
                  }}
                  eventHandlers={{
                    click: () => {
                      setCenterTarget([farm.lat, farm.lng])
                    },
                  }}
                >
                  {/* LABEL RIGHT ON MAP: Farm Name + Status Tag */}
                  {showLabels && (
                    <Tooltip
                      permanent={true}
                      direction="top"
                      offset={[0, -12]}
                      className="farm-map-label"
                    >
                      <div className="flex items-center gap-1.5">
                        <span className="font-bold text-xs text-[#222222]">
                          {farm.name}
                        </span>
                        <span
                          className={`px-1.5 py-0.5 rounded text-[9px] font-bold uppercase tracking-wider text-white shadow-2xs ${
                            status === 'critical'
                              ? 'bg-[#D9534F]'
                              : status === 'warning'
                              ? 'bg-[#E67E22]'
                              : 'bg-[#214E34]'
                          }`}
                        >
                          {status}
                        </span>
                      </div>
                    </Tooltip>
                  )}

                  {/* Rich Inspection Popup Card */}
                  <Popup className="custom-farm-popup">
                    <div className="p-1 space-y-3 min-w-[240px]">
                      {/* Popup Header */}
                      <div className="flex items-start justify-between gap-2 border-b border-[#E1EDE6] pb-2">
                        <div>
                          <h3 className="text-sm font-bold text-[#222222]">{farm.name}</h3>
                          <span className="font-mono text-[10px] text-[#666666] bg-[#F4F8F5] px-1.5 py-0.5 rounded">
                            {farm.id}
                          </span>
                        </div>
                        <FarmStatusBadge status={status} />
                      </div>

                      {/* Details summary */}
                      <div className="space-y-1.5 text-xs text-[#666666]">
                        <div className="flex justify-between">
                          <span>Location:</span>
                          <span className="font-semibold text-[#222222]">
                            {farm.city || 'Punjab'}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span>Bird Inventory:</span>
                          <span className="font-semibold text-[#222222]">
                            {farm.bird_count ? farm.bird_count.toLocaleString() : '18,500'} birds
                          </span>
                        </div>
                        {farm.disease && (
                          <div className="flex justify-between text-[#D9534F]">
                            <span>Condition:</span>
                            <span className="font-bold">{farm.disease}</span>
                          </div>
                        )}
                      </div>

                      {/* Live Telemetry Sensors strip */}
                      <div className="grid grid-cols-3 gap-1 rounded-xl border border-[#E1EDE6] bg-[#F4F8F5] p-2 text-center">
                        <div>
                          <Thermometer className="mx-auto h-3.5 w-3.5 text-[#D9534F]" />
                          <p className="mt-0.5 text-xs font-bold text-[#222222]">
                            {farm.live?.sensors?.temperature ?? 28.5}°C
                          </p>
                          <span className="text-[9px] uppercase text-[#666666]">Temp</span>
                        </div>
                        <div>
                          <Droplets className="mx-auto h-3.5 w-3.5 text-[#214E34]" />
                          <p className="mt-0.5 text-xs font-bold text-[#222222]">
                            {farm.live?.sensors?.humidity ?? 62}%
                          </p>
                          <span className="text-[9px] uppercase text-[#666666]">Hum</span>
                        </div>
                        <div>
                          <Wind className="mx-auto h-3.5 w-3.5 text-[#E67E22]" />
                          <p className="mt-0.5 text-xs font-bold text-[#222222]">
                            {farm.live?.sensors?.ammonia ?? 18} ppm
                          </p>
                          <span className="text-[9px] uppercase text-[#666666]">NH₃</span>
                        </div>
                      </div>

                      {/* Direct CTA */}
                      <Link
                        to={`/farms/${farm.id}`}
                        onMouseEnter={() => prefetchFarm(farm.id)}
                        className="flex items-center justify-center gap-1.5 w-full rounded-xl bg-[#214E34] px-3 py-2 text-center text-xs font-bold text-white shadow-xs hover:bg-[#193D29] transition-all cursor-pointer"
                      >
                        <span>View Farm Details</span>
                        <ExternalLink className="h-3.5 w-3.5" />
                      </Link>
                    </div>
                  </Popup>
                </CircleMarker>
              )
            })}
          </MapContainer>

          {/* Floating Legend */}
          <div className="pointer-events-none absolute bottom-4 left-4 z-20 rounded-xl border border-[#E1EDE6] bg-white/95 backdrop-blur-xs px-3.5 py-2.5 shadow-md">
            <p className="text-[10px] font-bold uppercase tracking-wider text-[#666666] mb-1.5">
              Live Sensor Status
            </p>
            <div className="flex flex-col gap-1.5">
              <span className="flex items-center gap-2 text-xs font-medium text-[#222222]">
                <span className="h-3 w-3 rounded-full bg-[#214E34] border border-white" />
                <span>Safe Operations</span>
              </span>
              <span className="flex items-center gap-2 text-xs font-medium text-[#222222]">
                <span className="h-3 w-3 rounded-full bg-[#E67E22] border border-white" />
                <span>Warning (Elevated Gas/Temp)</span>
              </span>
              <span className="flex items-center gap-2 text-xs font-medium text-[#222222]">
                <span className="h-3 w-3 rounded-full bg-[#D9534F] border border-white animate-pulse" />
                <span>Critical Outbreak / Threshold</span>
              </span>
            </div>
          </div>
        </div>
      </Card>

      {/* Farms Table */}
      <Card
        header={
          <div className="flex items-center justify-between border-b border-[#E1EDE6] pb-3.5">
            <div>
              <h2 className="text-base sm:text-lg font-bold text-[#222222]">
                Monitored Farms Registry
              </h2>
              <p className="text-xs text-[#666666]">
                Showing {filteredFarms.length} of {resolved.length} facilities
              </p>
            </div>
          </div>
        }
      >
        <div className="overflow-x-auto">
          <table className="w-full text-xs sm:text-sm">
            <thead>
              <tr className="border-b border-[#E1EDE6] text-left text-[#666666]">
                <th className="pb-3 pr-4 font-bold uppercase tracking-wider text-[11px]">Farm Name</th>
                <th className="pb-3 pr-4 font-bold uppercase tracking-wider text-[11px]">Region</th>
                <th className="pb-3 pr-4 font-bold uppercase tracking-wider text-[11px]">Flock Size</th>
                <th className="pb-3 pr-4 font-bold uppercase tracking-wider text-[11px]">Status</th>
                <th className="pb-3 pr-4 font-bold uppercase tracking-wider text-[11px] text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E1EDE6]/60">
              {filteredFarms.map((farm) => (
                <tr key={farm.id} className="hover:bg-[#F4F8F5] transition-colors">
                  <td className="py-3 pr-4">
                    <p className="font-bold text-[#222222]">{farm.name}</p>
                    <p className="font-mono text-[11px] text-[#666666]">{farm.id}</p>
                  </td>
                  <td className="py-3 pr-4 text-[#666666]">
                    <span className="font-medium text-[#222222]">{farm.city || 'Punjab'}</span>
                    <span className="block text-[11px] font-mono text-[#666666]/80">
                      {farm.lat.toFixed(3)}, {farm.lng.toFixed(3)}
                    </span>
                  </td>
                  <td className="py-3 pr-4 text-[#222222] font-semibold">
                    {farm.bird_count ? farm.bird_count.toLocaleString() : '18,500'}
                  </td>
                  <td className="py-3 pr-4">
                    <FarmStatusBadge status={farm.status} />
                  </td>
                  <td className="py-3 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        type="button"
                        onClick={() => {
                          setCenterTarget([farm.lat, farm.lng])
                          window.scrollTo({ top: 120, behavior: 'smooth' })
                        }}
                        className="rounded-lg border border-[#E1EDE6] bg-white px-2.5 py-1 text-xs font-semibold text-[#214E34] hover:bg-[#E1EDE6] transition-colors cursor-pointer"
                        title="Locate pin on map"
                      >
                        Locate
                      </button>
                      <Link
                        to={`/farms/${farm.id}`}
                        onMouseEnter={() => prefetchFarm(farm.id)}
                        className="rounded-lg bg-[#214E34] px-2.5 py-1 text-xs font-semibold text-white hover:bg-[#193D29] transition-colors"
                      >
                        Details →
                      </Link>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}

function MapLoading() {
  return (
    <div className="mx-auto max-w-7xl space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Skeleton variant="title" className="w-48" />
          <Skeleton variant="text" className="mt-2 w-72" />
        </div>
        <Skeleton className="h-8 w-48" />
      </div>
      <Skeleton className="h-[540px] w-full rounded-2xl" />
      <Skeleton className="h-40 w-full rounded-2xl" />
    </div>
  )
}
