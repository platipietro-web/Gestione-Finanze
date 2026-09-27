import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/theme/theme_mode_controller.dart';

/// Avvio: configurazione, Supabase (se configurato), preferenze e app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // URL senza "#" sul web: /storico invece di /#/storico.
  usePathUrlStrategy();

  final config = AppConfig.fromEnvironment();
  final preferences = await SharedPreferences.getInstance();

  if (config.isSupabaseConfigured) {
    // supabase_flutter usa di default il flusso PKCE e salva la sessione
    // in modo persistente, rinnovandola da solo.
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabaseKey,
    );
  }

  // Gli errori non gestiti non mostrano mai dettagli tecnici all'utente;
  // in sviluppo finiscono nella console.
  FlutterError.onError = (details) {
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) debugPrint('Errore non gestito: $error\n$stack');
    return true;
  };

  runApp(
    ProviderScope(
      // Nessun nuovo tentativo automatico: gli errori mostrano "Riprova".
      retry: (retryCount, error) => null,
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const PatrimonioApp(),
    ),
  );
}
