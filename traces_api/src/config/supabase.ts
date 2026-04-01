import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

dotenv.config()

const url = process.env.SUPABASE_URL
const serviceRole = process.env.SUPABASE_SERVICE_ROLE_KEY
const anonOrPublishable = process.env.SUPABASE_ANON_KEY
const key = serviceRole || anonOrPublishable

if (!url || !key) {
  throw new Error(
    'Missing Supabase env: set SUPABASE_URL and SUPABASE_ANON_KEY (and SUPABASE_SERVICE_ROLE_KEY for server-side admin)',
  )
}

if (!serviceRole && process.env.NODE_ENV !== 'production') {
  console.warn(
    '[supabase] SUPABASE_SERVICE_ROLE_KEY not set — using SUPABASE_ANON_KEY. RLS applies; set service role for admin API routes.',
  )
}

if (!serviceRole && process.env.NODE_ENV === 'production') {
  console.warn(
    '[supabase] SUPABASE_SERVICE_ROLE_KEY not set in production — using anon/publishable key only (RLS enforced).',
  )
}

// Prefer service role on the server; falls back to anon/publishable when unset
export const supabase = createClient(url, key, {
  auth: { autoRefreshToken: false, persistSession: false },
})

/** Anon/publishable client — used for password grant (e.g. legacy logins without password_hash). */
export const supabaseAnon = anonOrPublishable
  ? createClient(url, anonOrPublishable, {
      auth: { autoRefreshToken: false, persistSession: false },
    })
  : null
