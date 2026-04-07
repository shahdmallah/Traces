import MapboxClient from '@mapbox/mapbox-sdk'
import mbxStatic from '@mapbox/mapbox-sdk/services/static'
import mbxDirections from '@mapbox/mapbox-sdk/services/directions'
import mbxGeocoding from '@mapbox/mapbox-sdk/services/geocoding'

type LineStringGeometry = { type: 'LineString'; coordinates: number[][] }

const mapboxClient = MapboxClient({ accessToken: process.env.MAPBOX_ACCESS_TOKEN! })

export const staticMapService = mbxStatic(mapboxClient)
export const directionsService = mbxDirections(mapboxClient)
export const geocodingService = mbxGeocoding(mapboxClient)

export async function generateTrailMapPreview(
  trailId: string,
  geometry: LineStringGeometry,
  width: number = 800,
  height: number = 400,
): Promise<string> {
  const coordinates = geometry.coordinates.map((c) => `${c[0]},${c[1]}`).join(';')
  const url = `https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/path+5e3c3c(${coordinates})/auto/${width}x${height}?access_token=${process.env.MAPBOX_ACCESS_TOKEN}`
  return `${url}&trail_id=${trailId}`
}
