// Admin Flocks endpoints — PostgreSQL flocks management
import axiosClient from '../axiosClient'

/**
 * GET /admin/flocks — list all registered flocks
 * @param {Object} [params] - { farm_id?: number, bird_type?: string }
 */
export async function listFlocks(params = {}) {
  const res = await axiosClient.get('/admin/flocks', { params })
  return res.data
}

/**
 * POST /admin/flocks — register a new flock
 * @param {Object} flockData
 */
export async function createFlock(flockData) {
  const res = await axiosClient.post('/admin/flocks', flockData)
  return res.data
}
