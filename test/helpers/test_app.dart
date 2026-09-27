import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/app/app.dart';
import 'package:patrimonio/core/config/app_config.dart';
import 'package:patrimonio/core/l10n/l10n.dart';
import 'package:patrimonio/core/theme/app_theme.dart';
import 'package:patrimonio/core/theme/theme_mode_controller.dart';
import 'package:patrimonio/shared/models/profile.dart';
import 'package:patrimonio/shared/providers/app_mode.dart';
import 'package:patrimonio/shared/providers/repository_providers.dart';
import 'package:patrimonio/shared/repositories/demo/demo_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data fissa dei test: settembre 2026. I dati demo arrivano ad agosto.
final testNow = DateTime(2026, 9, 25, 10);

const unconfigured = AppConfig(supabaseUrl: '', supabaseKey: '');

class StartInDemo extends AppModeController {
  @override
  AppMode build() => AppMode.demo;
}

DemoStore emptyStore({bool onboarded = true}) => DemoStore(
  categories: const [],
  items: const [],
  snapshots: const [],
  profile: Profile(id: 'demo', onboardingCompleted: onboarded),
);

List<Override> baseOverrides({
  bool demo = true,
  DemoStore? store,
  Duration latency = Duration.zero,
}) => [
  appConfigProvider.overrideWithValue(unconfigured),
  clockProvider.overrideWithValue(() => testNow),
  demoLatencyProvider.overrideWithValue(latency),
  if (demo) appModeProvider.overrideWith(StartInDemo.new),
  if (store != null) demoStoreProvider.overrideWithValue(store),
];

/// Container per i test unitari, in modalità demo senza attese.
ProviderContainer makeContainer({
  DemoStore? store,
  bool demo = true,
  List<Override> overrides = const [],
}) => ProviderContainer.test(
  retry: (retryCount, error) => null,
  overrides: [
    ...baseOverrides(demo: demo, store: store),
    ...overrides,
  ],
);

void setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

const phone = Size(390, 844);
const desktop = Size(1440, 900);

/// Avvia l'app completa (router compreso).
Future<void> pumpApp(
  WidgetTester tester, {
  bool demo = true,
  DemoStore? store,
  List<Override> overrides = const [],
  Size size = phone,
  bool settle = true,
  Duration latency = Duration.zero,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  setViewSize(tester, size);
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        ...baseOverrides(demo: demo, store: store, latency: latency),
        ...overrides,
      ],
      child: const PatrimonioApp(),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

/// Monta un singolo widget con tema e localizzazione.
Future<void> pumpWidgetInApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  DemoStore? store,
  Size size = phone,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  setViewSize(tester, size);
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        ...baseOverrides(store: store),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
