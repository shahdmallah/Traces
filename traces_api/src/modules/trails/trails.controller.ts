import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError, createValidationError } from '../../shared/middleware/error.middleware'
import { created, noContent, ok, paginated } from '../../shared/utils/response'
import * as trailsService from './trails.service'
import { createTrailSchema, trailFiltersSchema, updateTrailSchema } from './trails.validation'

export const create = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const parsed = createTrailSchema.safeParse(req.body)
    if (!parsed.success) return next(createValidationError(parsed.error))
    return created(res, await trailsService.createTrail(parsed.data))
  } catch (error) {
    return next(error as Error)
  }
}

export const get = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    return ok(res, await trailsService.getTrailById(req.params.id))
  } catch (error) {
    return next(error as Error)
  }
}

export const list = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const parsed = trailFiltersSchema.safeParse(req.query)
    if (!parsed.success) return next(createValidationError(parsed.error))
    const result = await trailsService.listTrails(parsed.data)
    return paginated(res, result.data, result.total, result.page, result.limit)
  } catch (error) {
    return next(error as Error)
  }
}

export const nearby = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const lat = Number(req.query.lat)
    const lng = Number(req.query.lng)
    const radius = Number(req.query.radius ?? 5000)
    if (Number.isNaN(lat) || Number.isNaN(lng) || Number.isNaN(radius)) {
      return next(new AppError(400, 'lat, lng and radius are required numeric query params'))
    }
    return ok(res, await trailsService.findNearbyTrails(lat, lng, radius, Number(req.query.limit ?? 20)))
  } catch (error) {
    return next(error as Error)
  }
}

export const search = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const q = String(req.query.q ?? '').trim()
    if (!q) return next(new AppError(400, 'q query parameter is required'))
    const parsed = trailFiltersSchema.partial().safeParse(req.query)
    if (!parsed.success) return next(createValidationError(parsed.error))
    return ok(res, await trailsService.searchTrails(q, parsed.data))
  } catch (error) {
    return next(error as Error)
  }
}

export const update = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const parsed = updateTrailSchema.safeParse(req.body)
    if (!parsed.success) return next(createValidationError(parsed.error))
    return ok(res, await trailsService.updateTrail(req.params.id, parsed.data))
  } catch (error) {
    return next(error as Error)
  }
}

export const remove = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    await trailsService.deleteTrail(req.params.id)
    return noContent(res)
  } catch (error) {
    return next(error as Error)
  }
}
