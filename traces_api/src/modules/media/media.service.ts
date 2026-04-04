import crypto from 'crypto'
import path from 'path'
import sharp from 'sharp'
import { supabase } from '../../config/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { getTripById } from '../trips/trips.service'
import {
  CreateMediaInput,
  MediaListResponse,
  MediaRecord,
  MediaResponse,
  MediaType,
  NearbyMediaQuery,
  TagMediaInput,
  UpdateMediaInput,
} from './media.types'

export type MediaUploadFile = {
  originalname: string
  mimetype: string
  size: number
  buffer: Buffer
}

const IMAGE_MIME_TYPES = new Set(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
const VIDEO_MIME_TYPES = new Set(['video/mp4', 'video/quicktime'])
const MAX_IMAGE_SIZE = 10 * 1024 * 1024
const MAX_VIDEO_SIZE = 50 * 1024 * 1024
const STORAGE_BUCKET = 'media'
const STORAGE_DATA_FOLDER = 'media'
const THUMBNAIL_FOLDER = `${STORAGE_DATA_FOLDER}/thumbnails`

type MediaRow = MediaRecord & {
  uploader?: {
    id: string
    full_name: string | null
    avatar_url: string | null
  }
}

const parseStoragePath = (publicUrl: string): string => {
  const match = publicUrl.match(/\/storage\/v1\/object\/public\/[\w-]+\/(.+)$/)
  if (!match) {
    throw new AppError(500, 'Invalid media storage URL')
  }
  return decodeURIComponent(match[1])
}

const getUploadKey = (type: MediaType, originalName: string) => {
  const extension = path.extname(originalName).toLowerCase() || (type === 'photo' ? '.jpg' : '.mp4')
  return `${STORAGE_DATA_FOLDER}/${type === 'photo' ? 'photos' : 'videos'}/${crypto.randomUUID()}${extension}`
}

const uploadToStorage = async (key: string, buffer: Buffer, contentType: string): Promise<string> => {
  const { error } = await supabase.storage.from(STORAGE_BUCKET).upload(key, buffer, {
    contentType,
    upsert: false,
  })

  if (error) {
    console.error('Media upload failed', { key, error })
    throw new AppError(500, 'Failed to upload media file')
  }

  const { data } = supabase.storage.from(STORAGE_BUCKET).getPublicUrl(key)
  if (!data?.publicUrl) {
    throw new AppError(500, 'Failed to generate media URL')
  }

  return data.publicUrl
}

const deleteFromStorage = async (publicUrl: string | null | undefined): Promise<void> => {
  if (!publicUrl) return

  const key = parseStoragePath(publicUrl)
  const { error } = await supabase.storage.from(STORAGE_BUCKET).remove([key])
  if (error && !/not found|404/i.test(error.message ?? '')) {
    console.error('Storage delete failed', { key, error })
  }
}

const validateMediaFile = (file: MediaUploadFile): MediaType => {
  if (IMAGE_MIME_TYPES.has(file.mimetype)) {
    if (file.size > MAX_IMAGE_SIZE) {
      throw new AppError(400, 'Image file size must be 10MB or less')
    }
    return 'photo'
  }

  if (VIDEO_MIME_TYPES.has(file.mimetype)) {
    if (file.size > MAX_VIDEO_SIZE) {
      throw new AppError(400, 'Video file size must be 50MB or less')
    }
    return 'video'
  }

  throw new AppError(400, 'Unsupported media type')
}

const ensureDestinationExists = async (destinationId: string): Promise<void> => {
  const { data, error } = await supabase
    .from('destinations')
    .select('id')
    .eq('id', destinationId)
    .maybeSingle()

  if (error) {
    console.error('Destination lookup failed', error)
    throw new AppError(500, 'Failed to validate destination_id')
  }

  if (!data) {
    throw new AppError(400, 'Invalid destination_id')
  }
}

const resolveOrganizerProfileId = async (userId: string): Promise<string | null> => {
  const { data, error } = await supabase
    .from('organizer_profiles')
    .select('id')
    .eq('user_id', userId)
    .maybeSingle()

  if (error) {
    console.error('Organizer profile lookup failed', error)
    throw new AppError(500, 'Failed to validate organizer profile')
  }

  return data?.id ?? null
}

const isAcceptedFriend = async (viewerId: string, ownerId: string): Promise<boolean> => {
  if (viewerId === ownerId) return true

  const { data, error } = await supabase
    .from('friendships')
    .select('id')
    .or(
      `and(requester_id.eq.${viewerId},addressee_id.eq.${ownerId}),and(requester_id.eq.${ownerId},addressee_id.eq.${viewerId})`,
    )
    .eq('status', 'accepted')
    .limit(1)
    .maybeSingle()

  if (error) {
    console.error('Friendship lookup failed', error)
    throw new AppError(500, 'Failed to validate friendship status')
  }

  return Boolean(data)
}

const isTripParticipantOrOrganizer = async (userId: string, tripId: string): Promise<boolean> => {
  const trip = await getTripById(tripId)
  if (!trip) return false

  const organizerProfileId = await resolveOrganizerProfileId(userId)
  if (organizerProfileId && trip.organizer_id === organizerProfileId) {
    return true
  }

  const { data, error } = await supabase
    .from('bookings')
    .select('id')
    .eq('trip_id', tripId)
    .eq('traveler_id', userId)
    .limit(1)
    .maybeSingle()

  if (error) {
    console.error('Trip participant lookup failed', error)
    throw new AppError(500, 'Failed to validate trip participation')
  }

  return Boolean(data)
}

const getReactionCount = async (mediaId: string): Promise<number> => {
  const { count, error } = await supabase
    .from('reactions')
    .select('id', { count: 'exact', head: false })
    .eq('content_type', 'media')
    .eq('content_id', mediaId)

  if (error) {
    console.error('Reaction count lookup failed', error)
    throw new AppError(500, 'Failed to fetch reaction count')
  }

  return count ?? 0
}

const mapRowToMediaResponse = (row: MediaRow, extra: { likeCount?: number; commentCount?: number; distance?: number } = {}): MediaResponse => {
  return {
    id: row.id,
    uploaderId: row.uploader_id,
    tripId: row.trip_id,
    destinationId: row.destination_id,
    url: row.url,
    thumbnailUrl: row.thumbnail_url ?? null,
    type: row.type,
    caption: row.caption ?? null,
    latitude: row.latitude ?? null,
    longitude: row.longitude ?? null,
    locationName: row.location_name ?? null,
    isPublic: row.is_public,
    isFeatured: row.is_featured,
    tagCount: row.tag_count,
    taggedUsers: row.tagged_users ?? [],
    createdAt: row.created_at,
    uploader: row.uploader
      ? {
          id: row.uploader.id,
          fullName: row.uploader.full_name,
          avatarUrl: row.uploader.avatar_url,
        }
      : undefined,
    likeCount: extra.likeCount ?? 0,
    commentCount: extra.commentCount ?? 0,
    distance: extra.distance,
  }
}

export const createMedia = async (uploaderId: string, file: MediaUploadFile, input: CreateMediaInput): Promise<MediaResponse> => {
  if (!file) {
    throw new AppError(400, 'Media file is required')
  }

  const type = validateMediaFile(file)

  let tripId = input.tripId ?? null
  if (tripId) {
    const trip = await getTripById(tripId)
    if (!trip) {
      throw new AppError(404, 'Trip not found')
    }

    const authorized = await isTripParticipantOrOrganizer(uploaderId, tripId)
    if (!authorized) {
      throw new AppError(403, 'You must be a participant or organizer to attach media to this trip')
    }
  }

  let destinationId = input.destinationId ?? null
  if (destinationId) {
    await ensureDestinationExists(destinationId)
  }

  const key = getUploadKey(type, file.originalname)
  const url = await uploadToStorage(key, file.buffer, file.mimetype)

  let thumbnailUrl: string | null = null
  if (type === 'photo') {
    const thumbnailBuffer = await sharp(file.buffer)
      .rotate()
      .resize(400, 400, {
        fit: 'inside',
        withoutEnlargement: true,
      })
      .jpeg({ quality: 80 })
      .toBuffer()

    const thumbnailKey = `${THUMBNAIL_FOLDER}/${crypto.randomUUID()}.jpg`
    thumbnailUrl = await uploadToStorage(thumbnailKey, thumbnailBuffer, 'image/jpeg')
  }

  const taggedUsers = input.taggedUsers ?? []
  const { data, error } = await supabase
    .from('media')
    .insert({
      uploader_id: uploaderId,
      trip_id: tripId,
      destination_id: destinationId,
      url,
      thumbnail_url: thumbnailUrl,
      type,
      caption: input.caption ?? null,
      latitude: input.latitude ?? null,
      longitude: input.longitude ?? null,
      location_name: input.locationName ?? null,
      is_public: input.isPublic ?? true,
      is_featured: false,
      tag_count: taggedUsers.length,
      tagged_users: taggedUsers,
    })
    .select('*')
    .single()

  if (error || !data) {
    console.error('Media insert failed', error)
    throw new AppError(500, 'Failed to create media record')
  }

  return mapRowToMediaResponse(data as MediaRow)
}

export const getMediaById = async (mediaId: string, viewerId?: string | null): Promise<MediaResponse> => {
  const { data, error } = await supabase
    .from('media')
    .select('*, uploader:users!uploader_id(id, full_name, avatar_url)')
    .eq('id', mediaId)
    .maybeSingle()

  if (error) {
    console.error('Media lookup failed', error)
    throw new AppError(500, 'Failed to fetch media')
  }

  if (!data) {
    throw new AppError(404, 'Media not found')
  }

  const row = data as MediaRow
  if (!row.is_public && !viewerId) {
    throw new AppError(403, 'Media is private')
  }

  if (!row.is_public && viewerId) {
    const viewerAllowed = await isAcceptedFriend(viewerId, row.uploader_id)
    if (!viewerAllowed) {
      throw new AppError(403, 'Media is private')
    }
  }

  const likeCount = await getReactionCount(mediaId)
  return mapRowToMediaResponse(row, { likeCount, commentCount: 0 })
}

export const deleteMedia = async (userId: string, userRole: string, mediaId: string): Promise<void> => {
  const { data, error } = await supabase
    .from('media')
    .select('*')
    .eq('id', mediaId)
    .maybeSingle()

  if (error) {
    console.error('Media delete lookup failed', error)
    throw new AppError(500, 'Failed to fetch media record')
  }

  if (!data) {
    throw new AppError(404, 'Media not found')
  }

  if (data.uploader_id !== userId && userRole !== 'admin') {
    throw new AppError(403, 'Not authorized to delete this media')
  }

  await deleteFromStorage(data.url)
  await deleteFromStorage(data.thumbnail_url)

  const { error: reactionError } = await supabase
    .from('reactions')
    .delete()
    .eq('content_type', 'media')
    .eq('content_id', mediaId)

  if (reactionError) {
    console.error('Failed to delete media reactions', reactionError)
  }

  const { error: deleteError } = await supabase.from('media').delete().eq('id', mediaId)
  if (deleteError) {
    console.error('Failed to delete media record', deleteError)
    throw new AppError(500, 'Failed to remove media')
  }
}

export const listUserMedia = async (
  userId: string,
  viewerId: string | null | undefined,
  query: { page: number; limit: number; type: MediaType | 'all' },
): Promise<MediaListResponse> => {
  const includePrivate = viewerId === userId || (viewerId ? await isAcceptedFriend(viewerId, userId) : false)

  const offset = (query.page - 1) * query.limit
  const request = supabase
    .from('media')
    .select('*, uploader:users!uploader_id(id, full_name, avatar_url)', { count: 'exact' })
    .eq('uploader_id', userId)
    .order('created_at', { ascending: false })
    .range(offset, offset + query.limit - 1)

  if (!includePrivate) {
    request.eq('is_public', true)
  }

  if (query.type !== 'all') {
    request.eq('type', query.type)
  }

  const { data, count, error } = await request
  if (error) {
    console.error('User media lookup failed', error)
    throw new AppError(500, 'Failed to fetch user media')
  }

  return {
    items: (data ?? []).map((row) => mapRowToMediaResponse(row as MediaRow)),
    page: query.page,
    limit: query.limit,
    total: count ?? 0,
  }
}

export const listTripMedia = async (
  tripId: string,
  viewerId: string | null | undefined,
  query: { page: number; limit: number },
): Promise<MediaListResponse> => {
  const trip = await getTripById(tripId)
  if (!trip) {
    throw new AppError(404, 'Trip not found')
  }

  const authorized = viewerId ? await isTripParticipantOrOrganizer(viewerId, tripId) : false
  const offset = (query.page - 1) * query.limit

  const request = supabase
    .from('media')
    .select('*, uploader:users!uploader_id(id, full_name, avatar_url)', { count: 'exact' })
    .eq('trip_id', tripId)
    .order('created_at', { ascending: false })
    .range(offset, offset + query.limit - 1)

  if (!authorized) {
    request.eq('is_public', true)
  }

  const { data, count, error } = await request
  if (error) {
    console.error('Trip media lookup failed', error)
    throw new AppError(500, 'Failed to fetch trip media')
  }

  return {
    items: (data ?? []).map((row) => mapRowToMediaResponse(row as MediaRow)),
    page: query.page,
    limit: query.limit,
    total: count ?? 0,
  }
}

const haversineDistanceKm = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
  const toRad = (value: number) => (value * Math.PI) / 180
  const dLat = toRad(lat2 - lat1)
  const dLon = toRad(lon2 - lon1)
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return 6371 * c
}

