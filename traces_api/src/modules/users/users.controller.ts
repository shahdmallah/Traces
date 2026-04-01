import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError } from '../../shared/middleware/error.middleware'
import { ok } from '../../shared/utils/response'
import * as usersService from './users.service'

export const getMe = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const id = req.user?.id
    if (!id) {
      return next(new AppError(401, 'Unauthorized'))
    }

    let user: Awaited<ReturnType<typeof usersService.findMeById>>
    try {
      user = await usersService.findMeById(id)
    } catch {
      return next(new AppError(500, 'Internal server error'))
    }

    if (!user) {
      return next(new AppError(404, 'User not found'))
    }

    return ok(res, user)
  } catch (error) {
    return next(error as Error)
  }
}
