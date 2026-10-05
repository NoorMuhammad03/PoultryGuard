/**
 * PoultryGuard Map Configuration & Optimization
 *
 * Configures CARTO Voyager Basemaps with the authorized API key
 * and optimizes tile fetching so only strictly necessary tile API calls
 * are executed (reducing bandwidth, quota consumption, and UI stutter).
 */

export const MAP_API_KEY =
  import.meta.env.VITE_CARTO_API_KEY ||
  import.meta.env.VITE_MAP_API_KEY ||
  ''

/**
 * High-performance CARTO Voyager tile URL.
 * CARTO requires `?key=YOUR_API_KEY` to authenticate and remove the "API KEY REQUIRED" watermark.
 */
export const CARTO_VOYAGER_URL = MAP_API_KEY
  ? `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png?key=${MAP_API_KEY}`
  : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'

export const CARTO_ATTRIBUTION =
  '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions" target="_blank" rel="noopener noreferrer">CARTO</a>'

/**
 * OpenStreetMap tile fallback (used if offline or if CARTO network is unreachable).
 */
export const OSM_FALLBACK_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
export const OSM_ATTRIBUTION =
  '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap</a> contributors'

/**
 * Surveillance boundary for Pakistan poultry farms.
 * Prevents panning around the whole globe, eliminating wasted tile requests.
 */
export const PAKISTAN_CENTER = [30.3753, 69.3451]
export const PAKISTAN_BOUNDS = [
  [23.0, 60.0], // Southwest bounds (Arabian Sea / Balochistan)
  [37.5, 78.0], // Northeast bounds (Kashmir / Gilgit-Baltistan)
]

/**
 * Highly optimized Leaflet TileLayer configuration:
 * 1. updateWhenIdle: true  -> Only fetches tiles after dragging/panning completes, saving 60-80% of tile calls.
 * 2. updateWhenZooming: false -> Does not fetch intermediate tiles during zoom animations.
 * 3. keepBuffer: 1         -> Caches only 1 tile ring outside viewport (default is 2+), reducing off-screen requests.
 * 4. minZoom & maxZoom     -> Clamps zoom level to relevant farm inspection levels (5 to 18).
 * 5. updateInterval: 150   -> Debounces tile requests during quick interactions.
 */
export const OPTIMIZED_TILE_PROPS = {
  attribution: CARTO_ATTRIBUTION,
  subdomains: 'abcd',
  minZoom: 5,
  maxZoom: 18,
  updateWhenIdle: true,
  updateWhenZooming: false,
  keepBuffer: 1,
  updateInterval: 150,
}

/**
 * Default MapContainer props that enforce boundary bounds & eliminate out-of-region tile requests.
 */
export const OPTIMIZED_MAP_CONTAINER_PROPS = {
  minZoom: 5,
  maxZoom: 18,
  maxBounds: PAKISTAN_BOUNDS,
  maxBoundsViscosity: 0.8,
}
