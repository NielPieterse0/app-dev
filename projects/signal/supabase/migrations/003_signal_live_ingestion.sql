create table if not exists public.signal_feed_state (
  feed_key text primary key,
  last_refreshed_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now())
);

insert into public.signal_feed_state (feed_key, last_refreshed_at)
values ('default', null)
on conflict (feed_key) do nothing;

create table if not exists public.source_items (
  id text primary key,
  source text not null check (source in ('github', 'hacker_news')),
  external_id text not null,
  title text not null,
  summary text not null,
  url text not null,
  author text not null,
  published_at timestamptz not null,
  collected_at timestamptz not null,
  engagement_count integer not null check (engagement_count >= 0),
  score numeric not null check (score >= 0),
  keywords text[] not null default '{}',
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists source_items_source_external_id_idx
  on public.source_items (source, external_id);

drop trigger if exists set_signal_feed_state_updated_at on public.signal_feed_state;
create trigger set_signal_feed_state_updated_at
before update on public.signal_feed_state
for each row execute function public.set_updated_at();

drop trigger if exists set_source_items_updated_at on public.source_items;
create trigger set_source_items_updated_at
before update on public.source_items
for each row execute function public.set_updated_at();

alter table public.signal_feed_state enable row level security;
alter table public.source_items enable row level security;

revoke insert, update, delete on public.source_settings from anon, authenticated;
revoke insert, update, delete on public.signal_preferences from anon, authenticated;
revoke insert, update, delete on public.signal_feed_state from anon, authenticated;
revoke insert, update, delete on public.source_items from anon, authenticated;

grant select on public.signal_feed_state to anon, authenticated;
grant select on public.source_items to anon, authenticated;

drop policy if exists "internal_mvp_no_auth_read_signal_feed_state" on public.signal_feed_state;
create policy "internal_mvp_no_auth_read_signal_feed_state"
on public.signal_feed_state
for select
to anon, authenticated
using (true);

drop policy if exists "internal_mvp_no_auth_read_source_items" on public.source_items;
create policy "internal_mvp_no_auth_read_source_items"
on public.source_items
for select
to anon, authenticated
using (true);

create or replace function public.save_signal_settings(
  enabled_sources_input text[],
  include_keywords_input text[]
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  source_rows jsonb;
  preference_rows jsonb;
begin
  insert into public.source_settings (source, enabled)
  select source_value, source_value = any(enabled_sources_input)
  from unnest(array['github', 'hacker_news']) as source_value
  on conflict (source)
  do update set
    enabled = excluded.enabled,
    updated_at = timezone('utc', now());

  insert into public.signal_preferences (preference_key, include_keywords)
  values ('default', coalesce(include_keywords_input, '{}'))
  on conflict (preference_key)
  do update set
    include_keywords = excluded.include_keywords,
    updated_at = timezone('utc', now());

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'source', source,
        'enabled', enabled,
        'updated_at', updated_at
      )
      order by source
    ),
    '[]'::jsonb
  )
  into source_rows
  from public.source_settings;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'preference_key', preference_key,
        'include_keywords', include_keywords,
        'updated_at', updated_at
      )
    ),
    '[]'::jsonb
  )
  into preference_rows
  from public.signal_preferences
  where preference_key = 'default';

  return jsonb_build_object(
    'source_rows', source_rows,
    'preference_rows', preference_rows
  );
end;
$$;

revoke all on function public.save_signal_settings(text[], text[]) from public;
grant execute on function public.save_signal_settings(text[], text[]) to anon, authenticated;

create or replace function public.replace_signal_source_items(
  items_payload jsonb,
  refreshed_at_input timestamptz default timezone('utc', now())
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if items_payload is null or jsonb_typeof(items_payload) <> 'array' then
    raise exception 'items_payload must be a json array';
  end if;

  delete from public.source_items;

  insert into public.source_items (
    id,
    source,
    external_id,
    title,
    summary,
    url,
    author,
    published_at,
    collected_at,
    engagement_count,
    score,
    keywords
  )
  select
    item->>'id',
    item->>'source',
    item->>'external_id',
    item->>'title',
    item->>'summary',
    item->>'url',
    item->>'author',
    (item->>'published_at')::timestamptz,
    (item->>'collected_at')::timestamptz,
    (item->>'engagement_count')::integer,
    (item->>'score')::numeric,
    coalesce(array(select jsonb_array_elements_text(item->'keywords')), '{}')
  from jsonb_array_elements(items_payload) as item;

  insert into public.signal_feed_state (feed_key, last_refreshed_at)
  values ('default', refreshed_at_input)
  on conflict (feed_key)
  do update set
    last_refreshed_at = excluded.last_refreshed_at,
    updated_at = timezone('utc', now());
end;
$$;

revoke all on function public.replace_signal_source_items(jsonb, timestamptz) from public;
grant execute on function public.replace_signal_source_items(jsonb, timestamptz) to anon, authenticated;

comment on function public.save_signal_settings(text[], text[]) is
  'Internal MVP browser settings only. Transactional settings write boundary. Not production-ready for public launch.';

comment on function public.replace_signal_source_items(jsonb, timestamptz) is
  'Internal MVP browser ingestion only. Replaces the persisted public-source feed for manual refresh. Not production-ready for public launch.';

comment on table public.signal_feed_state is
  'Internal MVP feed metadata only. Tracks last refresh timing for the persisted Signal source feed.';

comment on table public.source_items is
  'Internal MVP persisted public-source feed for Signal. This no-auth browser-readable model is not public-launch safe.';
