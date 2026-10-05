// Admin outbreak endpoints — PostgreSQL (PostGIS for geofencing)
import axiosClient from '../axiosClient'

/**
 * GET /admin/outbreaks — outbreak heatmap data (geographic + 15km radius overlays)
 * @returns {Promise<{date:string,farm_id:string,farm_name:string,lat:number,lng:number,disease:string,radius_km:number}[]>}
 */
export async function getOutbreaks() {
  const res = await axiosClient.get('/admin/outbreaks')
  return res.data
}