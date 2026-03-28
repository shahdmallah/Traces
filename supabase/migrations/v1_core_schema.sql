
create extension if not exists "uuid-ossp";
create extension if not exists "postgis"; 



create type user_role as enum ('traveler', 'organizer', 'admin');
create type verification_status as enum ('none', 'pending', 'approved', 'rejected');
create type organizer_tier as enum ('new', 'established', 'premier', 'elite');
create type loyalty_tier as enum ('bronze', 'silver', 'gold', 'platinum');
create type trip_status as enum ('draft', 'active', 'cancelled', 'completed');
create type cancellation_policy as enum ('flexible', 'moderate', 'strict');
create type booking_status as enum ('pending', 'confirmed', 'cancelled', 'completed');
create type payment_status as enum ('unpaid', 'partial', 'paid', 'refunded');
create type media_type as enum ('photo', 'video', 'story');
create type badge_entity_type as enum ('traveler', 'organizer');
create type message_type as enum ('direct', 'group', 'broadcast');

-- ============================================================
-- USERS
-- ============================================================

create table users (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  password_hash text,                          -- null if using OAuth
  role user_role not null default 'traveler',
  full_name text not null,
  avatar_url text,
  phone text,
  is_verified boolean not null default false,
  verification_status verification_status not null default 'none',
  verification_documents jsonb,                -- { id_url, license_url, insurance_url }
  emergency_contact jsonb,                     -- { name, phone, relationship }
  notification_preferences jsonb default '{}',
  privacy_settings jsonb default '{}',
  social_links jsonb default '{}',
  is_suspended boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table users is 'Core user accounts for all roles (traveler, organizer, admin)';

-- ============================================================
-- ORGANIZER PROFILES
-- ============================================================

create table organizer_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique references users(id) on delete cascade,
  bio text,
  specialties text[] default '{}',
  languages text[] default '{}',
  bank_account_details jsonb,                  -- encrypted in practice
  response_rate numeric(5,2) default 0,
  acceptance_rate numeric(5,2) default 0,
  cancellation_rate numeric(5,2) default 0,
  tier organizer_tier not null default 'new',
  commission_rate numeric(5,2) not null default 10.00,
  is_featured boolean not null default false,
  featured_tier int,                           -- 1, 2, 3 for homepage placement
  portfolio_media jsonb default '[]',          -- array of { url, caption, type }
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table organizer_profiles is 'Extended profile for users with organizer role';

-- ============================================================
-- TRAVELER PROFILES
-- ============================================================

create table traveler_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique references users(id) on delete cascade,
  travel_preferences jsonb default '{}',       -- { moods, budgets, activity_types }
  travel_styles text[] default '{}',           -- solo, group, adventure, relaxation, cultural
  loyalty_tier loyalty_tier not null default 'bronze',
  trips_completed int not null default 0,
  total_spent numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table traveler_profiles is 'Extended profile for users with traveler role';

-- ============================================================
-- DESTINATIONS
-- ============================================================

create table destinations (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  country text not null,
  region text,
  description text,
  cover_image_url text,
  latitude numeric(10,7),
  longitude numeric(10,7),
  is_featured boolean not null default false,
  popular_spots jsonb default '[]',            -- array of { name, lat, lng, tag_count }
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table destinations is 'Places that trips are linked to and that accumulate media memories';

-- ============================================================
-- TRIPS
-- ============================================================

create table trips (
  id uuid primary key default uuid_generate_v4(),
  organizer_id uuid not null references organizer_profiles(id) on delete cascade,
  destination_id uuid references destinations(id) on delete set null,
  title text not null,
  description text,
  start_date timestamptz not null,
  end_date timestamptz not null,
  max_participants int not null,
  current_participants int not null default 0,
  price numeric(10,2) not null,
  deposit_amount numeric(10,2),                -- null = full payment required
  status trip_status not null default 'draft',
  cancellation_policy cancellation_policy not null default 'moderate',
  instant_booking boolean not null default false,
  is_featured boolean not null default false,
  is_private boolean not null default false,
  is_recurring boolean not null default false,
  recurrence_pattern jsonb,                    -- { frequency: 'weekly'|'monthly', end_date }
  min_age int,
  max_age int,
  fitness_level text,
  required_skills text[],
  itinerary jsonb default '[]',                -- array of { day, time, activity, location, notes }
  meeting_point jsonb,                         -- { address, lat, lng, notes }
  included_items text[] default '{}',
  excluded_items text[] default '{}',
  meal_plan text,
  packing_recommendations text[],
  group_discounts jsonb default '[]',          -- array of { min_people, discount_percent }
  early_bird_discount jsonb,                   -- { deadline, discount_percent }
  custom_questions jsonb default '[]',         -- array of { question, required }
  cover_image_url text,
  media_urls jsonb default '[]',
  route_coordinates jsonb default '[]',        -- array of { lat, lng } for map path
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table trips is 'Trips created and managed by organizers';

-- ============================================================
-- GROUP BOOKINGS
-- ============================================================

create table group_bookings (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  leader_id uuid not null references users(id),
  total_participants int not null,
  total_amount numeric(12,2) not null,
  paid_amount numeric(12,2) not null default 0,
  payment_status payment_status not null default 'unpaid',
  invite_token text unique default encode(gen_random_bytes(16), 'hex'),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table group_bookings is 'Coordinator record for group trips — individual bookings reference this';

-- ============================================================
-- BOOKINGS
-- ============================================================

create table bookings (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  traveler_id uuid not null references users(id),
  group_booking_id uuid references group_bookings(id) on delete set null,
  participant_count int not null default 1,
  total_amount numeric(10,2) not null,
  paid_amount numeric(10,2) not null default 0,
  status booking_status not null default 'pending',
  payment_status payment_status not null default 'unpaid',
  special_requests jsonb default '{}',         -- { dietary, accessibility, custom_answers }
  qr_code text unique default encode(gen_random_bytes(16), 'hex'),
  checked_in boolean not null default false,
  checked_in_at timestamptz,
  loyalty_discount_applied numeric(5,2) default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(trip_id, traveler_id)
);

comment on table bookings is 'Individual trip reservations — linked to a group booking if applicable';

-- ============================================================
-- MEDIA (the memory archive)
-- ============================================================

create table media (
  id uuid primary key default uuid_generate_v4(),
  uploader_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete set null,
  destination_id uuid references destinations(id) on delete set null,
  url text not null,
  thumbnail_url text,
  type media_type not null default 'photo',
  caption text,
  latitude numeric(10,7),
  longitude numeric(10,7),
  location_name text,
  is_public boolean not null default true,
  is_featured boolean not null default false,
  tag_count int not null default 0,
  tagged_users uuid[] default '{}',
  created_at timestamptz not null default now()
);

comment on table media is 'All user-uploaded photos, videos, stories — the living memory layer';

create index idx_media_destination on media(destination_id) where is_public = true;
create index idx_media_location on media(latitude, longitude) where latitude is not null;
create index idx_media_trip on media(trip_id);

-- ============================================================
-- REVIEWS
-- ============================================================

create table reviews (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  reviewer_id uuid not null references users(id),
  booking_id uuid references bookings(id),
  overall_rating int not null check (overall_rating between 1 and 5),
  category_ratings jsonb default '{}',         -- { organization, value, safety, communication }
  comment text,
  private_feedback text,                       -- visible to organizer only
  is_public boolean not null default true,
  organizer_reply text,
  organizer_replied_at timestamptz,
  is_flagged boolean not null default false,
  created_at timestamptz not null default now(),
  unique(trip_id, reviewer_id)
);

comment on table reviews is 'Post-trip ratings and comments from travelers';

-- ============================================================
-- MESSAGES
-- ============================================================

create table messages (
  id uuid primary key default uuid_generate_v4(),
  sender_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  group_booking_id uuid references group_bookings(id) on delete cascade,
  recipient_id uuid references users(id),      -- null = group message
  type message_type not null default 'direct',
  content text not null,
  is_read boolean not null default false,
  sent_at timestamptz not null default now()
);

comment on table messages is 'In-app messaging — direct, trip group, and broadcast';

create index idx_messages_trip on messages(trip_id);
create index idx_messages_recipient on messages(recipient_id) where recipient_id is not null;

-- ============================================================
-- BADGES
-- ============================================================

create table badges (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  badge_type text not null,
  entity_type badge_entity_type not null,
  is_displayed boolean not null default true,
  earned_at timestamptz not null default now(),
  unique(user_id, badge_type)
);

comment on table badges is 'Achievement badges earned by travelers and organizers';

-- ============================================================
-- TRAVELER TRIBES (communities)
-- ============================================================

create table tribes (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  description text,
  cover_image_url text,
  member_count int not null default 0,
  is_featured boolean not null default false,
  created_at timestamptz not null default now()
);

create table tribe_memberships (
  id uuid primary key default uuid_generate_v4(),
  tribe_id uuid not null references tribes(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  is_leader boolean not null default false,
  joined_at timestamptz not null default now(),
  unique(tribe_id, user_id)
);

comment on table tribes is 'Interest-based traveler communities (Solo Female Travelers, Foodies, etc.)';

-- ============================================================
-- POST-TRIP TRIVIA
-- ============================================================

create table trivia_quizzes (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  organizer_id uuid not null references organizer_profiles(id),
  title text not null,
  is_public boolean not null default false,
  join_code text unique default upper(substring(encode(gen_random_bytes(4), 'hex'), 1, 6)),
  reward_type text,                            -- 'discount_code' | 'badge' | null
  reward_value text,
  questions jsonb not null default '[]',       -- array of { question, options, answer, image_url, timer_seconds }
  created_at timestamptz not null default now()
);

create table trivia_results (
  id uuid primary key default uuid_generate_v4(),
  quiz_id uuid not null references trivia_quizzes(id) on delete cascade,
  user_id uuid not null references users(id),
  score int not null default 0,
  rank int,
  completed_at timestamptz not null default now(),
  unique(quiz_id, user_id)
);

-- ============================================================
-- WISHLISTS
-- ============================================================

create table wishlists (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  destination_id uuid references destinations(id) on delete cascade,
  created_at timestamptz not null default now(),
  check (
    (trip_id is not null and destination_id is null) or
    (trip_id is null and destination_id is not null)
  )
);

-- ============================================================
-- UPDATED_AT TRIGGER (auto-update on all tables that have it)
-- ============================================================

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_users_updated_at
  before update on users
  for each row execute function set_updated_at();

create trigger trg_organizer_profiles_updated_at
  before update on organizer_profiles
  for each row execute function set_updated_at();

create trigger trg_traveler_profiles_updated_at
  before update on traveler_profiles
  for each row execute function set_updated_at();

create trigger trg_trips_updated_at
  before update on trips
  for each row execute function set_updated_at();

create trigger trg_bookings_updated_at
  before update on bookings
  for each row execute function set_updated_at();

create trigger trg_group_bookings_updated_at
  before update on group_bookings
  for each row execute function set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS on all tables
alter table users enable row level security;
alter table organizer_profiles enable row level security;
alter table traveler_profiles enable row level security;
alter table destinations enable row level security;
alter table trips enable row level security;
alter table bookings enable row level security;
alter table group_bookings enable row level security;
alter table media enable row level security;
alter table reviews enable row level security;
alter table messages enable row level security;
alter table badges enable row level security;
alter table tribes enable row level security;
alter table tribe_memberships enable row level security;
alter table trivia_quizzes enable row level security;
alter table trivia_results enable row level security;
alter table wishlists enable row level security;

-- USERS: users can read public profiles, only edit their own
create policy "users: read own row" on users
  for select using (auth.uid() = id);

create policy "users: update own row" on users
  for update using (auth.uid() = id);

-- ORGANIZER PROFILES: public read, own write
create policy "organizer_profiles: public read" on organizer_profiles
  for select using (true);

create policy "organizer_profiles: own write" on organizer_profiles
  for all using (auth.uid() = user_id);

-- TRAVELER PROFILES: own read/write only
create policy "traveler_profiles: own access" on traveler_profiles
  for all using (auth.uid() = user_id);

-- DESTINATIONS: public read, admin write
create policy "destinations: public read" on destinations
  for select using (true);

-- TRIPS: public read for active trips, organizer full access
create policy "trips: public read active" on trips
  for select using (status = 'active' or status = 'completed');

create policy "trips: organizer full access" on trips
  for all using (
    exists (
      select 1 from organizer_profiles op
      where op.id = trips.organizer_id and op.user_id = auth.uid()
    )
  );

-- BOOKINGS: traveler sees own, organizer sees for their trips
create policy "bookings: traveler own" on bookings
  for select using (auth.uid() = traveler_id);

create policy "bookings: organizer sees trip bookings" on bookings
  for select using (
    exists (
      select 1 from trips t
      join organizer_profiles op on op.id = t.organizer_id
      where t.id = bookings.trip_id and op.user_id = auth.uid()
    )
  );

create policy "bookings: traveler insert" on bookings
  for insert with check (auth.uid() = traveler_id);

-- MEDIA: public media visible to all, private only to uploader
create policy "media: public read" on media
  for select using (is_public = true);

create policy "media: private read own" on media
  for select using (auth.uid() = uploader_id);

create policy "media: own write" on media
  for all using (auth.uid() = uploader_id);

-- REVIEWS: public reviews visible, own full access
create policy "reviews: public read" on reviews
  for select using (is_public = true);

create policy "reviews: own write" on reviews
  for all using (auth.uid() = reviewer_id);

-- MESSAGES: participants only
create policy "messages: read own" on messages
  for select using (
    auth.uid() = sender_id or
    auth.uid() = recipient_id or
    exists (
      select 1 from bookings b
      where b.trip_id = messages.trip_id and b.traveler_id = auth.uid()
    )
  );

create policy "messages: send own" on messages
  for insert with check (auth.uid() = sender_id);

-- BADGES: public read, system write (use service role for inserts)
create policy "badges: public read" on badges
  for select using (true);

-- TRIBES: public read, own membership
create policy "tribes: public read" on tribes
  for select using (true);

create policy "tribe_memberships: own access" on tribe_memberships
  for all using (auth.uid() = user_id);

-- WISHLISTS: own access only
create policy "wishlists: own access" on wishlists
  for all using (auth.uid() = user_id);

-- TRIVIA: public quizzes readable by all, own results
create policy "trivia_quizzes: read public" on trivia_quizzes
  for select using (is_public = true);

create policy "trivia_results: own access" on trivia_results
  for all using (auth.uid() = user_id);

create extension if not exists "uuid-ossp";
create extension if not exists "postgis"; 



create type user_role as enum ('traveler', 'organizer', 'admin');
create type verification_status as enum ('none', 'pending', 'approved', 'rejected');
create type organizer_tier as enum ('new', 'established', 'premier', 'elite');
create type loyalty_tier as enum ('bronze', 'silver', 'gold', 'platinum');
create type trip_status as enum ('draft', 'active', 'cancelled', 'completed');
create type cancellation_policy as enum ('flexible', 'moderate', 'strict');
create type booking_status as enum ('pending', 'confirmed', 'cancelled', 'completed');
create type payment_status as enum ('unpaid', 'partial', 'paid', 'refunded');
create type media_type as enum ('photo', 'video', 'story');
create type badge_entity_type as enum ('traveler', 'organizer');
create type message_type as enum ('direct', 'group', 'broadcast');

-- ============================================================
-- USERS
-- ============================================================

create table users (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  password_hash text,                          -- null if using OAuth
  role user_role not null default 'traveler',
  full_name text not null,
  avatar_url text,
  phone text,
  is_verified boolean not null default false,
  verification_status verification_status not null default 'none',
  verification_documents jsonb,                -- { id_url, license_url, insurance_url }
  emergency_contact jsonb,                     -- { name, phone, relationship }
  notification_preferences jsonb default '{}',
  privacy_settings jsonb default '{}',
  social_links jsonb default '{}',
  is_suspended boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table users is 'Core user accounts for all roles (traveler, organizer, admin)';

-- ============================================================
-- ORGANIZER PROFILES
-- ============================================================

create table organizer_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique references users(id) on delete cascade,
  bio text,
  specialties text[] default '{}',
  languages text[] default '{}',
  bank_account_details jsonb,                  -- encrypted in practice
  response_rate numeric(5,2) default 0,
  acceptance_rate numeric(5,2) default 0,
  cancellation_rate numeric(5,2) default 0,
  tier organizer_tier not null default 'new',
  commission_rate numeric(5,2) not null default 10.00,
  is_featured boolean not null default false,
  featured_tier int,                           -- 1, 2, 3 for homepage placement
  portfolio_media jsonb default '[]',          -- array of { url, caption, type }
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table organizer_profiles is 'Extended profile for users with organizer role';

-- ============================================================
-- TRAVELER PROFILES
-- ============================================================

create table traveler_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique references users(id) on delete cascade,
  travel_preferences jsonb default '{}',       -- { moods, budgets, activity_types }
  travel_styles text[] default '{}',           -- solo, group, adventure, relaxation, cultural
  loyalty_tier loyalty_tier not null default 'bronze',
  trips_completed int not null default 0,
  total_spent numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table traveler_profiles is 'Extended profile for users with traveler role';

-- ============================================================
-- DESTINATIONS
-- ============================================================

create table destinations (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  country text not null,
  region text,
  description text,
  cover_image_url text,
  latitude numeric(10,7),
  longitude numeric(10,7),
  is_featured boolean not null default false,
  popular_spots jsonb default '[]',            -- array of { name, lat, lng, tag_count }
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table destinations is 'Places that trips are linked to and that accumulate media memories';

-- ============================================================
-- TRIPS
-- ============================================================

create table trips (
  id uuid primary key default uuid_generate_v4(),
  organizer_id uuid not null references organizer_profiles(id) on delete cascade,
  destination_id uuid references destinations(id) on delete set null,
  title text not null,
  description text,
  start_date timestamptz not null,
  end_date timestamptz not null,
  max_participants int not null,
  current_participants int not null default 0,
  price numeric(10,2) not null,
  deposit_amount numeric(10,2),                -- null = full payment required
  status trip_status not null default 'draft',
  cancellation_policy cancellation_policy not null default 'moderate',
  instant_booking boolean not null default false,
  is_featured boolean not null default false,
  is_private boolean not null default false,
  is_recurring boolean not null default false,
  recurrence_pattern jsonb,                    -- { frequency: 'weekly'|'monthly', end_date }
  min_age int,
  max_age int,
  fitness_level text,
  required_skills text[],
  itinerary jsonb default '[]',                -- array of { day, time, activity, location, notes }
  meeting_point jsonb,                         -- { address, lat, lng, notes }
  included_items text[] default '{}',
  excluded_items text[] default '{}',
  meal_plan text,
  packing_recommendations text[],
  group_discounts jsonb default '[]',          -- array of { min_people, discount_percent }
  early_bird_discount jsonb,                   -- { deadline, discount_percent }
  custom_questions jsonb default '[]',         -- array of { question, required }
  cover_image_url text,
  media_urls jsonb default '[]',
  route_coordinates jsonb default '[]',        -- array of { lat, lng } for map path
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table trips is 'Trips created and managed by organizers';

-- ============================================================
-- GROUP BOOKINGS
-- ============================================================

create table group_bookings (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  leader_id uuid not null references users(id),
  total_participants int not null,
  total_amount numeric(12,2) not null,
  paid_amount numeric(12,2) not null default 0,
  payment_status payment_status not null default 'unpaid',
  invite_token text unique default encode(gen_random_bytes(16), 'hex'),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table group_bookings is 'Coordinator record for group trips — individual bookings reference this';

-- ============================================================
-- BOOKINGS
-- ============================================================

create table bookings (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  traveler_id uuid not null references users(id),
  group_booking_id uuid references group_bookings(id) on delete set null,
  participant_count int not null default 1,
  total_amount numeric(10,2) not null,
  paid_amount numeric(10,2) not null default 0,
  status booking_status not null default 'pending',
  payment_status payment_status not null default 'unpaid',
  special_requests jsonb default '{}',         -- { dietary, accessibility, custom_answers }
  qr_code text unique default encode(gen_random_bytes(16), 'hex'),
  checked_in boolean not null default false,
  checked_in_at timestamptz,
  loyalty_discount_applied numeric(5,2) default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(trip_id, traveler_id)
);

comment on table bookings is 'Individual trip reservations — linked to a group booking if applicable';

-- ============================================================
-- MEDIA (the memory archive)
-- ============================================================

create table media (
  id uuid primary key default uuid_generate_v4(),
  uploader_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete set null,
  destination_id uuid references destinations(id) on delete set null,
  url text not null,
  thumbnail_url text,
  type media_type not null default 'photo',
  caption text,
  latitude numeric(10,7),
  longitude numeric(10,7),
  location_name text,
  is_public boolean not null default true,
  is_featured boolean not null default false,
  tag_count int not null default 0,
  tagged_users uuid[] default '{}',
  created_at timestamptz not null default now()
);

comment on table media is 'All user-uploaded photos, videos, stories — the living memory layer';

create index idx_media_destination on media(destination_id) where is_public = true;
create index idx_media_location on media(latitude, longitude) where latitude is not null;
create index idx_media_trip on media(trip_id);

-- ============================================================
-- REVIEWS
-- ============================================================

create table reviews (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  reviewer_id uuid not null references users(id),
  booking_id uuid references bookings(id),
  overall_rating int not null check (overall_rating between 1 and 5),
  category_ratings jsonb default '{}',         -- { organization, value, safety, communication }
  comment text,
  private_feedback text,                       -- visible to organizer only
  is_public boolean not null default true,
  organizer_reply text,
  organizer_replied_at timestamptz,
  is_flagged boolean not null default false,
  created_at timestamptz not null default now(),
  unique(trip_id, reviewer_id)
);

comment on table reviews is 'Post-trip ratings and comments from travelers';

-- ============================================================
-- MESSAGES
-- ============================================================

create table messages (
  id uuid primary key default uuid_generate_v4(),
  sender_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  group_booking_id uuid references group_bookings(id) on delete cascade,
  recipient_id uuid references users(id),      -- null = group message
  type message_type not null default 'direct',
  content text not null,
  is_read boolean not null default false,
  sent_at timestamptz not null default now()
);

comment on table messages is 'In-app messaging — direct, trip group, and broadcast';

create index idx_messages_trip on messages(trip_id);
create index idx_messages_recipient on messages(recipient_id) where recipient_id is not null;

-- ============================================================
-- BADGES
-- ============================================================

create table badges (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  badge_type text not null,
  entity_type badge_entity_type not null,
  is_displayed boolean not null default true,
  earned_at timestamptz not null default now(),
  unique(user_id, badge_type)
);

comment on table badges is 'Achievement badges earned by travelers and organizers';

-- ============================================================
-- TRAVELER TRIBES (communities)
-- ============================================================

create table tribes (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  description text,
  cover_image_url text,
  member_count int not null default 0,
  is_featured boolean not null default false,
  created_at timestamptz not null default now()
);

create table tribe_memberships (
  id uuid primary key default uuid_generate_v4(),
  tribe_id uuid not null references tribes(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  is_leader boolean not null default false,
  joined_at timestamptz not null default now(),
  unique(tribe_id, user_id)
);

comment on table tribes is 'Interest-based traveler communities (Solo Female Travelers, Foodies, etc.)';

-- ============================================================
-- POST-TRIP TRIVIA
-- ============================================================

create table trivia_quizzes (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  organizer_id uuid not null references organizer_profiles(id),
  title text not null,
  is_public boolean not null default false,
  join_code text unique default upper(substring(encode(gen_random_bytes(4), 'hex'), 1, 6)),
  reward_type text,                            -- 'discount_code' | 'badge' | null
  reward_value text,
  questions jsonb not null default '[]',       -- array of { question, options, answer, image_url, timer_seconds }
  created_at timestamptz not null default now()
);

create table trivia_results (
  id uuid primary key default uuid_generate_v4(),
  quiz_id uuid not null references trivia_quizzes(id) on delete cascade,
  user_id uuid not null references users(id),
  score int not null default 0,
  rank int,
  completed_at timestamptz not null default now(),
  unique(quiz_id, user_id)
);

-- ============================================================
-- WISHLISTS
-- ============================================================

create table wishlists (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  destination_id uuid references destinations(id) on delete cascade,
  created_at timestamptz not null default now(),
  check (
    (trip_id is not null and destination_id is null) or
    (trip_id is null and destination_id is not null)
  )
);

-- ============================================================
-- UPDATED_AT TRIGGER (auto-update on all tables that have it)
-- ============================================================

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_users_updated_at
  before update on users
  for each row execute function set_updated_at();

create trigger trg_organizer_profiles_updated_at
  before update on organizer_profiles
  for each row execute function set_updated_at();

create trigger trg_traveler_profiles_updated_at
  before update on traveler_profiles
  for each row execute function set_updated_at();

create trigger trg_trips_updated_at
  before update on trips
  for each row execute function set_updated_at();

create trigger trg_bookings_updated_at
  before update on bookings
  for each row execute function set_updated_at();

create trigger trg_group_bookings_updated_at
  before update on group_bookings
  for each row execute function set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS on all tables
alter table users enable row level security;
alter table organizer_profiles enable row level security;
alter table traveler_profiles enable row level security;
alter table destinations enable row level security;
alter table trips enable row level security;
alter table bookings enable row level security;
alter table group_bookings enable row level security;
alter table media enable row level security;
alter table reviews enable row level security;
alter table messages enable row level security;
alter table badges enable row level security;
alter table tribes enable row level security;
alter table tribe_memberships enable row level security;
alter table trivia_quizzes enable row level security;
alter table trivia_results enable row level security;
alter table wishlists enable row level security;

-- USERS: users can read public profiles, only edit their own
create policy "users: read own row" on users
  for select using (auth.uid() = id);

create policy "users: update own row" on users
  for update using (auth.uid() = id);

-- ORGANIZER PROFILES: public read, own write
create policy "organizer_profiles: public read" on organizer_profiles
  for select using (true);

create policy "organizer_profiles: own write" on organizer_profiles
  for all using (auth.uid() = user_id);

-- TRAVELER PROFILES: own read/write only
create policy "traveler_profiles: own access" on traveler_profiles
  for all using (auth.uid() = user_id);

-- DESTINATIONS: public read, admin write
create policy "destinations: public read" on destinations
  for select using (true);

-- TRIPS: public read for active trips, organizer full access
create policy "trips: public read active" on trips
  for select using (status = 'active' or status = 'completed');

create policy "trips: organizer full access" on trips
  for all using (
    exists (
      select 1 from organizer_profiles op
      where op.id = trips.organizer_id and op.user_id = auth.uid()
    )
  );

-- BOOKINGS: traveler sees own, organizer sees for their trips
create policy "bookings: traveler own" on bookings
  for select using (auth.uid() = traveler_id);

create policy "bookings: organizer sees trip bookings" on bookings
  for select using (
    exists (
      select 1 from trips t
      join organizer_profiles op on op.id = t.organizer_id
      where t.id = bookings.trip_id and op.user_id = auth.uid()
    )
  );

create policy "bookings: traveler insert" on bookings
  for insert with check (auth.uid() = traveler_id);

-- MEDIA: public media visible to all, private only to uploader
create policy "media: public read" on media
  for select using (is_public = true);

create policy "media: private read own" on media
  for select using (auth.uid() = uploader_id);

create policy "media: own write" on media
  for all using (auth.uid() = uploader_id);

-- REVIEWS: public reviews visible, own full access
create policy "reviews: public read" on reviews
  for select using (is_public = true);

create policy "reviews: own write" on reviews
  for all using (auth.uid() = reviewer_id);

-- MESSAGES: participants only
create policy "messages: read own" on messages
  for select using (
    auth.uid() = sender_id or
    auth.uid() = recipient_id or
    exists (
      select 1 from bookings b
      where b.trip_id = messages.trip_id and b.traveler_id = auth.uid()
    )
  );

create policy "messages: send own" on messages
  for insert with check (auth.uid() = sender_id);

-- BADGES: public read, system write (use service role for inserts)
create policy "badges: public read" on badges
  for select using (true);

-- TRIBES: public read, own membership
create policy "tribes: public read" on tribes
  for select using (true);

create policy "tribe_memberships: own access" on tribe_memberships
  for all using (auth.uid() = user_id);

-- WISHLISTS: own access only
create policy "wishlists: own access" on wishlists
  for all using (auth.uid() = user_id);

-- TRIVIA: public quizzes readable by all, own results
create policy "trivia_quizzes: read public" on trivia_quizzes
  for select using (is_public = true);

create policy "trivia_results: own access" on trivia_results
  for all using (auth.uid() = user_id);
