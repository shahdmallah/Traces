import crypto from 'crypto'
import { supabase } from '../../config/supabase'
import { AppError } from '../../shared/middleware/error.middleware'
import { CreateBookingInput, Booking, BookingWithTrip, BookingWithDetails, BookingListResponse, TripAvailability } from './bookings.types'

export const createBooking = async (travelerId: string, tripId: string, input: CreateBookingInput): Promise<Booking> => {
  try {
    console.info('[booking] createBooking start', { travelerId, tripId, participant_count: input.participant_count })

    const { data: trip, error: tripError } = await supabase
      .from('trips')
      .select('id, title, start_date, max_participants, current_participants, price, status, organizer_id')
      .eq('id', tripId)
      .single()

    if (tripError || !trip) {
      console.error('[booking] trip lookup failed', { tripId, tripError })
      throw new AppError(404, 'Trip not found')
    }

    console.info('[booking] trip details', {
      tripId,
      status: trip.status,
      start_date: trip.start_date,
      current_participants: trip.current_participants,
      max_participants: trip.max_participants,
      organizer_id: trip.organizer_id
    })

    if (trip.status !== 'active') {
      throw new AppError(400, 'Trip is not available for booking')
    }

    const now = new Date()
    const tripStart = new Date(trip.start_date)
    if (tripStart <= now) {
      throw new AppError(400, 'Cannot book trips that have already started')
    }

    const { data: traveler, error: travelerError } = await supabase
      .from('users')
      .select('id, is_suspended')
      .eq('id', travelerId)
      .single()

    if (travelerError) {
      console.error('[booking] traveler lookup failed', { travelerId, travelerError })
      throw new AppError(500, 'Traveler lookup failed')
    }

    if (!traveler) {
      throw new AppError(404, 'Traveler not found')
    }

    if (traveler.is_suspended) {
      throw new AppError(403, 'Traveler account is suspended')
    }

    const { data: organizerProfile, error: organizerError } = await supabase
      .from('organizer_profiles')
      .select('user_id')
      .eq('id', trip.organizer_id)
      .single()

    if (organizerError) {
      console.error('[booking] organizer profile lookup failed', { tripId, organizerError })
      throw new AppError(500, 'Failed to verify trip organizer')
    }

    if (organizerProfile?.user_id === travelerId) {
      throw new AppError(403, 'Cannot book your own trip')
    }

    const { data: existingBooking, error: existingBookingError } = await supabase
      .from('bookings')
      .select('id')
      .eq('trip_id', tripId)
      .eq('traveler_id', travelerId)
      .maybeSingle()

    if (existingBookingError) {
      console.error('[booking] existing booking lookup failed', { tripId, travelerId, existingBookingError })
      throw new AppError(500, 'Failed to verify existing booking')
    }

    if (existingBooking) {
      throw new AppError(409, 'You have already booked this trip')
    }

    const availableSpots = trip.max_participants - trip.current_participants
    console.info('[booking] availability', { tripId, availableSpots })

    if (availableSpots < input.participant_count) {
      throw new AppError(400, 'Not enough spots available')
    }

    const totalAmount = trip.price * input.participant_count
    const qrCode = crypto.randomBytes(16).toString('hex')

    const { data: booking, error: bookingError } = await supabase.rpc('create_booking_transaction', {
      p_traveler_id: travelerId,
      p_trip_id: tripId,
      p_participant_count: input.participant_count,
      p_total_amount: totalAmount,
      p_qr_code: qrCode,
      p_special_requests: input.special_requests || null
    })

    if (bookingError) {
      console.error('[booking] create_booking_transaction failed', {
        tripId,
        travelerId,
        input,
        bookingError
      })

      if (bookingError.message && bookingError.message.toLowerCase().includes('not enough spots')) {
        throw new AppError(400, 'Not enough spots available')
      }

      // If this is a unique constraint issue or other known issue, map accordingly
      if (bookingError.code === '23505' || (bookingError.message && bookingError.message.toLowerCase().includes('unique'))) {
        throw new AppError(409, 'You have already booked this trip')
      }

      throw new AppError(500, `Booking creation failed: ${bookingError.message || 'Database error'}`)
    }

    return booking as Booking
  } catch (error) {
    console.error('[booking] createBooking failed', { tripId, travelerId, error })
    if (error instanceof AppError) {
      throw error
    }
    throw new AppError(500, 'Failed to create booking due to internal server error')
  }
}

