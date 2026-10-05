// Admin user management endpoints — PostgreSQL
import axiosClient from '../axiosClient'

/**
 * GET /admin/users — list all farmers & vets
 * @returns {Promise<{id:string,name:string,email:string,phone:string,role:'farmer'|'vet',is_active:boolean,is_verified:boolean}[]>}
 */
export async function listUsers() {
  const res = await axiosClient.get('/admin/users')
  return res.data
}

/**
 * PATCH /admin/users/{id}/verify — approve vet credentials
 * @param {string} userId
 * @returns {Promise<{id:string,is_verified:boolean}>}
 */
export async function verifyVet(userId) {
  const res = await axiosClient.patch(`/admin/users/${userId}/verify`)
  return res.data
}

/**
 * PATCH /admin/users/{id}/deactivate — deactivate account
 * @param {string} userId
 * @returns {Promise<{id:string,is_active:boolean}>}
 */
export async function deactivateUser(userId) {
  const res = await axiosClient.patch(`/admin/users/${userId}/deactivate`)
  return res.data
}
