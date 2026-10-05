// Admin diagnoses endpoint — PostgreSQL
import axiosClient from '../axiosClient'

/**
 * GET /admin/analytics/diagnoses — daily diagnosis counts by disease type
 * @returns {Promise<{date:string,disease_type:string,count:number}[]>}
 */
export async function getDiagnosesAnalytics() {
  const res = await axiosClient.get('/admin/analytics/diagnoses')
  return res.data
}