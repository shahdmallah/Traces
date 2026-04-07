import { Router } from 'express'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './profiles.controller'

export const profilesRouter = Router()

profilesRouter.get('/me', authenticate, controller.getMe)
profilesRouter.patch('/me', authenticate, controller.updateMe)
profilesRouter.get('/:id', controller.getPublic)
