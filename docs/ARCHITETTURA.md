# Patrimonio — Piano architetturale

**Piano approvato e implementato** · 25 settembre 2026

Nome dell'app: **Patrimonio**. Il piano qui sotto è quello approvato nella Milestone 1. Lo stato dell'implementazione, con le differenze rispetto al piano, è nella sezione 13 in fondo.

**Indice**

0. Sintesi e decisioni da approvare
1. Architettura tecnica
2. Struttura cartelle
3. Schema database
4. Modello dati e calcoli
5. State management
6. Routing
7. Design system
8. Wireframe
9. Dipendenze
10. Piano delle milestone
11. Test, sicurezza, performance, estendibilità
12. Problemi identificati e rischi
13. Stato dell'implementazione

---

## 0. Sintesi e decisioni da approvare

### L'idea in una riga

Una volta al mese l'utente inserisce i valori delle sue voci. L'app salva una fotografia del mese (lo *snapshot*) e da lì calcola tutto il resto: patrimonio netto, variazioni, grafici, distribuzione, investimenti.

### Scelte principali

| Area | Scelta |
|---|---|
| App | Flutter con Material 3: un solo codice per iOS, Android e Web |
| Backend | Supabase: Auth, PostgreSQL, Row Level Security. Nessun server da gestire |
| Stato | Riverpod 3, senza generazione di codice per i provider |
| Navigazione | go_router, con URL leggibili sul web |
| Grafici | fl_chart: licenza MIT, molto diffuso, aggiornato di recente |
| Importi | Interi in centesimi: `bigint` nel database, `int` in Dart. Mai `double` |
| Calcoli | Funzioni pure in Dart, coperte da test unitari |
| Sicurezza | RLS su ogni tabella, più chiavi esterne che impediscono riferimenti tra utenti diversi |

### Verifiche già fatte

- **Flutter installato:** 3.41.6 con Dart 3.11.4. `flutter doctor` non segnala problemi: Android SDK 36, Xcode 26.5 e Chrome sono pronti.
- **Ultima stabile:** Flutter 3.47.5 con Dart 3.13.4, rilasciata il 18/09/2026.
- **Compatibilità:** le versioni più recenti di Riverpod (3.4), go_router (18) e freezed (4) richiedono Dart 3.12 o 3.13. Sulla 3.41.6 non si installano.
- **Build di prova:** in una cartella temporanea, fuori dal progetto, ho compilato per il web un'app minima con flutter_riverpod 3.3.2, go_router 17.5.0, fl_chart 1.2.0 e supabase_flutter 2.17.2. Sia la build JavaScript sia quella WebAssembly sono riuscite.
- **Riverpod e web:** pub.dev segnala Riverpod come "non compatibile con il web". La causa è un import indiretto di `flutter_test` dentro il pacchetto. La compilazione web funziona comunque; lo verificherò anche in esecuzione nel browser all'inizio della Milestone 2.
- **Palette dei grafici:** validata per daltonismo e contrasto, in tema chiaro e scuro (sezione 7.3).

### Decisioni da approvare

| # | Tema | Proposta | Alternativa |
|---|---|---|---|
| D1 | Versione Flutter | Aggiornare a 3.47.5 prima della Milestone 2, per usare le versioni correnti dei pacchetti | Restare su 3.41.6 con Riverpod 3.3, go_router 17.5 e freezed 3.2, combinazione già verificata |
| D2 | Tabelle | Una tabella `items` per attività e passività. Gli investimenti si ricavano dagli snapshot, senza `investment_categories` e `investment_snapshots` | Seguire la struttura indicativa: l'utente inserirebbe gli investimenti due volte |
| D3 | Crypto | Voce dentro "Investimenti" come predefinito. L'utente può farne una categoria a sé | Categoria separata come predefinito |
| D4 | Un aggiornamento al mese | Riaprire un mese già salvato modifica quello esistente. Si possono inserire anche mesi passati | Più snapshot nello stesso mese |
| D5 | Form precompilato | Il form parte dai valori del mese precedente: si cambia solo ciò che è cambiato | Campi vuoti ogni mese |
| D6 | Demo | Modalità demo locale, senza account e senza database, con banner fisso "Dati di esempio" | Account demo condiviso su Supabase |
| D7 | Elimina account | Aggiungerlo nelle impostazioni. Apple lo richiede alle app che permettono di registrarsi | Rinviare a dopo l'MVP |
| D8 | Conferma email | Attiva: protegge l'account e rende affidabile il recupero password | Disattiva: registrazione più rapida |
| D9 | Desktop | Nel browser per l'MVP. App native macOS e Windows più avanti, con lo stesso codice | Build macOS nativa da subito |
| D10 | Identità dell'app | Nome "Patrimonio", bundle id `it.pietroplati.patrimonio` | Un altro nome. Il bundle id è difficile da cambiare dopo la pubblicazione |
| D11 | Git | Repository dedicato nella cartella del progetto | Nessuna alternativa sensata: vedi il problema P1 nella sezione 12 |
| D12 | Test RLS | Test pgTAP su un Supabase locale, che richiede Docker Desktop oppure OrbStack | Test di integrazione Dart su un progetto Supabase di sviluppo con due utenti di prova |

### Prerequisiti da parte tua

1. **Supabase:** un account con un progetto `dev`; il piano gratuito basta. Mi serviranno l'URL del progetto e la chiave pubblica (*publishable key*). Non condividere mai la chiave segreta.
2. **Supabase CLI:** via libera a installarla con Homebrew. Serve per applicare le migrazioni del database.
3. **Solo per D12:** Docker Desktop oppure OrbStack.
4. **Solo per D1:** via libera a eseguire `flutter upgrade`. Aggiorna l'SDK Flutter globale in `~/flutter`, quindi anche quello usato dagli altri tuoi progetti Flutter.

---

## 1. Architettura tecnica

### 1.1 Vista d'insieme

```
┌──────────────────────────── App Flutter (iOS · Android · Web) ────────────────────────────┐
│                                                                                           │
│  PRESENTATION   Schermate e widget. Material 3, layout adattivo                           │
│       │         ref.watch (lettura) · ref.read (azioni)                                   │
│       ▼                                                                                   │
│  APPLICATION    Provider Riverpod: controller (Notifier, AsyncNotifier) e valori derivati │
│       │                                                                                   │
│       ▼                                                                                   │
│  DOMAIN         Modelli immutabili · Money · YearMonth · WealthCalculator                 │
│       ▲         Dart puro: niente Flutter, niente Supabase                                │
│       │                                                                                   │
│  DATA           Repository astratti ─┬─ Supabase…Repository  (dati reali)                 │
│                                      └─ Demo…Repository      (in memoria: demo e test)    │
└──────────────────────────────────────┬────────────────────────────────────────────────────┘
                                       │ HTTPS · supabase_flutter
                     ┌─────────────────┴──────────────────┐
                     │ Supabase                           │
                     │  Auth: email e password, JWT       │
                     │  PostgREST e funzioni RPC          │
                     │  PostgreSQL con Row Level Security │
                     └────────────────────────────────────┘
```

### 1.2 Principi

- **La UI non parla mai con Supabase.** Passa sempre dai repository. Così la stessa UI funziona con i dati reali, con la demo e nei test.
- **I calcoli sono Dart puro.** Totali, variazioni e distribuzioni stanno in funzioni senza dipendenze, facili da testare e riusabili per l'export futuro.
- **Una sola fonte di verità:** l'elenco degli snapshot. Tutto il resto si deriva e resta in cache finché i dati non cambiano.
- **Salvataggio atomico.** Uno snapshot e le sue righe si salvano con una sola funzione PostgreSQL, in un'unica transazione: o si salva tutto o niente.
- **La sicurezza sta nel database.** Il client non è considerato affidabile: RLS e vincoli valgono anche per chi chiama le API direttamente.
- **La demo è la stessa app con repository diversi.** I dati demo non toccano mai il database.

### 1.3 Il flusso "Aggiorna patrimonio"

1. L'utente preme **+ Aggiorna patrimonio** e si apre il form del mese corrente. Se quel mese ha già un aggiornamento, il form lo apre in modifica.
2. Ogni voce attiva parte dal valore dell'ultimo aggiornamento precedente; le voci nuove partono da zero.
3. Mentre l'utente scrive, il controller ricalcola i totali in centesimi. Una barra fissa mostra il patrimonio netto e la variazione rispetto al mese precedente.
4. **Salva aggiornamento** chiama il repository, che chiama la funzione `save_snapshot` nel database.
5. Il provider degli snapshot aggiorna il suo stato. Dashboard, grafici, storico e investimenti si ricalcolano da soli, una volta sola, senza ricaricare la pagina.

### 1.4 Configurazione e ambienti

- URL e chiave pubblica di Supabase arrivano da `--dart-define-from-file=env/dev.json`. Il file è escluso da git; nel repository c'è solo `env/example.json` con valori finti.
- Nel client esiste solo la chiave pubblica, che è protetta dalle policy RLS. La chiave segreta non entra mai nel progetto.
- Due progetti Supabase, `dev` e `prod`, quando arriveremo alla pubblicazione. Il piano gratuito ne consente due attivi.
- Le migrazioni SQL stanno in `supabase/migrations/` e si applicano con la Supabase CLI.

### 1.5 Piattaforme

| Piattaforma | MVP | Note |
|---|---|---|
| iPhone | Sì | Transizioni e gesti iOS, tastiera numerica, deep link per email di conferma e reset |
| Android | Sì | Predictive back, tastiera numerica, deep link |
| Web (desktop, tablet) | Sì | URL leggibili, tastiera e mouse, build WebAssembly da valutare |
| macOS e Windows nativi | Dopo l'MVP | Stesso codice; servono configurazioni di firma e deep link (decisione D9) |

---

## 2. Struttura cartelle

