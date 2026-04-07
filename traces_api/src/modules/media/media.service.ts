import crypto from 'crypto'
import path from 'path'
import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { TrailPhoto } from './media.types'

const STORAGE_BUCKET = 'media'
export type MediaUploadFile = { originalname: string; mimetype: string; size: number; buffer: Buffer }

export const uploadTrailPhoto = async (
  trailId: string,
  userId: string,
  file: Buffer,
  caption?: string,
): Promise<TrailPhoto> => {
  const key = `trail-photos/${trailId}/${crypto.randomUUID()}${path.extname('photo.jpg')}`
  const { error: storageError } = await supabase.storage.from(STORAGE_BUCKET).upload(key, file, { contentType: 'image/jpeg', upsert: false })
  if (storageError) throw new AppError(500, 'Failed to upload photo')

  const { data, error } = await supabaseAdmin
    .from('trail_photos')
    .insert({ trail_id: trailId, user_id: userId, storage_path: key, caption: caption ?? null, is_primary: false })
    .select('*')
    .single()
  if (error) throw new AppError(500, 'Failed to save trail photo')
  return data as TrailPhoto
}

export const deletePhoto = async (photoId: string, userId: string): Promise<void> => {
  const { data, error } = await supabase.from('trail_photos').select('*').eq('id', photoId).maybeSingle()
  if (error || !data) throw new AppError(404, 'Photo not found')
  if (data.user_id !== userId) throw new AppError(403, 'Forbidden')
  await supabase.storage.from(STORAGE_BUCKET).remove([data.storage_path])
  const { error: deleteError } = await supabaseAdmin.from('trail_photos').delete().eq('id', photoId)
  if (deleteError) throw new AppError(500, 'Failed to delete photo')
}

export const getTrailPhotos = async (trailId: string): Promise<TrailPhoto[]> => {
  const { data, error } = await supabase.from('trail_photos').select('*').eq('trail_id', trailId).order('is_primary', { ascending: false })
  if (error) throw new AppError(500, 'Failed to fetch trail photos')
  return (data ?? []) as TrailPhoto[]
}

export const setPrimaryPhoto = async (photoId: string, trailId: string, userId: string): Promise<void> => {
  const { data: photo, error } = await supabase.from('trail_photos').select('*').eq('id', photoId).eq('trail_id', trailId).maybeSingle()
  if (error || !photo) throw new AppError(404, 'Photo not found')
  if (photo.user_id !== userId) throw new AppError(403, 'Forbidden')
  await supabaseAdmin.from('trail_photos').update({ is_primary: false }).eq('trail_id', trailId)
  const { error: primaryError } = await supabaseAdmin.from('trail_photos').update({ is_primary: true }).eq('id', photoId)
  if (primaryError) throw new AppError(500, 'Failed to set primary photo')
}
