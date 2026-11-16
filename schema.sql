-- ====================================================================
-- SUPABASE DATABASE SCHEMA FOR PANU
-- Run this in your Supabase SQL Editor:
-- Dashboard -> SQL Editor -> New Query -> Paste & Run
-- ====================================================================

-- 1. PROFILES TABLE
create table if not exists public.profiles (
  id text primary key,                        -- User UID (e.g. from Firebase Auth)
  email text,
  full_name text default '',
  address text default '',
  phone text default '',
  age integer default 0,
  jurisdiction text default '',
  avatar_url text default '',
  created_at timestamptz default timezone('utc'::text, now()) not null,
  updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- Index for searching profiles
create index if not exists idx_profiles_email on public.profiles(email);

-- Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- Drop existing policies if re-running
drop policy if exists "Allow service_role full access to profiles" on public.profiles;
drop policy if exists "Allow users to read their own profile" on public.profiles;
drop policy if exists "Allow users to upsert their own profile" on public.profiles;

-- Policies for profiles
create policy "Allow service_role full access to profiles" 
  on public.profiles
  for all 
  to service_role 
  using (true) 
  with check (true);

create policy "Allow users to read their own profile" 
  on public.profiles
  for select 
  using (true);

create policy "Allow users to upsert their own profile" 
  on public.profiles
  for all 
  to service_role 
  using (true) 
  with check (true);


-- ====================================================================
-- 2. DRAFTS TABLE
-- ====================================================================
create table if not exists public.drafts (
  id uuid default gen_random_uuid() primary key,
  user_id text not null,                      -- User UID
  petition_type text not null,                -- e.g. "Bail Application", "Consumer Complaint"
  draft_content text not null,                -- Generated Markdown text
  form_data jsonb default '{}'::jsonb,        -- Raw questionnaire data stored as JSON
  created_at timestamptz default timezone('utc'::text, now()) not null
);

-- Index to fetch user drafts quickly
create index if not exists idx_drafts_user_id_created_at 
  on public.drafts(user_id, created_at desc);

-- Enable Row Level Security (RLS)
alter table public.drafts enable row level security;

-- Drop existing policies if re-running
drop policy if exists "Allow service_role full access to drafts" on public.drafts;
drop policy if exists "Allow read drafts" on public.drafts;
drop policy if exists "Allow insert drafts" on public.drafts;

-- Policies for drafts
create policy "Allow service_role full access to drafts" 
  on public.drafts
  for all 
  to service_role 
  using (true) 
  with check (true);

create policy "Allow read drafts" 
  on public.drafts
  for select 
  using (true);

create policy "Allow insert drafts" 
  on public.drafts
  for insert 
  with check (true);
