import { parseStringPromise } from 'xml2js'
import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { Activity, ActivityFilters, ActivityPoint, CreateActivityInput, GPXPoint, GPXStats } from './activities.types'

const haversineMeters = (aLat: number, aLng: number, bLat: number, bLng: number): number => {
  const toRad = (v: number) => (v * Math.PI) / 180
  const dLat = toRad(bLat - aLat)
  const dLng = toRad(bLng - aLng)
  const aa = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(aLat)) * Math.cos(toRad(bLat)) * Math.sin(dLng / 2) ** 2
  return 6371000 * (2 * Math.atan2(Math.sqrt(aa), Math.sqrt(1 - aa)))
}

export const createActivity = async (userId: string, data: CreateActivityInput): Promise<Activity> => {
  const { data: created, error } = await supabaseAdmin
    .from('activities')
    .insert({ ...data, user_id: userId })
    .select('*')
    .single()
  if (error) throw new AppError(500, 'Failed to create activity')
  return created as Activity
}

export const getActivityById = async (id: string, userId?: string): Promise<Activity> => {
  const { data, error } = await supabase.from('activities').select('*').eq('id', id).maybeSingle()
  if (error) throw new AppError(500, 'Failed to fetch activity')
  if (!data) throw new AppError(404, 'Activity not found')
  if (!data.is_public && data.user_id !== userId) throw new AppError(403, 'Activity is private')
  return data as Activity
}

export const getUserActivities = async (
  userId: string,
  filters: ActivityFilters,
): Promise<{ data: Activity[]; total: number }> => {
  const page = filters.page ?? 1
  const limit = filters.limit ?? 20
  const offset = (page - 1) * limit
  const to = offset + limit - 1
  let query = supabase.from('activities').select('*', { count: 'exact' }).eq('user_id', userId)
  if (filters.trail_id) query = query.eq('trail_id', filters.trail_id)
  if (filters.activity_type) query = query.eq('activity_type', filters.activity_type)
  const { data, count, error } = await query.order('start_time', { ascending: false }).range(offset, to)
  if (error) throw new AppError(500, 'Failed to fetch user activities')
  return { data: (data ?? []) as Activity[], total: count ?? 0 }
}

export const parseGPX = async (buffer: Buffer): Promise<{ points: GPXPoint[]; stats: GPXStats }> => {
  const xml = await parseStringPromise(buffer.toString('utf-8'))
  const trkpts = xml?.gpx?.trk?.[0]?.trkseg?.[0]?.trkpt ?? []
  const points: GPXPoint[] = trkpts.map((trkpt: any) => ({
    lat: Number(trkpt.$.lat),
    lon: Number(trkpt.$.lon),
    ele: trkpt.ele?.[0] ? Number(trkpt.ele[0]) : null,
    time: trkpt.time?.[0] ?? null,
  }))

  let distance = 0
  let elevationGain = 0
  let elevationLoss = 0
  let movingTimeSeconds = 0

  for (let i = 1; i < points.length; i += 1) {
    const prev = points[i - 1]
    const curr = points[i]
    const segment = haversineMeters(prev.lat, prev.lon, curr.lat, curr.lon)
    distance += segment
    if (prev.ele !== null && curr.ele !== null) {
      const delta = curr.ele - prev.ele
      if (delta > 0) elevationGain += delta
      if (delta < 0) elevationLoss += Math.abs(delta)
    }
    if (prev.time && curr.time) {
      const seconds = (new Date(curr.time).getTime() - new Date(prev.time).getTime()) / 1000
      if (seconds > 0 && segment / seconds > 0.3) movingTimeSeconds += seconds
    }
  }

  return { points, stats: { distance, elevationGain, elevationLoss, movingTimeSeconds } }
}

export const uploadGPX = async (activityId: string, gpxBuffer: Buffer) => {
  const { points, stats } = await parseGPX(gpxBuffer)
  const activityPoints = points.map((p, index) => ({
    activity_id: activityId,
    sequence: index + 1,
    latitude: p.lat,
    longitude: p.lon,
    elevation_meters: p.ele,
    timestamp: p.time,
  }))

  const trackGeometry = { type: 'LineString', coordinates: points.map((p) => [p.lon, p.lat]) }

  await supabaseAdmin.from('activity_points').delete().eq('activity_id', activityId)
  const { error: pointsError } = await supabaseAdmin.from('activity_points').insert(activityPoints)
  if (pointsError) throw new AppError(500, 'Failed to save activity points')

  const { error: updateError } = await supabaseAdmin
    .from('activities')
    .update({
      track_geometry: trackGeometry,
      distance_meters: stats.distance,
      elevation_gain_meters: stats.elevationGain,
      elevation_loss_meters: stats.elevationLoss,
      moving_time_seconds: stats.movingTimeSeconds,
    })
    .eq('id', activityId)
  if (updateError) throw new AppError(500, 'Failed to update activity track')

  return { trackGeometry, distance: stats.distance, elevationGain: stats.elevationGain, points: activityPoints as ActivityPoint[] }
}

export const matchActivityToTrail = async (activityId: string): Promise<string | null> => {
  const { data: activity, error: aErr } = await supabase.from('activities').select('track_geometry').eq('id', activityId).maybeSingle()
  if (aErr) throw new AppError(500, 'Failed to read activity geometry')
  if (!activity?.track_geometry) return null

  const wkt = `SRID=4326;${JSON.stringify(activity.track_geometry)}`
  const { data, error } = await supabase
    .from('trails')
    .select('id')
    // Equivalent SQL: ST_Intersects(trails.geometry, activity.track_geometry)
    .filter('geometry', 'st_intersects', wkt)
    .limit(1)
    .maybeSingle()
  if (error) throw new AppError(500, 'Failed to match trail')
  return data?.id ?? null
}

export const updateActivity = async (id: string, updates: Partial<Activity>): Promise<Activity> => {
  const { data, error } = await supabaseAdmin.from('activities').update(updates).eq('id', id).select('*').single()
  if (error) throw new AppError(500, 'Failed to update activity')
  return data as Activity
}

export const deleteActivity = async (id: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('activities').delete().eq('id', id)
  if (error) throw new AppError(500, 'Failed to delete activity')
}
