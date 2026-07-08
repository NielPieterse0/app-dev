create table if not exists public.source_items (
  id text primary key,
  source text not null check (source in ('github', 'hacker_news')),
  external_id text not null,
  title text not null,
  summary text not null,
  url text not null,
  author text not null,
  published_at timestamptz not null,
  collected_at timestamptz not null default timezone('utc', now()),
  engagement_count integer not null default 0 check (engagement_count >= 0),
  score numeric(8,2) not null default 0 check (score >= 0),
  keywords text[] not null default '{}'
);

create unique index if not exists source_items_source_external_id_idx
  on public.source_items (source, external_id);

create index if not exists source_items_source_published_at_idx
  on public.source_items (source, published_at desc);

create index if not exists source_items_score_idx
  on public.source_items (score desc);

create table if not exists public.source_settings (
  source text primary key check (source in ('github', 'hacker_news')),
  enabled boolean not null default true,
  updated_at timestamptz not null default timezone('utc', now())
);

insert into public.source_settings (source, enabled)
values ('github', true), ('hacker_news', true)
on conflict (source) do nothing;
