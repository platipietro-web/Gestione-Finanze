import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_project.dart';

/// Configurazione dell'app.
///
/// Di default l'app è collegata al progetto in [SupabaseProject]: basta
/// `flutter run` o `flutter build web`. Per usare un altro progetto, per
/// esempio uno di prova, si possono sovrascrivere i valori con
/// `--dart-define-from-file=env/<nome>.json` (vedi `env/example.json`).
///
/// Nel client esiste solo la chiave pubblica di Supabase: i dati sono
/// protetti dalle policy Row Level Security del database.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseKey});

  factory AppConfig.fromEnvironment() => const AppConfig(
    supabaseUrl: String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: SupabaseProject.url,
    ),
    supabaseKey: String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: SupabaseProject.publishableKey,
    ),
  );

  final String supabaseUrl;
  final String supabaseKey;

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// Schema usato dai link delle email (conferma e reset) su iOS e Android.
  static const mobileScheme = 'it.pietroplati.patrimonio';
  static const mobileAuthCallback = '$mobileScheme://auth-callback';
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
