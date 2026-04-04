import { z } from 'zod'

export const UpdateMediaSchema = z.object({
  caption: z.string().max(500).nullable().optional(),
  is_public: z.boolean().optional(),
  location_name: z.string().max(255).nullable().optional(),
  tagged_users: z.array(z.string().uuid()).optional(),
})

export const TagMediaSchema = z.object({
  user_id: z.string().uuid(),
})

export const UserMediaQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
  type: z.enum(['photo', 'video', 'all']).default('all'),
})

export const NearbyMediaQuerySchema = z.object({
  lat: z.coerce.number(),
  lng: z.coerce.number(),
  radius_km: z.coerce.number().positive().default(5),
})

export const PaginationQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
})
