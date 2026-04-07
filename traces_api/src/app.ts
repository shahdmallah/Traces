import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import dotenv from 'dotenv'
import { rateLimit } from 'express-rate-limit'

import { authRouter } from './modules/auth/auth.router'
import { profilesRouter } from './modules/profiles/profiles.router'
import { trailsRouter } from './modules/trails/trails.router'
import { activitiesRouter } from './modules/activities/activities.router'
import { mediaRouter } from './modules/media/media.router'
import { reviewsRouter } from './modules/reviews/reviews.router'
import { socialRouter } from './modules/social/social.router'
import { listsRouter } from './modules/lists/lists.router'
import { errorHandler } from './shared/middleware/error.middleware'
import { supabase } from './lib/supabase'

dotenv.config()

const app = express()
const PORT = process.env.PORT ?? 3000

app.use(helmet())
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') ?? '*' }))
app.use(morgan('dev'))
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 })
app.use('/api/', limiter)

// Routes are registered only after body-parsing middleware.
app.use('/api/auth',          authRouter)
app.use('/api/profiles',      profilesRouter)
app.use('/api/trails',        trailsRouter)
app.use('/api/activities',    activitiesRouter)
app.use('/api/media',         mediaRouter)
app.use('/api/reviews',       reviewsRouter)
app.use('/api/social',        socialRouter)
app.use('/api/lists',         listsRouter)

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