export const listMediaNearby = async (query: NearbyMediaQuery): Promise<MediaResponse[]> => {
  const latDelta = query.radiusKm / 110.574
  const lngDelta = query.radiusKm / (111.320 * Math.cos((query.lat * Math.PI) / 180))

  const { data, error } = await supabase
    .from('media')
    .select('*, uploader:users!uploader_id(id, full_name, avatar_url)')
    .eq('is_public', true)
    .not('latitude', 'is', null)
    .not('longitude', 'is', null)
    .gte('latitude', query.lat - latDelta)
    .lte('latitude', query.lat + latDelta)
    .gte('longitude', query.lng - lngDelta)
    .lte('longitude', query.lng + lngDelta)

  if (error) {
    console.error('Nearby media lookup failed', error)
    throw new AppError(500, 'Failed to fetch nearby media')
  }

  const items = (data ?? []).map((row) => {
    const mapped = mapRowToMediaResponse(row as MediaRow)
    const distance = row.latitude != null && row.longitude != null ? haversineDistanceKm(query.lat, query.lng, Number(row.latitude), Number(row.longitude)) : Infinity
    return { ...mapped, distance }
  })

  return items.filter((item) => item.distance != null && item.distance <= query.radiusKm).sort((a, b) => (a.distance ?? 0) - (b.distance ?? 0))
}

