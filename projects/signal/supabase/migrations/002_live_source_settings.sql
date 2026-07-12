create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.signal_preferences (
  preference_key text primary key check (preference_key = 'default'),
  include_keywords text[] not null default '{}',
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.source_settings
  alter column enabled set default true;

alter table public.signal_preferences
  alter column include_keywords set default '{}';

insert into public.source_settings (source, enabled)
values ('github', true), ('hacker_news', true)
on conflict (source) do nothing;

insert into public.signal_preferences (preference_key, include_keywords)
values ('default', '{}')
on conflict (preference_key) do nothing;

drop trigger if exists set_source_settings_updated_at on public.source_settings;
create trigger set_source_settings_updated_at
before update on public.source_settings
for each row
execute function public.set_updated_at();

drop trigger if exists set_signal_preferences_updated_at on public.signal_preferences;
create trigger set_signal_preferences_updated_at
before update on public.signal_preferences
for each row
execute function public.set_updated_at();

alter table public.source_settings enable row level security;
alter table public.signal_preferences enable row level security;

grant select, insert, update on public.source_settings to anon, authenticated;
grant select, insert, update on public.signal_preferences to anon, authenticated;

drop policy if exists "internal_mvp_no_auth_read_source_settings" on public.source_settings;
create policy "internal_mvp_no_auth_read_source_settings"
on public.source_settings
for select
to anon, authenticated
using (true);

drop policy if exists "internal_mvp_no_auth_write_source_settings" on public.source_settings;
create policy "internal_mvp_no_auth_write_source_settings"
on public.source_settings
for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "internal_mvp_no_auth_insert_source_settings" on public.source_settings;
create policy "internal_mvp_no_auth_insert_source_settings"
on public.source_settings
for insert
to anon, authenticated
with check (true);

drop policy if exists "internal_mvp_no_auth_read_signal_preferences" on public.signal_preferences;
create policy "internal_mvp_no_auth_read_signal_preferences"
on public.signal_preferences
for select
to anon, authenticated
using (true);

drop policy if exists "internal_mvp_no_auth_write_signal_preferences" on public.signal_preferences;
create policy "internal_mvp_no_auth_write_signal_preferences"
on public.signal_preferences
for update
to anon, authenticated
using (preference_key = 'default')
with check (preference_key = 'default');

drop policy if exists "internal_mvp_no_auth_insert_signal_preferences" on public.signal_preferences;
create policy "internal_mvp_no_auth_insert_signal_preferences"
on public.signal_preferences
for insert
to anon, authenticated
with check (preference_key = 'default');

comment on table public.source_settings is
  'Internal MVP browser settings only. Anonymous writes are not safe for public launch without auth and tighter RLS.';

comment on table public.signal_preferences is
  'Internal MVP browser settings only. Anonymous writes are not safe for public launch without auth and tighter RLS.';
