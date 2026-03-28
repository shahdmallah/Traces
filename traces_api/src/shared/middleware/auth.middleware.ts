import { Request, Response, NextFunction } from 'express'
import { supabase } from '../../config/supabase'

export interface AuthRequest extends Request {
  user?: { id: string; role: string; email: string }
}

export const requireAuth = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (!token) return res.status(401).json({ error: 'Unauthorized' })

  const { data: { user }, error } = await supabase.auth.getUser(token)
  if (error || !user) return res.status(401).json({ error: 'Invalid token' })

  const { data: userData } = await supabase
    .from('users')
    .select('id, role, email')
    .eq('id', user.id)
    .single()

  if (!userData) return res.status(401).json({ error: 'User not found' })

  req.user = userData
  next()
}

export const requireRole = (roles: string[]) =>
  (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' })
    }
    next()
  }
