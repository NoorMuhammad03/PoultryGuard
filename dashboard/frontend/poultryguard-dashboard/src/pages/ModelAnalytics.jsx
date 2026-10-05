import { useQuery } from '@tanstack/react-query'
import axiosClient from '../api/axiosClient'
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
} from 'recharts'
import { Activity, CheckCircle, Sparkles, Brain, ArrowRight } from 'lucide-react'
import { Link } from 'react-router-dom'
import { Card } from '../components/Card'

// Chart colors aligned with PoultryGuard design tokens
export const CHART_COLORS = {
  coccidiosis: '#D9534F',      // Alert red
  newcastle: '#E67E22',        // Alert amber
  salmonellosis: '#214E34',    // Primary dark green
  other: '#666666',            // Secondary text
}

const COLORS = [CHART_COLORS.coccidiosis, CHART_COLORS.newcastle, CHART_COLORS.salmonellosis, CHART_COLORS.other]

export default function ModelAnalytics() {
  // Diagnosis counts
  const { data: diagnoses = [], isLoading: diagnosesLoading } = useQuery({
    queryKey: ['analytics', 'diagnoses', 'summary'],
    queryFn: async () => {
      const res = await axiosClient.get('/admin/analytics/diagnoses/summary')
      return res.data
    },
    staleTime: 5 * 60_000,
  })

  // Model accuracy
  const { data: modelData = [], isLoading: modelLoading } = useQuery({
    queryKey: ['analytics', 'model', 'summary'],
    queryFn: async () => {
      const res = await axiosClient.get('/admin/analytics/model/summary')
      return res.data
    },
    staleTime: 5 * 60_000,
  })

  if (diagnosesLoading || modelLoading) {
    return (
      <div className="flex min-h-64 items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#E1EDE6] border-t-[#214E34]" />
        <p className="ml-3 text-sm text-[#666666]">Loading model metrics…</p>
      </div>
    )
  }

  return (
    <div className="space-y-6 sm:space-y-8 pb-12">
      {/* Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#E1EDE6] text-[#214E34]">
              <Brain className="h-4 w-4" />
            </span>
            <span className="text-xs font-bold uppercase tracking-wider text-[#214E34]">
              Neural Inference Analytics
            </span>
          </div>
          <h1 className="mt-1 text-2xl sm:text-3xl font-bold tracking-tight text-[#222222]">
            AI Model Accuracy & Pathology Trends
          </h1>
          <p className="text-sm text-[#666666] mt-0.5">
            Statistical validation metrics across multi-class convolutional neural networks for avian diagnostics.
          </p>
        </div>

        <Link
          to="/ai-detection"
          className="inline-flex items-center gap-2 rounded-xl bg-[#214E34] px-4 py-2.5 text-xs sm:text-sm font-bold text-[#FFFFFF] hover:bg-[#193D29] shadow-sm transition-all"
        >
          <Sparkles className="h-4 w-4" />
          Test New Sample
        </Link>
      </div>

      {/* Diagnosis Counts by Disease */}
      <Card header={<h2 className="text-base sm:text-lg font-bold text-[#222222]">Diagnoses by Disease Type</h2>}>
        {diagnoses.length === 0 ? (
          <div className="h-64 flex items-center justify-center text-sm text-[#666666]">
            No diagnosis data available
          </div>
        ) : (
          <div className="h-80 sm:h-96 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={diagnoses} margin={{ top: 20, right: 20, left: 0, bottom: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E1EDE6" />
                <XAxis
                  dataKey="disease_type"
                  tick={{ fontSize: 12, fill: '#666666' }}
                  tickMargin={8}
                />
                <YAxis
                  tick={{ fontSize: 12, fill: '#666666' }}
                  tickFormatter={(value) => value.toLocaleString()}
                />
                <Tooltip
                  contentStyle={{
                    borderRadius: '12px',
                    border: '1px solid #E1EDE6',
                    backgroundColor: '#FFFFFF',
                    boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
                  }}
                  formatter={(value) => [value.toLocaleString(), 'Verified Inferences']}
                />
                <Legend />
                <Bar dataKey="total" fill="#214E34" radius={[6, 6, 0, 0]} name="Inference Count" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
      </Card>

      {/* Accuracy & Distribution Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card header={<h2 className="text-base sm:text-lg font-bold text-[#222222]">Model Accuracy by Disease Class</h2>}>
          {modelData.length === 0 ? (
            <div className="h-64 flex items-center justify-center text-sm text-[#666666]">
              No model inference data available
            </div>
          ) : (
            <div className="h-80 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={modelData} margin={{ top: 20, right: 20, left: 0, bottom: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E1EDE6" />
                  <XAxis dataKey="disease" tick={{ fontSize: 12, fill: '#666666' }} />
                  <YAxis
                    domain={[0, 1]}
                    tickFormatter={(value) => `${(value * 100).toFixed(0)}%`}
                    tick={{ fontSize: 12, fill: '#666666' }}
                  />
                  <Tooltip
                    contentStyle={{
                      borderRadius: '12px',
                      border: '1px solid #E1EDE6',
                      backgroundColor: '#FFFFFF',
                      boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
                    }}
                    formatter={(value) => [`${(value * 100).toFixed(1)}%`, 'Accuracy']}
                  />
                  <Legend />
                  <Bar dataKey="accuracy" fill="#214E34" radius={[6, 6, 0, 0]} name="Accuracy Score" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}
        </Card>

        <Card header={<h2 className="text-base sm:text-lg font-bold text-[#222222]">Inference Distribution Share</h2>}>
          {modelData.length === 0 ? (
            <div className="h-64 flex items-center justify-center text-sm text-[#666666]">
              No inference distribution data available
            </div>
          ) : (
            <div className="h-80 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={modelData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ disease, accuracy }) => `${disease} (${(accuracy * 100).toFixed(0)}%)`}
                    outerRadius={100}
                    fill="#214E34"
                    dataKey="total_inferences"
                  >
                    {modelData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      borderRadius: '12px',
                      border: '1px solid #E1EDE6',
                      backgroundColor: '#FFFFFF',
                      boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
                    }}
                    formatter={(value) => [value.toLocaleString(), 'Inferences']}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          )}
        </Card>
      </div>

      {/* Model Performance Summary Breakdown */}
      <Card header={<h2 className="text-base sm:text-lg font-bold text-[#222222]">Performance Matrix by Avian Condition</h2>}>
        {modelData.length === 0 ? (
          <div className="h-32 flex items-center justify-center text-sm text-[#666666]">
            No detailed summary available
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {modelData.map((entry, idx) => (
              <div
                key={entry.disease}
                className="rounded-2xl border border-[#E1EDE6] bg-[#FFFFFF] p-4 sm:p-5 shadow-2xs"
              >
                <div className="flex items-center gap-2 mb-3">
                  <div
                    className="h-3.5 w-3.5 rounded-full shrink-0"
                    style={{ backgroundColor: COLORS[idx % COLORS.length] }}
                  />
                  <h3 className="font-bold text-sm sm:text-base text-[#222222] truncate">{entry.disease}</h3>
                </div>

                <div className="space-y-1.5 text-xs">
                  <div className="flex justify-between py-1 border-b border-[#E1EDE6]">
                    <span className="text-[#666666]">Accuracy:</span>
                    <span className="font-bold text-[#214E34]">{(entry.accuracy * 100).toFixed(1)}%</span>
                  </div>
                  <div className="flex justify-between py-1 border-b border-[#E1EDE6]">
                    <span className="text-[#666666]">Total Inferences:</span>
                    <span className="font-bold text-[#222222]">{entry.total_inferences.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between py-1 border-b border-[#E1EDE6]">
                    <span className="text-[#666666]">Correct Diagnoses:</span>
                    <span className="font-bold text-[#214E34]">{entry.correct_predictions.toLocaleString()}</span>
                  </div>
                </div>

                {/* Progress bar fill in secondary soft sage #E1EDE6 with #214E34 fill */}
                <div className="mt-4 h-2.5 w-full rounded-full bg-[#E1EDE6] overflow-hidden p-0.5">
                  <div
                    className="h-full rounded-full bg-[#214E34] transition-all duration-700"
                    style={{ width: `${entry.accuracy * 100}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  )
}