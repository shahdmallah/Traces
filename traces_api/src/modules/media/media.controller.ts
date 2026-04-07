import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { created, noContent, ok } from '../../shared/utils/response'
import * as mediaService from './media.service'

export const uploadTrailPhoto = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    if (!req.file) return next(new AppError(400, 'file is required'))
    return created(res, await mediaService.uploadTrailPhoto(req.params.trailId, req.user.id, req.file.buffer, req.body.caption))
  } catch (error) { return next(error as Error) }
}
export const removePhoto = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await mediaService.deletePhoto(req.params.id, req.user.id); return noContent(res) } catch (error) { return next(error as Error) }
}
export const listTrailPhotos = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { return ok(res, await mediaService.getTrailPhotos(req.params.trailId)) } catch (error) { return next(error as Error) }
}
export const setPrimaryPhoto = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await mediaService.setPrimaryPhoto(req.params.id, String(req.body.trailId ?? req.query.trailId ?? ''), req.user.id); return ok(res, { message: 'Primary photo updated' }) } catch (error) { return next(error as Error) }
}