```
GestioneFinanze/
├── lib/
│   ├── main.dart                     # Avvio: chiama bootstrap()
│   ├── bootstrap.dart                # Supabase.initialize, ProviderScope, gestione errori globale
│   ├── app.dart                      # MaterialApp.router: tema, localizzazione, router
│   │
│   ├── core/                         # Infrastruttura senza logica di prodotto
│   │   ├── config/app_config.dart    # Valori da --dart-define (URL, chiave pubblica)
│   │   ├── theme/
│   │   │   ├── tokens/               # colors, typography, spacing, radius, shadows, motion
│   │   │   ├── app_theme.dart        # ThemeData chiaro e scuro costruiti dai token
│   │   │   └── theme_mode_controller.dart
│   │   ├── layout/                   # breakpoints, adaptive_scaffold, responsive_grid
│   │   ├── router/                   # app_router, routes, redirect di autenticazione
│   │   ├── money/                    # Money, formattazione, parsing, Percent
│   │   ├── time/year_month.dart      # Il mese come tipo (2026-09)
│   │   ├── errors/                   # AppFailure e traduzione delle eccezioni
│   │   └── l10n/app_it.arb           # Testi dell'interfaccia in italiano
│   │
│   ├── shared/                       # Dominio e dati usati da più feature
│   │   ├── models/                   # WealthCategory, WealthItem, Snapshot, SnapshotItem, Profile
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart          # Interfacce astratte
│   │   │   ├── catalog_repository.dart       # Categorie e voci
│   │   │   ├── snapshot_repository.dart
│   │   │   ├── profile_repository.dart
│   │   │   ├── supabase/                     # Implementazioni reali
│   │   │   └── demo/                         # Implementazioni in memoria e dataset demo
│   │   ├── services/
│   │   │   └── wealth_calculator.dart        # Calcoli puri: totali, variazioni, distribuzione
│   │   ├── providers/                # Provider condivisi: repository, catalogo, snapshot
│   │   └── widgets/                  # AppCard, MoneyText, DeltaBadge, Skeleton, EmptyState,
│   │       │                         # ErrorView, AsyncView, DemoBanner, SectionHeader
│   │       └── charts/               # NetWorthLineChart, DistributionDonut, RangeSelector
│   │
│   └── features/
│       ├── auth/                     # Accesso, registrazione, recupero e reset password
│       ├── onboarding/               # Benvenuto, scelta voci, primo aggiornamento
│       ├── dashboard/
│       ├── assets/                   # Sezione "Patrimonio": categorie e voci
│       ├── monthly_update/           # Form di aggiornamento: nuovo e modifica
│       ├── investments/
│       ├── history/                  # Storico e dettaglio aggiornamento
│       └── settings/                 # Profilo, tema, esci, elimina account
│
├── test/                             # Stessa struttura di lib/
│   ├── unit/  ·  widget/  ·  helpers/
├── supabase/
│   ├── config.toml
│   ├── migrations/                   # SQL versionato
│   └── tests/                        # Test pgTAP delle policy RLS
├── env/example.json                  # Modello di configurazione (quello vero è in .gitignore)
├── assets/fonts/                     # Inter, incluso nell'app
├── docs/ARCHITETTURA.md              # Questo documento
├── analysis_options.yaml  ·  l10n.yaml  ·  pubspec.yaml
```

Ogni feature ha la stessa forma interna:

```
features/dashboard/
├── application/      # Provider e controller della feature
└── presentation/
    ├── dashboard_screen.dart
    └── widgets/      # Widget usati solo da questa feature
```

**Regole di dipendenza.**

- `features` può usare `shared` e `core`. `shared` può usare `core`. Mai il contrario.
- Una feature non importa un'altra feature. Quello che serve a più feature sale in `shared`.
- Modelli e repository stanno in `shared` perché snapshot e categorie servono a cinque feature su otto. Tenerli dentro una sola feature creerebbe dipendenze incrociate.
- Un widget pubblico per file, file sotto le 300 righe circa, nomi dei file in snake_case.

---

## 3. Schema database

### 3.1 Dalla struttura indicativa a quella proposta

| Struttura indicativa | Proposta | Motivo |
|---|---|---|
| `users` | `auth.users` di Supabase più `profiles` | Supabase gestisce credenziali e sessioni. `profiles` contiene solo i dati dell'app |
| `categories` | `categories` | Aggiunto il flag `is_investment` |
| `assets` e `liabilities` | `items` | Stessi campi e stesso comportamento. Il tipo, attività o passività, lo dà la categoria. Una sola gestione, un solo form |
| `monthly_snapshots` | `monthly_snapshots` | Un solo snapshot per utente e per mese |
| `snapshot_items` | `snapshot_items` | Ogni riga copia nome, categoria e tipo della voce: è la fotografia |
| `investment_categories` | Flag `is_investment` sulla categoria | Evita di inserire due volte lo stesso valore |
| `investment_snapshots` | Righe di `snapshot_items` con `is_investment = true` | Nessun dato duplicato da tenere allineato |

**Configurazione corrente contro storico.** `categories` e `items` descrivono la situazione di oggi e si possono modificare liberamente. `monthly_snapshots` e `snapshot_items` sono lo storico. Le righe dello storico conservano una copia dei nomi, quindi rinominare, spostare o archiviare una voce oggi non cambia i mesi passati.

### 3.2 Relazioni

```
auth.users ──1:1── profiles
     │
     ├──1:N── categories ──1:N── items
     │             ┆                ┆
     │             ┆ category_id    ┆ item_id          collegamenti deboli:
     │             ┆ (SET NULL)     ┆ (SET NULL)       se la voce sparisce
     │             ▼                ▼                   lo storico resta
     └──1:N── monthly_snapshots ──1:N── snapshot_items
```

### 3.3 Tabelle (bozza della prima migrazione)

```sql
create type public.item_kind as enum ('asset', 'liability');

-- Aggiorna updated_at a ogni modifica
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

-- PROFILI ---------------------------------------------------------------
create table public.profiles (
  id                       uuid primary key references auth.users (id) on delete cascade,
  display_name             text check (char_length(display_name) <= 60),
  currency                 char(3) not null default 'EUR',   -- pronto per più valute
  onboarding_completed_at  timestamptz,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

-- CATEGORIE -------------------------------------------------------------
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

-- VOCI: attività e passività -------------------------------------------
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
  -- la categoria deve appartenere allo stesso utente
  foreign key (category_id, user_id)
    references public.categories (id, user_id) on delete restrict
);

-- SNAPSHOT MENSILI ------------------------------------------------------
create table public.monthly_snapshots (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  period_month  date not null
                check (extract(day from period_month) = 1),   -- sempre il giorno 1 del mese
  currency      char(3) not null default 'EUR',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (user_id, period_month),   -- un solo aggiornamento per mese
  unique (id, user_id)
);

-- RIGHE DELLO SNAPSHOT: la fotografia -----------------------------------
create table public.snapshot_items (
  id              uuid primary key default gen_random_uuid(),
  snapshot_id     uuid not null,
  user_id         uuid not null default auth.uid(),
  item_id         uuid,     -- legame con la voce di oggi; NULL se la voce viene eliminata
  category_id     uuid,
  item_name       text not null,          -- copie al momento dello snapshot
  category_name   text not null,
  kind            public.item_kind not null,
  is_investment   boolean not null,
  category_order  integer not null default 0,
  item_order      integer not null default 0,
  amount_cents    bigint not null check (amount_cents >= 0),  -- passività positive, poi sottratte
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

create index categories_user_idx       on public.categories (user_id, sort_order);
create index items_user_category_idx   on public.items (user_id, category_id);
create index snapshot_items_snapshot_idx on public.snapshot_items (snapshot_id);
create index snapshot_items_user_idx   on public.snapshot_items (user_id);
create index snapshot_items_item_idx   on public.snapshot_items (item_id);

-- Trigger updated_at, uno per tabella
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

-- Profilo creato automaticamente alla registrazione
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
```

`on delete set null (item_id)` con l'elenco di colonne richiede PostgreSQL 15 o successivo. I progetti Supabase attuali lo soddisfano; lo verifico sul progetto reale nella Milestone 4.

### 3.4 Row Level Security

```sql
alter table public.profiles          enable row level security;
alter table public.categories        enable row level security;
alter table public.items             enable row level security;
alter table public.monthly_snapshots enable row level security;
alter table public.snapshot_items    enable row level security;

-- Profilo: lettura e modifica solo del proprio.
-- Lo crea il trigger e lo cancella l'eliminazione dell'account.
create policy profiles_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Stesso schema di quattro policy per categories, items,
-- monthly_snapshots e snapshot_items. Esempio per categories:
create policy categories_select_own on public.categories
  for select to authenticated using (user_id = (select auth.uid()));
create policy categories_insert_own on public.categories
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy categories_update_own on public.categories
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy categories_delete_own on public.categories
  for delete to authenticated using (user_id = (select auth.uid()));

-- Permessi espliciti: gli utenti non autenticati non vedono nulla
revoke all on public.profiles, public.categories, public.items,
              public.monthly_snapshots, public.snapshot_items from anon;
revoke all on public.profiles from authenticated;
grant select on public.profiles to authenticated;
grant update (display_name, onboarding_completed_at) on public.profiles to authenticated;
grant select, insert, update, delete
  on public.categories, public.items, public.monthly_snapshots, public.snapshot_items
  to authenticated;
```

`(select auth.uid())` invece di `auth.uid()` è la forma consigliata da Supabase: il valore si calcola una volta per query invece che una volta per riga.

**Due livelli di protezione.** Le policy impediscono di leggere o scrivere righe altrui. Le chiavi esterne composte, per esempio `(category_id, user_id)`, impediscono di collegare una propria voce alla categoria di un altro utente: un controllo che le sole policy non coprono.

### 3.5 Funzioni

**Salvataggio di uno snapshot, in una sola transazione.**

```sql
create or replace function public.save_snapshot(
  p_period_month  date,
  p_items         jsonb,              -- [{ item_id, category_id, item_name, category_name,
                                      --    kind, is_investment, category_order,
                                      --    item_order, amount_cents }, ...]
  p_snapshot_id   uuid default null   -- NULL: nuovo snapshot; altrimenti: modifica
)
returns uuid
language plpgsql
security invoker                      -- le policy RLS restano attive
set search_path = ''
as $$
declare
  v_user_id     uuid := auth.uid();
  v_snapshot_id uuid;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_snapshot_id is null then
    insert into public.monthly_snapshots (user_id, period_month)
    values (v_user_id, date_trunc('month', p_period_month)::date)
    returning id into v_snapshot_id;           -- mese già presente: errore 23505
  else
    update public.monthly_snapshots
       set period_month = date_trunc('month', p_period_month)::date
     where id = p_snapshot_id
    returning id into v_snapshot_id;           -- RLS: solo i propri snapshot
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
         (x->>'kind')::public.item_kind, (x->>'is_investment')::boolean,
         (x->>'category_order')::integer, (x->>'item_order')::integer,
         (x->>'amount_cents')::bigint
    from jsonb_array_elements(p_items) as x;

  return v_snapshot_id;
end;
$$;

revoke execute on function public.save_snapshot(date, jsonb, uuid) from public, anon;
grant  execute on function public.save_snapshot(date, jsonb, uuid) to authenticated;
```

La funzione tocca solo lo snapshot indicato. Correggere agosto non può modificare settembre: cambia solo la variazione di settembre, che viene ricalcolata perché non è salvata da nessuna parte.

