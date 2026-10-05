import { useQuery } from '@tanstack/react-query'
import axiosClient from '../api/axiosClient'
import { MapContainer, TileLayer, Circle, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { useEffect, useState } from 'react'
import { AlertTriangle, Loader2, MapPin, AlertCircle, CheckCircle } from 'lucide-react'
import {
  CARTO_VOYAGER_URL,
  OPTIMIZED_TILE_PROPS,
  OPTIMIZED_MAP_CONTAINER_PROPS,
} from '../config/mapConfig'

export default function OutbreakHeatmap() {
  const { data: outbreaks = [], isLoading, isError } = useQuery({
    queryKey: ['outbreaks'],
    queryFn: async () => {
      const res = await axiosClient.get('/admin/outbreaks')
      return res.data
    },
    staleTime: 5 * 60_000,
    gcTime: 30 * 60_000,
    refetchOnWindowFocus: false,
    refetchOnMount: false,
  })

  const [mapCenter, setMapCenter] = useState([30.3753, 69.3451])  // Islamabad as default

  useEffect(() => {
    // Center map on first outbreak location if available
    if (outbreaks.length > 0 && outbreaks[0].location_lat && outbreaks[0].location_lng) {
      setMapCenter([outbreaks[0].location_lat, outbreaks[0].location_lng])
    }
  }, [outbreaks])

  if (isLoading) {
    return (
      <div className="flex min-h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
        <p className="ml-3 text-sm text-slate-500">Loading outbreaks...</p>
      </div>
    )
  }

  if (isError) {
    return (
      <div className="rounded-lg border border-red-200 bg-red-50 p-12 text-center">
        <AlertCircle className="mx-auto h-12 w-12 text-red-600" />
        <h2 className="mt-3 text-lg font-semibold text-slate-800">Failed to load outbreaks</h2>
        <p className="mt-1 text-sm text-slate-600">
          Could not fetch outbreak data from the backend.
        </p>
      </div>
    )
  }

  const activeOutbreaks = outbreaks.filter((o) => o.radius_km > 0)

  const severityColors = {
    low: '#22c55e',      // green-500
    medium: '#f59e0b',   // amber-500
    high: '#ef4444',     // red-500
    critical: '#dc2626', // red-600
  }

  const severityIcons = {
    low: <CheckCircle className="h-4 w-4" />,
    medium: <AlertTriangle className="h-4 w-4" />,
    high: <AlertTriangle className="h-4 w-4" />,
    critical: <AlertCircle className="h-4 w-4" />,
  }

  return (
    <div className="mx-auto max-w-7xl">
      <div className="mb-6">
        <h1 className="mb-2 text-2xl font-bold text-slate-800">Outbreak Heatmap</h1>
        <p className="text-sm text-slate-500">
          Geographic view of disease outbreaks with 15km alert radius
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Map */}
        <div className="lg:col-span-2 rounded-lg border border-slate-200 bg-white overflow-hidden shadow-sm">
          {activeOutbreaks.length === 0 ? (
            <div className="h-96 w-full bg-slate-100 flex items-center justify-center rounded-lg">
              <div className="text-center">
                <MapPin className="mx-auto h-12 w-12 text-slate-300" />
                <p className="mt-2 text-sm text-slate-500">No active outbreaks</p>
                <p className="text-xs text-slate-400">All alerts are resolved or within the filter window</p>
              </div>
            </div>
          ) : (
            <MapContainer
              center={mapCenter}
              zoom={8}
              style={{ height: '500px', width: '100%' }}
              className="rounded-lg"
              {...OPTIMIZED_MAP_CONTAINER_PROPS}
            >
              <TileLayer
                url={CARTO_VOYAGER_URL}
                {...OPTIMIZED_TILE_PROPS}
              />
              {activeOutbreaks.map((outbreak) => (
                <Circle
                  key={outbreak.id}
                  center={[outbreak.location_lat, outbreak.location_lng]}
                  radius={outbreak.radius_km * 1000}
                  pathOptions={{
                    color: severityColors[outbreak.severity] || severityColors.medium,
                    fillColor: severityColors[outbreak.severity] || severityColors.medium,
                    fillOpacity: 0.15,
                    weight: 2,
                  }}
                >
                  <Popup>
                    <div className="p-2 min-w-[200px]">
                      <h3 className="font-semibold text-slate-800">{outbreak.disease}</h3>
                      <p className="text-xs text-slate-500">{outbreak.farm_name || `Farm ID: ${outbreak.farm_id}`}</p>
                      <div className="mt-2 space-y-1">
                        <div className="flex items-center gap-2 text-xs">
                          {severityIcons[outbreak.severity] || severityIcons.medium}
                          <span className="capitalize">{outbreak.severity} severity</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs">
                          <MapPin className="h-3 w-3" />
                          <span>{outbreak.radius_km}km radius alert</span>
                        </div>
                        {outbreak.bird_count_affected && (
                          <div className="flex items-center gap-2 text-xs">
                            <AlertCircle className="h-3 w-3" />
                            <span>{outbreak.bird_count_affected} birds affected</span>
                          </div>
                        )}
                      </div>
                      <p className="mt-2 text-xs text-slate-400">
                        Reported: {new Date(outbreak.reported_at).toLocaleDateString()}
                      </p>
                    </div>
                  </Popup>
                </Circle>
              ))}
            </MapContainer>
          )}
        </div>

        {/* Legend and Info */}
        <div className="space-y-4">
          <div className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm">
            <h2 className="text-lg font-semibold text-slate-800 mb-3">
              Active Alerts ({activeOutbreaks.length})
            </h2>

            <div className="space-y-2">
              {Object.entries(severityColors).map(([severity, color]) => (
                <div key={severity} className="flex items-center justify-between text-sm">
                  <div className="flex items-center gap-2">
                    <div
                      className="h-3 w-3 rounded-full"
                      style={{ backgroundColor: color }}
                    />
                    <span className="capitalize text-slate-700">{severity}</span>
                  </div>
                  <span className="text-slate-500">
                    {activeOutbreaks.filter((o) => o.severity === severity).length}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm">
            <h3 className="text-sm font-semibold text-slate-800 mb-2">
              About 15km Radius Alerts
            </h3>
            <p className="text-xs text-slate-600">
              When a disease is confirmed on one farm, neighboring farms within a 15km radius are automatically notified to take preventive action (Section 6.8).
            </p>
            <ul className="mt-2 space-y-1 text-xs text-slate-600 list-disc list-inside">
              <li>Push notifications via FCM</li>
              <li>SMS alerts via GSM gateway</li>
              <li>On-site buzzer/LED alerts</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Outbreak List */}
      {outbreaks.length > 0 && (
        <div className="mt-6 rounded-lg border border-slate-200 bg-white overflow-hidden shadow-sm">
          <div className="px-6 py-4 border-b border-slate-200 bg-slate-50">
            <h2 className="text-lg font-semibold text-slate-800">Outbreak List</h2>
          </div>
          <div className="divide-y divide-slate-200">
            {outbreaks.map((outbreak) => (
              <div key={outbreak.id} className="px-6 py-4 hover:bg-slate-50">
                <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                  <div className="flex items-start gap-3">
                    <div
                      className="h-2 w-2 rounded-full mt-2"
                      style={{ backgroundColor: severityColors[outbreak.severity] || severityColors.medium }}
                    />
                    <div>
                      <h3 className="font-medium text-slate-800">{outbreak.disease}</h3>
                      <p className="text-xs text-slate-500">
                        {outbreak.farm_name || `Farm ID: ${outbreak.farm_id}`}
                      </p>
                      {outbreak.description && (
                        <p className="text-xs text-slate-600 mt-1">{outbreak.description}</p>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-xs">
                    <span className={`inline-flex items-center gap-1 rounded-full border px-2 py-0.5 capitalize ${
                      outbreak.severity === 'critical' || outbreak.severity === 'high'
                        ? 'border-red-200 bg-red-50 text-red-700'
                        : outbreak.severity === 'medium'
                        ? 'border-amber-200 bg-amber-50 text-amber-700'
                        : 'border-green-200 bg-green-50 text-green-700'
                    }`}>
                      {severityIcons[outbreak.severity] || severityIcons.low}
                      {outbreak.severity}
                    </span>
                    <span className="text-slate-500">
                      {new Date(outbreak.reported_at).toLocaleDateString()}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}