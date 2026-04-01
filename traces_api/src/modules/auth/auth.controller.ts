import { NextFunction, Request, Response } from 'express'
import { created, ok } from '../../shared/utils/response'
import { AppError } from '../../shared/middleware/error.middleware'
import { LoginSchema, SignUpSchema } from './auth.validation'
import * as authService from './auth.service'

export const signUp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = SignUpSchema.safeParse(req.body)
    if (!parsed.success) {
      return next(new AppError(422, parsed.error.issues[0]?.message ?? 'Invalid signup payload'))
    }

    const user = await authService.signUp(parsed.data)
    return created(res, user)
  } catch (error) {
    return next(error as Error)
  }
}

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = LoginSchema.safeParse(req.body)
    if (!parsed.success) {
      return next(new AppError(422, parsed.error.issues[0]?.message ?? 'Invalid login payload'))
    }

    const result = await authService.login(parsed.data)
    return ok(res, result, 200)
  } catch (error) {
    return next(error as Error)
  }
}