**Eliminazione dell'account (decisione D7).**

```sql
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from auth.users where id = auth.uid();   -- a cascata su tutti i dati dell'utente
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant  execute on function public.delete_my_account() to authenticated;
```

### 3.6 Regole di integrità

- **Un aggiornamento per mese:** vincolo `unique (user_id, period_month)`.
- **Nessun riferimento tra utenti diversi:** chiavi esterne composte con `user_id`.
- **Importi mai negativi:** le passività si inseriscono come numeri positivi e vengono sottratte nel calcolo.
- **Archiviare, non cancellare.** Nell'interfaccia l'azione principale su una voce è "Archivia": la voce sparisce dai prossimi form ma resta nello storico. Anche la cancellazione vera non rompe lo storico, grazie ai nomi copiati e a `SET NULL`.
- **Categorie con voci:** non si possono cancellare (`RESTRICT`). Prima si archiviano o si spostano le voci.
- **Il tipo di una categoria non cambia dopo la creazione.** Trasformare un'attività in passività falserebbe i confronti con il passato.

### 3.7 Letture

All'avvio servono al massimo due richieste:

| Richiesta | Contenuto |
|---|---|
| Catalogo | Categorie con le loro voci, in una query con embedding PostgREST |
| Storico | Tutti gli snapshot con le loro righe, ordinati per mese |

Dieci anni di storico con venti voci fanno circa 2.400 righe, poche centinaia di KB. Una richiesta sola, poi tutto resta in cache e ogni schermata deriva ciò che le serve. Se un giorno i volumi crescessero molto, si aggiunge una vista SQL con i totali per mese: cambierebbe solo il repository Supabase.

---

## 4. Modello dati e calcoli

### 4.1 Parole dell'interfaccia

L'utente non vede mai la parola "snapshot".

| Nel codice | Nell'app |
|---|---|
| Snapshot | Aggiornamento, per esempio "Aggiornamento di settembre" |
| Category | Categoria: Liquidità, Investimenti, Immobili, Altri beni, Debiti |
| Item | Voce: Conto corrente, ETF, Casa, Mutuo |
| Asset / Liability | Attività / Passività |
| Net worth | Patrimonio netto |
| Gross worth | Patrimonio lordo, cioè il totale delle attività |

### 4.2 Modelli Dart

```dart
/// Importo in centesimi di euro. Mai double.
final class Money implements Comparable<Money> {
  const Money(this.cents);
  final int cents;                     // 18452000 = € 184.520,00
  Money operator +(Money other);
  Money operator -(Money other);
  bool get isNegative;
  bool get isZero;
}

/// Mese di riferimento, per esempio 2026-09.
final class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month);
  final int year;
  final int month;
}

enum ItemKind { asset, liability }

// Configurazione corrente (freezed: immutabili, con copyWith e JSON)
WealthCategory(id, name, kind, isInvestment, sortOrder, isActive)
WealthItem(id, categoryId, name, sortOrder, isActive)
Profile(id, email, displayName, onboardingCompleted)

// Storico
Snapshot(id, month: YearMonth, updatedAt, items: List<SnapshotItem>)
SnapshotItem(itemId?, categoryId?, itemName, categoryName, kind,
             isInvestment, categoryOrder, itemOrder, amount: Money)

// Valori derivati: calcolati, mai salvati
SnapshotTotals(assets, liabilities, netWorth, investments)
Percent(basisPoints)                  // 179 = +1,79 %
Change(absolute: Money?, percent: Percent?, comparedTo: YearMonth?)
TimelinePoint(month, totals, monthlyChange)
```

I modelli si chiamano `WealthCategory` e `WealthItem` e non `Category` e `Item`: Flutter esporta già una classe `Category`, e il conflitto di nomi sarebbe una fonte di errori.

### 4.3 Regole di calcolo

| Grandezza | Formula | Casi particolari |
|---|---|---|
| Patrimonio lordo | Somma delle attività | Nessuna voce: 0 |
| Passività | Somma delle passività, in positivo | Nessuna passività: 0 |
| Patrimonio netto | Lordo meno passività | Può essere negativo |
| Variazione assoluta | Netto attuale meno netto precedente | Primo aggiornamento: nessuna variazione, si mostra "Primo aggiornamento" |
| Variazione percentuale | (attuale − precedente) / \|precedente\| × 100 | Precedente uguale a zero: si mostra "—". Precedente negativo: vedi sotto |
| Variazione mensile | Rispetto all'aggiornamento precedente esistente | Mesi mancanti: si confronta con l'ultimo disponibile e l'etichetta dice "da luglio" |
| Variazione annuale | Rispetto allo stesso mese dell'anno prima, o al più recente precedente | Storico più corto di un anno: "dall'inizio (giugno 2026)" |
| Investimenti | Somma delle righe con `is_investment` | Nessuna voce di investimento: stato vuoto dedicato |
| Distribuzione | Quota di ogni categoria di attività sul lordo | Le passività non entrano nel donut. Lordo uguale a zero: stato vuoto |

**Precedente negativo.** Si divide per il valore assoluto, così il segno indica sempre se la situazione è migliorata. Esempio: da −10.000 € a −5.000 € la variazione è +5.000 € e **+50%**. La formula letterale darebbe −50%, un segnale sbagliato.

**Arrotondamento.** Le percentuali si calcolano su interi, cioè sui centesimi, e si arrotondano a due decimali per eccesso dalla metà in su: 1,785% diventa 1,79%. Le percentuali del donut usano il metodo del resto maggiore, così la somma fa sempre esattamente 100%.

**Valori nulli.** Nel database un importo non è mai nullo: vale di default 0. Nel form un campo svuotato conta come 0. Una voce che non esisteva in un mese passato, in quel mese semplicemente non c'è: i calcoli non la trattano come errore.

### 4.4 Inserimento e visualizzazione degli importi

**Lettura di quello che scrive l'utente**, senza passare da `double`:

| Scritto | Centesimi | Nota |
|---|---|---|
| `12.500` | 1.250.000 | Punto seguito da tre cifre: separatore delle migliaia |
| `12500,5` | 1.250.050 | Virgola: decimali |
| `12.50` | 1.250 | Punto seguito da una o due cifre finali: decimali, per chi usa la tastiera inglese |
| `€ 1.250.000` | 125.000.000 | Simbolo e spazi ignorati |
| `12,345` · `-5` · `abc` | errore | Messaggio chiaro sotto il campo |

**Visualizzazione.** Formato italiano: `€ 184.520`. Nelle schermate di riepilogo gli euro sono interi; nel form e nel dettaglio compaiono i centesimi solo se diversi da zero. Sugli assi dei grafici si usa la forma compatta, per esempio `€ 185k`. I numeri usano cifre a larghezza fissa, così le colonne restano allineate.

---

## 5. State management

**Riverpod 3, senza generazione di codice.** La sintassi manuale di Riverpod 3 (`Notifier`, `AsyncNotifier`, `Provider`) è stabile, leggibile e non richiede `build_runner` per i provider. La generazione di codice resta solo per i modelli (freezed).

### 5.1 Mappa dei provider

| Provider | Tipo | Contenuto | Durata |
|---|---|---|---|
| `appModeProvider` | Notifier | Modalità reale o demo | App |
| `supabaseClientProvider` | Provider | Client Supabase | App |
| `…RepositoryProvider` | Provider | Implementazione reale o demo, in base alla modalità | App |
| `authStateProvider` | StreamProvider | Sessione corrente | App |
| `profileProvider` | AsyncNotifier | Nome, onboarding completato | Sessione |
| `catalogProvider` | AsyncNotifier | Categorie e voci, con i metodi per crearle e modificarle | Sessione |
| `snapshotsProvider` | AsyncNotifier | Tutto lo storico, con `save()` e `delete()` | Sessione |
| `timelineProvider` | Provider derivato | Totali e variazioni di ogni mese, calcolati una volta | Derivato |
| `chartRangeProvider` | Notifier | 3M, 6M, 1A, 3A, Tutto | App |
| `netWorthChartProvider` | Provider derivato | Punti del grafico già pronti per fl_chart | Derivato |
| `distributionProvider` | Provider derivato | Fette del donut con colori e percentuali | Derivato |
| `investmentsProvider` | Provider derivato | Valore, variazioni, serie storica, ripartizione | Derivato |
| `updateReminderProvider` | Provider derivato | Se mostrare il promemoria | Derivato |
| `updateFormProvider(id?)` | Notifier con parametro, autoDispose | Bozza del form e totale in tempo reale | Schermata |
| `themeModeProvider` | Notifier | Sistema, chiaro o scuro; salvato sul dispositivo | App |

### 5.2 Regole

- **Le modifiche passano dai controller.** Per esempio `ref.read(snapshotsProvider.notifier).save(draft)`: il controller chiama il repository e aggiorna il proprio stato. I provider derivati si aggiornano da soli.
- **Dopo un salvataggio** il controller rilegge solo lo snapshot salvato e lo sostituisce nella lista. Nessun ricaricamento completo.
- **I filtri non ricaricano i dati.** Cambiare da 1A a 3A taglia una serie già calcolata.
- **Rebuild mirati:** `ref.watch(provider.select(...))` fa ricostruire solo i widget interessati.
- **Caricamento ed errore in un solo posto:** un widget condiviso `AsyncView` mostra lo skeleton durante il caricamento e un messaggio con "Riprova" in caso di errore.
- **Al logout** tutti i provider di sessione vengono invalidati. In memoria non restano dati dell'utente precedente.
- **Test:** ogni provider si prova con un `ProviderContainer` e repository finti.

### 5.3 Promemoria mensile

Il promemoria compare quando **il mese corrente non ha ancora un aggiornamento** e l'utente ne ha almeno uno. È una regola semplice e prevedibile, e sta in un solo provider: se preferisci un'altra soglia, per esempio "almeno 30 giorni dall'ultimo salvataggio", è una modifica di una riga. Lo stesso provider servirà in futuro alle notifiche push.

---

## 6. Routing

**go_router**, dichiarativo, con un solo punto di controllo degli accessi e URL leggibili sul web.

### 6.1 Mappa

