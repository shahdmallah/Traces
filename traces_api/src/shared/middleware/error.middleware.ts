import { Request, Response, NextFunction } from 'express'
import { ZodError } from 'zod'

type ErrorDetail = {
  field: string
  message: string
}

export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public details?: ErrorDetail[]
  ) {
    super(message)
    this.name = 'AppError'
  }
}

const toSnakeCase = (value: string): string =>
  value.replace(/([a-z0-9])([A-Z])/g, '$1_$2').toLowerCase()

const formatFieldName = (path: Array<string | number>): string => {
  const first = path[0]
  if (typeof first === 'number') return String(first)
  if (typeof first === 'string' && first.length > 0) return toSnakeCase(first)
  return 'body'
}

const formatIssueMessage = (field: string, message: string): string => {
  if (message === 'Required') {
    return `${field} is required`
  }
  return message
}

export const mapZodIssues = (error: ZodError): ErrorDetail[] =>
  error.issues.map((issue) => {
    const field = formatFieldName(issue.path)
    return {
      field,
      message: formatIssueMessage(field, issue.message),
    }
  })

export const createValidationError = (error: ZodError): AppError =>
  new AppError(400, 'Validation failed', mapZodIssues(error))

export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof ZodError) {
    return res.status(400).json({
      error: {
        message: 'Validation failed',
        details: mapZodIssues(err),
      },
    })
  }

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        message: err.message,
        ...(err.details ? { details: err.details } : {}),
      },
    })
  }
  console.error(err)
  res.status(500).json({
    error: { message: 'Internal server error' },
  })
}
