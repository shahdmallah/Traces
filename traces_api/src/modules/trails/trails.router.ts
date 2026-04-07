import { Router } from 'express'
import { authenticate, requireRole } from '../../shared/middleware/auth.middleware'
import * as controller from './trails.controller'

export const trailsRouter = Router()

trailsRouter.get('/nearby', controller.nearby)
trailsRouter.get('/search', controller.search)
trailsRouter.get('/', controller.list)
trailsRouter.get('/:id', controller.get)
trailsRouter.post('/', authenticate, requireRole(['organizer', 'admin']), controller.create)
trailsRouter.patch('/:id', authenticate, controller.update)
trailsRouter.delete('/:id', authenticate, controller.remove)
