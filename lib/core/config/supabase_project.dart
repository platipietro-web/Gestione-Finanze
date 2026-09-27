/// Progetto Supabase a cui l'app si collega di default, in sviluppo e in
/// produzione.
///
/// URL e chiave pubblica (publishable key) sono fatti per stare nel client:
/// finiscono comunque nel pacchetto web pubblicato. I dati sono protetti
/// dalle policy Row Level Security del database, non dalla segretezza di
/// questi valori.
///
/// Qui non va MAI la chiave segreta (secret key / service_role), né la
/// password del database: scavalcherebbero tutte le policy.
abstract final class SupabaseProject {
  static const url = 'https://xbubelflhmeyusydgtdt.supabase.co';
  static const publishableKey = 'sb_publishable_KPbBqRpx_Rout-MKWfm8nw_l2wcPAs-';
}
