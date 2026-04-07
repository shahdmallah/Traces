import { z } from 'zod'

const difficultySchema = z.enum(['easy', 'moderate', 'hard', 'expert'])
const routeTypeSchema = z.enum(['loop', 'out-and-back', 'point-to-point'])

export const createTrailSchema = z.object({
  name: z.string().trim().min(1),
  description: z.string().trim().nullable().optional(),
  difficulty: difficultySchema,
  route_type: routeTypeSchema,
  length_meters: z.number().nonnegative(),
  elevation_gain_meters: z.number().nonnegative(),
  min_elevation_meters: z.number().nullable().optional(),
  max_elevation_meters: z.number().nullable().optional(),
  estimated_duration_minutes: z.number().int().nonnegative().nullable().optional(),
  geometry: z.record(z.any()).nullable().optional(),
  bounding_box: z.array(z.number()).length(4).nullable().optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional(),
  is_dog_friendly: z.boolean().default(false),
  is_kid_friendly: z.boolean().default(false),
  is_wheelchair_accessible: z.boolean().default(false),
  is_parking_available: z.boolean().default(false),
  is_bathroom_available: z.boolean().default(false),
  is_camping_allowed: z.boolean().default(false),
  popularity_score: z.number().default(0),
  total_reviews: z.number().int().nonnegative().default(0),
  average_rating: z.number().min(0).max(5).default(0),
  is_active: z.boolean().default(true),
  is_verified: z.boolean().default(false),
})

export const updateTrailSchema = createTrailSchema.partial()

export const trailFiltersSchema = z.object({
  difficulty: difficultySchema.optional(),
  min_length: z.coerce.number().nonnegative().optional(),
  max_length: z.coerce.number().nonnegative().optional(),
  min_elevation: z.coerce.number().optional(),
  max_elevation: z.coerce.number().optional(),
  is_dog_friendly: z.coerce.boolean().optional(),
  is_kid_friendly: z.coerce.boolean().optional(),
  lat: z.coerce.number().optional(),
  lng: z.coerce.number().optional(),
  radius_meters: z.coerce.number().positive().optional(),
  limit: z.coerce.number().int().positive().default(20),
  page: z.coerce.number().int().positive().default(1),
})

export type CreateTrailInput = z.infer<typeof createTrailSchema>
export type UpdateTrailInput = z.infer<typeof updateTrailSchema>
