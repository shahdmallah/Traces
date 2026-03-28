export type UserRole = 'traveler' | 'organizer' | 'admin'
export type TripStatus = 'draft' | 'active' | 'cancelled' | 'completed'
export type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'completed'
export type PaymentStatus = 'unpaid' | 'partial' | 'paid' | 'refunded'
export type MediaType = 'photo' | 'video' | 'story'

export interface PaginationQuery {
  page?: number
  limit?: number
}

export interface SupabaseListResponse<T> {
  data: T[] | null
  count: number | null
  error: unknown
}
