import { Router } from 'express'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './reviews.controller'

export const reviewsRouter = Router()

reviewsRouter.post('/trails/:trailId/reviews', authenticate, controller.create)
reviewsRouter.get('/trails/:trailId/reviews', controller.listTrailReviews)
reviewsRouter.get('/profiles/me/reviews', authenticate, controller.listMyReviews)
reviewsRouter.patch('/:id', authenticate, controller.update)
reviewsRouter.delete('/:id', authenticate, controller.remove)
reviewsRouter.post('/:id/helpful', authenticate, controller.helpful)
