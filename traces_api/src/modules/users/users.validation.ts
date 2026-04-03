import { z } from 'zod'

export const UpdateMeSchema = z.object({
  full_name: z.string().trim().min(2).max(120).optional(),
  avatar_url: z.string().url().optional(),
  phone: z.string().trim().min(7).max(25).optional(),
  notification_preferences: z.record(z.any()).optional(),
  privacy_settings: z.record(z.any()).optional(),
})

