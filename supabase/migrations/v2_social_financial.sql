-- ============================================================
-- Rahalla Travel App — Migration v2
-- Run AFTER supabase_migration.sql (v1)
-- ============================================================

-- ============================================================
-- NEW ENUMS
-- ============================================================

create type transaction_type as enum ('payment', 'refund', 'commission', 'payout');
create type transaction_status as enum ('pending', 'completed', 'failed', 'reversed');
create type payout_status as enum ('requested', 'processing', 'paid', 'failed');
create type ticket_status as enum ('open', 'in_progress', 'resolved', 'closed');
create type report_status as enum ('pending', 'reviewed', 'actioned', 'dismissed');
create type report_content_type as enum ('media', 'review', 'blog_post', 'message', 'trip', 'user');
create type notification_type as enum ('booking', 'payment', 'message', 'reminder', 'badge', 'match', 'social', 'system');
create type auth_provider as enum ('email', 'google', 'apple', 'facebook');
create type reaction_type as enum ('like', 'love', 'wow', 'helpful');
create type friendship_status as enum ('pending', 'accepted', 'blocked');

-- ============================================================
-- COLUMNS ADDED TO EXISTING TABLES
-- ============================================================

-- Users: OAuth support + push tokens + calendar sync
alter table users
  add column if not exists provider auth_provider not null default 'email',
  add column if not exists provider_id text,
  add column if not exists calendar_sync_token text,
  add column if not exists calendar_sync_provider text;  -- 'google' | 'apple'

create unique index if not exists idx_users_provider
  on users(provider, provider_id)
  where provider_id is not null;

-- Organizer profiles: auto payout config
alter table organizer_profiles
  add column if not exists auto_payout_enabled boolean not null default false,
  add column if not exists auto_payout_threshold numeric(10,2) default 100.00,
  add column if not exists payout_schedule text default 'weekly'; -- 'weekly' | 'monthly' | 'manual'

-- Traveler profiles: places visited tracking
alter table traveler_profiles
  add column if not exists places_visited uuid[] default '{}',  -- array of destination_ids
  add column if not exists travel_goals jsonb default '[]';     -- bucket list destinations

-- Trips: AI suggestion cache columns
alter table trips
  add column if not exists ai_price_suggestion numeric(10,2),
  add column if not exists ai_price_updated_at timestamptz,
  add column if not exists smart_match_config jsonb default '{}'; -- criteria weights for AI matching

-- ============================================================
-- FINANCIAL: TRANSACTIONS
-- ============================================================

