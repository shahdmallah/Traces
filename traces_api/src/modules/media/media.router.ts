import { RequestHandler, Router } from 'express'
import multer from 'multer'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './media.controller'

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 50 * 1024 * 1024 } })
const uploadSingleFile: RequestHandler = (req, res, next) => {
  upload.single('file')(req, res, (error) => controller.handleUploadMiddlewareError(error, req, res, next))
}

export const mediaRouter = Router()

mediaRouter.get('/debug/storage-status', authenticate, controller.debugStorageStatus)
mediaRouter.get('/nearby', controller.listNearby)
mediaRouter.get('/users/:userId/media', controller.listUserMedia)
mediaRouter.get('/:id', controller.getById)
mediaRouter.post('/', authenticate, uploadSingleFile, controller.create)
mediaRouter.patch('/:id', authenticate, controller.update)
mediaRouter.delete('/:id', authenticate, controller.remove)
mediaRouter.post('/:id/tag', authenticate, controller.tag)
