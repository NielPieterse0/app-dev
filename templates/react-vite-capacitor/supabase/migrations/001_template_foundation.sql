create extension if not exists pgcrypto;

create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.user_profiles enable row level security;

drop policy if exists "authenticated_users_read_own_profile" on public.user_profiles;
create policy "authenticated_users_read_own_profile"
on public.user_profiles
for select
to authenticated
using (auth.uid() = user_id);

revoke insert, update, delete on public.user_profiles from anon, authenticated;

comment on table public.user_profiles is
  'Template baseline profile table. Replace or extend this in generated apps once the real auth and domain model are defined. Internal scaffold, not production-ready policy.';
