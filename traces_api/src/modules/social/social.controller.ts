import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { noContent, ok } from '../../shared/utils/response'
import * as socialService from './social.service'

export const follow = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    await socialService.followUser(req.user.id, req.params.id)
    return ok(res, { message: 'Followed' })
  } catch (error) { return next(error as Error) }
}
export const unfollow = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    if (!req.user?.id) return next(new AppError(401, 'Unauthorized'))
    await socialService.unfollowUser(req.user.id, req.params.id)
    return noContent(res)
  } catch (error) { return next(error as Error) }
}
export const followers = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { return ok(res, await socialService.getFollowers(req.params.id, Number(req.query.limit ?? 20))) } catch (error) { return next(error as Error) }
}
export const following = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { return ok(res, await socialService.getFollowing(req.params.id, Number(req.query.limit ?? 20))) } catch (error) { return next(error as Error) }
}
export const like = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await socialService.likeActivity(req.user.id, req.params.id); return ok(res, { message: 'Liked' }) } catch (error) { return next(error as Error) }
}
export const unlike = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await socialService.unlikeActivity(req.user.id, req.params.id); return noContent(res) } catch (error) { return next(error as Error) }
}
export const comment = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); return ok(res, await socialService.commentOnActivity(req.user.id, req.params.id, req.body.content)) } catch (error) { return next(error as Error) }
}
export const removeComment = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await socialService.deleteComment(req.params.id, req.user.id); return noContent(res) } catch (error) { return next(error as Error) }
}
export const comments = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { return ok(res, await socialService.getActivityComments(req.params.id, Number(req.query.limit ?? 50))) } catch (error) { return next(error as Error) }
}
export const feed = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); return ok(res, await socialService.getFeed(req.user.id, Number(req.query.limit ?? 20), Number(req.query.page ?? 1))) } catch (error) { return next(error as Error) }
}
