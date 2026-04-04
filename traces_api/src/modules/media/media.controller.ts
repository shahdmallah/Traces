
import { Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import multer from 'multer'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import * as service from './media.service'
import type { MediaUploadFile } from './media.service'
import {
  PaginationQuerySchema,
  TagMediaSchema,
  UpdateMediaSchema,
  UserMediaQuerySchema,
  NearbyMediaQuerySchema,
} from './media.validation'

type MulterFile = {
  fieldname: string
  originalname: string
  encoding: string
  mimetype: string
  size: number
  buffer: Buffer
  destination?: string
  filename?: string
  path?: string
  stream?: NodeJS.ReadableStream
}

type MediaUploadRequest = AuthRequest & {
  file?: MulterFile
}

const extractBearer = (authorization: string | undefined): string | null => {
  if (!authorization || typeof authorization !== 'string') return null
  const match = /^Bearer\s+(.+)$/i.exec(authorization.trim())
  return match?.[1]?.trim() ?? null
}

const tryGetViewerId = (req: AuthRequest): string | null => {
  const token = extractBearer(req.get('authorization'))
  if (!token) return null

  const secret = process.env.JWT_SECRET
  if (!secret) return null

  try {
    const decoded = jwt.verify(token, secret)
    if (!decoded || typeof decoded !== 'object') return null

    const payload = decoded as Record<string, unknown>
    return typeof payload.id === 'string' ? payload.id : null
  } catch {
    return null
  }
}

const parseTaggedUsers = (value: unknown): string[] => {
  if (!value) return []
  if (Array.isArray(value)) return value.filter((item): item is string => typeof item === 'string')
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value)
      if (Array.isArray(parsed)) {
        return parsed.filter((item): item is string => typeof item === 'string')
      }
    } catch {
      return value.split(',').map((item) => item.trim()).filter(Boolean)
    }
  }
  return []
}

const parseBoolean = (value: unknown, fallback: boolean): boolean => {
  if (typeof value === 'boolean') return value
  if (typeof value === 'string') return value.toLowerCase() === 'true'
  return fallback
}

const parseNumber = (value: unknown): number | undefined => {
  if (typeof value === 'number') return value
  if (typeof value === 'string' && value.trim() !== '') {
    const parsed = Number(value)
    return Number.isFinite(parsed) ? parsed : undefined
  }
  return undefined
}

export const create = async (req: MediaUploadRequest, res: Response, next: NextFunction) => {
  try {
    const uploaderId = req.user?.id
    const file = req.file

    if (!uploaderId) {
      throw new Error('Unauthorized')
    }

    if (!file) {
      console.error('[media] No file received by multer', {
        uploaderId,
        bodyKeys: Object.keys(req.body ?? {}),
        contentType: req.get('content-type'),
      })
      throw new AppError(400, 'Media file is required')
    }

    const input = {
      caption: req.body.caption?.trim() ?? undefined,
      latitude: parseNumber(req.body.latitude),
      longitude: parseNumber(req.body.longitude),
      locationName: req.body.location_name?.trim() ?? undefined,
      tripId: req.body.trip_id?.trim() || undefined,
      destinationId: req.body.destination_id?.trim() || undefined,
      isPublic: parseBoolean(req.body.is_public, true),
      taggedUsers: parseTaggedUsers(req.body.tagged_users),
    }

    const media = await service.createMedia(uploaderId, file as MediaUploadFile, input)
    res.status(201).json(media)
  } catch (error) {
    next(error)
  }
}

export const handleUploadMiddlewareError = (error: unknown, _req: AuthRequest, _res: Response, next: NextFunction) => {
  if (error instanceof multer.MulterError) {
    console.error('[media] Multer upload error', error)

    if (error.code === 'LIMIT_FILE_SIZE') {
      return next(new AppError(400, 'File too large. Maximum size is 10MB for images, 50MB for videos.'))
    }

    return next(new AppError(400, `Failed to upload media file: ${error.message}`))
  }

  if (error) {
    console.error('[media] Unexpected upload middleware error', error)
  }

  return next(error)
}

export const debugStorageStatus = async (_req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const status = await service.getStorageDebugStatus()
    res.json(status)
  } catch (error) {
    next(error)
  }
}

export const getById = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const viewerId = req.user?.id ?? tryGetViewerId(req)
    const media = await service.getMediaById(req.params.id, viewerId)
    res.json(media)
  } catch (error) {
    next(error)
  }
}

export const remove = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    const userRole = req.user?.role
    if (!userId || !userRole) {
      throw new Error('Unauthorized')
    }

    await service.deleteMedia(userId, userRole, req.params.id)
    res.json({ message: 'Media deleted successfully' })
  } catch (error) {
    next(error)
  }
}

export const listUserMedia = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const query = UserMediaQuerySchema.parse(req.query)
    const viewerId = req.user?.id ?? tryGetViewerId(req)
    const media = await service.listUserMedia(req.params.userId, viewerId, query)
    res.json(media)
  } catch (error) {
    next(error)
  }
}

export const listNearby = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const query = NearbyMediaQuerySchema.parse(req.query)
    const media = await service.listMediaNearby({
      lat: query.lat,
      lng: query.lng,
      radiusKm: query.radius_km,
    })
    res.json(media)
  } catch (error) {
    next(error)
  }
}

export const listTripMedia = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const query = PaginationQuerySchema.parse(req.query)
    const viewerId = req.user?.id ?? tryGetViewerId(req)
    const media = await service.listTripMedia(req.params.tripId, viewerId, query)
    res.json(media)
  } catch (error) {
    next(error)
  }
}

export const update = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    if (!userId) {
      throw new Error('Unauthorized')
    }

    const updatePayload = UpdateMediaSchema.parse(req.body)
    const media = await service.updateMedia(userId, req.params.id, {
      caption: updatePayload.caption ?? undefined,
      isPublic: updatePayload.is_public,
      locationName: updatePayload.location_name ?? undefined,
      taggedUsers: updatePayload.tagged_users,
    })
    res.json(media)
  } catch (error) {
    next(error)
  }
}

export const tag = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    if (!userId) {
      throw new Error('Unauthorized')
    }

    const payload = TagMediaSchema.parse(req.body)
    const media = await service.tagMediaUser(userId, req.params.id, payload.user_id)
    res.json(media)
  } catch (error) {
    next(error)
  }
}
