import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'

export const followUser = async (followerId: string, followingId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('user_follows').insert({ follower_id: followerId, following_id: followingId })
  if (error) throw new AppError(500, 'Failed to follow user')
}
export const unfollowUser = async (followerId: string, followingId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('user_follows').delete().eq('follower_id', followerId).eq('following_id', followingId)
  if (error) throw new AppError(500, 'Failed to unfollow user')
}
export const getFollowers = async (userId: string, limit = 20) => {
  const { data, error } = await supabase.from('user_follows').select('follower_id, profiles:profiles!user_follows_follower_id_fkey(*)').eq('following_id', userId).limit(limit)
  if (error) throw new AppError(500, 'Failed to fetch followers')
  return data ?? []
}
export const getFollowing = async (userId: string, limit = 20) => {
  const { data, error } = await supabase.from('user_follows').select('following_id, profiles:profiles!user_follows_following_id_fkey(*)').eq('follower_id', userId).limit(limit)
  if (error) throw new AppError(500, 'Failed to fetch following')
  return data ?? []
}
export const likeActivity = async (userId: string, activityId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('activity_likes').insert({ user_id: userId, activity_id: activityId })
  if (error) throw new AppError(500, 'Failed to like activity')
}
export const unlikeActivity = async (userId: string, activityId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('activity_likes').delete().eq('user_id', userId).eq('activity_id', activityId)
  if (error) throw new AppError(500, 'Failed to unlike activity')
}
export const commentOnActivity = async (userId: string, activityId: string, content: string) => {
  const { data, error } = await supabaseAdmin.from('activity_comments').insert({ user_id: userId, activity_id: activityId, content }).select('*').single()
  if (error) throw new AppError(500, 'Failed to comment on activity')
  return data
}
export const deleteComment = async (commentId: string, userId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('activity_comments').delete().eq('id', commentId).eq('user_id', userId)
  if (error) throw new AppError(500, 'Failed to delete comment')
}
export const getActivityComments = async (activityId: string, limit = 50) => {
  const { data, error } = await supabase.from('activity_comments').select('*').eq('activity_id', activityId).order('created_at', { ascending: false }).limit(limit)
  if (error) throw new AppError(500, 'Failed to fetch comments')
  return data ?? []
}
export const getFeed = async (userId: string, limit = 20, page = 1) => {
  const { data: followingRows, error: followError } = await supabase.from('user_follows').select('following_id').eq('follower_id', userId)
  if (followError) throw new AppError(500, 'Failed to build feed')
  const ids = (followingRows ?? []).map((r: any) => r.following_id)
  if (ids.length === 0) return []
  const offset = (page - 1) * limit
  const to = offset + limit - 1
  const { data, error } = await supabase.from('activities').select('*').in('user_id', ids).eq('is_public', true).order('start_time', { ascending: false }).range(offset, to)
  if (error) throw new AppError(500, 'Failed to fetch feed')
  return data ?? []
}
