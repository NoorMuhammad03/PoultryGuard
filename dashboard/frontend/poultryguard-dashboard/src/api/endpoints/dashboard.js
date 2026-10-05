// Admin BFF aggregated dashboard endpoint
import axiosClient from '../axiosClient'

/**
 * GET /admin/dashboard/summary
 * Consolidated single-roundtrip BFF endpoint for KPIs, alerts, farm previews, and activity feed.
 * @returns {Promise<{kpis: Object, farms_preview: Array, recent_activity: Array, generated_at: string}>}
 */
export async function getDashboardSummary() {
  const res = await axiosClient.get('/admin/dashboard/summary')
  return res.data
}
