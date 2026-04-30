-- =============================================================
-- USER FAVORITES - Migration for event favorites
-- Run this in Supabase SQL Editor after 001_initial_schema.sql
-- =============================================================

-- User favorites table (links auth users to events)
create table user_favorites (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id uuid not null references events(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, event_id)
);

-- Indexes
create index idx_user_favorites_user on user_favorites(user_id);
create index idx_user_favorites_event on user_favorites(event_id);

-- Row Level Security
alter table user_favorites enable row level security;

-- Users can only see their own favorites
create policy "Users can view own favorites"
  on user_favorites for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can only insert their own favorites
create policy "Users can insert own favorites"
  on user_favorites for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can only delete their own favorites
create policy "Users can delete own favorites"
  on user_favorites for delete
  to authenticated
  using (auth.uid() = user_id);

-- Also allow app users to READ chapters, events, and event_tags
-- (The existing policies allow all authenticated users, so this is already covered)

-- Add read-only policies for the app (if you want to restrict app users later):
-- create policy "App users can read chapters" on chapters for select to authenticated using (true);
-- create policy "App users can read events" on events for select to authenticated using (true);
-- create policy "App users can read event_tags" on event_tags for select to authenticated using (true);
