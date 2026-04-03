import { z } from 'zod'

export const CreateBookingSchema = z.object({
  participant_count: z.number().int().min(1).max(20),
  special_requests: z.string().max(500).optional(),
})

export type CreateBookingInput = z.infer<typeof CreateBookingSchema>