export const updateMedia = async (userId: string, mediaId: string, updates: UpdateMediaInput): Promise<MediaResponse> => {
  const { data: current, error: currentError } = await supabase
    .from('media')
    .select('*')
    .eq('id', mediaId)
    .maybeSingle()

  if (currentError) {
    console.error('Media update lookup failed', currentError)
    throw new AppError(500, 'Failed to fetch media')
  }

  if (!current) {
    throw new AppError(404, 'Media not found')
  }

  if (current.uploader_id !== userId) {
    throw new AppError(403, 'Not authorized to update this media')
  }

  const payload: Record<string, unknown> = {}
  if (updates.caption !== undefined) payload.caption = updates.caption
  if (updates.isPublic !== undefined) payload.is_public = updates.isPublic
  if (updates.locationName !== undefined) payload.location_name = updates.locationName
  if (updates.taggedUsers !== undefined) {
    payload.tagged_users = updates.taggedUsers
    payload.tag_count = updates.taggedUsers.length
  }

  const { data, error } = await supabase
    .from('media')
    .update(payload)
    .eq('id', mediaId)
    .select('*, uploader:users!uploader_id(id, full_name, avatar_url)')
    .single()

  if (error || !data) {
    console.error('Media update failed', error)
    throw new AppError(500, 'Failed to update media')
  }

  return mapRowToMediaResponse(data as MediaRow)
}