| Percorso | Schermata | Accesso |
|---|---|---|
| `/accedi` | Login | Pubblico |
| `/registrati` | Registrazione | Pubblico |
| `/password-dimenticata` | Richiesta email di reset | Pubblico |
| `/reimposta-password` | Nuova password, aperta dal link nell'email | Sessione di recupero |
| `/benvenuto` | Onboarding in tre passi | Autenticato, onboarding da completare |
| `/` | Dashboard | Shell con navigazione |
| `/patrimonio` | Categorie e voci | Shell |
| `/investimenti` | Investimenti | Shell |
| `/storico` | Elenco aggiornamenti | Shell |
| `/storico/:id` | Dettaglio. Su desktop si apre a destra dell'elenco | Shell |
| `/aggiorna?mese=2026-09` | Aggiornamento mensile: nuovo, o esistente per quel mese | Tutto schermo |
| `/storico/:id/modifica` | Modifica di un aggiornamento passato | Tutto schermo |
| `/impostazioni` | Profilo, tema, esci, elimina account | Tutto schermo su mobile, nella shell su desktop |

**La modalità demo** usa gli stessi percorsi. Cambia solo la modalità dell'app, e compare il banner "Dati di esempio".

### 6.2 Controllo degli accessi

Una sola funzione di redirect, rivalutata a ogni cambio di sessione o di profilo:

1. Sessione in caricamento: splash, così non lampeggia la pagina di login.
2. Non autenticato e non in demo: solo pagine pubbliche. Le altre portano a `/accedi`, ricordando dove l'utente voleva andare.
3. Autenticato su una pagina pubblica: si va a `/`.
4. Autenticato con onboarding da completare: si va a `/benvenuto`.
5. Evento di recupero password: si va a `/reimposta-password`.

### 6.3 Dettagli tecnici

- **Navigazione principale:** `StatefulShellRoute.indexedStack` con quattro rami. Ogni sezione mantiene il proprio stato, per esempio la posizione di scorrimento.
- **Aggiornamento dello stato:** `refreshListenable` collegato ai provider di sessione e profilo.
- **Web:** `usePathUrlStrategy()` per URL senza `#`. L'hosting dovrà reindirizzare ogni percorso a `index.html`; tutti gli hosting statici comuni lo supportano.
- **Link nelle email (conferma e reset):** sul web un URL come `https://<dominio>/reimposta-password`. Su iOS e Android uno schema come `it.pietroplati.patrimonio://auth-callback`, configurato in Info.plist, AndroidManifest e negli URL di redirect di Supabase. supabase_flutter usa il flusso PKCE di default.
- **Sessione:** supabase_flutter la salva e la rinnova da solo. Se il rinnovo fallisce arriva l'evento di uscita e il router porta a `/accedi` con il messaggio "La sessione è scaduta. Accedi di nuovo."

---

## 7. Design system

### 7.1 Principi

- **Un solo colore d'accento**, un verde profondo, e molto spazio vuoto.
- **I numeri sono i protagonisti:** grandi, con cifre a larghezza fissa.
- **Verde e rosso solo per le variazioni**, sempre accompagnati da freccia e segno. Il colore non è mai l'unica informazione.
- **Ombre quasi assenti.** Nel tema chiaro: bordo sottile e ombra morbida. Nel tema scuro: superfici leggermente più chiare dello sfondo.
- **Nessun colore scritto a mano nei widget.** Si usano solo i token.

### 7.2 Colori dell'interfaccia

| Token | Chiaro | Scuro | Uso |
|---|---|---|---|
| `background` | `#F6F6F3` | `#0D1012` | Sfondo dell'app |
| `surface` | `#FFFFFF` | `#15191C` | Card, sheet, sidebar |
| `surfaceMuted` | `#EFEFEA` | `#1C2125` | Input, skeleton, chip |
| `border` | `#E4E4DE` | `#262C31` | Bordi delle card, divisori |
| `textPrimary` | `#101418` | `#F1F3F4` | Numeri, titoli, testo |
| `textSecondary` | `#5A6068` | `#A1A9B0` | Etichette |
| `textTertiary` | `#666C74` | `#7F8790` | Note, assi dei grafici |
| `primary` | `#0B7D5E` | `#5DD3AC` | Bottoni principali, selezione, link |
| `onPrimary` | `#FFFFFF` | `#04261C` | Testo sui bottoni principali |
| `primaryContainer` | `#E8F5EF` | `#12362C` | Banner, chip selezionati |
| `onPrimaryContainer` | `#053D2E` | `#BDEBD9` | Testo su banner e chip |
| `positive` | `#177A48` | `#5BCB8C` | Variazioni favorevoli |
| `negative` | `#B93A2E` | `#F0837A` | Variazioni sfavorevoli, errori |

Contrasti misurati, testo su `surface` e su `background`:

| Token | Chiaro | Scuro |
|---|---|---|
| `textSecondary` | 6,35 · 5,86 | 7,42 · 8,02 |
| `textTertiary` | 5,30 · 4,90 | 4,86 · 5,25 |
| `primary` come testo | 5,11 · 4,72 | 9,58 · 10,34 |
| `positive` | 5,37 · 4,96 | 8,73 · 9,42 |
| `negative` | 5,66 · 5,23 | 6,93 · 7,48 |
| `onPrimary` su `primary` | 5,11 | 8,76 |

Tutti i testi superano la soglia WCAG AA di 4,5:1.

### 7.3 Colori dei grafici

Le fette del donut rappresentano categorie diverse, quindi servono tinte distinguibili e non sfumature dello stesso verde: con cinque sfumature, chi ha una forma di daltonismo non distinguerebbe le fette vicine. La palette resta sobria: cinque tinte smorzate, aperte dal verde del marchio.

| Posizione | Tinta | Chiaro | Scuro |
|---|---|---|---|
| 1 | Verde (marchio) | `#0B7D5E` | `#22A07A` |
| 2 | Ambra | `#B47B0C` | `#B98424` |
| 3 | Blu | `#3B6FD1` | `#4F86E8` |
| 4 | Rosa | `#D0668F` | `#C9658F` |
| 5 | Viola | `#6E5BC4` | `#8A7BE0` |
| Altro | Grigio neutro | `#9AA0A6` | `#5F676E` |

**Validazione.** Le due palette sono state verificate con uno script che simula protanopia e deuteranopia e misura la distanza percettiva tra colori vicini:

| Controllo | Chiaro | Scuro | Soglia |
|---|---|---|---|
| Distanza minima tra colori vicini, con daltonismo | 9,5 | 9,6 | almeno 8 |
| Distanza minima tra colori vicini, vista normale | 19,6 | 15,6 | almeno 15 |
| Chiusura del cerchio, tra posizione 5 e 1 | 16,9 | 16,0 | almeno 8 |
| Contrasto delle fette sulla card | tutte ≥ 3:1 | tutte ≥ 3:1 | almeno 3:1 |

**Regole d'uso.**

- **Grafico a linee:** una sola serie, nel colore 1, con una sfumatura leggera sotto la linea. Nessuna legenda: il titolo dice cosa mostra.
- **Donut:** al massimo cinque fette colorate, più "Altro" in grigio. Tra le fette c'è uno spazio di 2 px del colore della card. La legenda è sempre visibile con nome, percentuale e valore. Il grigio di "Altro" nel tema chiaro è sotto 3:1, ed è accettabile proprio perché la legenda riporta sempre etichetta e valore.
- **Il colore segue la categoria, non la sua posizione nel grafico.** Deriva dall'ordine della categoria nel catalogo completo, archiviate comprese, così archiviare una categoria non ricolora le altre.
- **Ripartizione degli investimenti:** barre orizzontali tutte nel colore 1. È una sola serie, quindi nessun colore in più.
- **Verde e rosso delle variazioni** non si usano mai come colori delle serie.
- **Interazione:** tooltip al passaggio del mouse su desktop e al tocco su mobile, con mese e valore, e una linea verticale di riferimento. Assi e griglia discreti, poche etichette.
- **Accessibilità:** ogni grafico ha una descrizione per lo screen reader, per esempio "Patrimonio netto: da 145.000 euro a ottobre 2025 a 184.520 euro a settembre 2026". Lo Storico è la versione in tabella degli stessi dati.

### 7.4 Tipografia

Font **Inter**, licenza SIL Open Font License, incluso nell'app nei pesi 400, 500 e 600. Tutti i numeri usano cifre a larghezza fissa.

| Stile | Smartphone | Desktop | Peso | Uso |
|---|---|---|---|---|
| Display | 40/44 | 56/60 | 600 | Patrimonio netto |
| Headline | 24/30 | 28/34 | 600 | Titoli di pagina |
| Title | 17/24 | 18/26 | 600 | Titoli delle card, totali di gruppo |
| Body | 15/22 | 15/22 | 400 | Testo |
| Label | 13/18 | 13/18 | 500 | Etichette, chip, bottoni piccoli |
| Caption | 12/16 | 12/16 | 400 | Assi, note |

Le misure sono dimensione e interlinea in punti logici. Il Display ha una spaziatura tra lettere leggermente ridotta. L'interfaccia regge l'ingrandimento del testo fino al 200%.

### 7.5 Spaziature, raggi, ombre, movimento

| Token | Valori |
|---|---|
| Spaziature | 4 · 8 · 12 · 16 · 20 · 24 · 32 · 48 · 64 |
| Margini di pagina | 16 smartphone · 24 tablet · 32 desktop |
| Distanza tra card | 12 smartphone · 16 tablet · 24 desktop |
| Raggi | 8 chip e badge · 12 bottoni e input · 20 card · 28 sheet e dialog · pillola |
| Ombra card, chiaro | Bordo 1 px più `0 1 2 rgba(16,20,24,.04)` e `0 8 24 rgba(16,20,24,.04)` |
| Ombra elementi sollevati, chiaro | `0 12 32 rgba(16,20,24,.12)` per menu, sheet, bottone flottante |
| Ombre, scuro | Nessuna. L'elevazione si ottiene con superfici più chiare e bordi |
| Durate | 150 ms hover e pressione · 250 ms transizioni · 450 ms ingresso di grafici e numeri |
| Curva | easeOutCubic. Con "Riduci movimento" attivo le animazioni si disattivano |

### 7.6 Componenti

- **Bottoni.** Primario pieno in `primary`, alto 48 px su smartphone e 40 px su desktop. Secondario tonale in `primaryContainer`. Terziario solo testo. **+ Aggiorna patrimonio** è un bottone primario con icona; su smartphone è un bottone flottante esteso nella Dashboard.
- **Card.** Colore `surface`, raggio 20, padding 20, o 16 su smartphone, bordo di 1 px.
- **Campi di testo.** Sfondo `surfaceMuted`, raggio 12, nessuna sottolineatura. Al focus un bordo `primary` di 1,5 px. L'errore compare sotto il campo in `negative`.
- **Campi importo.** Allineati a destra, cifre fisse, prefisso €, tastiera numerica con decimali. Al tocco il contenuto viene selezionato, così si sovrascrive subito.
- **Badge di variazione.** Freccia, segno e valore. Verde se la situazione migliora, rosso se peggiora, grigio se invariata. Per le passività una diminuzione è verde.
- **Importi.** Un componente unico per il formato italiano, con cifre fisse e forma compatta opzionale.
- **Skeleton.** Blocchi `surfaceMuted` con una pulsazione lenta, nella stessa forma del contenuto che arriverà.
- **Stato vuoto.** Un titolo, una frase, un bottone. Nessuna illustrazione pesante.
- **Banner.** Sfondo `primaryContainer`, discreto, con una sola azione.
- **Pannelli.** Bottom sheet su smartphone, dialog centrato largo al massimo 480 px su tablet e desktop.

