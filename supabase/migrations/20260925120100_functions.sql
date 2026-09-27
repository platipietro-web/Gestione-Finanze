-- Patrimonio · funzioni chiamate dall'app

-- Salva un aggiornamento mensile in un'unica transazione.
-- p_snapshot_id NULL: nuovo aggiornamento. Altrimenti: modifica di quello
-- indicato. Tocca solo quell'aggiornamento: correggere agosto non cambia
-- settembre (la variazione di settembre si ricalcola nell'app).
create or replace function public.save_snapshot(
  p_period_month  date,
  p_items         jsonb,
  p_snapshot_id   uuid default null
)
returns uuid
language plpgsql
security invoker            -- le policy RLS restano attive
set search_path = ''
as $$
declare
  v_user_id     uuid := auth.uid();
  v_snapshot_id uuid;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception 'p_items deve essere un array' using errcode = '22023';
  end if;

  if p_snapshot_id is null then
    insert into public.monthly_snapshots (user_id, period_month)
    values (v_user_id, date_trunc('month', p_period_month)::date)
    returning id into v_snapshot_id;             -- mese già presente: 23505
  else
    update public.monthly_snapshots
       set period_month = date_trunc('month', p_period_month)::date
     where id = p_snapshot_id
    returning id into v_snapshot_id;             -- RLS: solo i propri
    if v_snapshot_id is null then
      raise exception 'snapshot_not_found' using errcode = 'P0002';
    end if;
    delete from public.snapshot_items where snapshot_id = v_snapshot_id;
  end if;

  insert into public.snapshot_items (
    snapshot_id, user_id, item_id, category_id, item_name, category_name,
    kind, is_investment, category_order, item_order, amount_cents)
  select v_snapshot_id, v_user_id,
         (x->>'item_id')::uuid, (x->>'category_id')::uuid,
         x->>'item_name', x->>'category_name',
         (x->>'kind')::public.item_kind,
         coalesce((x->>'is_investment')::boolean, false),
         coalesce((x->>'category_order')::integer, 0),
         coalesce((x->>'item_order')::integer, 0),
         (x->>'amount_cents')::bigint
    from jsonb_array_elements(p_items) as x;

  return v_snapshot_id;
end;
$$;

revoke execute on function public.save_snapshot(date, jsonb, uuid) from public, anon;
grant  execute on function public.save_snapshot(date, jsonb, uuid) to authenticated;

-- Elimina l'account dell'utente corrente e, a cascata, tutti i suoi dati.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  delete from auth.users where id = v_user_id;
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant  execute on function public.delete_my_account() to authenticated;
