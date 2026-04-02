import { supabase } from '../../config/supabase'
import { MeUser } from './users.types'

type UserRow = {
  id: string
  email: string
  full_name: string
  role: string
}

export const findMeById = async (id: string): Promise<MeUser | null> => {
  const { data, error } = await supabase
    .from('users')
    .select('id, email, full_name, role')
    .eq('id', id)
    .maybeSingle()

  if (error) {
    console.error('findMeById failed', error)
    throw new Error('USER_LOOKUP_FAILED')
  }

  if (!data) return null

  const row = data as UserRow
  return {
    id: row.id,
    email: row.email,
    fullName: row.full_name,
    role: row.role,
  }
}