### 7.7 Layout adattivo

Le soglie seguono le *window size classes* di Material 3.

| Classe | Larghezza | Navigazione | Dashboard | Form mensile | Storico |
|---|---|---|---|---|---|
| Compact: smartphone | sotto 600 | Barra in basso con 4 voci | Una colonna, card a tutta larghezza, categorie in griglia 2×2 | Tutto schermo, barra fissa con totale e Salva | Elenco, poi dettaglio in una nuova pagina |
| Medium: tablet verticale | 600–839 | Navigation rail | Due colonne | Tutto schermo, riepilogo in alto | Elenco, poi dettaglio |
| Expanded: tablet orizzontale | 840–1199 | Rail estesa | Due o tre colonne | Due colonne: voci a sinistra, riepilogo fisso a destra | Elenco e dettaglio affiancati |
| Large: desktop | da 1200 | Sidebar fissa di 248 px | Griglia a 12 colonne, grafico grande, contenuto largo al massimo 1320 px | Due colonne | Affiancati |

**Dove si trovano le azioni principali.**

| Azione | Smartphone | Desktop |
|---|---|---|
| Aggiorna patrimonio | Bottone flottante in Dashboard, banner del promemoria, stati vuoti | In cima alla sidebar, sempre visibile, e nell'intestazione della Dashboard |
| Impostazioni | Avatar in alto nella Dashboard | In fondo alla sidebar |

### 7.8 Convenzioni per piattaforma

- **iOS:** transizioni e swipe indietro di iOS, switch e dialog adattivi, scorrimento elastico, tastiera decimale.
- **Android:** predictive back, effetto ripple di Material, tastiera decimale.
- **Web e desktop:** stati hover e cursore a mano sugli elementi cliccabili. Ordine di tabulazione curato: Invio passa al campo successivo, Ctrl o ⌘ + S salva, Esc chiude chiedendo conferma se ci sono modifiche. Valori selezionabili e copiabili. Il tasto indietro del browser funziona.

### 7.9 Accessibilità

- Contrasto dei testi almeno 4,5:1, elementi grafici almeno 3:1.
- Aree di tocco di almeno 48 × 48 px.
- Testo ingrandibile fino al 200% senza tagli.
- Descrizioni per lo screen reader su numeri e grafici. Esempio: "Patrimonio netto 184.520 euro, in aumento di 3.240 euro, più 1,79 per cento".
- Il colore non è mai l'unico portatore di significato.

### 7.10 Implementazione in Flutter

- I token stanno in `core/theme/tokens/`: colori, tipografia, spaziature, raggi, ombre, movimento.
- `ThemeData` di Material 3 usa un `ColorScheme` scritto per esteso, non generato da un solo colore, così i toni sono esattamente quelli scelti.
- Per i token che Material non prevede (positive, negative, surfaceMuted, palette dei grafici) si usa una `ThemeExtension`. Nei widget si leggono con scorciatoie come `context.colors.positive`.
- Il tema segue quello del sistema. Nelle impostazioni si può scegliere Sistema, Chiaro o Scuro; la scelta si salva sul dispositivo.

---

## 8. Wireframe

I wireframe mostrano struttura e gerarchia, non lo stile finale. I numeri sono di esempio e coerenti tra le schermate: settembre 2026 vale 184.520 €, agosto 181.280 €.

### 8.1 Dashboard · smartphone

```
┌────────────────────────────────────────────┐
│ Ciao, Pietro                   [avatar]    │
│                                            │
│ Patrimonio netto                           │
│ € 184.520                                  │
│ ▲ +€ 3.240 · +1,79% questo mese            │
│                                            │
│ ╭──────────────────────────────────────╮   │
│ │ È ora di aggiornare il tuo           │   │
│ │ patrimonio.            Aggiorna ora  │   │
│ ╰──────────────────────────────────────╯   │
│ ╭──────────────────────────────────────╮   │
│ │ 3M   6M  [1A]  3A   Tutto            │   │
│ │                             ╭●       │   │
│ │               ╭─╮     ╭────╯         │   │
│ │       ╭──╮ ╭──╯ ╰─────╯              │   │
│ │   ───╯   ╰─╯                         │   │
│ │ ott       feb        giu       set   │   │
│ ╰──────────────────────────────────────╯   │
│ ╭─────────────────╮  ╭─────────────────╮   │
│ │ Liquidità       │  │ Investimenti    │   │
│ │ € 24.520        │  │ € 132.000       │   │
│ │ ▲ +€ 540        │  │ ▲ +€ 2.400      │   │
│ ╰─────────────────╯  ╰─────────────────╯   │
│ ╭─────────────────╮  ╭─────────────────╮   │
│ │ Immobili        │  │ Passività       │   │
│ │ € 80.000        │  │ −€ 52.000       │   │
│ │ = invariato     │  │ ▼ −€ 300        │   │
│ ╰─────────────────╯  ╰─────────────────╯   │
│ ╭──────────────────────────────────────╮   │
│ │ Dove sono i tuoi soldi               │   │
│ │                                      │   │
│ │   ╭─────╮   ● Investimenti   56%     │   │
│ │  │ 236k │  ● Immobili       34%      │   │
│ │   ╰─────╯   ● Liquidità      10%     │   │
│ │                                      │   │
│ │ Tocca una categoria per i dettagli   │   │
│ ╰──────────────────────────────────────╯   │
│                                            │
│             ╭──────────────────────╮       │
│             │ + Aggiorna patrimonio │      │
│             ╰──────────────────────╯       │
├────────────────────────────────────────────┤
│  Home    Patrimonio  Investimenti  Storico │
└────────────────────────────────────────────┘
```

L'ordine segue le domande dell'utente: quanto ho, com'è andata, come sta andando nel tempo, dove sono i soldi. Il promemoria compare solo quando serve. Toccare una categoria apre la sezione Patrimonio.

### 8.2 Dashboard · desktop

