import { RequestHandler, Router } from 'express'
import multer from 'multer'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './media.controller'

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 20 * 1024 * 1024 } })
const uploadSingleFile: RequestHandler = (req, res, next) => upload.single('file')(req, res, next)

export const mediaRouter = Router()

mediaRouter.post('/trails/:trailId/photos', authenticate, uploadSingleFile, controller.uploadTrailPhoto)
mediaRouter.delete('/photos/:id', authenticate, controller.removePhoto)
mediaRouter.get('/trails/:trailId/photos', controller.listTrailPhotos)
mediaRouter.patch('/photos/:id/primary', authenticate, controller.setPrimaryPhoto)
