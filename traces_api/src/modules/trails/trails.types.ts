export type TrailDifficulty = 'easy' | 'moderate' | 'hard' | 'expert'
export type RouteType = 'loop' | 'out-and-back' | 'point-to-point'

export type GeoJSONGeometry = Record<string, any>

export interface Trail {
  id: string
  name: string
  description: string | null
  difficulty: TrailDifficulty
  route_type: RouteType
  length_meters: number
  elevation_gain_meters: number
  min_elevation_meters: number | null
  max_elevation_meters: number | null
  estimated_duration_minutes: number | null
  geometry: GeoJSONGeometry | null
  bounding_box: number[] | null
  latitude: number | null
  longitude: number | null
  is_dog_friendly: boolean
  is_kid_friendly: boolean
  is_wheelchair_accessible: boolean
  is_parking_available: boolean
  is_bathroom_available: boolean
  is_camping_allowed: boolean
  popularity_score: number
  total_reviews: number
  average_rating: number
  is_active: boolean
  is_verified: boolean
  created_by?: string | null
}

export interface TrailFilters {
  difficulty?: TrailDifficulty
  min_length?: number
  max_length?: number
  min_elevation?: number
  max_elevation?: number
  is_dog_friendly?: boolean
  is_kid_friendly?: boolean
  lat?: number
  lng?: number
  radius_meters?: number
  limit?: number
  page?: number
}
