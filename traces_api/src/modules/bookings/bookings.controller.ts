
import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError, createValidationError } from '../../shared/middleware/error.middleware'
import { created, ok } from '../../shared/utils/response'
import * as bookingsService from './bookings.service'
import { CreateBookingSchema } from './bookings.validation'

export const createBooking = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const travelerId = req.user?.id
    if (!travelerId) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const { tripId } = req.params
    if (!tripId) {
      return next(new AppError(400, 'Trip ID is required'))
    }

    const parsed = CreateBookingSchema.safeParse(req.body)
    if (!parsed.success) {
      return next(createValidationError(parsed.error))
    }

    const booking = await bookingsService.createBooking(travelerId, tripId, parsed.data)
    return created(res, booking)
  } catch (error) {
    return next(error as Error)
  }
}

export const getTravelerBookings = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const travelerId = req.user?.id
    if (!travelerId) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10

    const result = await bookingsService.getTravelerBookings(travelerId, page, limit)
    return ok(res, result)
  } catch (error) {
    return next(error as Error)
  }
}

export const getBookingById = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    const userRole = req.user?.role
    if (!userId || !userRole) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const { id } = req.params
    if (!id) {
      return next(new AppError(400, 'Booking ID is required'))
    }

    const booking = await bookingsService.getBookingById(id, userId, userRole)
    if (!booking) {
      return next(new AppError(404, 'Booking not found'))
    }

    return ok(res, booking)
  } catch (error) {
    return next(error as Error)
  }
}

export const getOrganizerBookings = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const organizerId = req.user?.id
    if (!organizerId) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const tripId = req.query.tripId as string
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10

    const result = await bookingsService.getOrganizerBookings(organizerId, tripId, page, limit)
    return ok(res, result)
  } catch (error) {
    return next(error as Error)
  }
}

export const cancelBooking = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id
    const userRole = req.user?.role
    if (!userId || !userRole) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const { id } = req.params
    if (!id) {
      return next(new AppError(400, 'Booking ID is required'))
    }

    const booking = await bookingsService.cancelBooking(id, userId, userRole)
    return ok(res, booking)
  } catch (error) {
    return next(error as Error)
  }
}

export const confirmBooking = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const organizerId = req.user?.id
    if (!organizerId) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const { id } = req.params
    if (!id) {
      return next(new AppError(400, 'Booking ID is required'))
    }

    const booking = await bookingsService.confirmBooking(id, organizerId)
    return ok(res, booking)
  } catch (error) {
    return next(error as Error)
  }
}

export const getTripAvailability = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { tripId } = req.params
    if (!tripId) {
      return next(new AppError(400, 'Trip ID is required'))
    }

    const availability = await bookingsService.getTripAvailability(tripId)
    return ok(res, availability)
  } catch (error) {
    return next(error as Error)
  }
}
