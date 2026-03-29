export type SignUpRole = 'traveler' | 'organizer'

export interface SignUpInput {
  email: string
  password: string
  fullName: string
  role: SignUpRole
}

export interface AuthUserResponse {
  id: string
  email: string
  fullName: string
  role: SignUpRole
}
