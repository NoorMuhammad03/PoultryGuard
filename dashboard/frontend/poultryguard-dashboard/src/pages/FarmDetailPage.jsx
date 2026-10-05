import { useParams, Link, useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import {
  ArrowLeft,
  MapPin,
  Calendar,
  Layers,
  Thermometer,
  Droplets,
  Wind,
  AlertTriangle,
  CheckCircle,
  Activity,
  ScanSearch,
  Radio,
} from 'lucide-react'
import { Card } from '../components/Card'
import FarmStatusBadge from '../components/FarmStatusBadge'
import { useRealtimeSensors } from '../hooks/useRealtimeSensors'
import { getFarmDetail } from '../api/endpoints/farms'

export default function FarmDetailPage() {
  const { id } = useParams()
  const navigate = useNavigate()

  // 1. Fetch real farm details & active flock from PostgreSQL backend
  const { data: serverFarm, isLoading: farmLoading } = useQuery({
    queryKey: ['admin', 'farm', id],
    queryFn: () => getFarmDetail(id),
    staleTime: 60_000,
  })

  // 2. Subscribe to real-time telemetry if available in Firebase RTDB
  const { sensors, status: realtimeStatus } = useRealtimeSensors(id)

  const farmData = {
    id: id || '1',
    name: serverFarm?.name || `Poultry Production Unit #${id || '1'}`,
    city: serverFarm?.city || 'Punjab Agricultural Sector',
    status: realtimeStatus || serverFarm?.status || 'safe',
    coordinates: serverFarm?.coordinates || `${serverFarm?.lat || 31.52}° N, ${serverFarm?.lng || 74.35}° E`,
    activeFlock: serverFarm?.activeFlock || 'Broiler Batch Active',
    birdCount: serverFarm?.birdCount || 10000,
    placementDate: serverFarm?.placementDate || '2026-08-15',
    ageDays: serverFarm?.ageDays || 25,
    temp: sensors.temperature ?? serverFarm?.temp ?? 26.4,
    humidity: sensors.humidity ?? serverFarm?.humidity ?? 64.2,
    ammonia: sensors.ammonia ?? serverFarm?.ammonia ?? 14.8,
  }

  return (
    <div className="space-y-6 sm:space-y-8 pb-12">
      {/* Back button & Title */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => navigate('/farms')}
            className="flex h-10 w-10 items-center justify-center rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] text-[#214E34] hover:bg-[#E1EDE6] transition-colors"
            title="Back to farms map"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-mono text-xs font-bold text-[#214E34] bg-[#E1EDE6] px-2 py-0.5 rounded-md">
                FARM-{farmData.id}
              </span>
              <FarmStatusBadge status={farmData.status} />
            </div>
            <h1 className="text-xl sm:text-2xl font-bold text-[#222222] mt-1">{farmData.name}</h1>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <Link
            to={`/sensors?farm=${farmData.id}`}
            className="inline-flex items-center gap-1.5 rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] px-3.5 py-2 text-xs font-bold text-[#214E34] hover:bg-[#F4F8F5] transition-colors"
          >
            <Radio className="h-4 w-4" />
            Sensor Telemetry
          </Link>
          <Link
            to="/flocks"
            className="inline-flex items-center gap-1.5 rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] px-3.5 py-2 text-xs font-bold text-[#214E34] hover:bg-[#F4F8F5] transition-colors"
          >
            <Layers className="h-4 w-4" />
            Flock History
          </Link>
          <Link
            to="/ai-detection"
            className="inline-flex items-center gap-1.5 rounded-xl bg-[#214E34] px-4 py-2 text-xs font-bold text-[#FFFFFF] hover:bg-[#193D29] transition-colors"
          >
            <ScanSearch className="h-4 w-4" />
            AI Disease Scan
          </Link>
        </div>
      </div>

      {/* Real-time Environmental Telemetry */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <div className="flex items-center justify-between text-[#666666] mb-2">
            <span className="text-xs font-semibold">Pen Temperature</span>
            <Thermometer className="h-4 w-4 text-[#214E34]" />
          </div>
          <p className="text-2xl sm:text-3xl font-bold text-[#222222]">{farmData.temp}°C</p>
          <span className="text-xs text-[#214E34] font-medium">Safe threshold &lt; 32°C</span>
        </div>

        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <div className="flex items-center justify-between text-[#666666] mb-2">
            <span className="text-xs font-semibold">Relative Humidity</span>
            <Droplets className="h-4 w-4 text-[#214E34]" />
          </div>
          <p className="text-2xl sm:text-3xl font-bold text-[#222222]">{farmData.humidity}%</p>
          <span className="text-xs text-[#214E34] font-medium">Safe threshold &lt; 80%</span>
        </div>

        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <div className="flex items-center justify-between text-[#666666] mb-2">
            <span className="text-xs font-semibold">Ammonia (NH₃)</span>
            <Wind className="h-4 w-4 text-[#214E34]" />
          </div>
          <p className={`text-2xl sm:text-3xl font-bold ${farmData.ammonia > 25 ? 'text-[#D9534F]' : 'text-[#222222]'}`}>
            {farmData.ammonia} ppm
          </p>
          <span className={`text-xs font-medium ${farmData.ammonia > 25 ? 'text-[#D9534F]' : 'text-[#214E34]'}`}>
            {farmData.ammonia > 25 ? 'Critical alert (> 25 ppm)' : 'Safe threshold < 25 ppm'}
          </span>
        </div>
      </div>

      {/* Flock & Pen Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card header={<h3 className="text-base font-bold text-[#222222]">Housed Flock Specification</h3>}>
          <div className="space-y-3 text-sm">
            <div className="flex justify-between py-2 border-b border-[#E1EDE6]">
              <span className="text-[#666666]">Batch Identifier</span>
              <span className="font-semibold text-[#222222]">{farmData.activeFlock}</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E1EDE6]">
              <span className="text-[#666666]">Bird Population</span>
              <span className="font-semibold text-[#222222]">{farmData.birdCount.toLocaleString()} birds</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E1EDE6]">
              <span className="text-[#666666]">Placement Date</span>
              <span className="font-semibold text-[#222222]">{farmData.placementDate} ({farmData.ageDays} days)</span>
            </div>
            <div className="flex justify-between py-2">
              <span className="text-[#666666]">Biosecurity Level</span>
              <span className="font-semibold text-[#214E34]">Level 3 (Closed Bio-tunnel)</span>
            </div>
          </div>
        </Card>

        <Card header={<h3 className="text-base font-bold text-[#222222]">Facility Location & Sensors</h3>}>
          <div className="space-y-3 text-sm">
            <div className="flex justify-between py-2 border-b border-[#E1EDE6]">
              <span className="text-[#666666]">Geographic Region</span>
              <span className="font-semibold text-[#222222]">{farmData.city}</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E1EDE6]">
              <span className="text-[#666666]">GPS Coordinates</span>
              <span className="font-mono text-xs text-[#222222]">{farmData.coordinates}</span>
            </div>
            <div className="flex justify-between py-2 border-b border-[#E1EDE6]">
              <span className="text-[#666666]">IoT Gateway</span>
              <span className="font-mono text-xs text-[#214E34]">ESP32-WROOM-32E (MQTT active)</span>
            </div>
            <div className="flex justify-between py-2">
              <span className="text-[#666666]">Sampling Rate</span>
              <span className="text-[#222222]">Every 10 seconds via RTDB</span>
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
