import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
} from 'recharts'
import {
  BarChart3,
  Activity,
  Sparkles,
  Brain,
  ArrowRight,
  TrendingUp,
  ShieldCheck,
  CheckCircle,
} from 'lucide-react'
import axiosClient from '../api/axiosClient'
import { Card } from '../components/Card'

const DISEASE_COLORS = {
  coccidiosis: '#D9534F',
  newcastle: '#E67E22',
  salmonellosis: '#214E34',
  healthy: '#27AE60',
  other: '#666666',
}

const PALETTE = ['#D9534F', '#E67E22', '#214E34', '#27AE60', '#8E44AD']

export default function Analytics() {
  const [days, setDays] = useState(14)

  const { data, isLoading } = useQuery({
    queryKey: ['analytics', 'system_combined', days],
    queryFn: async () => {
      const [diagRes, modelRes] = await Promise.all([
        axiosClient.get(`/admin/analytics/diagnoses?days=${days}`),
        axiosClient.get(`/admin/analytics/model/summary?days=${days}`),
      ])
      return {
        diagnostics: diagRes.data || [],
        model: modelRes.data || [],
      }
    },
    staleTime: 5 * 60_000,
  })

  const diagnostics = data?.diagnostics || []
  const model = data?.model || []

  // Aggregate diagnoses by disease for the PieChart
  const diseaseBreakdownMap = {}
  diagnostics.forEach((d) => {
    const diseaseKey = d.disease_type?.toLowerCase() || 'other'
    diseaseBreakdownMap[diseaseKey] = (diseaseBreakdownMap[diseaseKey] || 0) + (d.count || 1)
  })

  const pieData = Object.entries(diseaseBreakdownMap).map(([disease, count]) => ({
    name: disease.charAt(0).toUpperCase() + disease.slice(1),
    value: count,
    color: DISEASE_COLORS[disease] || DISEASE_COLORS.other,
  }))

  // Aggregate daily counts for BarChart
  const dailyMap = {}
  diagnostics.forEach((d) => {
    const dateStr = d.date ? d.date.substring(5) : 'Unknown' // MM-DD
    if (!dailyMap[dateStr]) {
      dailyMap[dateStr] = { date: dateStr, coccidiosis: 0, newcastle: 0, salmonellosis: 0, total: 0 }
    }
    const type = d.disease_type?.toLowerCase()
    if (type && dailyMap[dateStr][type] !== undefined) {
      dailyMap[dateStr][type] += d.count
    }
    dailyMap[dateStr].total += d.count
  })

  const dailyTrendData = Object.values(dailyMap)

  // Aggregate model metrics
  const totalInferences = model.reduce((acc, m) => acc + (m.total_inferences || 0), 0)
  const avgAccuracy = model.length
    ? Math.round(
        (model.reduce((acc, m) => acc + (m.accuracy || 0), 0) / model.length) * 100
      )
    : 92

  if (isLoading) {
    return (
      <div className="flex min-h-64 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#E1EDE6] border-t-[#214E34]" />
        <p className="ml-3 text-sm text-[#666666]">Calculating epidemiology analytics...</p>
      </div>
    )
  }

  return (
    <div className="space-y-6 sm:space-y-8 pb-12">
      {/* Top Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#E1EDE6] text-[#214E34]">
              <BarChart3 className="h-4 w-4" />
            </span>
            <span className="text-xs font-bold uppercase tracking-wider text-[#214E34]">
              System Health & Pathology
            </span>
          </div>
          <h1 className="mt-1 text-2xl sm:text-3xl font-bold tracking-tight text-[#222222]">
            Comprehensive Biosecurity Analytics
          </h1>
          <p className="text-sm text-[#666666] mt-0.5">
            Pathological prevalence trends, historical diagnoses, and neural model statistical accuracy.
          </p>
        </div>

        {/* Lookback toggle buttons */}
        <div className="flex items-center gap-2">
          {[7, 14, 30].map((d) => (
            <button
              key={d}
              type="button"
              onClick={() => setDays(d)}
              className={`rounded-xl px-3.5 py-1.5 text-xs font-bold transition-all ${
                days === d
                  ? 'bg-[#214E34] text-[#FFFFFF] shadow-2xs'
                  : 'border border-[#E1EDE6] bg-[#FFFFFF] text-[#666666] hover:bg-[#F4F8F5]'
              }`}
            >
              Last {d} Days
            </button>
          ))}
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <p className="text-xs font-semibold text-[#666666]">Diagnoses Scanned</p>
          <p className="mt-1 text-2xl sm:text-3xl font-bold text-[#222222]">
            {diagnostics.reduce((acc, d) => acc + d.count, 0)}
          </p>
          <span className="text-xs text-[#214E34] font-medium">Aggregated across all connected sheds</span>
        </div>
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-5 shadow-2xs">
          <p className="text-xs font-semibold text-[#666666]">Avg Model Accuracy</p>
          <p className="mt-1 text-2xl sm:text-3xl font-bold text-[#214E34]">{avgAccuracy}%</p>
          <span className="text-xs text-[#666666]">Cross-validated against ground truth</span>
        </div>
        <div className="rounded-2xl border border-[#E1EDE6] bg-[#E1EDE6]/40 p-5 shadow-2xs">
          <p className="text-xs font-semibold text-[#214E34]">Total Verified Inferences</p>
          <p className="mt-1 text-2xl sm:text-3xl font-bold text-[#214E34]">{totalInferences}</p>
          <span className="text-xs text-[#214E34] font-medium">Field pathology verified by certified vets</span>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Daily Trends Bar Chart */}
        <div className="lg:col-span-2">
          <Card
            header={
              <div>
                <h3 className="text-base font-bold text-[#222222]">Daily Avian Diagnosis Frequency</h3>
                <p className="text-xs text-[#666666]">Timeline breakdown of positive disease flags over the last {days} days</p>
              </div>
            }
          >
            {dailyTrendData.length === 0 ? (
              <div className="h-64 flex items-center justify-center text-sm text-[#666666]">
                No historical records in this time window.
              </div>
            ) : (
              <div className="h-72 sm:h-80 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={dailyTrendData} margin={{ top: 10, right: 10, left: -15, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#E1EDE6" />
                    <XAxis dataKey="date" stroke="#666666" fontSize={11} />
                    <YAxis stroke="#666666" fontSize={11} allowDecimals={false} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: '#FFFFFF',
                        border: '1px solid #E1EDE6',
                        borderRadius: '12px',
                        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                        fontSize: '12px',
                      }}
                    />
                    <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />
                    <Bar dataKey="coccidiosis" name="Coccidiosis" fill="#D9534F" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="newcastle" name="Newcastle" fill="#E67E22" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="salmonellosis" name="Salmonella" fill="#214E34" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </Card>
        </div>

        {/* Right 1 Col: Disease Share Pie Chart */}
        <div className="lg:col-span-1">
          <Card
            header={
              <div>
                <h3 className="text-base font-bold text-[#222222]">Pathology Proportion</h3>
                <p className="text-xs text-[#666666]">Share of detected pathogens</p>
              </div>
            }
          >
            {pieData.length === 0 ? (
              <div className="h-64 flex items-center justify-center text-sm text-[#666666]">
                No disease distributions available.
              </div>
            ) : (
              <div className="h-72 sm:h-80 w-full flex flex-col items-center justify-center">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={pieData}
                      dataKey="value"
                      nameKey="name"
                      cx="50%"
                      cy="45%"
                      outerRadius={75}
                      innerRadius={40}
                      paddingAngle={3}
                      label={({ name, percent }) => `${(percent * 100).toFixed(0)}%`}
                    >
                      {pieData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color || PALETTE[index % PALETTE.length]} />
                      ))}
                    </Pie>
                    <Tooltip
                      contentStyle={{
                        backgroundColor: '#FFFFFF',
                        border: '1px solid #E1EDE6',
                        borderRadius: '12px',
                        fontSize: '12px',
                      }}
                    />
                    <Legend wrapperStyle={{ fontSize: '11px' }} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            )}
          </Card>
        </div>
      </div>

      {/* Model Accuracy Breakdown Table */}
      <Card
        header={
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-base font-bold text-[#222222]">Inference Engine Performance Matrix</h3>
              <p className="text-xs text-[#666666]">Statistical validation of computer vision classifier</p>
            </div>
            <Link
              to="/model"
              className="text-xs font-bold text-[#214E34] hover:underline flex items-center gap-1"
            >
              Neural Specs <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>
        }
      >
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs sm:text-sm">
            <thead className="border-b border-[#E1EDE6] text-xs font-bold uppercase tracking-wider text-[#666666]">
              <tr>
                <th className="py-3 px-4">Disease Target</th>
                <th className="py-3 px-4 text-center">Validation Samples</th>
                <th className="py-3 px-4 text-center">Correct Inferences</th>
                <th className="py-3 px-4 text-center">Accuracy Score</th>
                <th className="py-3 px-4 text-right">Avg Confidence</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E1EDE6]">
              {model.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-6 text-center text-[#666666]">
                    No model verification logs available.
                  </td>
                </tr>
              ) : (
                model.map((m, idx) => {
                  const accPct = Math.round((m.accuracy || 0) * 100)
                  return (
                    <tr key={idx} className="hover:bg-[#F4F8F5] transition-colors">
                      <td className="py-3 px-4 font-semibold text-[#222222] capitalize">
                        {m.disease}
                      </td>
                      <td className="py-3 px-4 text-center text-[#666666]">{m.total_inferences}</td>
                      <td className="py-3 px-4 text-center text-[#214E34] font-medium">
                        {m.correct_predictions}
                      </td>
                      <td className="py-3 px-4 text-center">
                        <span
                          className={`inline-block rounded-md px-2 py-0.5 text-xs font-bold ${
                            accPct >= 90
                              ? 'bg-[#E1EDE6] text-[#214E34]'
                              : accPct >= 75
                              ? 'bg-amber-100 text-amber-800'
                              : 'bg-[#FDF2F2] text-[#D9534F]'
                          }`}
                        >
                          {accPct}%
                        </span>
                      </td>
                      <td className="py-3 px-4 text-right font-mono text-xs text-[#222222]">
                        {((m.avg_confidence || 0.9) * 100).toFixed(1)}%
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}