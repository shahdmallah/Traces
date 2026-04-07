import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { created, noContent, ok } from '../../shared/utils/response'
import * as listsService from './lists.service'

export const myLists = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); return ok(res, await listsService.getUserLists(req.user.id)) } catch (error) { return next(error as Error) }
}
export const create = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); return created(res, await listsService.createList(req.user.id, req.body)) } catch (error) { return next(error as Error) }
}
export const get = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); return ok(res, await listsService.getListById(req.params.id, req.user.id)) } catch (error) { return next(error as Error) }
}
export const addTrail = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await listsService.addTrailToList(req.params.id, req.params.trailId, req.user.id); return ok(res, { message: 'Trail added' }) } catch (error) { return next(error as Error) }
}
export const removeTrail = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await listsService.removeTrailFromList(req.params.id, req.params.trailId, req.user.id); return noContent(res) } catch (error) { return next(error as Error) }
}
export const update = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); return ok(res, await listsService.updateList(req.params.id, req.user.id, req.body)) } catch (error) { return next(error as Error) }
}
export const remove = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try { if (!req.user?.id) return next(new AppError(401, 'Unauthorized')); await listsService.deleteList(req.params.id, req.user.id); return noContent(res) } catch (error) { return next(error as Error) }
}
