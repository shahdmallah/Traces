export type MeUser = {
  id: string
  email: string
  fullName: string
  role: string
  avatarUrl?: string | null
  phone?: string | null
  notificationPreferences?: unknown
  privacySettings?: unknown
}
