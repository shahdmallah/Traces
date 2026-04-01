import { supabase } from '../../config/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { AuthUserResponse, SignUpInput } from './auth.types'

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

export const signUp = async (input: SignUpInput): Promise<AuthUserResponse> => {
  const { password, fullName, role } = input
  const email = input.email.trim().toLowerCase()

  const { data: authData, error: createAuthError } =
    await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: false,
      user_metadata: { full_name: fullName, role },
    })

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

  return {
    id: authUserId,
    email: authEmail,
    fullName,
    role,
  }
}
