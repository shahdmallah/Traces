import { Router } from 'express'
import { authenticate, requireRole } from '../../shared/middleware/auth.middleware'
import * as controller from './bookings.controller'

export const bookingsRouter = Router()

// All routes require authentication
bookingsRouter.use(authenticate)

// POST /api/bookings/:tripId - Create a new booking (travelers only)
bookingsRouter.post('/:tripId', requireRole(['traveler']), controller.createBooking)

// GET /api/bookings - Get traveler's bookings (travelers only)
bookingsRouter.get('/', requireRole(['traveler']), controller.getTravelerBookings)

// GET /api/bookings/:id - Get booking by ID (travelers, organizers, admins)
bookingsRouter.get('/:id', controller.getBookingById)

// GET /api/bookings/organizer - Get organizer's trip bookings (organizers only)
bookingsRouter.get('/organizer/bookings', requireRole(['organizer']), controller.getOrganizerBookings)

// PATCH /api/bookings/:id/cancel - Cancel a booking (travelers, organizers)
bookingsRouter.patch('/:id/cancel', controller.cancelBooking)

// PATCH /api/bookings/:id/confirm - Confirm a booking (organizers only)
bookingsRouter.patch('/:id/confirm', requireRole(['organizer']), controller.confirmBooking)

// GET /api/bookings/trips/:tripId/availability - Get trip availability (public)
bookingsRouter.get('/trips/:tripId/availability', controller.getTripAvailability)
