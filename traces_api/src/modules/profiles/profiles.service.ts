import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { Profile } from './profiles.types'

export const getProfileByUserId = async (userId: string): Promise<Profile> => {
  const { data, error } = await supabase.from('profiles').select('*').eq('id', userId).maybeSingle()
  if (error) throw new AppError(500, 'Failed to fetch profile')
  if (!data) throw new AppError(404, 'Profile not found')
  return data as Profile
}

export const updateProfile = async (userId: string, updates: Partial<Profile>): Promise<Profile> => {
  const { data, error } = await supabaseAdmin.from('profiles').update(updates).eq('id', userId).select('*').single()
  if (error) throw new AppError(500, 'Failed to update profile')
  return data as Profile
}

export const getPublicProfile = async (usernameOrId: string): Promise<Profile> => {
  const byId = await supabase.from('profiles').select('*').eq('id', usernameOrId).maybeSingle()
  if (!byId.error && byId.data) return byId.data as Profile

  const { data, error } = await supabase.from('profiles').select('*').eq('username', usernameOrId).maybeSingle()
  if (error) throw new AppError(500, 'Failed to fetch public profile')
  if (!data) throw new AppError(404, 'Profile not found')
  return data as Profile
}

export const getUserStats = async (userId: string): Promise<{ totalDistanceMeters: number; totalActivities: number; totalTrailsCompleted: number }> => {
  const profile = await getProfileByUserId(userId)
  return {
    totalDistanceMeters: profile.total_distance_meters ?? 0,
    totalActivities: profile.total_activities ?? 0,
    totalTrailsCompleted: profile.total_trails_completed ?? 0,
  }
}
