import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { created, noContent, ok } from '../../shared/utils/response'
import * as activitiesService from './activities.service'

export const create = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return created(res, await activitiesService.createActivity(req.user.id, req.body))
  } catch (error) {
    return next(error as Error)
  }
}

export const get = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    return ok(res, await activitiesService.getActivityById(req.params.id, req.user?.id))
  } catch (error) {
    return next(error as Error)
  }
}

export const list = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return ok(res, await activitiesService.getUserActivities(req.user.id, req.query))
  } catch (error) {
    return next(error as Error)
  }
}

export const uploadGPX = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const file = req.file
    if (!file) return next(new AppError(400, 'GPX file is required'))
    return ok(res, await activitiesService.uploadGPX(req.params.id, file.buffer))
  } catch (error) {
    return next(error as Error)
  }
}

export const update = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    return ok(res, await activitiesService.updateActivity(req.params.id, req.body))
  } catch (error) {
    return next(error as Error)
  }
}

export const remove = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    await activitiesService.deleteActivity(req.params.id)
    return noContent(res)
  } catch (error) {
    return next(error as Error)
  }
}
