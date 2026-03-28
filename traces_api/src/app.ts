import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import dotenv from 'dotenv'
import { rateLimit } from 'express-rate-limit'

import { authRouter } from './modules/auth/auth.router'
import { usersRouter } from './modules/users/users.router'
import { tripsRouter } from './modules/trips/trips.router'
import { bookingsRouter } from './modules/bookings/bookings.router'
import { destinationsRouter } from './modules/destinations/destinations.router'
import { mediaRouter } from './modules/media/media.router'
import { reviewsRouter } from './modules/reviews/reviews.router'
import { messagingRouter } from './modules/messaging/messaging.router'
import { financialRouter } from './modules/financial/financial.router'
import { socialRouter } from './modules/social/social.router'
import { gamificationRouter } from './modules/gamification/gamification.router'
import { adminRouter } from './modules/admin/admin.router'
import { notificationsRouter } from './modules/notifications/notifications.router'
import { errorHandler } from './shared/middleware/error.middleware'
import { supabase } from './config/supabase'

dotenv.config()

const app = express()
const PORT = process.env.PORT ?? 3000

app.use(helmet())
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') ?? '*' }))
app.use(morgan('dev'))
app.use(express.json({ limit: '10mb' }))

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 })
app.use('/api/', limiter)

// Routes
app.use('/api/auth',          authRouter)
app.use('/api/users',         usersRouter)
app.use('/api/trips',         tripsRouter)
app.use('/api/bookings',      bookingsRouter)
app.use('/api/destinations',  destinationsRouter)
app.use('/api/media',         mediaRouter)
app.use('/api/reviews',       reviewsRouter)
app.use('/api/messaging',     messagingRouter)
app.use('/api/financial',     financialRouter)
app.use('/api/social',        socialRouter)
app.use('/api/gamification',  gamificationRouter)
app.use('/api/admin',         adminRouter)
app.use('/api/notifications', notificationsRouter)

app.get('/health', async (_req, res) => {
  try {
    const { error } = await supabase.from('_traces_health_probe').select('*').limit(0)
    const ok =
      !error ||
      /relation|does not exist|schema cache/i.test(error.message ?? '') ||
      error.code === 'PGRST116' ||
      error.code === '42P01'
    if (!ok) {
      return res.status(503).json({
        status: 'error',
        app: 'traces-api',
        database: 'query_failed',
        detail: error.message,
        code: error.code,
      })
    }
    return res.json({ status: 'ok', app: 'traces-api', database: 'connected' })
  } catch (e) {
    return res.status(503).json({
      status: 'error',
      app: 'traces-api',
      database: 'unreachable',
      detail: String(e),
    })
  }
})

app.use(errorHandler)

app.listen(PORT, () => console.log(`Traces API running on port ${PORT}`))

export default app
