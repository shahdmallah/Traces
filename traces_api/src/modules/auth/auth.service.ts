import { supabase } from '../../config/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { AuthUserResponse, SignUpInput } from './auth.types'

const isDuplicateEmailError = (message: string): boolean =>
  /already registered|already exists|duplicate/i.test(message)

export const signUp = async (input: SignUpInput): Promise<AuthUserResponse> => {
  const { email, password, fullName, role } = input

  const { data: authData, error: createAuthError } =
    await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: false,
      user_metadata: { full_name: fullName, role },
    })

  if (createAuthError) {
    if (isDuplicateEmailError(createAuthError.message)) {
      throw new AppError(409, 'Email is already registered')
    }
    throw new AppError(400, createAuthError.message)
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
    await supabase.auth.admin.deleteUser(authUserId)
    throw new AppError(400, profileInsertError.message)
  }

  return {
    id: authUserId,
    email: authEmail,
    fullName,
    role,
  }
}
