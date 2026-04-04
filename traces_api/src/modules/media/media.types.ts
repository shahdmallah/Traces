export type MediaType = 'photo' | 'video'

export interface MediaUploader {
  id: string
  fullName: string | null
  avatarUrl: string | null
}

export interface MediaRecord {
  id: string
  uploaderId: string
  tripId?: string | null
  destinationId?: string | null
  url: string
  thumbnailUrl?: string | null
  type: MediaType
  caption?: string | null
  latitude?: number | null
  longitude?: number | null
  locationName?: string | null
  isPublic: boolean
  isFeatured: boolean
  tagCount: number
  taggedUsers: string[]
  createdAt: string
}

export interface MediaResponse extends MediaRecord {
  uploader?: MediaUploader
  likeCount: number
  commentCount: number
  distance?: number
}

export interface MediaListResponse {
  items: MediaResponse[]
  page: number
  limit: number
  total: number
}

export interface CreateMediaInput {
  caption?: string
  latitude?: number
  longitude?: number
  locationName?: string
  tripId?: string
  destinationId?: string
  isPublic?: boolean
  taggedUsers?: string[]
}

export interface UpdateMediaInput {
  caption?: string | null
  isPublic?: boolean
  locationName?: string | null
  taggedUsers?: string[]
}

export interface TagMediaInput {
  userId: string
}

export interface UserMediaQuery {
  page: number
  limit: number
  type: MediaType | 'all'
}

export interface NearbyMediaQuery {
  lat: number
  lng: number
  radiusKm: number
}