const createNotification = async (
  userId: string,
  title: string,
  body: string,
  actionUrl: string,
  metadata: Record<string, unknown> = {},
): Promise<void> => {
  const { error } = await supabase
    .from('notifications')
    .insert({
      user_id: userId,
      type: 'social',
      title,
      body,
      action_url: actionUrl,
      metadata,
    })

  if (error) {
    console.error('Notification creation failed', error)
  }
}

export const tagMediaUser = async (userId: string, mediaId: string, taggedUserId: string): Promise<MediaResponse> => {
  const { data: media, error: mediaError } = await supabase
    .from('media')
    .select('*')
    .eq('id', mediaId)
    .maybeSingle()

  if (mediaError) {
    console.error('Media tag lookup failed', mediaError)
    throw new AppError(500, 'Failed to fetch media')
  }

  if (!media) {
    throw new AppError(404, 'Media not found')
  }

  if (media.uploader_id !== userId) {
    throw new AppError(403, 'Not authorized to tag users on this media')
  }

  const { data: userExists, error: userError } = await supabase
    .from('users')
    .select('id')
    .eq('id', taggedUserId)
    .maybeSingle()

  if (userError) {
    console.error('Tagged user lookup failed', userError)
    throw new AppError(500, 'Failed to verify tagged user')
  }

  if (!userExists) {
    throw new AppError(404, 'Tagged user not found')
  }

  const existingTags: string[] = media.tagged_users ?? []
  if (existingTags.includes(taggedUserId)) {
    throw new AppError(409, 'User is already tagged')
  }

  const taggedUsers = [...existingTags, taggedUserId]
  const { data, error: updateError } = await supabase
    .from('media')
    .update({ tagged_users: taggedUsers, tag_count: taggedUsers.length })
    .eq('id', mediaId)
    .select('*, uploader:users!uploader_id(id, full_name, avatar_url)')
    .single()

  if (updateError || !data) {
    console.error('Tag media update failed', updateError)
    throw new AppError(500, 'Failed to tag user')
  }

  await createNotification(
    taggedUserId,
    'You were tagged in media',
    `You were tagged in a media item by ${userId}`,
    `/media/${mediaId}`,
    { media_id: mediaId, tagged_by: userId },
  )

  return mapRowToMediaResponse(data as MediaRow)
}
