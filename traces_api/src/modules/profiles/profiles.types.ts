export interface Profile {
  id: string
  username: string | null
  full_name: string | null
  avatar_url: string | null
  bio: string | null
  location: string | null
  is_premium: boolean
  total_distance_meters: number
  total_activities: number
  total_trails_completed: number
}
