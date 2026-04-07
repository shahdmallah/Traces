import { RequestHandler, Router } from 'express'
import multer from 'multer'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './activities.controller'

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 20 * 1024 * 1024 } })
const uploadSingleFile: RequestHandler = (req, res, next) => upload.single('file')(req, res, next)

export const activitiesRouter = Router()

activitiesRouter.post('/', authenticate, controller.create)
activitiesRouter.get('/', authenticate, controller.list)
activitiesRouter.get('/:id', controller.get)
activitiesRouter.post('/:id/gpx', authenticate, uploadSingleFile, controller.uploadGPX)
activitiesRouter.patch('/:id', authenticate, controller.update)
activitiesRouter.delete('/:id', authenticate, controller.remove)
