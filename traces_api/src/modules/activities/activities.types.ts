export interface Activity {
  id: string
  user_id: string
  trail_id: string | null
  name: string
  activity_type: string
  notes: string | null
  is_public: boolean
  start_time: string | null
  end_time: string | null
  elapsed_time_seconds: number | null
  moving_time_seconds: number | null
  distance_meters: number | null
  elevation_gain_meters: number | null
  elevation_loss_meters: number | null
  max_elevation_meters: number | null
  min_elevation_meters: number | null
  average_pace_seconds_per_km: number | null
  max_speed_mps: number | null
  calories_burned: number | null
  gpx_url: string | null
  track_geometry: unknown
  featured_photo_url: string | null
}

export interface ActivityPoint {
  id: string
  activity_id: string
  sequence: number
  latitude: number
  longitude: number
  elevation_meters: number | null
  accuracy_meters: number | null
  speed_mps: number | null
  heading_degrees: number | null
  timestamp: string | null
}

export interface GPXPoint {
  lat: number
  lon: number
  ele: number | null
  time: string | null
}

export interface GPXStats {
  distance: number
  elevationGain: number
  elevationLoss: number
  movingTimeSeconds: number
}

export type CreateActivityInput = Partial<Activity> & Pick<Activity, 'name' | 'activity_type'>
export type ActivityFilters = { page?: number; limit?: number; trail_id?: string; activity_type?: string }
