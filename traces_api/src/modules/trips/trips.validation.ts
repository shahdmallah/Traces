import { z } from 'zod'

const recurrencePatternSchema = z.object({
  frequency: z.enum(['weekly', 'monthly']),
  end_date: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Recurrence end date must be a valid date',
  }),
}).strip()

const itineraryItemSchema = z.object({
  day: z.number().int().positive('Itinerary day must be a positive integer'),
  time: z.string().trim().min(1, 'Itinerary time is required'),
  activity: z.string().trim().min(1, 'Itinerary activity is required'),
  location: z.string().trim().min(1).optional(),
  notes: z.string().trim().min(1).optional(),
}).strip()

const meetingPointSchema = z.object({
  address: z.string().trim().min(1, 'Meeting point address is required'),
  lat: z.number(),
  lng: z.number(),
  notes: z.string().trim().min(1).optional(),
}).strip()

const groupDiscountSchema = z.object({
  min_people: z.number().int().positive('Group discount minimum people must be positive'),
  discount_percent: z.number().min(0).max(100),
}).strip()

const earlyBirdDiscountSchema = z.object({
  deadline: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Early bird deadline must be a valid date',
  }),
  discount_percent: z.number().min(0).max(100),
}).strip()

const customQuestionSchema = z.object({
  question: z.string().trim().min(1, 'Custom question is required'),
  required: z.boolean(),
}).strip()

const routeCoordinateSchema = z.object({
  lat: z.number(),
  lng: z.number(),
}).strip()

export const CreateTripSchema = z.object({
  location_id: z.string().uuid('Location id must be a valid UUID').nullable().optional(),

  title: z.string().trim().min(1, 'Title is required').max(255),

  description: z.string().trim().min(1, 'Description cannot be empty').nullable().optional(),

  start_date: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'Start date must be a valid date',
  }),

  end_date: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: 'End date must be a valid date',
  }),

  max_participants: z.number().int().positive('Max participants must be greater than 0'),

  price: z.number().nonnegative('Price cannot be negative'),

  deposit_amount: z.number().nonnegative('Deposit amount cannot be negative').nullable().optional(),

  cancellation_policy: z.enum(['flexible', 'moderate', 'strict']).optional(),
  instant_booking: z.boolean().optional(),
  is_featured: z.boolean().optional(),
  is_private: z.boolean().optional(),

  is_recurring: z.boolean().optional(),

  recurrence_pattern: recurrencePatternSchema.nullable().optional(),

  min_age: z.number().int().nonnegative().nullable().optional(),
  max_age: z.number().int().nonnegative().nullable().optional(),

  fitness_level: z.string().trim().min(1).nullable().optional(),

  required_skills: z.array(z.string().trim().min(1)).optional(),

  itinerary: z.array(itineraryItemSchema).optional(),

  meeting_point: meetingPointSchema.nullable().optional(),

  included_items: z.array(z.string().trim().min(1)).optional(),
  excluded_items: z.array(z.string().trim().min(1)).optional(),

  meal_plan: z.string().trim().min(1).nullable().optional(),

  packing_recommendations: z.array(z.string().trim().min(1)).optional(),

  group_discounts: z.array(groupDiscountSchema).optional(),

  early_bird_discount: earlyBirdDiscountSchema.nullable().optional(),

  custom_questions: z.array(customQuestionSchema).optional(),

  cover_image_url: z.string().url().nullable().optional(),

  media_urls: z.array(z.string().url()).optional(),

  route_coordinates: z.array(routeCoordinateSchema).optional(),
})
.strip()
.superRefine((data, ctx) => {
  const start = new Date(data.start_date)
  const end = new Date(data.end_date)

  if (isNaN(start.getTime())) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Invalid start_date',
      path: ['start_date'],
    })
  }

  if (isNaN(end.getTime())) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Invalid end_date',
      path: ['end_date'],
    })
  }

  if (end <= start) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'End date must be after start date',
      path: ['end_date'],
    })
  }

  if (
    data.deposit_amount != null &&
    data.deposit_amount > data.price
  ) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Deposit amount cannot exceed price',
      path: ['deposit_amount'],
    })
  }

  if (
    data.min_age != null &&
    data.max_age != null &&
    data.min_age > data.max_age
  ) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Minimum age cannot be greater than maximum age',
      path: ['min_age'],
    })
  }

  if (data.is_recurring && !data.recurrence_pattern) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Recurrence pattern is required when trip is recurring',
      path: ['recurrence_pattern'],
    })
  }
})

export type CreateTripInput = z.infer<typeof CreateTripSchema>