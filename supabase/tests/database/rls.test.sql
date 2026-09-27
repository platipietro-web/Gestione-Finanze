-- Test delle policy RLS e delle funzioni. Si eseguono con:
--   supabase start && supabase test db
-- Tutto avviene in una transazione annullata alla fine.

begin;
create extension if not exists pgtap with schema extensions;

select plan(31);

-- Due utenti di prova (il trigger crea i profili).
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'anna@example.com'),
  ('22222222-2222-2222-2222-222222222222', 'bruno@example.com');

select results_eq(
  'select count(*)::int from public.profiles',
  array[2],
  'Il trigger crea un profilo per ogni nuovo utente'
);

-- Id degli aggiornamenti, per i test che ne hanno bisogno.
create table public.test_ids (label text primary key, id uuid);
grant select, insert on public.test_ids to authenticated;

-- ANNA ---------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub": "11111111-1111-1111-1111-111111111111"}';

insert into public.categories (id, name, kind)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'Liquidità', 'asset');
insert into public.items (id, category_id, name)
values ('aaaaaaaa-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001', 'Conto corrente');

select lives_ok(
  $$ insert into public.test_ids
     select 'agosto', public.save_snapshot('2026-08-01', '[{"item_id": "aaaaaaaa-0000-0000-0000-000000000002",
       "category_id": "aaaaaaaa-0000-0000-0000-000000000001", "item_name": "Conto corrente",
       "category_name": "Liquidità", "kind": "asset", "amount_cents": 1000000}]'::jsonb) $$,
  'Anna salva l''aggiornamento di agosto'
);

select lives_ok(
  $$ insert into public.test_ids
     select 'settembre', public.save_snapshot('2026-09-01', '[{"item_id": "aaaaaaaa-0000-0000-0000-000000000002",
       "category_id": "aaaaaaaa-0000-0000-0000-000000000001", "item_name": "Conto corrente",
       "category_name": "Liquidità", "kind": "asset", "amount_cents": 1200000}]'::jsonb) $$,
  'Anna salva l''aggiornamento di settembre'
);

select throws_ok(
  $$ select public.save_snapshot('2026-08-20', '[]'::jsonb) $$,
  '23505', null,
  'Un solo aggiornamento per mese'
);

select throws_ok(
  $$ select public.save_snapshot('2026-07-01', '[{"item_name": "X", "category_name": "Y",
       "kind": "asset", "amount_cents": -1}]'::jsonb) $$,
  '23514', null,
  'Gli importi negativi sono rifiutati'
);

select throws_ok(
  $$ select public.save_snapshot('2026-07-01', '{"non": "array"}'::jsonb) $$,
  '22023', null,
  'Le righe devono essere un array'
);

select results_eq(
  'select count(*)::int from public.snapshot_items',
  array[2],
  'Anna vede le proprie righe'
);

select results_eq(
  $$ select to_char(period_month, 'YYYY-MM-DD') from public.monthly_snapshots order by period_month $$,
  array['2026-08-01', '2026-09-01'],
  'Il mese viene sempre salvato come primo giorno'
);

-- BRUNO --------------------------------------------------------------------
set local request.jwt.claims to '{"sub": "22222222-2222-2222-2222-222222222222"}';

select is_empty('select * from public.categories', 'Bruno non vede le categorie di Anna');
select is_empty('select * from public.items', 'Bruno non vede le voci di Anna');
select is_empty('select * from public.monthly_snapshots', 'Bruno non vede gli aggiornamenti di Anna');
select is_empty('select * from public.snapshot_items', 'Bruno non vede le righe di Anna');
select results_eq(
  'select count(*)::int from public.profiles',
  array[1],
  'Bruno vede solo il proprio profilo'
);

update public.categories set name = 'Modificata da Bruno';
delete from public.monthly_snapshots;
delete from public.items;

select throws_ok(
  $$ insert into public.categories (user_id, name, kind)
     values ('11111111-1111-1111-1111-111111111111', 'Intrusa', 'asset') $$,
  '42501', null,
  'Bruno non può creare dati a nome di Anna'
);

select throws_ok(
  $$ insert into public.items (category_id, name)
     values ('aaaaaaaa-0000-0000-0000-000000000001', 'Intrusa') $$,
  '23503', null,
  'Bruno non può collegare una voce a una categoria di Anna'
);

