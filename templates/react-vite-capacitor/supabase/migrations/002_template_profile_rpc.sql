create or replace function public.upsert_user_profile(display_name text)
returns public.user_profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  next_profile public.user_profiles;
begin
  if auth.uid() is null then
    raise exception 'Authenticated session required.';
  end if;

  insert into public.user_profiles (user_id, display_name)
  values (auth.uid(), nullif(trim(display_name), ''))
  on conflict (user_id) do update
    set display_name = excluded.display_name,
        updated_at = timezone('utc', now())
  returning * into next_profile;

  return next_profile;
end;
$$;

revoke all on function public.upsert_user_profile(text) from public;
grant execute on function public.upsert_user_profile(text) to authenticated;

comment on function public.upsert_user_profile(text) is
  'Template RPC example for authenticated profile writes. Internal scaffold, not production-ready policy.';
