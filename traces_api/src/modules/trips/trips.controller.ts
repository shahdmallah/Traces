
import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError, createValidationError } from '../../shared/middleware/error.middleware'
import { created, ok } from '../../shared/utils/response'
import * as tripsService from './trips.service'
import { CreateTripSchema } from './trips.validation'

export const create = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    if (!userId) {
      return next(new AppError(401, 'Unauthorized'))
    }

    console.log('POST /api/trips req.body:', req.body)

    const parsed = CreateTripSchema.safeParse(req.body)
    if (!parsed.success) {
      return next(createValidationError(parsed.error))
    }

    const trip = await tripsService.createTrip(userId, parsed.data)
    return created(res, trip)
  } catch (error) {
    return next(error as Error)
  }
}

export const listPublished = async (_req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const trips = await tripsService.listPublishedTrips()
    return ok(res, trips)
  } catch (error) {
    return next(error as Error)
  }
}

export const getById = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const id = req.params.id
    if (!id) {
      return next(new AppError(400, 'Trip ID is required'))
    }

    const detail = await tripsService.getTripByIdWithRelations(id)
    if (!detail) {
      return next(new AppError(404, 'Trip not found'))
    }

    return ok(res, detail)
  } catch (error) {
    return next(error as Error)
  }
}

export const listMyTrips = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    if (!userId) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const trips = await tripsService.listMyTrips(userId)
    return ok(res, trips)
  } catch (error) {
    return next(error as Error)
  }
}