export const getTravelerBookings = async (travelerId: string, page: number = 1, limit: number = 10): Promise<BookingListResponse> => {
  const offset = (page - 1) * limit

  const { data: bookings, error, count } = await supabase
    .from('bookings')
    .select(`
      *,
      trip:trips(id, title, start_date, end_date, cover_image_url, destination:destinations(name, country))
    `, { count: 'exact' })
    .eq('traveler_id', travelerId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  if (error) {
    console.error('Get traveler bookings failed', error)
    throw new AppError(500, 'Failed to fetch bookings')
  }

  const total = count || 0
  const pages = Math.ceil(total / limit)

  return {
    data: (bookings || []) as BookingWithTrip[],
    pagination: { page, limit, total, pages }
  }
}

export const getBookingById = async (bookingId: string, userId: string, userRole: string): Promise<BookingWithDetails | null> => {
  const { data: booking, error } = await supabase
    .from('bookings')
    .select(`
      *,
      trip:trips(id, title, description, start_date, end_date, cover_image_url, destination:destinations(name, country), organizer_id),
      traveler:users!traveler_id(id, full_name, email, avatar_url)
    `)
    .eq('id', bookingId)
    .single()

  if (error || !booking) {
    return null
  }

  // Check permissions
  const isTraveler = booking.traveler_id === userId
  const isOrganizer = booking.trip.organizer_id === userId // Note: organizer_id is profile id, need to check user_id
  const isAdmin = userRole === 'admin'

  if (!isTraveler && !isOrganizer && !isAdmin) {
    throw new AppError(403, 'Forbidden')
  }

  // Get organizer info
  const { data: organizerProfile } = await supabase
    .from('organizer_profiles')
    .select('user_id, bio')
    .eq('id', booking.trip.organizer_id)
    .single()

  let organizer = null
  if (organizerProfile) {
    const { data: organizerUser } = await supabase
      .from('users')
      .select('full_name, avatar_url')
      .eq('id', organizerProfile.user_id)
      .single()

    organizer = {
      full_name: organizerUser?.full_name || '',
      avatar_url: organizerUser?.avatar_url || null,
      bio: organizerProfile.bio || null
    }
  }

  return {
    ...booking,
    organizer
  } as BookingWithDetails
}

export const getOrganizerBookings = async (organizerUserId: string, tripId?: string, page: number = 1, limit: number = 10): Promise<BookingListResponse> => {
  // Get organizer profile id
  const { data: profile } = await supabase
    .from('organizer_profiles')
    .select('id')
    .eq('user_id', organizerUserId)
    .single()

  if (!profile) {
    throw new AppError(404, 'Organizer profile not found')
  }

  let query = supabase
    .from('bookings')
    .select(`
      *,
      trip:trips!inner(id, title, start_date, end_date, organizer_id),
      traveler:users!traveler_id(id, full_name, email, avatar_url)
    `, { count: 'exact' })
    .eq('trip.organizer_id', profile.id)
    .order('created_at', { ascending: false })

  if (tripId) {
    query = query.eq('trip.id', tripId)
  }

  const offset = (page - 1) * limit
  const { data: bookings, error, count } = await query.range(offset, offset + limit - 1)

  if (error) {
    console.error('Get organizer bookings failed', error)
    throw new AppError(500, 'Failed to fetch bookings')
  }

  const total = count || 0
  const pages = Math.ceil(total / limit)

  return {
    data: (bookings || []) as BookingWithTrip[],
    pagination: { page, limit, total, pages }
  }
}

export const cancelBooking = async (bookingId: string, userId: string, userRole: string): Promise<Booking> => {
  const { data: booking, error: fetchError } = await supabase
    .from('bookings')
    .select('*, trip:trips(organizer_id, start_date)')
    .eq('id', bookingId)
    .single()

  if (fetchError || !booking) {
    throw new AppError(404, 'Booking not found')
  }

  // Check permissions
  const isTraveler = booking.traveler_id === userId
  const isOrganizer = booking.trip.organizer_id === userId // Again, need to check properly
  const isAdmin = userRole === 'admin'

  if (!isTraveler && !isOrganizer && !isAdmin) {
    throw new AppError(403, 'Forbidden')
  }

  if (booking.status === 'cancelled' || booking.status === 'completed') {
    throw new AppError(400, 'Cannot cancel this booking')
  }

  const tripStart = new Date(booking.trip.start_date)
  if (tripStart <= new Date()) {
    throw new AppError(400, 'Cannot cancel bookings for trips that have started')
  }

  const { data: updatedBooking, error: updateError } = await supabase
    .from('bookings')
    .update({
      status: 'cancelled',
      payment_status: booking.payment_status === 'paid' ? 'refunded' : booking.payment_status,
      updated_at: new Date().toISOString()
    })
    .eq('id', bookingId)
    .select('*')
    .single()

  if (updateError) {
    console.error('Cancel booking failed', updateError)
    throw new AppError(500, 'Failed to cancel booking')
  }

  // Decrement participants
  await supabase.rpc('decrement_trip_participants', {
    p_trip_id: booking.trip_id,
    p_count: booking.participant_count
  })

  return updatedBooking as Booking
}

export const confirmBooking = async (bookingId: string, organizerUserId: string): Promise<Booking> => {
  // Get organizer profile
  const { data: profile } = await supabase
    .from('organizer_profiles')
    .select('id')
    .eq('user_id', organizerUserId)
    .single()

  if (!profile) {
    throw new AppError(404, 'Organizer profile not found')
  }

  const { data: booking, error: fetchError } = await supabase
    .from('bookings')
    .select('*, trip:trips(organizer_id)')
    .eq('id', bookingId)
    .single()

  if (fetchError || !booking) {
    throw new AppError(404, 'Booking not found')
  }

  if (booking.trip.organizer_id !== profile.id) {
    throw new AppError(403, 'Forbidden')
  }

  if (booking.status !== 'pending') {
    throw new AppError(400, 'Can only confirm pending bookings')
  }

  const { data: updatedBooking, error: updateError } = await supabase
    .from('bookings')
    .update({
      status: 'confirmed',
      updated_at: new Date().toISOString()
    })
    .eq('id', bookingId)
    .select('*')
    .single()

  if (updateError) {
    console.error('Confirm booking failed', updateError)
    throw new AppError(500, 'Failed to confirm booking')
  }

  return updatedBooking as Booking
}

export const getTripAvailability = async (tripId: string): Promise<TripAvailability> => {
  const { data: trip, error } = await supabase
    .from('trips')
    .select('id, title, max_participants, current_participants, start_date')
    .eq('id', tripId)
    .single()

  if (error || !trip) {
    throw new AppError(404, 'Trip not found')
  }

  const availableSpots = trip.max_participants - trip.current_participants
  const isAvailable = availableSpots > 0

  return {
    trip_id: trip.id,
    title: trip.title,
    max_participants: trip.max_participants,
    current_participants: trip.current_participants,
    available_spots: availableSpots,
    is_available: isAvailable,
    start_date: trip.start_date
  }
}
