// Admin farm endpoints — PostgreSQL + RTDB live status
import axiosClient from '../axiosClient'

/**
 * GET /admin/farms — list all farms with current status
 * @returns {Promise<{id:string,name:string,location:{lat:number,lng:number},status:'safe'|'warning'|'critical',last_updated:Date}[]>}
 */
export async function listFarms() {
  const res = await axiosClient.get('/admin/farms')
  return res.data
}

/**
 * GET /admin/farms/map — live map data (coords + status)
 * @returns {Promise<{id:string,lat:number,lng:number,status:'safe'|'warning'|'critical'}[]>}
 */
export async function getFarmsMapData() {
  const res = await axiosClient.get('/admin/farms/map')
  return res.data
}

/**
 * GET /admin/sensors/{farm_id}/history — 7/30-day sensor trends
 * @param {string} farmId
 * @param {Object} params - {days: number (7|30)}
 * @returns {Promise<{timestamp:Date,temp:number,humidity:number,ammonia:number}[]>}
 */
export async function getSensorHistory(farmId, params = { days: 7 }) {
  const res = await axiosClient.get(`/admin/sensors/${farmId}/history`, {
    params,
  })
  return res.data
}

/**
 * GET /admin/farms/{farm_id} — detail for a specific farm
 * @param {string|number} farmId
 */
export async function getFarmDetail(farmId) {
  const res = await axiosClient.get(`/admin/farms/${farmId}`)
  return res.data
}
