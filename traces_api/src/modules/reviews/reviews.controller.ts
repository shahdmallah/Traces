import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { created, noContent, ok } from '../../shared/utils/response'
import * as reviewsService from './reviews.service'

export const create = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return created(res, await reviewsService.createReview(req.user.id, req.params.trailId, req.body))
  } catch (error) {
    return next(error as Error)
  }
}
export const listTrailReviews = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    return ok(res, await reviewsService.getTrailReviews(req.params.trailId, req.query))
  } catch (error) {
    return next(error as Error)
  }
}
export const listMyReviews = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return ok(res, await reviewsService.getUserReviews(req.user.id))
  } catch (error) {
    return next(error as Error)
  }
}
export const update = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    return ok(res, await reviewsService.updateReview(req.params.id, req.user.id, req.body))
  } catch (error) {
    return next(error as Error)
  }
}
export const remove = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    await reviewsService.deleteReview(req.params.id, req.user.id)
    return noContent(res)
  } catch (error) {
    return next(error as Error)
  }
}
export const helpful = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    await reviewsService.markHelpful(req.params.id, req.user.id)
    return ok(res, { message: 'Marked as helpful' })
  } catch (error) {
    return next(error as Error)
  }
}

// TODO: implement reviews controller methods
// export const list    = async (req: AuthRequest, res: Response) => {}
// export const getById = async (req: AuthRequest, res: Response) => {}
// export const create  = async (req: AuthRequest, res: Response) => {}
// export const update  = async (req: AuthRequest, res: Response) => {}
// export const remove  = async (req: AuthRequest, res: Response) => {}
