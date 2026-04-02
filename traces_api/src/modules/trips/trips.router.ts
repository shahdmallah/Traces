import { Router } from 'express'
import { authenticate, requireRole } from '../../shared/middleware/auth.middleware'
import * as controller from './trips.controller'

export const tripsRouter = Router()

tripsRouter.get('/', controller.listPublished)
tripsRouter.get('/my', authenticate, requireRole(['organizer']), controller.listMyTrips)
tripsRouter.post('/', authenticate, requireRole(['organizer']), controller.create)