```
┌────────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ◆ Patrimonio           │ Dashboard                                                 ╭────────────────────────╮             │
│                        │                                                           │ + Aggiorna patrimonio  │             │
│ ╭──────────────────╮   │                                                           ╰────────────────────────╯             │
│ │ + Aggiorna       │   │ ╭────────────────────────╮  ╭──────────────╮ ╭──────────────╮ ╭──────────────╮ ╭──────────────╮  │
│ ╰──────────────────╯   │ │ Patrimonio netto       │  │ Liquidità    │ │ Investimenti │ │ Immobili     │ │ Passività    │  │
│                        │ │                        │  │ € 24.520     │ │ € 132.000    │ │ € 80.000     │ │ −€ 52.000    │  │
│ ▌ Dashboard            │ │ € 184.520              │  │ ▲ +€ 540     │ │ ▲ +€ 2.400   │ │ = invariato  │ │ ▼ −€ 300     │  │
│   Patrimonio           │ │ ▲ +€ 3.240 · +1,79%    │  ╰──────────────╯ ╰──────────────╯ ╰──────────────╯ ╰──────────────╯  │
│   Investimenti         │ │ rispetto ad agosto     │                                                                       │
│   Storico              │ ╰────────────────────────╯                                                                       │
│                        │ ╭───────────────────────────────────────────────────────────╮ ╭────────────────────────────────╮ │
│                        │ │ Patrimonio netto              3M  6M  [1A]  3A  Tutto     │ │ Distribuzione                  │ │
│                        │ │                                                           │ │                                │ │
│                        │ │                                   ╭──────────────╮        │ │      ╭───────╮                 │ │
│                        │ │                                   │ ago 2026     │  ╭●    │ │     │ € 236k │                 │ │
│                        │ │                   ╭──╮            │ € 181.280    │╭─╯     │ │      ╰───────╯                 │ │
│                        │ │           ╭──╮ ╭──╯  ╰──╮  ╭──╮   ╰──────────────╯│       │ │                                │ │
│                        │ │       ╭──╯  ╰─╯        ╰──╯  ╰──────────────────╯         │ │ ● Investimenti  56%  € 132.000 │ │
│                        │ │   ───╯                                                    │ │ ● Immobili      34%   € 80.000 │ │
│                        │ │                                                           │ │ ● Liquidità     10%   € 24.520 │ │
│ ────────────────────── │ │ ott   nov   dic   gen   feb   mar   apr   mag   giu   set │ │                                │ │
│   Impostazioni         │ ╰───────────────────────────────────────────────────────────╯ │                                │ │
│   Pietro · Esci        │                                                               ╰────────────────────────────────╯ │
└────────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

Il grafico occupa due terzi della larghezza. Passando il mouse compare il tooltip con mese e valore.

### 8.3 Dashboard · tablet

```
┌───┬──────────────────────────────────────────────────────────────────────┐
│ ⌂ │ ╭───────────────────────────────╮ ╭────────────────────────────────╮ │
│   │ │ Patrimonio netto              │ │ Liquidità           € 24.520   │ │
│ ◧ │ │ € 184.520                     │ │ Investimenti       € 132.000   │ │
│   │ │ ▲ +€ 3.240 · +1,79%           │ │ Immobili            € 80.000   │ │
│ ◔ │ │                               │ │ Passività          −€ 52.000   │ │
│   │ ╰───────────────────────────────╯ ╰────────────────────────────────╯ │
│ ☰ │ ╭──────────────────────────────────────────────────────────────────╮ │
│   │ │ Patrimonio netto        3M  6M  [1A]  3A  Tutto                  │ │
│   │ │                                                                  │ │
│   │ │         (grafico a tutta larghezza)                              │ │
│   │ │                                                                  │ │
│   │ ╰──────────────────────────────────────────────────────────────────╯ │
│ + │ ╭───────────────────────────────╮ ╭────────────────────────────────╮ │
│   │ │ Distribuzione                 │ │ Ultimi aggiornamenti           │ │
│   │ │ (donut + legenda)             │ │ (3 righe, link allo Storico)   │ │
│   │ ╰───────────────────────────────╯ ╰────────────────────────────────╯ │
└───┴──────────────────────────────────────────────────────────────────────┘
```

### 8.4 Aggiorna patrimonio · smartphone

```
┌────────────────────────────────────────────┐
│ ✕          Aggiorna patrimonio             │
│          ‹  Settembre 2026  ›              │
│                                            │
│ Valori del mese scorso già inseriti:       │
│ modifica solo quello che è cambiato.       │
│                                            │
│ LIQUIDITÀ                    € 24.520      │
│ Conto corrente         ╭────────────╮      │
│                        │ € 15.520   │      │
│                        ╰────────────╯      │
│ Conto deposito               € 8.000       │
│ Contanti                     € 1.000       │
│                                            │
│ INVESTIMENTI                € 132.000      │
│ ETF                         € 75.000       │
│ Azioni                      € 32.000       │
│ Obbligazioni                € 20.000       │
│ Crypto                       € 5.000       │
│                                            │
│ IMMOBILI                     € 80.000      │
│ Casa                        € 80.000       │
│                                            │
│ PASSIVITÀ                   −€ 52.000      │
│ Mutuo                       € 50.000       │
│ Carta di credito             € 2.000       │
│                                            │
│ + Aggiungi voce                            │
├────────────────────────────────────────────┤
│ Patrimonio netto            € 184.520      │
│ ▲ +€ 3.240 · +1,79% rispetto ad agosto     │
│ ╭────────────────────────────────────╮     │
│ │         Salva aggiornamento        │     │
│ ╰────────────────────────────────────╯     │
└────────────────────────────────────────────┘
```

- La barra in basso si aggiorna mentre si scrive.
- Il selettore del mese permette di inserire mesi passati. Se il mese ha già un aggiornamento, compare la nota "Stai modificando l'aggiornamento di luglio".
- **+ Aggiungi voce** chiede nome e categoria; la voce entra anche nel catalogo per i mesi successivi.
- Chiudere con modifiche non salvate chiede conferma.

### 8.5 Aggiorna patrimonio · desktop

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ✕  Aggiorna patrimonio                          ‹  Settembre 2026  ›                                                     │
│                                                                                                                          │
│ Valori del mese scorso già inseriti: modifica solo quello che è cambiato.                                                │
│                                                                                                                          │
│ ╭──────────────────────────────────────────────────╮        ╭─────────────────────────────────────────╮                  │
│ │ LIQUIDITÀ                               € 24.520 │        │ Riepilogo · Settembre 2026              │                  │
│ │ Conto corrente            ╭──────────────────╮   │        │                                         │                  │
│ │                           │         € 15.520 │   │        │ Patrimonio netto                        │                  │
│ │                           ╰──────────────────╯   │        │ € 184.520                               │                  │
│ │ Conto deposito                          € 8.000  │        │ ▲ +€ 3.240 · +1,79% vs agosto           │                  │
│ │ Contanti                                € 1.000  │        │                                         │                  │
│ ╰──────────────────────────────────────────────────╯        │ Attività                   € 236.520    │                  │
│ ╭──────────────────────────────────────────────────╮        │ Passività                  −€ 52.000    │                  │
│ │ INVESTIMENTI                           € 132.000 │        │                                         │                  │
│ │ ETF                                    € 75.000  │        │ ╭─────────────────────────────────╮     │                  │
│ │ Azioni                                 € 32.000  │        │ │        Salva aggiornamento      │     │                  │
│ │ Obbligazioni                           € 20.000  │        │ ╰─────────────────────────────────╯     │                  │
│ │ Crypto                                  € 5.000  │        │                                         │                  │
│ ╰──────────────────────────────────────────────────╯        │ Tab: campo successivo · ⌘/Ctrl+S: salva │                  │
│ ╭──────────────────────────────────────────────────╮        │ Esc: chiudi                             │                  │
│ │ IMMOBILI  ·  PASSIVITÀ  (stessa struttura)       │        ╰─────────────────────────────────────────╯                  │
│ ╰──────────────────────────────────────────────────╯                                                                     │
│ + Aggiungi voce                                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

Modalità concentrata: la sidebar sparisce e restano solo le voci e il riepilogo, che resta fisso mentre si scorre.

### 8.6 Storico e dettaglio · smartphone

```
┌──────────────────────────────────────┐    ┌──────────────────────────────────┐
│ Storico                              │    │ ‹ Storico                     ⋯  │
│                                      │    │                                  │
│ Settembre 2026            € 184.520  │    │ Settembre 2026                   │
│                            ▲ +1,8%   │    │ € 184.520                        │
│ ──────────────────────────────────── │    │ ▲ +€ 3.240 · +1,8% vs agosto     │
│ Agosto 2026               € 181.280  │    │                                  │
│                            ▲ +1,3%   │    │ LIQUIDITÀ               € 24.520 │
│ ──────────────────────────────────── │    │ Conto corrente          € 15.520 │
│ Luglio 2026               € 178.900  │    │ Conto deposito           € 8.000 │
│                            ▲ +2,2%   │    │ Contanti                 € 1.000 │
│ ──────────────────────────────────── │    │                                  │
│ Giugno 2026               € 175.000  │    │ INVESTIMENTI           € 132.000 │
│                Primo aggiornamento   │    │ …                                │
├──────────────────────────────────────┤    │                                  │
│  Home  Patrimonio  Invest.  Storico  │    │ ╭──────────────────────────────╮ │
└──────────────────────────────────────┘    │ │        Modifica valori       │ │
                                            │ ╰──────────────────────────────╯ │
                                            │ (menu ⋯ : Elimina aggiornamento) │
                                            └──────────────────────────────────┘
```

### 8.7 Storico · desktop

```
┌──────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ◆ Patrimonio     │ Storico                                ╭──────────────────────────────────────────────────────╮  │
│                  │                                        │ Settembre 2026                        [Modifica]  ⋯  │  │
│   Dashboard      │ ▌Settembre 2026     € 184.520  +1,8%   │ € 184.520   ▲ +€ 3.240 · +1,8% vs agosto             │  │
│   Patrimonio     │  Agosto 2026        € 181.280  +1,3%   │                                                      │  │
│   Investimenti   │  Luglio 2026        € 178.900  +2,2%   │ LIQUIDITÀ                                  € 24.520  │  │
│ ▌ Storico        │  Giugno 2026        € 175.000     —    │ INVESTIMENTI                              € 132.000  │  │
│                  │                                        │ IMMOBILI                                   € 80.000  │  │
│                  │                                        │ PASSIVITÀ                                 −€ 52.000  │  │
│                  │                                        │ (ogni gruppo si espande nelle singole voci)          │  │
│                  │                                        ╰──────────────────────────────────────────────────────╯  │
└──────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 8.8 Investimenti · smartphone

```
┌────────────────────────────────────────┐
│ Investimenti                           │
│                                        │
│ Valore investimenti                    │
│ € 132.000                              │
│                                        │
│ ╭────────────────╮ ╭─────────────────╮ │
│ │ Questo mese    │ │ Ultimi 12 mesi  │ │
│ │ ▲ +€ 2.400     │ │ ▲ +€ 12.500     │ │
│ │ +1,85%         │ │ +10,5%          │ │
│ ╰────────────────╯ ╰─────────────────╯ │
│ ╭────────────────────────────────────╮ │
│ │ 3M   6M  [1A]  3A   Tutto          │ │
│ │                          ╭──●      │ │
│ │           ╭────╮  ╭─────╯          │ │
│ │   ───────╯    ╰──╯                 │ │
│ │ ott        feb       giu     set   │ │
│ ╰────────────────────────────────────╯ │
│ ╭────────────────────────────────────╮ │
│ │ Ripartizione                       │ │
│ │                                    │ │
│ │ ETF            € 75.000     57%    │ │
│ │ ██████████████████░░░░░░░░░░░░░    │ │
│ │ Azioni         € 32.000     24%    │ │
│ │ ████████░░░░░░░░░░░░░░░░░░░░░░░    │ │
│ │ Obbligazioni   € 20.000     15%    │ │
│ │ █████░░░░░░░░░░░░░░░░░░░░░░░░░░    │ │
│ │ Crypto          € 5.000      4%    │ │
│ │ █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░    │ │
│ ╰────────────────────────────────────╯ │
└────────────────────────────────────────┘
```

La ripartizione usa barre di un solo colore: è più leggibile di un secondo donut e non aggiunge colori.

### 8.9 Patrimonio · smartphone, con il pannello di modifica di una voce

```
┌──────────────────────────────────────────┐    ╭────────────────────────────────────────╮
│ Patrimonio                    Modifica   │    │ Modifica voce                          │
│ Valori dell'ultimo aggiornamento (set)   │    │                                        │
│                                          │    │ Nome          [ Conto corrente      ]  │
│ LIQUIDITÀ                    € 24.520    │    │ Categoria     [ Liquidità         ▾ ]  │
│   Conto corrente             € 15.520    │    │                                        │
│   Conto deposito              € 8.000    │    │ [ Archivia ]              [ Salva ]    │
│   Contanti                    € 1.000    │    │                                        │
│                                          │    │ Archiviare non cancella lo storico.    │
│ INVESTIMENTI  ◔             € 132.000    │    ╰────────────────────────────────────────╯
│   ETF                        € 75.000    │
│   …                                      │
│                                          │
│ PASSIVITÀ                   −€ 52.000    │
│   Mutuo                      € 50.000    │
│   Carta di credito            € 2.000    │
│                                          │
│ + Nuova voce      + Nuova categoria      │
│ Voci archiviate (2)                 ›    │
├──────────────────────────────────────────┤
│  Home   Patrimonio   Invest.   Storico   │
└──────────────────────────────────────────┘
```

In modalità **Modifica** compaiono le maniglie per riordinare voci e categorie.

### 8.10 Onboarding

