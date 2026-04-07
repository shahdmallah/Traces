import { Router } from 'express'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './lists.controller'

export const listsRouter = Router()

listsRouter.get('/profiles/me/lists', authenticate, controller.myLists)
listsRouter.post('/', authenticate, controller.create)
listsRouter.get('/:id', authenticate, controller.get)
listsRouter.post('/:id/trails/:trailId', authenticate, controller.addTrail)
listsRouter.delete('/:id/trails/:trailId', authenticate, controller.removeTrail)
listsRouter.patch('/:id', authenticate, controller.update)
listsRouter.delete('/:id', authenticate, controller.remove)
