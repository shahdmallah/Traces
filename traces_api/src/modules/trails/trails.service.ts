import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { Trail, TrailFilters } from './trails.types'
import { CreateTrailInput } from './trails.validation'

type TrailListResult = { data: Trail[]; total: number; page: number; limit: number }

export const createTrail = async (data: CreateTrailInput): Promise<Trail> => {
  const { data: created, error } = await supabaseAdmin.from('trails').insert(data).select('*').single()
  if (error) throw new AppError(500, 'Failed to create trail')
  return created as Trail
}

export const getTrailById = async (id: string): Promise<Trail> => {
  const { data, error } = await supabase.from('trails').select('*').eq('id', id).eq('is_active', true).maybeSingle()
  if (error) throw new AppError(500, 'Failed to fetch trail')
  if (!data) throw new AppError(404, 'Trail not found')
  return data as Trail
}

export const listTrails = async (filters: TrailFilters): Promise<TrailListResult> => {
  const page = filters.page ?? 1
  const limit = filters.limit ?? 20
  const offset = (page - 1) * limit
  const to = offset + limit - 1

  let query = supabase.from('trails').select('*', { count: 'exact' }).eq('is_active', true)
  if (filters.difficulty) query = query.eq('difficulty', filters.difficulty)
  if (filters.min_length !== undefined) query = query.gte('length_meters', filters.min_length)
  if (filters.max_length !== undefined) query = query.lte('length_meters', filters.max_length)
  if (filters.min_elevation !== undefined) query = query.gte('elevation_gain_meters', filters.min_elevation)
  if (filters.max_elevation !== undefined) query = query.lte('elevation_gain_meters', filters.max_elevation)
  if (filters.is_dog_friendly !== undefined) query = query.eq('is_dog_friendly', filters.is_dog_friendly)
  if (filters.is_kid_friendly !== undefined) query = query.eq('is_kid_friendly', filters.is_kid_friendly)

  const { data, count, error } = await query.order('popularity_score', { ascending: false }).range(offset, to)
  if (error) throw new AppError(500, 'Failed to fetch trails')

  return { data: (data ?? []) as Trail[], total: count ?? 0, page, limit }
}

export const findNearbyTrails = async (
  lat: number,
  lng: number,
  radiusMeters: number,
  limit = 20,
): Promise<Trail[]> => {
  const point = `SRID=4326;POINT(${lng} ${lat})`
  const { data, error } = await supabase
    .from('trails')
    .select('*')
    .eq('is_active', true)
    // Equivalent SQL:
    // ST_DWithin(geometry::geography, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, radiusMeters)
    .filter('geometry', 'st_dwithin', `${point},${radiusMeters}`)
    .limit(limit)

  if (error) throw new AppError(500, 'Failed to fetch nearby trails')
  return (data ?? []) as Trail[]
}

export const searchTrails = async (query: string, filters: TrailFilters = {}): Promise<Trail[]> => {
  let request = supabase
    .from('trails')
    .select('*')
    .eq('is_active', true)
    .or(`name.ilike.%${query}%,description.ilike.%${query}%`)

  if (filters.difficulty) request = request.eq('difficulty', filters.difficulty)
  if (filters.is_dog_friendly !== undefined) request = request.eq('is_dog_friendly', filters.is_dog_friendly)
  if (filters.is_kid_friendly !== undefined) request = request.eq('is_kid_friendly', filters.is_kid_friendly)

  const { data, error } = await request.limit(filters.limit ?? 20)
  if (error) throw new AppError(500, 'Failed to search trails')
  return (data ?? []) as Trail[]
}

export const updateTrail = async (id: string, updates: Partial<Trail>): Promise<Trail> => {
  const { data, error } = await supabaseAdmin.from('trails').update(updates).eq('id', id).select('*').single()
  if (error) throw new AppError(500, 'Failed to update trail')
  return data as Trail
}

export const deleteTrail = async (id: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('trails').update({ is_active: false }).eq('id', id)
  if (error) throw new AppError(500, 'Failed to delete trail')
}