```
┌──────────────────────────────┐  ┌──────────────────────────────┐  ┌──────────────────────────────┐
│                              │  │ Cosa possiedi?               │  │ Quanto vale oggi?            │
│          ◆                   │  │ Scegli le voci da seguire.   │  │ Settembre 2026               │
│                              │  │                              │  │                              │
│ Benvenuto                    │  │ LIQUIDITÀ                    │  │ Conto corrente   [ 12.500 ]  │
│                              │  │ [✓ Conto corrente]           │  │ ETF              [ 75.000 ]  │
│ Monitora il tuo patrimonio   │  │ [Conto deposito] [Contanti]  │  │ …                            │
│ aggiornandolo una volta      │  │ INVESTIMENTI                 │  │                              │
│ al mese.                     │  │ [✓ ETF] [Azioni] [Crypto]    │  │ Patrimonio netto             │
│                              │  │ [Obbligazioni] [Fondo pens]  │  │ € 87.500                     │
│                              │  │ IMMOBILI E BENI              │  │                              │
│ ╭──────────────────────────╮ │  │ [Casa] [Auto]                │  │                              │
│ │          Inizia          │ │  │ PASSIVITÀ                    │  │ ╭──────────────────────────╮ │
│ ╰──────────────────────────╯ │  │ [Mutuo] [Prestito] [Carta]   │  │ │   Salva e vai alla home  │ │
│ ● ○ ○        passo 1 di 3    │  │ + Aggiungi voce              │  │ ╰──────────────────────────╯ │
└──────────────────────────────┘  │                              │  └──────────────────────────────┘
                                  │ ╭──────────────────────────╮ │
                                  │ │         Continua         │ │
                                  │ ╰──────────────────────────╯ │
                                  └──────────────────────────────┘
```

Tre schermate e due decisioni: quali voci seguire e quanto valgono oggi. L'obiettivo è stare sotto i due minuti. Le voci suggerite sono raggruppate nelle categorie predefinite: Liquidità, Investimenti, Immobili, Altri beni e Debiti. Tutto si può rinominare in seguito.

### 8.11 Login e primo avvio senza dati

```
┌──────────────────────────────────────┐    ┌──────────────────────────────────────┐
│                                      │    │ Ciao, Pietro                [avatar] │
│          ◆ Patrimonio                │    │                                      │
│                                      │    │                                      │
│ Accedi                               │    │                                      │
│                                      │    │                                      │
│ Email      [                     ]   │    │ Non hai ancora nessun aggiornamento. │
│ Password   [                     ]   │    │                                      │
│                Password dimenticata? │    │ Inserisci i valori di oggi: da qui   │
│                                      │    │ in poi vedrai crescere il grafico.   │
│ ╭──────────────────────────────────╮ │    │                                      │
│ │              Accedi              │ │    │ ╭──────────────────────────────────╮ │
│ ╰──────────────────────────────────╯ │    │ │  + Inserisci il primo patrimonio │ │
│                                      │    │ ╰──────────────────────────────────╯ │
│ Non hai un account?   Registrati     │    │                                      │
│                                      │    │                                      │
│          Prova la demo  →            │    ├──────────────────────────────────────┤
└──────────────────────────────────────┘    │  Home  Patrimonio  Invest.  Storico  │
                                            └──────────────────────────────────────┘
```

### 8.12 Modalità demo

```
┌──────────────────────────────────────────────────────────┐
│ ◇ Modalità demo · dati di esempio, non salvati   Esci ›  │
└──────────────────────────────────────────────────────────┘
```

Il banner resta visibile in ogni schermata: in alto su smartphone, in cima al contenuto su desktop. La demo contiene 24 mesi di dati; gli ultimi 12 seguono l'andamento indicato nella specifica, da 145.000 € a 180.000 €. Le modifiche fatte in demo restano in memoria e si perdono uscendo.

### 8.13 Caricamento ed errori

- **Caricamento:** skeleton con la forma di numero principale, grafico e card. Mai una pagina bianca.
- **Senza connessione:** "Non riesco a collegarmi. Controlla la connessione e riprova." con il bottone **Riprova**.
- **Salvataggio fallito:** i valori restano nel form e compare "Salvataggio non riuscito. I tuoi dati sono ancora qui: riprova."
- **Mese già presente:** "Settembre ha già un aggiornamento." con il bottone **Modificalo**.
- **Sessione scaduta:** ritorno al login con "La sessione è scaduta. Accedi di nuovo."
- **Dato non valido:** il messaggio compare sotto il campo, per esempio "Usa al massimo due decimali."

Nessun messaggio mostra dettagli tecnici. I dettagli finiscono solo nei log di sviluppo, mai con importi.

---

## 9. Dipendenze

Versioni verificate su pub.dev il 25/09/2026, nell'ipotesi che la decisione D1 sia approvata.

| Pacchetto | Versione | Licenza | A cosa serve | Note |
|---|---|---|---|---|
| supabase_flutter | ^2.17.2 | MIT | Auth, database, sessione persistente, deep link | Pubblicato il 14/08/2026, 150/160 punti pub, pronto per WASM |
| flutter_riverpod | ^3.4.3 | MIT | Stato | Pubblicato il 03/09/2026. Richiede Dart 3.12 |
| go_router | ^18.0.1 | BSD-3 | Navigazione | Mantenuto dal team Flutter. Richiede Flutter 3.44 |
| fl_chart | ^1.2.0 | MIT | Grafici a linee, donut, barre, con tooltip e animazioni | Oltre 7.000 like, repository attivo, ultimo commit il 19/09/2026 |
| intl | versione fissata da Flutter | BSD-3 | Formati italiani di numeri, valute, date | Team Dart |
| flutter_localizations | SDK | BSD-3 | Traduzione dei widget Material | Incluso in Flutter |
| freezed_annotation | ^3.1.0 | MIT | Annotazioni dei modelli | |
| json_annotation | ^4.12.0 | BSD-3 | Annotazioni JSON | Team Dart |
| shared_preferences | ^2.5.5 | BSD-3 | Preferenza del tema | Team Flutter. Già usato da supabase_flutter |

Solo per lo sviluppo:

| Pacchetto | Versione | Licenza | A cosa serve |
|---|---|---|---|
| freezed | ^4.0.2 | MIT | Genera `copyWith`, uguaglianza e JSON dei modelli. Richiede Dart 3.13 |
| json_serializable | ^6.14.1 | BSD-3 | Genera la conversione JSON |
| build_runner | ^2.16.1 | BSD-3 | Esegue la generazione di codice |
| flutter_lints | ^6.0.0 | BSD-3 | Regole di analisi statica ufficiali |
| mocktail | ^1.0.5 | MIT | Repository finti nei test |
| flutter_test, integration_test | SDK | BSD-3 | Test |

**Senza la decisione D1**, cioè restando su Flutter 3.41.6: flutter_riverpod ^3.3.2, go_router ^17.5.0 e freezed ^3.2.5. Le prime due sono la combinazione già compilata con successo nella build di prova.

**Fuori da pub.dev:** il font Inter, incluso negli asset; la Supabase CLI via Homebrew; Docker Desktop oppure OrbStack solo se si sceglie la prima opzione di D12.

**Da valutare più avanti:** flutter_secure_storage (BSD-3, versione 11.2.0) per salvare la sessione nel Keychain di iOS e nel Keystore di Android. Vedi la sezione 11.2.

**Scartate.**

| Pacchetto | Motivo |
|---|---|
| syncfusion_flutter_charts | Licenza commerciale con limiti di fatturato |
| google_fonts | Scarica i font dai server Google mentre l'app è in uso: invia dati a terzi e dipende dalla rete |
| flutter_dotenv | Il file `.env` finirebbe comunque dentro l'app. `--dart-define-from-file` è già integrato in Flutter |
| decimal | Non serve: interi in centesimi e divisione intera coprono tutti i calcoli |
| riverpod_generator | Aggiunge generazione di codice ai provider senza un vantaggio reale per un progetto di queste dimensioni |
| skeletonizer | Libreria valida, ma uno skeleton su misura sono poche decine di righe e usa direttamente i token |

---

## 10. Piano delle milestone

| # | Milestone | Contenuto | Come si verifica |
|---|---|---|---|
| 1 | Architettura | Questo documento | La tua approvazione |
| 2 | Setup | Aggiornamento di Flutter (D1). Repository git dedicato. Progetto Flutter per iOS, Android e Web con il bundle id scelto. Lint, struttura cartelle, token, temi chiaro e scuro. Shell adattiva con le quattro sezioni vuote, router, testi in italiano. Supabase inizializzato dalla configurazione. Verifica dello stack nel browser, anche in WASM | L'app si avvia su simulatore iOS, emulatore Android e Chrome. Navigazione e cambio tema funzionano. `flutter analyze` senza segnalazioni |
| 3 | Autenticazione | Tabella `profiles` e trigger. Login, registrazione, conferma email, recupero e reset password con deep link. Redirect, sessione persistente, logout. Profilo con il nome. Elimina account (D7) | Flusso completo sulle tre piattaforme. Test del controller di autenticazione e del redirect |
| 4 | Database | Migrazioni complete, RLS, funzioni. Test delle policy (D12). Modelli, Money, YearMonth, calcoli. Repository Supabase e demo | Test unitari di tutti i calcoli e test delle policy verdi |
| 5 | Patrimonio | Categorie e voci: creazione, rinomina, riordino, archiviazione, eliminazione. Schermata Patrimonio. Onboarding, passi 1 e 2 | Test dei controller e widget test della schermata |
| 6 | Aggiornamenti mensili | Form nuovo e modifica con totale in tempo reale. Salvataggio atomico. Storico, dettaglio, eliminazione. Onboarding, passo 3. Promemoria | Test di primo aggiornamento, modifica senza effetti sui mesi successivi, valori a zero |
| 7 | Dashboard | Patrimonio netto, variazioni, card delle categorie, grafico con filtro, donut, promemoria, stati vuoti. Modalità demo dal login | Widget test di caricamento, vuoto, dati ed errore |
| 8 | Investimenti | Valore, variazione mensile e annuale, grafico storico, ripartizione | Test dei calcoli annuali e widget test |
| 9 | Responsive | Rifinitura di tablet e desktop, elenco e dettaglio affiancati, scorciatoie da tastiera, hover | Prova su smartphone, tablet e browser a varie larghezze |
| 10 | Rifinitura | Animazioni, skeleton, stati di errore, tema scuro, accessibilità, performance con dieci anni di dati demo, sessione sicura su mobile | Profilo di performance e controllo di accessibilità |

A fine milestone: analisi statica pulita, test verdi e un breve riepilogo. Propongo di fermarmi per la tua conferma alla fine di ogni milestone. Se preferisci, posso proseguire senza fermarmi dove non servono decisioni.

---

## 11. Test, sicurezza, performance, estendibilità

### 11.1 Test

