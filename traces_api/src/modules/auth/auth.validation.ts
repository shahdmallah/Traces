import { z } from 'zod'

export const SignUpSchema = z.object({
  email: z
    .string()
    .trim()
    .email('A valid email is required'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters'),
  fullName: z
    .string()
    .trim()
    .min(2, 'Full name must be at least 2 characters')
    .max(120, 'Full name is too long'),
  role: z
    .enum(['traveler', 'organizer'])
    .default('traveler'),
})
