# Patrimonio

App multipiattaforma (iOS, Android, Web) per monitorare il proprio patrimonio:
una volta al mese si inseriscono i valori, l'app calcola patrimonio netto,
variazioni, grafici, distribuzione e investimenti.

- **App:** Flutter 3.47 · Material 3 · Riverpod 3 · go_router · fl_chart
- **Backend:** Supabase (Auth, PostgreSQL, Row Level Security)
- **Architettura e decisioni:** [docs/ARCHITETTURA.md](docs/ARCHITETTURA.md)

---

## 1. Requisiti

Serve **Flutter 3.44 o successivo**: Riverpod 3.4 e go_router 18 richiedono
Dart 3.12. La Flutter globale in `~/flutter` è aggiornata alla 3.47.5, quindi
basta il comando `flutter`.

### Progetto sulla Scrivania sincronizzata con iCloud

iCloud aggiunge attributi ai file compilati e la firma delle build iOS
fallisce. Per questo `build` è un collegamento a
`/Users/pietro/development/patrimonio-build`, fuori da iCloud. Dopo un
`flutter clean` ricrealo con:

```bash
./tool/link_build_dir.sh
```

## 2. Avviare l'app

L'app è **già collegata** al progetto Supabase: URL e chiave pubblica sono in
[lib/core/config/supabase_project.dart](lib/core/config/supabase_project.dart).
Non servono opzioni:

```bash
flutter pub get
flutter run                     # chiede su quale dispositivo avviarla
flutter run -d chrome           # web, sempre sulla porta 3000
```

La porta 3000 è fissata in `web_dev_config.yaml`: è quella registrata negli
URL di redirect di Supabase, così i link delle email di conferma e di reset
tornano all'app.

In VS Code: configurazione **Patrimonio** o **Patrimonio web**, poi F5.

Dal login, **Prova la demo** apre 24 mesi di dati di esempio, in memoria e mai
salvati.

### Usare un altro progetto Supabase

Per esempio un progetto di prova: copia `env/example.json` in
`env/<nome>.json` (escluso da git), inserisci URL e chiave pubblica e avvia
con `--dart-define-from-file=env/<nome>.json`.

**Nell'app va solo la chiave pubblica** (`sb_publishable_...`). La chiave
segreta e la password del database non devono mai finire nel codice.

## 3. Configurazione di Supabase (già fatta)

1. **Migrazioni** in `supabase/migrations/`, eseguite in ordine nell'SQL
   Editor della dashboard, oppure con la Supabase CLI:
   ```bash
   supabase init
   supabase link --project-ref xbubelflhmeyusydgtdt
   supabase db push
   ```
2. **Autenticazione** (Dashboard → Authentication):
   - *Email*: conferma email attiva, lunghezza minima password 8.
   - *URL Configuration → Site URL*: in sviluppo `http://localhost:3000`.
   - *Redirect URLs*: `http://localhost:3000/**` e
     `it.pietroplati.patrimonio://auth-callback`.
3. **Email**: il servizio incluso in Supabase invia solo agli indirizzi del
   team del progetto e poche email all'ora. Prima di aprire l'app ad altre
   persone configura un servizio SMTP in Authentication → Emails.

## 4. Test

```bash
flutter analyze
flutter test                    # 140 test: calcoli, controller, schermate, accessibilità
```

Test del database (policy RLS e funzioni), con Docker Desktop o OrbStack:

```bash
supabase start
supabase test db                # supabase/tests/database/rls.test.sql
```

I test SQL verificano che un utente non possa leggere, creare, modificare o
cancellare dati altrui, che lo storico non cambi rinominando o eliminando una
voce, che correggere un mese non tocchi gli altri e che l'eliminazione
dell'account cancelli tutto.

## 5. Build e pubblicazione

```bash
flutter build web --release             # oppure --wasm per WebAssembly
flutter build appbundle                 # Android
flutter build ipa                       # iOS, serve un account sviluppatore Apple
```

Le build sono già collegate al database, senza opzioni.

**GitHub Pages.** Ogni push sul ramo `Develop` avvia
`.github/workflows/deploy.yml`: analisi, test, build web e pubblicazione su
<https://platipietro-web.github.io/Gestione-Finanze/>. Se i test falliscono, il
sito non viene aggiornato. L'avanzamento si vede nella scheda **Actions** del
repository. Configurazione una tantum su GitHub:
1. Settings → Pages → Build and deployment → Source: **GitHub Actions**.
2. Settings → Environments → github-pages → Deployment branches and tags:
   aggiungi il ramo **Develop**.

Il sito vive nella sottocartella `/Gestione-Finanze/`: il workflow imposta il
base href e copia `index.html` in `404.html`, così anche i link diretti e
quelli delle email aprono l'app.

**Prima di pubblicare il sito web**, in Supabase → Authentication → URL
Configuration:
- imposta come *Site URL* l'indirizzo pubblico, per esempio
  `https://platipietro-web.github.io/Gestione-Finanze/`;
- aggiungi ai *Redirect URLs* `https://platipietro-web.github.io/Gestione-Finanze/**`,
  lasciando anche quelli di sviluppo.

**Hosting web:** qualsiasi hosting statico (Cloudflare Pages, Netlify, Vercel,
Firebase Hosting). Tutti i percorsi devono rispondere con `index.html`
(regola "SPA"), perché l'app usa URL come `/storico` senza `#`.

**Supabase in produzione:** i progetti gratuiti vanno in pausa dopo una
settimana senza attività; per l'uso reale serve un piano a pagamento o un
uso regolare.

## 6. Struttura

```
lib/
  app/        composizione: MaterialApp, router, shell di navigazione
  core/       configurazione, tema e token, layout, importi, mesi, errori, testi
  shared/     modelli, repository (Supabase e demo), calcoli, provider, widget comuni
  features/   auth, onboarding, dashboard, assets (Patrimonio), monthly_update,
              investments, history, settings
supabase/     migrazioni SQL e test pgTAP
test/         test unitari e widget test
```

Rigenerare il codice dei modelli (freezed) e dei testi dopo una modifica:

```bash
/Users/pietro/development/flutter-3.47.5/bin/dart run build_runner build --delete-conflicting-outputs
$FLUTTER gen-l10n
```
