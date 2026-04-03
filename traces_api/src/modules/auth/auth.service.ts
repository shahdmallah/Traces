import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

import { supabase, supabaseAnon } from '../../config/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { AuthUserResponse, LoginInput, LoginResponse, SignUpInput } from './auth.types'

const BCRYPT_SALT_ROUNDS = 12

type ProviderError = {
  message?: string
  code?: string
  status?: number
}

const isDuplicateEmailError = (error: ProviderError): boolean => {
  const code = error.code?.toLowerCase() ?? ''
  const message = error.message?.toLowerCase() ?? ''
  return (
    code === 'email_exists' ||
    code === 'user_already_exists' ||
    code === '23505' ||
    /already registered|already exists|duplicate/.test(message)
  )
}

/** Used when public.users was deleted but auth.users still has the email. */
const findAuthUserIdByEmail = async (email: string): Promise<string | null> => {
  let page = 1
  const perPage = 1000
  const maxPages = 100

  for (let i = 0; i < maxPages; i++) {
    const { data, error } = await supabase.auth.admin.listUsers({ page, perPage })
    if (error) {
      console.error('listUsers failed while resolving auth user by email', error)
      return null
    }
    const match = data.users.find((u) => u.email?.toLowerCase() === email)
    if (match?.id) return match.id
    if (!data.nextPage) break
    page = data.nextPage
  }
  return null
}

export const signUp = async (input: SignUpInput): Promise<AuthUserResponse> => {
  const { password, fullName, role } = input
  const email = input.email.trim().toLowerCase()
  const passwordHash = await bcrypt.hash(password, BCRYPT_SALT_ROUNDS)

  const createAuthUser = () =>
    supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: false,
      user_metadata: { full_name: fullName, role },
    })

  let { data: authData, error: createAuthError } = await createAuthUser()

  if (createAuthError && isDuplicateEmailError(createAuthError)) {
    const { data: profileRow } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .maybeSingle()

    if (profileRow) {
      throw new AppError(409, 'Email is already registered')
    }

    const orphanAuthId = await findAuthUserIdByEmail(email)
    if (!orphanAuthId) {
      throw new AppError(409, 'Email is already registered')
    }

    const { error: deleteOrphanError } = await supabase.auth.admin.deleteUser(orphanAuthId)
    if (deleteOrphanError) {
      console.error('Failed to delete orphaned auth user before signup retry', {
        email,
        orphanAuthId,
        deleteOrphanError,
      })
      throw new AppError(502, 'Authentication provider error')
    }

    const retry = await createAuthUser()
    authData = retry.data
    createAuthError = retry.error
  }

  if (createAuthError) {
    if (isDuplicateEmailError(createAuthError)) {
      throw new AppError(409, 'Email is already registered')
    }
    if (createAuthError.status === 400 || createAuthError.status === 422) {
      throw new AppError(422, 'Invalid signup data')
    }
    throw new AppError(502, 'Authentication provider error')
  }

  const authUserId = authData.user?.id
  const authEmail = authData.user?.email

  if (!authUserId || !authEmail) {
    throw new AppError(500, 'Failed to create auth user')
  }

  const { error: profileInsertError } = await supabase
    .from('users')
    .insert({
      id: authUserId,
      email: authEmail,
      password_hash: passwordHash,
      full_name: fullName,
      role,
    })

  if (profileInsertError) {
    try {
      const { error: rollbackError } = await supabase.auth.admin.deleteUser(authUserId)
      if (rollbackError) {
        console.error('Failed to rollback auth user after profile insert error', {
          authUserId,
          rollbackError,
        })
      }
    } catch (rollbackException) {
      console.error('Unexpected rollback exception while deleting auth user', {
        authUserId,
        rollbackException,
      })
    }

    if (isDuplicateEmailError(profileInsertError as ProviderError)) {
      throw new AppError(409, 'Email is already registered')
    }
    throw new AppError(500, 'Failed to create user profile')
  }

  if (role === 'organizer') {
    const { error: organizerInsertError } = await supabase
      .from('organizer_profiles')
      .insert({
        user_id: authUserId,
        tier: 'new',
        commission_rate: 10.0,
      })

    if (organizerInsertError) {
      console.error('Failed to create organizer profile', organizerInsertError)
      try {
        const { error: rollbackError } = await supabase.auth.admin.deleteUser(authUserId)
        if (rollbackError) {
          console.error('Failed to rollback auth user after organizer profile insert error', {
            authUserId,
            rollbackError,
          })
        }
      } catch (rollbackException) {
        console.error('Unexpected rollback exception while deleting auth user', {
          authUserId,
          rollbackException,
        })
      }
      throw new AppError(500, 'Failed to create organizer profile')
    }
  }

  return {
    id: authUserId,
    email: authEmail,
    fullName,
    role,
  }
}

type UserRow = {
  id: string
  email: string
  password_hash: string | null
  full_name: string
  role: string
  is_suspended: boolean
}

export const login = async (input: LoginInput): Promise<LoginResponse> => {
  const email = input.email.trim().toLowerCase()
  const jwtSecret = process.env.JWT_SECRET

  if (!jwtSecret) {
    console.error('JWT_SECRET is not configured')
    throw new AppError(500, 'Server configuration error')
  }

  const { data: user, error } = await supabase
    .from('users')
    .select('id, email, password_hash, full_name, role, is_suspended')
    .eq('email', email)
    .maybeSingle()

  if (error) {
    console.error('Login user lookup failed', error)
    throw new AppError(500, 'Failed to sign in')
  }

  if (!user) {
    throw new AppError(401, 'Invalid credentials')
  }

  const row = user as UserRow

  let passwordOk = false

  if (row.password_hash) {
    try {
      passwordOk = await bcrypt.compare(input.password, row.password_hash)
    } catch (e) {
      console.error('Password verification failed', e)
      throw new AppError(500, 'Failed to sign in')
    }
  } else {
    // Legacy users: row exists but password was only in Supabase Auth (no bcrypt in DB yet)
    if (!supabaseAnon) {
      console.error('SUPABASE_ANON_KEY missing — cannot verify legacy password login')
      throw new AppError(500, 'Server configuration error')
    }

    const { data: authData, error: authError } = await supabaseAnon.auth.signInWithPassword({
      email,
      password: input.password,
    })

    if (authError || !authData.user) {
      throw new AppError(401, 'Invalid credentials')
    }

    if (authData.user.id !== row.id) {
      console.error('Auth user id mismatch vs public.users row', {
        authUserId: authData.user.id,
        profileId: row.id,
      })
      throw new AppError(401, 'Invalid credentials')
    }

    passwordOk = true

    try {
      const newHash = await bcrypt.hash(input.password, BCRYPT_SALT_ROUNDS)
      const { error: backfillError } = await supabase
        .from('users')
        .update({ password_hash: newHash })
        .eq('id', row.id)

      if (backfillError) {
        console.error('Failed to backfill password_hash after Supabase auth login', backfillError)
      }
    } catch (e) {
      console.error('Unexpected error backfilling password_hash', e)
    }
  }

  if (!passwordOk) {
    throw new AppError(401, 'Invalid credentials')
  }

  if (row.is_suspended) {
    throw new AppError(403, 'Account suspended')
  }

  let token: string
  try {
    token = jwt.sign({ id: row.id, role: row.role }, jwtSecret, { expiresIn: '7d' })
  } catch (e) {
    console.error('JWT signing failed', e)
    throw new AppError(500, 'Failed to sign in')
  }

  return {
    user: {
      id: row.id,
      email: row.email,
      fullName: row.full_name,
      role: row.role,
    },
    token,
  }
}
