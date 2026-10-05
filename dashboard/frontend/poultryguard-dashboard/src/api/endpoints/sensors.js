// Model accuracy metrics endpoint — PostgreSQL (logged inference results)
import axiosClient from '../axiosClient'

/**
 * GET /admin/analytics/model — per-disease accuracy over time
 * @returns {Promise<{date:string,disease:string,accuracy:number,total_inferences:number}[]>}
 */
export async function getModelAnalytics() {
  const res = await axiosClient.get('/admin/analytics/model')
  return res.data
}