import { NextFunction, Request, Response } from 'express'
import jwt from 'jsonwebtoken'

export interface AuthRequest extends Request {
  user?: {
    id: string
    role: string
  }
}

const extractBearer = (authorization: string | undefined): string | null => {
  if (!authorization || typeof authorization !== 'string') return null
  const match = /^Bearer\s+(.+)$/i.exec(authorization.trim())
  const token = match?.[1]?.trim()
  return token || null
}

const isJwtPayload = (decoded: unknown): decoded is { id: string; role: string } => {
  if (decoded === null || typeof decoded !== 'object') return false
  const o = decoded as Record<string, unknown>
  return typeof o.id === 'string' && typeof o.role === 'string'
}

export const authenticate = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const token = extractBearer(req.headers.authorization)
  if (!token) {
    res.status(401).json({ error: 'Unauthorized' })
    return
  }

  const secret = process.env.JWT_SECRET
  if (!secret) {
    console.error('JWT_SECRET is not configured')
    res.status(500).json({ error: { message: 'Internal server error' } })
    return
  }

  try {
    const decoded = jwt.verify(token, secret)
    if (!isJwtPayload(decoded)) {
      res.status(401).json({ error: 'Invalid or expired token' })
      return
    }
    req.user = { id: decoded.id, role: decoded.role }
    next()
  } catch {
    res.status(401).json({ error: 'Invalid or expired token' })
  }
}

export const requireRole = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role)) {
      res.status(403).json({ error: 'Forbidden' })
      return
    }
    next()
  }
}
