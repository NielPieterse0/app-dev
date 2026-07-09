alter table public.source_items
  add column if not exists updated_at timestamptz not null default timezone('utc', now());

alter table public.source_items
  alter column collected_at set default timezone('utc', now());

alter table public.source_items
  alter column engagement_count set default 0;

alter table public.source_items
  alter column score type numeric(8,2) using round(score::numeric, 2),
  alter column score set default 0;

drop trigger if exists set_source_items_updated_at on public.source_items;
create trigger set_source_items_updated_at
before update on public.source_items
for each row execute function public.set_updated_at();

comment on table public.source_items is
  'Internal MVP persisted public-source feed for Signal. This table shape is aligned across migrations 001, 003, and 005. Not public-launch safe.';
