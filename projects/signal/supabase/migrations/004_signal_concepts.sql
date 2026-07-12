create table if not exists public.signal_concepts (
  id text primary key,
  title text not null,
  target_user text not null default '',
  problem text not null default '',
  opportunity text not null default '',
  evidence_summary text not null default '',
  risks text not null default '',
  confidence text not null check (confidence in ('low', 'medium', 'high')),
  status text not null check (status in ('draft', 'reviewing', 'ready', 'archived')),
  source_item_ids text[] not null default '{}',
  evidence_items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists signal_concepts_updated_at_idx
  on public.signal_concepts (updated_at desc);

drop trigger if exists set_signal_concepts_updated_at on public.signal_concepts;
create trigger set_signal_concepts_updated_at
before update on public.signal_concepts
for each row execute function public.set_updated_at();

alter table public.signal_concepts enable row level security;

revoke insert, update, delete on public.signal_concepts from anon, authenticated;
grant select on public.signal_concepts to anon, authenticated;

drop policy if exists "internal_mvp_no_auth_read_signal_concepts" on public.signal_concepts;
create policy "internal_mvp_no_auth_read_signal_concepts"
on public.signal_concepts
for select
to anon, authenticated
using (true);

create or replace function public.upsert_signal_concept(
  concept_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  concept_row public.signal_concepts%rowtype;
begin
  if concept_payload is null or jsonb_typeof(concept_payload) <> 'object' then
    raise exception 'concept_payload must be a json object';
  end if;

  if jsonb_typeof(coalesce(concept_payload->'source_item_ids', '[]'::jsonb)) <> 'array' then
    raise exception 'concept_payload.source_item_ids must be a json array';
  end if;

  if jsonb_typeof(coalesce(concept_payload->'evidence_items', '[]'::jsonb)) <> 'array' then
    raise exception 'concept_payload.evidence_items must be a json array';
  end if;

  insert into public.signal_concepts (
    id,
    title,
    target_user,
    problem,
    opportunity,
    evidence_summary,
    risks,
    confidence,
    status,
    source_item_ids,
    evidence_items,
    created_at,
    updated_at
  )
  values (
    concept_payload->>'id',
    concept_payload->>'title',
    coalesce(concept_payload->>'target_user', ''),
    coalesce(concept_payload->>'problem', ''),
    coalesce(concept_payload->>'opportunity', ''),
    coalesce(concept_payload->>'evidence_summary', ''),
    coalesce(concept_payload->>'risks', ''),
    concept_payload->>'confidence',
    concept_payload->>'status',
    coalesce(array(select jsonb_array_elements_text(concept_payload->'source_item_ids')), '{}'),
    coalesce(concept_payload->'evidence_items', '[]'::jsonb),
    coalesce((concept_payload->>'created_at')::timestamptz, timezone('utc', now())),
    coalesce((concept_payload->>'updated_at')::timestamptz, timezone('utc', now()))
  )
  on conflict (id)
  do update set
    title = excluded.title,
    target_user = excluded.target_user,
    problem = excluded.problem,
    opportunity = excluded.opportunity,
    evidence_summary = excluded.evidence_summary,
    risks = excluded.risks,
    confidence = excluded.confidence,
    status = excluded.status,
    source_item_ids = excluded.source_item_ids,
    evidence_items = excluded.evidence_items,
    updated_at = timezone('utc', now())
  returning * into concept_row;

  return jsonb_build_object(
    'id', concept_row.id,
    'title', concept_row.title,
    'target_user', concept_row.target_user,
    'problem', concept_row.problem,
    'opportunity', concept_row.opportunity,
    'evidence_summary', concept_row.evidence_summary,
    'risks', concept_row.risks,
    'confidence', concept_row.confidence,
    'status', concept_row.status,
    'source_item_ids', concept_row.source_item_ids,
    'evidence_items', concept_row.evidence_items,
    'created_at', concept_row.created_at,
    'updated_at', concept_row.updated_at
  );
end;
$$;

revoke all on function public.upsert_signal_concept(jsonb) from public;
grant execute on function public.upsert_signal_concept(jsonb) to anon, authenticated;

comment on table public.signal_concepts is
  'Internal MVP concept drafts for Signal. Stores promoted signal evidence and editable product-brief fields. Not public-launch safe.';

comment on function public.upsert_signal_concept(jsonb) is
  'Internal MVP browser concept write boundary. Stores concept drafts and evidence snapshots for product shaping. Not production-ready for public launch.';
