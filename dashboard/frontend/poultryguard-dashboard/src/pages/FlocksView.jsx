import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Layers,
  Plus,
  Calendar,
  Syringe,
  AlertTriangle,
  CheckCircle,
  Filter,
  Search,
  ChevronRight,
  TrendingUp,
  X,
  Radio,
  ArrowRight,
} from 'lucide-react'
import { Card } from '../components/Card'
import FarmStatusBadge from '../components/FarmStatusBadge'
import { listFlocks, createFlock } from '../api/endpoints/flocks'
import { listFarms, getFarmDetail } from '../api/endpoints/farms'

export default function FlocksView() {
  const queryClient = useQueryClient()
  const [searchTerm, setSearchTerm] = useState('')
  const [filterType, setFilterType] = useState('all')
  const [showAddModal, setShowAddModal] = useState(false)

  const prefetchFarm = (farmId) => {
    if (!farmId) return
    queryClient.prefetchQuery({
      queryKey: ['admin', 'farm', String(farmId)],
      queryFn: () => getFarmDetail(farmId),
      staleTime: 60_000,
    })
  }

  // 1. Fetch real flocks from database API
  const { data: flocks = [], isLoading: flocksLoading } = useQuery({
    queryKey: ['admin', 'flocks'],
    queryFn: () => listFlocks(),
    staleTime: 60_000,
  })

  // 2. Fetch real farms for selection dropdown in modal
  const { data: farms = [] } = useQuery({
    queryKey: ['farms'],
    queryFn: listFarms,
    staleTime: 5 * 60_000,
  })

  // Form state for adding flock
  const [newFarmId, setNewFarmId] = useState('')
  const [newBirdType, setNewBirdType] = useState('broiler')
  const [newBirdCount, setNewBirdCount] = useState('10000')
  const [newPlacementDate, setNewPlacementDate] = useState(new Date().toISOString().split('T')[0])
  const [submitError, setSubmitError] = useState(null)

  // Flock creation mutation
  const createMutation = useMutation({
    mutationFn: (data) => createFlock(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'flocks'] })
      setShowAddModal(false)
      setSubmitError(null)
    },
    onError: (err) => {
      setSubmitError(err.response?.data?.detail || 'Failed to create flock batch.')
    },
  })

  const filteredFlocks = flocks.filter((flock) => {
    const matchesSearch =
      (flock.id || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (flock.farmName || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (flock.birdType || '').toLowerCase().includes(searchTerm.toLowerCase())
    if (filterType === 'all') return matchesSearch
    return matchesSearch && flock.status === filterType
  })

  const totalBirds = flocks.reduce((acc, f) => acc + (f.count || 0), 0)
  const avgAge = Math.round(flocks.reduce((acc, f) => acc + (f.ageDays || 0), 0) / (flocks.length || 1))

  const handleAddFlock = (e) => {
    e.preventDefault()
    const farmIdVal = parseInt(newFarmId || (farms[0]?.id) || '1', 10)
    createMutation.mutate({
      farm_id: farmIdVal,
      bird_type: newBirdType,
      bird_count: parseInt(newBirdCount, 10) || 5000,
      placement_date: newPlacementDate,
      vaccinations: [
        { name: 'Marek Disease (Hatchery)', date: 'Day 1', status: 'completed' },
        { name: 'NDV / IBD Primary', date: 'Day 7', status: 'scheduled' },
      ],
    })
  }

  return (
    <div className="space-y-6 sm:space-y-8 pb-12">
      {/* Top Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#E1EDE6] text-[#214E34]">
              <Layers className="h-4 w-4" />
            </span>
            <span className="text-xs font-bold uppercase tracking-wider text-[#214E34]">
              Livestock Tracking
            </span>
          </div>
          <h1 className="mt-1 text-2xl sm:text-3xl font-bold tracking-tight text-[#222222]">
            Flocks & Avian Batches
          </h1>
          <p className="text-sm text-[#666666] mt-0.5">
            Monitor age trajectories, vaccination milestones, and batch survival across regional houses.
          </p>
        </div>

        <button
          type="button"
          onClick={() => {
            if (farms.length > 0 && !newFarmId) {
              setNewFarmId(String(farms[0].id))
            }
            setShowAddModal(true)
          }}
          className="inline-flex items-center justify-center gap-2 rounded-xl bg-[#214E34] px-4 py-2.5 text-xs sm:text-sm font-bold text-[#FFFFFF] hover:bg-[#193D29] active:bg-[#122B1D] shadow-sm transition-all cursor-pointer"
        >
          <Plus className="h-4 w-4" />
          Add New Flock
        </button>
      </div>

      {/* Summary Stat Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <p className="text-xs font-semibold text-[#666666]">Total Population</p>
          <p className="mt-1 text-2xl sm:text-3xl font-bold text-[#222222]">{totalBirds.toLocaleString()}</p>
          <span className="text-xs text-[#214E34] font-medium">Across {flocks.length} active batches</span>
        </div>
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <p className="text-xs font-semibold text-[#666666]">Average Batch Age</p>
          <p className="mt-1 text-2xl sm:text-3xl font-bold text-[#222222]">{avgAge} days</p>
          <span className="text-xs text-[#666666]">Target slaughter: 35–42 days</span>
        </div>
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#E1EDE6]/40 p-5 shadow-2xs">
          <p className="text-xs font-semibold text-[#214E34]">Avg Mortality Index</p>
          <p className="mt-1 text-2xl sm:text-3xl font-bold text-[#214E34]">1.2%</p>
          <span className="text-xs text-[#214E34] font-medium">Well within 3% industry threshold</span>
        </div>
      </div>

      {/* Filters & Search */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative flex-1 max-w-md">
          <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#666666]" />
          <input
            type="text"
            placeholder="Search flock ID, farm, breed..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-[#E1EDE6] bg-[#FFFFFF] py-2 pl-9 pr-3 text-sm text-[#222222] placeholder-[#666666]/60 focus:border-[#214E34] focus:outline-none focus:ring-2 focus:ring-[#214E34]/20"
          />
        </div>

        <div className="flex items-center gap-2 overflow-x-auto pb-1">
          <Filter className="h-4 w-4 text-[#666666] shrink-0" />
          {['all', 'safe', 'warning', 'critical'].map((st) => (
            <button
              key={st}
              type="button"
              onClick={() => setFilterType(st)}
              className={`rounded-xl px-3 py-1.5 text-xs font-semibold capitalize transition-colors shrink-0 ${
                filterType === st
                  ? 'bg-[#214E34] text-[#FFFFFF]'
                  : 'border border-[#E1EDE6] bg-[#FFFFFF] text-[#666666] hover:bg-[#F4F8F5]'
              }`}
            >
              {st === 'all' ? 'All Flocks' : st}
            </button>
          ))}
        </div>
      </div>

      {/* Loading state */}
      {flocksLoading ? (
        <div className="flex min-h-64 items-center justify-center">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#E1EDE6] border-t-[#214E34]" />
          <p className="ml-3 text-sm text-[#666666]">Loading flocks telemetry...</p>
        </div>
      ) : filteredFlocks.length === 0 ? (
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-8 text-center text-sm text-[#666666]">
          No flocks found matching your criteria.
        </div>
      ) : (
        /* Flocks Cards List (Responsive Grid) */
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {filteredFlocks.map((flock) => {
            const farmTargetId = flock.farm_id || flock.db_id || 1
            const vaccinations = flock.vaccinations || []

            return (
              <Card key={flock.id} className="relative overflow-hidden">
                <div className="flex items-start justify-between gap-3 pb-3 border-b border-[#E1EDE6]">
                  <div>
                    <span className="font-mono text-xs font-bold text-[#214E34] bg-[#E1EDE6] px-2 py-0.5 rounded-md">
                      {flock.id}
                    </span>
                    <h3 className="mt-1.5 text-base font-bold text-[#222222]">
                      <Link
                        to={`/farms/${farmTargetId}`}
                        onMouseEnter={() => prefetchFarm(farmTargetId)}
                        className="hover:text-[#214E34] hover:underline"
                      >
                        {flock.farmName}
                      </Link>
                    </h3>
                    <p className="text-xs text-[#666666]">{flock.birdType} {flock.city ? `• ${flock.city}` : ''}</p>
                  </div>
                  <FarmStatusBadge status={flock.status || 'safe'} />
                </div>

                {/* Metrics row */}
                <div className="mt-4 grid grid-cols-3 gap-2 text-center border-b border-[#E1EDE6] pb-4">
                  <div className="rounded-xl bg-[#F4F8F5] p-2.5">
                    <span className="text-[10px] font-bold text-[#666666] uppercase">Count</span>
                    <p className="text-sm font-bold text-[#222222] mt-0.5">{(flock.count || 0).toLocaleString()}</p>
                  </div>
                  <div className="rounded-xl bg-[#F4F8F5] p-2.5">
                    <span className="text-[10px] font-bold text-[#666666] uppercase">Age</span>
                    <p className="text-sm font-bold text-[#222222] mt-0.5">{flock.ageDays} days</p>
                  </div>
                  <div className="rounded-xl bg-[#F4F8F5] p-2.5">
                    <span className="text-[10px] font-bold text-[#666666] uppercase">Mortality</span>
                    <p className={`text-sm font-bold mt-0.5 ${(flock.mortalityRate || 0) > 2 ? 'text-[#D9534F]' : 'text-[#214E34]'}`}>
                      {flock.mortalityRate || 1.1}%
                    </p>
                  </div>
                </div>

                {/* Vaccination Log */}
                <div className="mt-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs font-bold text-[#222222] flex items-center gap-1.5">
                      <Syringe className="h-3.5 w-3.5 text-[#214E34]" /> Vaccination Schedule
                    </span>
                    <span className="text-[10px] text-[#666666]">Placed: {flock.placementDate || 'Recent'}</span>
                  </div>
                  <div className="space-y-1.5">
                    {vaccinations.length === 0 ? (
                      <p className="text-xs text-[#666666] py-1 italic">Standard protocol initialized</p>
                    ) : (
                      vaccinations.map((vac, idx) => (
                        <div
                          key={idx}
                          className="flex items-center justify-between rounded-lg bg-[#FFFFFF] border border-[#E1EDE6] px-2.5 py-1.5 text-xs text-[#222222]"
                        >
                          <span className="truncate pr-2">{vac.name || vac.vaccine}</span>
                          <span className={`shrink-0 text-[10px] font-bold px-1.5 py-0.5 rounded ${
                            vac.status === 'completed'
                              ? 'bg-[#E1EDE6] text-[#214E34]'
                              : 'bg-amber-50 text-amber-700'
                          }`}>
                            {vac.status === 'completed' ? 'Done' : 'Upcoming'}
                          </span>
                        </div>
                      ))
                    )}
                  </div>
                </div>

                {/* Connected Action Links */}
                <div className="mt-4 pt-3 border-t border-[#E1EDE6] flex items-center justify-between text-xs">
                  <Link
                    to={`/farms/${farmTargetId}`}
                    onMouseEnter={() => prefetchFarm(farmTargetId)}
                    className="font-bold text-[#214E34] hover:underline flex items-center gap-1"
                  >
                    View Farm Details <ArrowRight className="h-3 w-3" />
                  </Link>
                  <Link
                    to={`/sensors?farm=${farmTargetId}`}
                    className="font-medium text-[#666666] hover:text-[#214E34] flex items-center gap-1"
                  >
                    <Radio className="h-3 w-3" /> Sensor Logs
                  </Link>
                </div>
              </Card>
            )
          })}
        </div>
      )}

      {/* Add Flock Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-[#222222]/50 backdrop-blur-xs">
          <div className="w-full max-w-md rounded-2xl bg-[#FFFFFF] border border-[#E1EDE6] p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-[#E1EDE6] pb-3 mb-4">
              <h3 className="text-base font-bold text-[#222222]">Register New Flock Batch</h3>
              <button
                type="button"
                onClick={() => setShowAddModal(false)}
                className="rounded-lg p-1 text-[#666666] hover:bg-[#E1EDE6] hover:text-[#214E34]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {submitError && (
              <div className="mb-3 rounded-xl bg-[#FDF2F2] border border-[#D9534F]/30 p-2.5 text-xs text-[#D9534F]">
                {submitError}
              </div>
            )}

            <form onSubmit={handleAddFlock} className="space-y-3.5">
              <div>
                <label className="block text-xs font-bold text-[#222222] mb-1">Target Farm Facility</label>
                <select
                  required
                  value={newFarmId}
                  onChange={(e) => setNewFarmId(e.target.value)}
                  className="w-full rounded-xl border border-[#E1EDE6] px-3 py-2 text-sm text-[#222222] bg-[#FFFFFF] focus:border-[#214E34] focus:outline-none"
                >
                  {farms.map((f) => (
                    <option key={f.id} value={f.id}>
                      {f.name} ({f.city || 'Punjab'})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#222222] mb-1">Bird Classification</label>
                <select
                  required
                  value={newBirdType}
                  onChange={(e) => setNewBirdType(e.target.value)}
                  className="w-full rounded-xl border border-[#E1EDE6] px-3 py-2 text-sm text-[#222222] bg-[#FFFFFF] focus:border-[#214E34] focus:outline-none"
                >
                  <option value="broiler">Broiler (Meat Production)</option>
                  <option value="layer">Layer (Egg Production)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#222222] mb-1">Initial Bird Count</label>
                <input
                  type="number"
                  required
                  min="100"
                  value={newBirdCount}
                  onChange={(e) => setNewBirdCount(e.target.value)}
                  className="w-full rounded-xl border border-[#E1EDE6] px-3 py-2 text-sm text-[#222222] focus:border-[#214E34] focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#222222] mb-1">Placement Date</label>
                <input
                  type="date"
                  required
                  value={newPlacementDate}
                  onChange={(e) => setNewPlacementDate(e.target.value)}
                  className="w-full rounded-xl border border-[#E1EDE6] px-3 py-2 text-sm text-[#222222] focus:border-[#214E34] focus:outline-none"
                />
              </div>

              <div className="mt-6 flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="rounded-xl border border-[#E1EDE6] px-4 py-2 text-xs font-semibold text-[#666666] hover:bg-[#F4F8F5]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={createMutation.isPending}
                  className="rounded-xl bg-[#214E34] px-4 py-2 text-xs font-semibold text-[#FFFFFF] hover:bg-[#193D29] disabled:opacity-50"
                >
                  {createMutation.isPending ? 'Registering...' : 'Create Batch'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
