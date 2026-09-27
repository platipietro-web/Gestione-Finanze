-- Patrimonio · schema iniziale
--
-- Configurazione corrente: categories, items (modificabili liberamente).
-- Storico: monthly_snapshots, snapshot_items (fotografie mensili che
-- conservano una copia di nomi e categorie).
-- Importi sempre in centesimi interi (bigint).

create type public.item_kind as enum ('asset', 'liability');

-- Aggiorna updated_at a ogni modifica ---------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- PROFILI --------------------------------------------------------------------
create table public.profiles (
  id                       uuid primary key references auth.users (id) on delete cascade,
  display_name             text check (char_length(display_name) <= 60),
  currency                 char(3) not null default 'EUR',
  onboarding_completed_at  timestamptz,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

-- CATEGORIE ------------------------------------------------------------------
create table public.categories (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name           text not null check (char_length(btrim(name)) between 1 and 40),
  kind           public.item_kind not null,
  is_investment  boolean not null default false,
  sort_order     integer not null default 0,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (id, user_id),
  constraint liabilities_are_not_investments
    check (not (kind = 'liability' and is_investment))
);

-- VOCI: attività e passività (il tipo lo dà la categoria) -------------------
create table public.items (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  category_id  uuid not null,
  name         text not null check (char_length(btrim(name)) between 1 and 60),
  sort_order   integer not null default 0,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (id, user_id),
  -- La categoria deve appartenere allo stesso utente.
  foreign key (category_id, user_id)
    references public.categories (id, user_id) on delete restrict
);

-- AGGIORNAMENTI MENSILI ------------------------------------------------------
create table public.monthly_snapshots (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  period_month  date not null check (extract(day from period_month) = 1),
  currency      char(3) not null default 'EUR',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (user_id, period_month),   -- un solo aggiornamento per mese
  unique (id, user_id)
);

-- RIGHE DELL'AGGIORNAMENTO: la fotografia -----------------------------------
create table public.snapshot_items (
  id              uuid primary key default gen_random_uuid(),
  snapshot_id     uuid not null,
  user_id         uuid not null default auth.uid(),
  item_id         uuid,     -- legame con la voce attuale; NULL se eliminata
  category_id     uuid,
  item_name       text not null,          -- copie al momento del salvataggio
  category_name   text not null,
  kind            public.item_kind not null,
  is_investment   boolean not null default false,
  category_order  integer not null default 0,
  item_order      integer not null default 0,
  amount_cents    bigint not null check (amount_cents >= 0),  -- passività positive
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  foreign key (snapshot_id, user_id)
    references public.monthly_snapshots (id, user_id) on delete cascade,
  foreign key (item_id, user_id)
    references public.items (id, user_id) on delete set null (item_id),
  foreign key (category_id, user_id)
    references public.categories (id, user_id) on delete set null (category_id),
  unique (snapshot_id, item_id)
);

create index categories_user_idx on public.categories (user_id, sort_order);
create index items_user_category_idx on public.items (user_id, category_id);
create index snapshot_items_snapshot_idx on public.snapshot_items (snapshot_id);
create index snapshot_items_user_idx on public.snapshot_items (user_id);
create index snapshot_items_item_idx on public.snapshot_items (item_id);
create index snapshot_items_category_idx on public.snapshot_items (category_id);

create trigger set_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.categories
  for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.items
  for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.monthly_snapshots
  for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.snapshot_items
  for each row execute function public.set_updated_at();

-- Profilo creato automaticamente alla registrazione ------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ROW LEVEL SECURITY ---------------------------------------------------------
-- Ogni utente legge, crea, modifica ed elimina solo i propri dati.
-- (select auth.uid()) viene calcolato una volta per query, non per riga.

alter table public.profiles          enable row level security;
alter table public.categories        enable row level security;
alter table public.items             enable row level security;
alter table public.monthly_snapshots enable row level security;
alter table public.snapshot_items    enable row level security;

create policy profiles_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy categories_select_own on public.categories
  for select to authenticated using (user_id = (select auth.uid()));
create policy categories_insert_own on public.categories
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy categories_update_own on public.categories
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy categories_delete_own on public.categories
  for delete to authenticated using (user_id = (select auth.uid()));

create policy items_select_own on public.items
  for select to authenticated using (user_id = (select auth.uid()));
create policy items_insert_own on public.items
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy items_update_own on public.items
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy items_delete_own on public.items
  for delete to authenticated using (user_id = (select auth.uid()));

create policy snapshots_select_own on public.monthly_snapshots
  for select to authenticated using (user_id = (select auth.uid()));
create policy snapshots_insert_own on public.monthly_snapshots
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy snapshots_update_own on public.monthly_snapshots
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy snapshots_delete_own on public.monthly_snapshots
  for delete to authenticated using (user_id = (select auth.uid()));

create policy snapshot_items_select_own on public.snapshot_items
  for select to authenticated using (user_id = (select auth.uid()));
create policy snapshot_items_insert_own on public.snapshot_items
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy snapshot_items_update_own on public.snapshot_items
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy snapshot_items_delete_own on public.snapshot_items
  for delete to authenticated using (user_id = (select auth.uid()));

-- PERMESSI -------------------------------------------------------------------
-- Gli utenti non autenticati non accedono a nulla. Del profilo si possono
-- modificare solo il nome e lo stato dell'onboarding.
revoke all on public.profiles, public.categories, public.items,
              public.monthly_snapshots, public.snapshot_items from anon;
revoke all on public.profiles from authenticated;
grant select on public.profiles to authenticated;
grant update (display_name, onboarding_completed_at) on public.profiles to authenticated;
grant select, insert, update, delete
  on public.categories, public.items, public.monthly_snapshots, public.snapshot_items
  to authenticated;

revoke execute on function public.set_updated_at() from public, anon, authenticated;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
