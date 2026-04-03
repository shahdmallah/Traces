import { NextFunction, Response } from 'express'
import { AuthRequest } from '../../shared/middleware/auth.middleware'
import { AppError, createValidationError } from '../../shared/middleware/error.middleware'
import { ok } from '../../shared/utils/response'
import * as usersService from './users.service'
import { UpdateMeSchema } from './users.validation'

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

export const updateMe = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const id = req.user?.id
    if (!id) {
      return next(new AppError(401, 'Unauthorized'))
    }

    const parsed = UpdateMeSchema.safeParse(req.body)
    if (!parsed.success) {
      return next(createValidationError(parsed.error))
    }

    const updatedUser = await usersService.updateMeById(id, parsed.data)
    if (!updatedUser) {
      return next(new AppError(404, 'User not found'))
    }

    return ok(res, updatedUser)
  } catch (error) {
    return next(error as Error)
  }
}
