import { supabase } from '../../config/supabase'
import { MeUser } from './users.types'

type UserRow = {
  id: string
  email: string
  full_name: string
  role: string
  avatar_url?: string | null
  phone?: string | null
  notification_preferences?: unknown
  privacy_settings?: unknown
}

export const findMeById = async (id: string): Promise<MeUser | null> => {
  const { data, error } = await supabase
    .from('users')
    .select('id, email, full_name, role, avatar_url, phone, notification_preferences, privacy_settings')
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
    avatarUrl: row.avatar_url,
    phone: row.phone,
    notificationPreferences: row.notification_preferences,
    privacySettings: row.privacy_settings,
  }
}

export const updateMeById = async (id: string, input: Partial<{
  full_name: string
  avatar_url: string
  phone: string
  notification_preferences: unknown
  privacy_settings: unknown
}>): Promise<MeUser | null> => {
  const { data, error } = await supabase
    .from('users')
    .update(input)
    .eq('id', id)
    .select('id, email, full_name, role, avatar_url, phone, notification_preferences, privacy_settings')
    .single()

  if (error) {
    console.error('updateMeById failed', error)
    throw new Error('UPDATE_ME_FAILED')
  }

  const row = data as UserRow
  return {
    id: row.id,
    email: row.email,
    fullName: row.full_name,
    role: row.role,
    avatarUrl: row.avatar_url,
    phone: row.phone,
    notificationPreferences: row.notification_preferences,
    privacySettings: row.privacy_settings,
  }
}