select throws_ok(
  $$ select public.save_snapshot('2026-08-01', '[]'::jsonb,
       (select id from public.test_ids where label = 'agosto')) $$,
  'P0002', null,
  'Bruno non può modificare un aggiornamento di Anna'
);

select throws_ok(
  $$ select public.save_snapshot('2026-09-01', '[{"item_id": "aaaaaaaa-0000-0000-0000-000000000002",
       "item_name": "Conto di Anna", "category_name": "Y", "kind": "asset", "amount_cents": 1}]'::jsonb) $$,
  '23503', null,
  'Bruno non può riferirsi a una voce di Anna nei propri aggiornamenti'
);

select throws_ok(
  $$ update public.profiles set currency = 'USD' $$,
  '42501', null,
  'Del profilo si possono cambiare solo nome e onboarding'
);

-- VERIFICA COME AMMINISTRATORE ---------------------------------------------
set local role postgres;

select results_eq(
  'select name from public.categories',
  array['Liquidità'],
  'Le modifiche di Bruno non hanno toccato i dati di Anna'
);
select results_eq(
  'select count(*)::int from public.monthly_snapshots',
  array[2],
  'Le cancellazioni di Bruno non hanno toccato gli aggiornamenti di Anna'
);

-- MODIFICA DI UN MESE PASSATO ---------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub": "11111111-1111-1111-1111-111111111111"}';

select lives_ok(
  $$ select public.save_snapshot('2026-08-01', '[{"item_id": "aaaaaaaa-0000-0000-0000-000000000002",
       "category_id": "aaaaaaaa-0000-0000-0000-000000000001", "item_name": "Conto corrente",
       "category_name": "Liquidità", "kind": "asset", "amount_cents": 1100000}]'::jsonb,
       (select id from public.test_ids where label = 'agosto')) $$,
  'Anna corregge agosto'
);

select results_eq(
  $$ select si.amount_cents from public.snapshot_items si
     join public.monthly_snapshots ms on ms.id = si.snapshot_id
     where ms.period_month = '2026-08-01' $$,
  array[1100000::bigint],
  'Agosto è stato corretto'
);

select results_eq(
  $$ select si.amount_cents from public.snapshot_items si
     join public.monthly_snapshots ms on ms.id = si.snapshot_id
     where ms.period_month = '2026-09-01' $$,
  array[1200000::bigint],
  'Correggere agosto non cambia settembre'
);

-- LO STORICO NON CAMBIA ---------------------------------------------------
update public.items set name = 'Conto Fineco' where id = 'aaaaaaaa-0000-0000-0000-000000000002';

select results_eq(
  'select distinct item_name from public.snapshot_items',
  array['Conto corrente'],
  'Rinominare una voce oggi non cambia lo storico'
);

delete from public.items where id = 'aaaaaaaa-0000-0000-0000-000000000002';

select results_eq(
  'select count(*)::int from public.snapshot_items where item_id is null',
  array[2],
  'Eliminare una voce non cancella le righe dello storico'
);

insert into public.items (category_id, name)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'Contanti');

-- Il codice d'errore dipende dalla versione di PostgreSQL (23001 o 23503):
-- si verifica il vincolo coinvolto.
select throws_like(
  $$ delete from public.categories where id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  '%items_category_id_user_id_fkey%',
  'Una categoria che contiene voci non si può eliminare'
);

select throws_ok(
  $$ insert into public.categories (name, kind, is_investment) values ('Mutui', 'liability', true) $$,
  '23514', null,
  'Una passività non può essere un investimento'
);

-- UTENTI NON AUTENTICATI --------------------------------------------------
set local role anon;
select throws_ok(
  'select * from public.categories',
  '42501', null,
  'Gli utenti non autenticati non accedono ai dati'
);
select throws_ok(
  $$ select public.save_snapshot('2026-09-01', '[]'::jsonb) $$,
  '42501', null,
  'Gli utenti non autenticati non possono salvare'
);

-- ELIMINAZIONE DELL'ACCOUNT -----------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub": "11111111-1111-1111-1111-111111111111"}';
select lives_ok('select public.delete_my_account()', 'Anna elimina il proprio account');

set local role postgres;
select is_empty(
  $$ select 1 from public.categories where user_id = '11111111-1111-1111-1111-111111111111'
     union all
     select 1 from public.monthly_snapshots where user_id = '11111111-1111-1111-1111-111111111111' $$,
  'Con l''account spariscono tutti i dati di Anna'
);

select * from finish();
rollback;
