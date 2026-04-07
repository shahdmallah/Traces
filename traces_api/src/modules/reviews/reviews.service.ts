import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'

export type Review = {
  id: string
  trail_id: string
  user_id: string
  rating: number
  title: string | null
  content: string | null
  helpful_count: number
  is_verified_hike: boolean
}

export type ReviewFilters = { page?: number; limit?: number }
export type CreateReviewInput = { rating: number; title?: string; content?: string; is_verified_hike?: boolean }

export const createReview = async (userId: string, trailId: string, data: CreateReviewInput): Promise<Review> => {
  const { data: created, error } = await supabaseAdmin
    .from('trail_reviews')
    .insert({ ...data, trail_id: trailId, user_id: userId })
    .select('*')
    .single()
  if (error) throw new AppError(500, 'Failed to create review')
  return created as Review
}

export const getTrailReviews = async (trailId: string, filters: ReviewFilters) => {
  const page = filters.page ?? 1
  const limit = filters.limit ?? 20
  const offset = (page - 1) * limit
  const to = offset + limit - 1
  const { data, count, error } = await supabase
    .from('trail_reviews')
    .select('*', { count: 'exact' })
    .eq('trail_id', trailId)
    .order('created_at', { ascending: false })
    .range(offset, to)
  if (error) throw new AppError(500, 'Failed to fetch trail reviews')
  const averageRating = (data ?? []).reduce((acc, r: any) => acc + Number(r.rating ?? 0), 0) / Math.max((data ?? []).length, 1)
  return { data: (data ?? []) as Review[], total: count ?? 0, averageRating }
}

export const getUserReviews = async (userId: string): Promise<Review[]> => {
  const { data, error } = await supabase.from('trail_reviews').select('*').eq('user_id', userId).order('created_at', { ascending: false })
  if (error) throw new AppError(500, 'Failed to fetch user reviews')
  return (data ?? []) as Review[]
}

export const updateReview = async (id: string, userId: string, updates: Partial<Review>): Promise<Review> => {
  const { data, error } = await supabaseAdmin.from('trail_reviews').update(updates).eq('id', id).eq('user_id', userId).select('*').single()
  if (error) throw new AppError(500, 'Failed to update review')
  return data as Review
}

export const deleteReview = async (id: string, userId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('trail_reviews').delete().eq('id', id).eq('user_id', userId)
  if (error) throw new AppError(500, 'Failed to delete review')
}

export const markHelpful = async (reviewId: string, _userId: string): Promise<void> => {
  const { data: review, error: findError } = await supabase.from('trail_reviews').select('helpful_count').eq('id', reviewId).maybeSingle()
  if (findError || !review) throw new AppError(404, 'Review not found')
  const { error } = await supabaseAdmin.from('trail_reviews').update({ helpful_count: Number(review.helpful_count ?? 0) + 1 }).eq('id', reviewId)
  if (error) throw new AppError(500, 'Failed to mark review as helpful')
}
