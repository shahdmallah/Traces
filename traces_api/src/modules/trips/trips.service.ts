import { supabase } from '../../config/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { CreateTripInput } from './trips.validation'

type OrganizerProfileRow = {
  id: string
}

type DestinationRow = {
  id: string
}

type TripRow = {
  id: string
  organizer_id: string
  destination_id: string | null
  title: string
  description: string | null
  start_date: string
  end_date: string
  max_participants: number
  current_participants: number
  price: number | string
  deposit_amount: number | string | null
  status: 'draft' | 'active' | 'cancelled' | 'completed'
  cancellation_policy: 'flexible' | 'moderate' | 'strict'
  instant_booking: boolean
  is_featured: boolean
  is_private: boolean
  is_recurring: boolean
  recurrence_pattern: unknown
  min_age: number | null
  max_age: number | null
  fitness_level: string | null
  required_skills: string[] | null
  itinerary: unknown
  meeting_point: unknown
  included_items: string[] | null
  excluded_items: string[] | null
  meal_plan: string | null
  packing_recommendations: string[] | null
  group_discounts: unknown
  early_bird_discount: unknown
  custom_questions: unknown
  cover_image_url: string | null
  media_urls: unknown
  route_coordinates: unknown
  created_at: string
  updated_at: string
}

const resolveOrganizerProfileId = async (userId: string): Promise<string> => {
  const { data, error } = await supabase
    .from('organizer_profiles')
    .select('id')
    .eq('user_id', userId)
    .maybeSingle()

  if (error) {
    console.error('Organizer profile lookup failed', error)
    throw new AppError(500, 'Failed to resolve organizer profile')
  }

  const row = data as OrganizerProfileRow | null
  if (!row) {
    throw new AppError(404, 'Organizer profile not found')
  }

  return row.id
}

const ensureDestinationExists = async (locationId: string): Promise<void> => {
  const { data, error } = await supabase
    .from('destinations')
    .select('id')
    .eq('id', locationId)
    .maybeSingle()

  if (error) {
    console.error('Destination lookup failed', error)
    throw new AppError(500, 'Failed to validate location_id')
  }

  const row = data as DestinationRow | null
  if (!row) {
    throw new AppError(400, 'Invalid location_id')
  }
}

const isLocationForeignKeyViolation = (error: { code?: string; message?: string | null }): boolean => {
  if (error.code !== '23503') return false

  const message = error.message?.toLowerCase() ?? ''
  return message.includes('destination_id') || message.includes('location_id')
}

const buildCreateTripPayload = (input: CreateTripInput, organizerId: string) => ({
  organizer_id: organizerId,
  destination_id: input.location_id ?? null,
  title: input.title,
  description: input.description ?? null,
  start_date: input.start_date,
  end_date: input.end_date,
  max_participants: input.max_participants,
  price: input.price,
  deposit_amount: input.deposit_amount ?? null,
  status: 'draft' as const,
  cancellation_policy: input.cancellation_policy ?? 'moderate',
  instant_booking: input.instant_booking ?? false,
  is_featured: input.is_featured ?? false,
  is_private: input.is_private ?? false,
  is_recurring: input.is_recurring ?? false,
  recurrence_pattern: input.recurrence_pattern ?? null,
  min_age: input.min_age ?? null,
  max_age: input.max_age ?? null,
  fitness_level: input.fitness_level ?? null,
  required_skills: input.required_skills ?? [],
  itinerary: input.itinerary ?? [],
  meeting_point: input.meeting_point ?? null,
  included_items: input.included_items ?? [],
  excluded_items: input.excluded_items ?? [],
  meal_plan: input.meal_plan ?? null,
  packing_recommendations: input.packing_recommendations ?? [],
  group_discounts: input.group_discounts ?? [],
  early_bird_discount: input.early_bird_discount ?? null,
  custom_questions: input.custom_questions ?? [],
  cover_image_url: input.cover_image_url ?? null,
  media_urls: input.media_urls ?? [],
  route_coordinates: input.route_coordinates ?? [],
})

export const createTrip = async (userId: string, input: CreateTripInput): Promise<TripRow> => {
  const organizerProfileId = await resolveOrganizerProfileId(userId)

  if (input.location_id) {
    await ensureDestinationExists(input.location_id)
  }

  const { data, error } = await supabase
    .from('trips')
    .insert(buildCreateTripPayload(input, organizerProfileId))
    .select('*')
    .single()

  if (error) {
    console.error('Trip creation failed', error)

    if (isLocationForeignKeyViolation(error)) {
      throw new AppError(400, 'Invalid location_id')
    }

    throw new AppError(500, 'Failed to create trip')
  }

  return data as TripRow
}

export const listPublishedTrips = async (): Promise<TripRow[]> => {
  const { data, error } = await supabase
    .from('trips')
    .select('*')
    .in('status', ['active', 'completed'])
    .order('start_date', { ascending: true })

  if (error) {
    console.error('Published trips lookup failed', error)
    throw new AppError(500, 'Failed to fetch trips')
  }

  return (data ?? []) as TripRow[]
}

export const listMyTrips = async (userId: string): Promise<TripRow[]> => {
  const organizerProfileId = await resolveOrganizerProfileId(userId)

  const { data, error } = await supabase
    .from('trips')
    .select('*')
    .eq('organizer_id', organizerProfileId)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Organizer trips lookup failed', error)
    throw new AppError(500, 'Failed to fetch organizer trips')
  }

  return (data ?? []) as TripRow[]
}