create table transactions (
  id uuid primary key default uuid_generate_v4(),
  booking_id uuid references bookings(id) on delete set null,
  payout_id uuid,                                   -- FK added below after payouts table
  user_id uuid not null references users(id),
  amount numeric(10,2) not null,
  currency text not null default 'USD',
  type transaction_type not null,
  status transaction_status not null default 'pending',
  provider text,                                    -- 'stripe' | 'paypal' | etc.
  provider_reference text,                          -- external transaction ID
  description text,
  metadata jsonb default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_transactions_booking on transactions(booking_id);
create index idx_transactions_user on transactions(user_id);
alter table transactions enable row level security;

create policy "transactions: user sees own" on transactions
  for select using (auth.uid() = user_id);

-- ============================================================
-- FINANCIAL: PAYOUTS
-- ============================================================

create table payouts (
  id uuid primary key default uuid_generate_v4(),
  organizer_id uuid not null references organizer_profiles(id) on delete cascade,
  amount numeric(10,2) not null,
  currency text not null default 'USD',
  status payout_status not null default 'requested',
  provider text,
  provider_reference text,
  notes text,
  requested_at timestamptz not null default now(),
  processed_at timestamptz,
  paid_at timestamptz
);

create index idx_payouts_organizer on payouts(organizer_id);
alter table payouts enable row level security;

create policy "payouts: organizer sees own" on payouts
  for select using (
    exists (
      select 1 from organizer_profiles op
      where op.id = payouts.organizer_id and op.user_id = auth.uid()
    )
  );

-- Now add the FK from transactions → payouts
alter table transactions
  add constraint fk_transactions_payout
  foreign key (payout_id) references payouts(id) on delete set null;

-- ============================================================
-- FINANCIAL: REFUND REQUESTS
-- ============================================================

create table refund_requests (
  id uuid primary key default uuid_generate_v4(),
  booking_id uuid not null references bookings(id) on delete cascade,
  requested_by uuid not null references users(id),
  amount numeric(10,2) not null,
  reason text,
  status transaction_status not null default 'pending',
  admin_notes text,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

alter table refund_requests enable row level security;

create policy "refund_requests: user sees own" on refund_requests
  for select using (auth.uid() = requested_by);

create policy "refund_requests: insert own" on refund_requests
  for insert with check (auth.uid() = requested_by);

-- ============================================================
-- PUSH NOTIFICATIONS
-- ============================================================

create table push_tokens (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  token text not null,
  platform text not null,                           -- 'ios' | 'android' | 'web'
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(user_id, token)
);

alter table push_tokens enable row level security;

create policy "push_tokens: own access" on push_tokens
  for all using (auth.uid() = user_id);

-- ============================================================
-- SCHEDULED NOTIFICATIONS / REMINDERS
-- ============================================================

create table scheduled_notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  booking_id uuid references bookings(id) on delete cascade,
  type notification_type not null,
  title text not null,
  body text not null,
  scheduled_for timestamptz not null,
  sent_at timestamptz,
  is_sent boolean not null default false,
  metadata jsonb default '{}'
);

create index idx_scheduled_notifications_pending
  on scheduled_notifications(scheduled_for)
  where is_sent = false;

alter table scheduled_notifications enable row level security;

create policy "scheduled_notifications: own read" on scheduled_notifications
  for select using (auth.uid() = user_id);

-- ============================================================
-- NOTIFICATION INBOX (in-app)
-- ============================================================

create table notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  type notification_type not null,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  action_url text,                                  -- deep link path in app
  metadata jsonb default '{}',
  created_at timestamptz not null default now()
);

create index idx_notifications_user_unread
  on notifications(user_id, created_at desc)
  where is_read = false;

alter table notifications enable row level security;

create policy "notifications: own access" on notifications
  for all using (auth.uid() = user_id);

-- ============================================================
-- BLOG POSTS (memory/storytelling layer)
-- ============================================================