| Requisito della specifica | Cosa si prova | Tipo | Milestone |
|---|---|---|---|
| Calcolo del patrimonio netto | Somme di attività e passività, netto negativo | Unitario | 4 |
| Variazione assoluta | Differenza tra mesi consecutivi e non consecutivi | Unitario | 4 |
| Variazione percentuale | Arrotondamenti, precedente negativo, valori grandi | Unitario | 4 |
| Primo snapshot | Nessuna variazione, etichetta "Primo aggiornamento" | Unitario | 4 |
| Snapshot senza precedente | Mesi mancanti, confronto con l'ultimo disponibile | Unitario | 4 |
| Gestione del valore zero | Precedente a zero, lordo a zero, campo vuoto | Unitario | 4 |
| Lettura degli importi | Tutti i casi della tabella 4.4 | Unitario | 4 |
| Modifica snapshot | Cambiano lo snapshot e la variazione del mese dopo, non i suoi dati | Unitario e database | 6 |
| Autenticazione | Login riuscito e fallito, sessione scaduta, redirect | Unitario | 3 |
| Accesso ai dati | Un utente non può leggere, creare, modificare o cancellare i dati di un altro, né collegarsi alle sue categorie | Database | 4 |
| Schermate principali | Dashboard, form mensile, storico, investimenti, login | Widget | 3–8 |

### 11.2 Sicurezza e privacy

- **Database:** RLS su ogni tabella e chiavi esterne composte. Le funzioni girano con i permessi dell'utente, tranne due che ne hanno bisogno: la creazione del profilo e l'eliminazione dell'account. Entrambe hanno `search_path` vuoto.
- **Chiavi:** nel client solo la chiave pubblica. I file di configurazione sono esclusi da git.
- **Memoria:** al logout la cache viene svuotata.
- **Log:** nessun importo in log, report di crash o statistiche d'uso. L'MVP non ha statistiche d'uso.
- **Terze parti:** font inclusi nell'app, nessuna richiesta a server esterni oltre Supabase.
- **Sessione su dispositivo:** supabase_flutter la salva nelle preferenze dell'app; sul web, nel localStorage del browser. Su iOS e Android propongo di spostarla nel Keychain e nel Keystore con flutter_secure_storage, nella Milestone 10.
- **Account:** password di almeno 8 caratteri, impostata in Supabase. I messaggi di login e di recupero non rivelano se un'email è registrata.

### 11.3 Performance

- Al massimo due richieste all'avvio, cache per tutta la sessione, ricalcoli solo quando i dati cambiano.
- I punti dei grafici si calcolano nei provider, non durante il disegno.
- `RepaintBoundary` attorno ai grafici, widget `const`, elenchi costruiti in modo pigro.
- Prova con dieci anni di dati demo nella Milestone 10.
- **Web:** il primo caricamento di un'app Flutter pesa più di un sito tradizionale. Nella build di prova il solo codice dell'app era di circa 2,4 MB in JavaScript o 2 MB in WASM, non compressi, più il motore grafico. Dalla seconda apertura tutto è in cache. Mitigazioni: schermata di caricamento leggera in `index.html`, compressione lato hosting, build WASM se la prova nel browser la conferma.

### 11.4 Estendibilità

| Funzione futura | Dove si innesta |
|---|---|
| Export CSV, Excel, PDF | Funzioni pure sull'elenco degli snapshot, in `shared/services/export/`. Nessuna modifica al database |
| Import CSV ed Excel | Produce la stessa bozza del form mensile e usa `save_snapshot` |
| Collegamento a banche e broker | Un servizio che produce valori per le voci. Una colonna `source` su `snapshot_items` distinguerà manuale, importato e sincronizzato |
| Più valute | La colonna `currency` esiste già su profilo e snapshot |
| Notifiche push | La logica del promemoria è già in un provider; si aggiunge il canale |
| Budget, entrate e spese, obiettivi | Nuove cartelle in `features/` e nuove tabelle, con lo stesso schema |
| Rendimento, dividendi, benchmark | Nuovi calcoli puri sugli stessi dati, più eventuali tabelle dedicate |
| Patrimonio familiare, più profili | È la modifica più profonda: serve un livello "portafoglio" tra utente e dati. Non conviene prepararlo ora; una migrazione successiva è fattibile |

---

## 12. Problemi identificati e rischi

| # | Problema | Proposta |
|---|---|---|
| P1 | **La tua home è un repository git.** `/Users/pietro` contiene un repository con un vecchio progetto Java, con file segnati come cancellati. Senza un repository dedicato, i file dell'app finirebbero lì dentro | Creare un repository nella cartella del progetto (D11). Non tocco il repository della home: valuta tu se è voluto |
| P2 | **Flutter non aggiornato.** Le versioni correnti di Riverpod, go_router e freezed non si installano sulla 3.41.6 | Aggiornare a 3.47.5 (D1) |
| P3 | **Doppio inserimento degli investimenti** con le tabelle `investment_categories` e `investment_snapshots` | Ricavare gli investimenti dagli snapshot (D2) |
| P4 | **Crypto ambigua.** Nel donut di esempio è una categoria a sé; nel form e negli investimenti è una voce di Investimenti | Voce di Investimenti come predefinito (D3) |
| P5 | **Categoria o voce?** La sezione 13 chiama "categorie" esempi come Conto corrente ed ETF, che nel resto della specifica sono voci | Due livelli espliciti: categorie e voci, entrambe personalizzabili (sezione 4.1) |
| P6 | **Data dello snapshot.** La specifica mostra "30 giugno", ma l'aggiornamento è mensile | Si salva il mese; si mostra "Giugno 2026" |
| P7 | **Conti dell'esempio.** Nella sezione 10 le voci sommano a 203.500 €, non a 193.500 € | Nessuna azione: l'app calcola da sola. I wireframe usano numeri coerenti |
| P8 | **Eliminazione dell'account.** Apple la richiede alle app con registrazione | Includerla (D7) |
| P9 | **Primo caricamento sul web** più lento di un sito tradizionale | Mitigazioni in 11.3 |
| P10 | **Riverpod segnalato come non compatibile con il web** su pub.dev | La compilazione funziona; verifica in esecuzione nella Milestone 2 |
| P11 | **Cambiare il flag "investimento" di una categoria** vale solo dai mesi successivi, per il principio della fotografia. Il grafico degli investimenti potrebbe fare un salto | Accettabile per l'MVP. In futuro, un'opzione "applica anche allo storico" |
| P12 | **Link nelle email.** Conferma e reset richiedono bundle id e dominio web, che non esistono ancora | In sviluppo si usano localhost e lo schema dell'app. Il dominio si sceglie con l'hosting, verso la Milestone 9 |
| P13 | **Piano gratuito Supabase.** I progetti gratuiti vengono messi in pausa dopo una settimana senza attività | Nessun problema in sviluppo. Per l'uso reale serve il piano a pagamento o un uso regolare |
| P14 | **Offline.** Non richiesto e non previsto nell'MVP | Se il salvataggio fallisce, i valori restano nel form e si può riprovare |

---

## 13. Stato dell'implementazione

Le milestone dalla 2 alla 10 sono state implementate il 25 settembre 2026. Le decisioni D1–D12 sono state applicate con le proposte del piano.

### 13.1 Differenze rispetto al piano

| Tema | Piano | Implementazione | Motivo |
|---|---|---|---|
| SDK Flutter (D1) | Aggiornare `~/flutter` | Prima una SDK dedicata 3.47.5; il 27/09 `~/flutter` è stata aggiornata alla 3.47.5 e il progetto usa quella | Riverpod 3.3, l'unico compatibile con la 3.41, ha un difetto (`markNeedsBuild` durante il build) corretto nella 3.4.2. Una modifica locale di giugno a `~/flutter` (per iCloud) è stata salvata con `git stash` prima dell'aggiornamento |
| Cartella `build` | Nel progetto | Collegamento a `/Users/pietro/development/patrimonio-build` | La Scrivania è sincronizzata con iCloud e gli attributi aggiunti da iCloud impediscono la firma delle build iOS |
| Modelli | freezed e json_serializable | Solo freezed; la conversione JSON sta nei repository Supabase | Il formato del database resta confinato nel livello dati; una dipendenza in meno |
| Composizione | Router in `core/router` | Percorsi e redirect in `core/router`; router e shell in `lib/app` | `core` non deve importare le feature |
| Controller di autenticazione | In `features/auth` | In `shared/providers` | È usato da più feature: login, impostazioni, sidebar |
| Codici d'errore | Categoria con voci: 23503 | 23001 oppure 23503 | Scoperto dai test del database: le versioni recenti di PostgreSQL usano 23001 per `RESTRICT` |
| Configurazione di Supabase | Solo da `--dart-define-from-file=env/dev.json` | URL e chiave pubblica nel codice (`lib/core/config/supabase_project.dart`) come valori predefiniti; il file resta possibile per usare un altro progetto. Porta web fissa a 3000 in `web_dev_config.yaml` | Richiesta tua: `flutter run` e `flutter build web` devono essere già collegati. La chiave pubblica è pensata per stare nel client; la chiave segreta resta fuori |
| Voci rinominate | Lo storico conserva i nomi di allora | Confermato per i mesi passati; l'ultimo aggiornamento, la pagina Investimenti e il form del mese nuovo usano i nomi attuali | Rinominare "ETF" in "Conto Fineco" non compariva nell'aggiornamento in corso |
| Mesi senza valori | Non previsto | Un mese salvato con tutti gli importi a zero vale come "non ancora aggiornato": escluso da dashboard, grafici, variazioni e storico; il suo form propone gli ultimi valori veri e il salvataggio sovrascrive lo stesso mese. Non si può più salvare un aggiornamento tutto a zero | Un onboarding chiuso senza importi faceva risultare €0 e −100% |
| Sessione scaduta | Messaggio al login | Implementato distinguendo l'uscita volontaria da quella non richiesta | Come da piano, sezione 6.3 |

### 13.2 Verifiche eseguite

| Verifica | Esito |
|---|---|
| `flutter analyze` | Nessuna segnalazione |
| `flutter test` | 140 test superati: importi, percentuali, parsing, calcoli, redirect, dataset demo, controller, sessione, errori, schermate, testo al 150% e al 200% |
| Test pgTAP del database | 31 su 31, eseguiti su PostgreSQL 17 in memoria (PGlite) con un ambiente che imita Supabase |
| Build web | JavaScript e WebAssembly |
| Build Android | APK di debug, senza avvisi con i modelli Gradle di Flutter 3.47 |
| Build iOS | App per simulatore, avviata su iPhone 16 |
| Controllo visivo | Smartphone, tablet e desktop, tema chiaro e scuro, in modalità demo |

### 13.3 Non ancora verificato

- **Flussi reali con Supabase:** registrazione, email di conferma, login, reset password e salvataggi richiedono un progetto Supabase configurato.
- **Test pgTAP sulla piattaforma reale:** vanno rieseguiti con `supabase test db`. In particolare `delete_my_account` dipende dai permessi del ruolo `postgres` sullo schema `auth`.
- **Dispositivi fisici:** l'app non è stata provata su un iPhone o un telefono Android reali; su questa macchina non c'è un emulatore Android.

