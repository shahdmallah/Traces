export interface Booking {
  id: string
  trip_id: string
  traveler_id: string
  group_booking_id?: string | null
  participant_count: number
  total_amount: number
  paid_amount: number
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed'
  payment_status: 'unpaid' | 'paid' | 'refunded'
  special_requests?: string | null
  qr_code: string
  checked_in: boolean
  checked_in_at?: string | null
  loyalty_discount_applied: number
  created_at: string
  updated_at: string
}

export interface BookingWithTrip extends Booking {
  trip: {
    id: string
    title: string
    start_date: string
    end_date: string
    cover_image_url?: string | null
    destination?: {
      name: string
      country: string
    } | null
  }
}

export interface BookingWithDetails extends Booking {
  trip: {
    id: string
    title: string
    description?: string | null
    start_date: string
    end_date: string
    cover_image_url?: string | null
    destination?: {
      name: string
      country: string
    } | null
  }
  organizer: {
    full_name: string
    avatar_url?: string | null
    bio?: string | null
  }
  traveler: {
    full_name: string
    email: string
    avatar_url?: string | null
  }
}

export interface CreateBookingInput {
  participant_count: number
  special_requests?: string
}

export interface BookingListResponse {
  data: BookingWithTrip[]
  pagination: {
    page: number
    limit: number
    total: number
    pages: number
  }
}

export interface TripAvailability {
  trip_id: string
  title: string
  max_participants: number
  current_participants: number
  available_spots: number
  is_available: boolean
  start_date: string
}