create table blog_posts (
  id uuid primary key default uuid_generate_v4(),
  author_id uuid not null references users(id) on delete cascade,
  destination_id uuid references destinations(id) on delete set null,
  trip_id uuid references trips(id) on delete set null,
  title text not null,
  slug text unique,                                 -- for URL: /blog/my-trip-to-petra
  body text not null,                               -- rich text / markdown
  cover_image_url text,
  tags text[] default '{}',
  is_published boolean not null default false,
  is_featured boolean not null default false,
  view_count int not null default 0,
  read_time_minutes int,                            -- estimated read time
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_blog_posts_destination on blog_posts(destination_id) where is_published = true;
create index idx_blog_posts_author on blog_posts(author_id);

alter table blog_posts enable row level security;

create policy "blog_posts: public read published" on blog_posts
  for select using (is_published = true);

create policy "blog_posts: author full access" on blog_posts
  for all using (auth.uid() = author_id);

create trigger trg_blog_posts_updated_at
  before update on blog_posts
  for each row execute function set_updated_at();

-- ============================================================
-- CONTENT REPORTS (moderation)
-- ============================================================

create table content_reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid not null references users(id),
  content_type report_content_type not null,
  content_id uuid not null,                         -- ID of the flagged item
  reason text not null,
  details text,
  status report_status not null default 'pending',
  reviewed_by uuid references users(id),            -- admin user
  admin_notes text,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create index idx_content_reports_pending
  on content_reports(created_at)
  where status = 'pending';

alter table content_reports enable row level security;

create policy "content_reports: reporter can insert" on content_reports
  for insert with check (auth.uid() = reporter_id);

create policy "content_reports: reporter can read own" on content_reports
  for select using (auth.uid() = reporter_id);

-- ============================================================
-- ADMIN AUDIT LOG
-- ============================================================

create table admin_logs (
  id uuid primary key default uuid_generate_v4(),
  admin_id uuid not null references users(id),
  action text not null,                             -- e.g. 'suspend_user', 'approve_organizer'
  target_type text not null,                        -- 'user' | 'trip' | 'review' | etc.
  target_id uuid not null,
  before_state jsonb,
  after_state jsonb,
  notes text,
  created_at timestamptz not null default now()
);

create index idx_admin_logs_admin on admin_logs(admin_id);
create index idx_admin_logs_target on admin_logs(target_type, target_id);

alter table admin_logs enable row level security;
-- Admin logs are service-role write only; no user-facing RLS needed

-- ============================================================
-- SUPPORT TICKETS
-- ============================================================

create table support_tickets (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  subject text not null,
  body text not null,
  status ticket_status not null default 'open',
  category text,                                    -- 'payment' | 'booking' | 'account' | 'other'
  priority int not null default 2,                  -- 1=high, 2=medium, 3=low
  assigned_to uuid references users(id),            -- admin user
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table ticket_replies (
  id uuid primary key default uuid_generate_v4(),
  ticket_id uuid not null references support_tickets(id) on delete cascade,
  author_id uuid not null references users(id),
  body text not null,
  is_internal boolean not null default false,       -- internal admin notes
  created_at timestamptz not null default now()
);

alter table support_tickets enable row level security;
alter table ticket_replies enable row level security;

create policy "support_tickets: own access" on support_tickets
  for all using (auth.uid() = user_id);

create policy "ticket_replies: participant read" on ticket_replies
  for select using (
    auth.uid() = author_id or
    exists (
      select 1 from support_tickets st
      where st.id = ticket_replies.ticket_id and st.user_id = auth.uid()
    )
  );

create trigger trg_support_tickets_updated_at
  before update on support_tickets
  for each row execute function set_updated_at();

-- ============================================================
-- SOCIAL: FOLLOWS
-- ============================================================

create table follows (
  id uuid primary key default uuid_generate_v4(),
  follower_id uuid not null references users(id) on delete cascade,
  following_id uuid not null references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(follower_id, following_id),
  check (follower_id <> following_id)
);

create index idx_follows_follower on follows(follower_id);
create index idx_follows_following on follows(following_id);

alter table follows enable row level security;

create policy "follows: public read" on follows
  for select using (true);

create policy "follows: own write" on follows
  for all using (auth.uid() = follower_id);

-- ============================================================
-- SOCIAL: FRIENDSHIPS
-- ============================================================

create table friendships (
  id uuid primary key default uuid_generate_v4(),
  requester_id uuid not null references users(id) on delete cascade,
  addressee_id uuid not null references users(id) on delete cascade,
  status friendship_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

alter table friendships enable row level security;

create policy "friendships: participants access" on friendships
  for all using (
    auth.uid() = requester_id or auth.uid() = addressee_id
  );

-- ============================================================
-- SOCIAL: REACTIONS (likes on media, blog posts, reviews)
-- ============================================================

create table reactions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  content_type report_content_type not null,        -- reusing enum: 'media' | 'blog_post' | 'review'
  content_id uuid not null,
  reaction reaction_type not null default 'like',
  created_at timestamptz not null default now(),
  unique(user_id, content_type, content_id)
);

create index idx_reactions_content on reactions(content_type, content_id);

alter table reactions enable row level security;

create policy "reactions: public read" on reactions
  for select using (true);

create policy "reactions: own write" on reactions
  for all using (auth.uid() = user_id);

-- ============================================================
-- SOCIAL: MESSAGE READ RECEIPTS (for group chats)
-- ============================================================

create table message_reads (
  message_id uuid not null references messages(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

alter table message_reads enable row level security;

create policy "message_reads: own access" on message_reads
  for all using (auth.uid() = user_id);

-- ============================================================
-- SOCIAL: MESSAGE TEMPLATES (organizer saved templates)
-- ============================================================

create table message_templates (
  id uuid primary key default uuid_generate_v4(),
  organizer_id uuid not null references organizer_profiles(id) on delete cascade,
  title text not null,
  body text not null,
  category text,                                    -- 'booking_confirmation' | 'reminder' | 'welcome'
  created_at timestamptz not null default now()
);

alter table message_templates enable row level security;

create policy "message_templates: own access" on message_templates
  for all using (
    exists (
      select 1 from organizer_profiles op
      where op.id = message_templates.organizer_id and op.user_id = auth.uid()
    )
  );

-- ============================================================
-- TRIBES: TRIBE POSTS / DISCUSSION FEED
-- ============================================================

create table tribe_posts (
  id uuid primary key default uuid_generate_v4(),
  tribe_id uuid not null references tribes(id) on delete cascade,
  author_id uuid not null references users(id) on delete cascade,
  body text not null,
  media_urls jsonb default '[]',
  linked_trip_id uuid references trips(id) on delete set null,
  is_pinned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_tribe_posts_tribe on tribe_posts(tribe_id, created_at desc);

alter table tribe_posts enable row level security;

create policy "tribe_posts: member read" on tribe_posts
  for select using (
    exists (
      select 1 from tribe_memberships tm
      where tm.tribe_id = tribe_posts.tribe_id and tm.user_id = auth.uid()
    )
  );

create policy "tribe_posts: author write" on tribe_posts
  for all using (auth.uid() = author_id);

create trigger trg_tribe_posts_updated_at
  before update on tribe_posts
  for each row execute function set_updated_at();

-- ============================================================
-- GAMIFICATION: BADGE DEFINITIONS
-- ============================================================

create table badge_definitions (
  id uuid primary key default uuid_generate_v4(),
  badge_type text not null unique,
  entity_type badge_entity_type not null,
  name text not null,
  description text,
  icon_url text,
  criteria jsonb not null,                          -- { metric: 'trips_completed', threshold: 10 }
  is_seasonal boolean not null default false,
  season_start timestamptz,
  season_end timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table badge_definitions enable row level security;

create policy "badge_definitions: public read" on badge_definitions
  for select using (is_active = true);

-- ============================================================
-- GAMIFICATION: BADGE PROGRESS
-- ============================================================

create table badge_progress (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references users(id) on delete cascade,
  badge_type text not null references badge_definitions(badge_type),
  current_value numeric not null default 0,
  target_value numeric not null,
  is_completed boolean not null default false,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  unique(user_id, badge_type)
);

create index idx_badge_progress_user on badge_progress(user_id);

alter table badge_progress enable row level security;

create policy "badge_progress: own access" on badge_progress
  for all using (auth.uid() = user_id);

-- ============================================================
-- SMART MATCHING: MATCH SCORES CACHE
-- ============================================================

create table match_scores (
  id uuid primary key default uuid_generate_v4(),
  traveler_id uuid not null references users(id) on delete cascade,
  trip_id uuid not null references trips(id) on delete cascade,
  score numeric(5,2) not null,                      -- 0.00 to 100.00
  score_breakdown jsonb default '{}',               -- { budget: 90, style: 85, dates: 70 }
  computed_at timestamptz not null default now(),
  unique(traveler_id, trip_id)
);

create index idx_match_scores_traveler on match_scores(traveler_id, score desc);
create index idx_match_scores_trip on match_scores(trip_id);

alter table match_scores enable row level security;

create policy "match_scores: own read" on match_scores
  for select using (auth.uid() = traveler_id);

-- ============================================================
-- WISHLISTS: TRIP SAVED ITEMS (if using separate saved destinations)
-- ============================================================

-- Already in v1, but add bucket list notes column
alter table wishlists
  add column if not exists notes text,
  add column if not exists priority int default 3;  -- 1=high, 2=medium, 3=low

-- ============================================================
-- REVIEW REQUESTS (organizer nudges traveler to review)
-- ============================================================

create table review_requests (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  traveler_id uuid not null references users(id) on delete cascade,
  organizer_id uuid not null references organizer_profiles(id),
  sent_at timestamptz not null default now(),
  completed_at timestamptz,
  unique(trip_id, traveler_id)
);

alter table review_requests enable row level security;

create policy "review_requests: traveler read own" on review_requests
  for select using (auth.uid() = traveler_id);

-- ============================================================
-- UPDATED_AT TRIGGERS for new tables
-- ============================================================

create trigger trg_transactions_updated_at
  before update on transactions
  for each row execute function set_updated_at();

create trigger trg_friendships_updated_at
  before update on friendships
  for each row execute function set_updated_at();

create trigger trg_badge_progress_updated_at
  before update on badge_progress
  for each row execute function set_updated_at();

-- ============================================================
-- SEED: BADGE DEFINITIONS
-- ============================================================

insert into badge_definitions (badge_type, entity_type, name, description, criteria) values
  -- Traveler badges
  ('first_step',       'traveler', 'First step',        'Complete your first trip',                  '{"metric":"trips_completed","threshold":1}'),
  ('explorer',         'traveler', 'Explorer',          'Complete 5 trips',                          '{"metric":"trips_completed","threshold":5}'),
  ('wanderlust',       'traveler', 'Wanderlust',        'Complete 10 trips',                         '{"metric":"trips_completed","threshold":10}'),
  ('photographer',     'traveler', 'Photographer',      'Upload 20 photos',                          '{"metric":"photos_uploaded","threshold":20}'),
  ('storyteller',      'traveler', 'Storyteller',       'Publish 3 blog posts',                      '{"metric":"blog_posts_published","threshold":3}'),
  ('reviewer',         'traveler', 'Reviewer',          'Leave 5 reviews',                           '{"metric":"reviews_written","threshold":5}'),
  ('group_leader',     'traveler', 'Group leader',      'Lead a group booking',                      '{"metric":"group_bookings_led","threshold":1}'),
  ('local_expert',     'traveler', 'Local expert',      'Visit the same destination 3 times',        '{"metric":"destination_revisits","threshold":3}'),
  -- Organizer badges
  ('first_trip',       'organizer', 'First trip',       'Host your first trip',                      '{"metric":"trips_hosted","threshold":1}'),
  ('superhost',        'organizer', 'Superhost',        'Maintain 4.8+ rating over 20 trips',        '{"metric":"avg_rating_20trips","threshold":4.8}'),
  ('rising_star',      'organizer', 'Rising star',      'Get 10 bookings in first month',            '{"metric":"bookings_first_month","threshold":10}'),
  ('fast_responder',   'organizer', 'Fast responder',   'Maintain 95%+ response rate',               '{"metric":"response_rate","threshold":95}'),
  ('high_demand',      'organizer', 'High demand',      'Sell out 5 trips',                          '{"metric":"sold_out_trips","threshold":5}'),
  ('community_fav',    'organizer', 'Community fav',    'Receive 50 five-star reviews',              '{"metric":"five_star_reviews","threshold":50}'),
  ('year_one',         'organizer', 'Year one',         'Active on platform for 1 year',             '{"metric":"days_on_platform","threshold":365}');

-- ============================================================
-- END OF MIGRATION v2
-- ============================================================
