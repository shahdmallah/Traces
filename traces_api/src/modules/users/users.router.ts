import { Router } from 'express'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './users.controller'

export const usersRouter = Router()

usersRouter.get('/me', authenticate, controller.getMe)
usersRouter.patch('/me', authenticate, controller.updateMe)
