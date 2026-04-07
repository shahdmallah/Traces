import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { ok } from '../../shared/utils/response'
import * as profilesService from './profiles.service'

export const getMe = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return ok(res, await profilesService.getProfileByUserId(req.user.id))
  } catch (error) {
    return next(error as Error)
  }
}

export const updateMe = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return ok(res, await profilesService.updateProfile(req.user.id, req.body))
  } catch (error) {
    return next(error as Error)
  }
}

export const getPublic = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    return ok(res, await profilesService.getPublicProfile(req.params.id))
  } catch (error) {
    return next(error as Error)
  }
}
