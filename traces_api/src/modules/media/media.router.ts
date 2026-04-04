import { Router } from 'express'
import multer from 'multer'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './media.controller'

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 50 * 1024 * 1024 } })

export const mediaRouter = Router()

mediaRouter.get('/nearby', controller.listNearby)
mediaRouter.get('/users/:userId/media', controller.listUserMedia)
mediaRouter.get('/:id', controller.getById)
mediaRouter.post('/', authenticate, upload.single('file'), controller.create)
mediaRouter.patch('/:id', authenticate, controller.update)
mediaRouter.delete('/:id', authenticate, controller.remove)
mediaRouter.post('/:id/tag', authenticate, controller.tag)
