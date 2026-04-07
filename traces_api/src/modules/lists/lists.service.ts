import { supabase, supabaseAdmin } from '../../lib/supabase'
import { AppError } from '../../shared/middleware/error.middleware'

export type List = { id: string; user_id: string; name: string; description: string | null; is_private: boolean }
export type CreateListInput = { name: string; description?: string; is_private?: boolean }

export const createList = async (userId: string, data: CreateListInput): Promise<List> => {
  const { data: created, error } = await supabaseAdmin.from('saved_lists').insert({ ...data, user_id: userId }).select('*').single()
  if (error) throw new AppError(500, 'Failed to create list')
  return created as List
}
export const getUserLists = async (userId: string): Promise<List[]> => {
  const { data, error } = await supabase.from('saved_lists').select('*').eq('user_id', userId)
  if (error) throw new AppError(500, 'Failed to fetch lists')
  return (data ?? []) as List[]
}
export const getListById = async (listId: string, userId: string): Promise<List> => {
  const { data, error } = await supabase.from('saved_lists').select('*').eq('id', listId).eq('user_id', userId).maybeSingle()
  if (error) throw new AppError(500, 'Failed to fetch list')
  if (!data) throw new AppError(404, 'List not found')
  return data as List
}
export const addTrailToList = async (listId: string, trailId: string, userId: string): Promise<void> => {
  await getListById(listId, userId)
  const { error } = await supabaseAdmin.from('list_items').insert({ list_id: listId, trail_id: trailId })
  if (error) throw new AppError(500, 'Failed to add trail to list')
}
export const removeTrailFromList = async (listId: string, trailId: string, userId: string): Promise<void> => {
  await getListById(listId, userId)
  const { error } = await supabaseAdmin.from('list_items').delete().eq('list_id', listId).eq('trail_id', trailId)
  if (error) throw new AppError(500, 'Failed to remove trail from list')
}
export const updateList = async (listId: string, userId: string, updates: Partial<List>): Promise<List> => {
  const { data, error } = await supabaseAdmin.from('saved_lists').update(updates).eq('id', listId).eq('user_id', userId).select('*').single()
  if (error) throw new AppError(500, 'Failed to update list')
  return data as List
}
export const deleteList = async (listId: string, userId: string): Promise<void> => {
  const { error } = await supabaseAdmin.from('saved_lists').delete().eq('id', listId).eq('user_id', userId)
  if (error) throw new AppError(500, 'Failed to delete list')
}
