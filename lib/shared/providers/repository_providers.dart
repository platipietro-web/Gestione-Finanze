import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_failure.dart';
import '../../core/time/year_month.dart';
import '../repositories/auth_repository.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/demo/demo_dataset.dart';
import '../repositories/demo/demo_repositories.dart';
import '../repositories/demo/demo_store.dart';
import '../repositories/profile_repository.dart';
import '../repositories/snapshot_repository.dart';
import '../repositories/supabase/supabase_auth_repository.dart';
import '../repositories/supabase/supabase_catalog_repository.dart';
import '../repositories/supabase/supabase_profile_repository.dart';
import '../repositories/supabase/supabase_snapshot_repository.dart';
import 'app_mode.dart';

/// Ora corrente, sostituibile nei test.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final currentMonthProvider = Provider<YearMonth>(
  (ref) => YearMonth.fromDate(ref.watch(clockProvider)()),
);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!ref.watch(appConfigProvider).isSupabaseConfigured) {
    throw const AppFailure(FailureKind.notConfigured);
  }
  return Supabase.instance.client;
});

/// Dati della demo; ricreati a ogni nuovo ingresso nella demo.
final demoStoreProvider = Provider<DemoStore>(
  (ref) => DemoDataset.build(ref.read(currentMonthProvider)),
);

/// Attesa simulata della demo (zero nei test).
final demoLatencyProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 350),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (!ref.watch(appConfigProvider).isSupabaseConfigured) {
    return const UnavailableAuthRepository();
  }
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

bool _isDemo(Ref ref) => ref.watch(appModeProvider) == AppMode.demo;

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (_isDemo(ref)) {
    return DemoProfileRepository(
      ref.watch(demoStoreProvider),
      ref.watch(demoLatencyProvider),
    );
  }
  return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  if (_isDemo(ref)) {
    return DemoCatalogRepository(
      ref.watch(demoStoreProvider),
      ref.watch(demoLatencyProvider),
    );
  }
  return SupabaseCatalogRepository(ref.watch(supabaseClientProvider));
});

final snapshotRepositoryProvider = Provider<SnapshotRepository>((ref) {
  if (_isDemo(ref)) {
    return DemoSnapshotRepository(
      ref.watch(demoStoreProvider),
      ref.watch(demoLatencyProvider),
    );
  }
  return SupabaseSnapshotRepository(ref.watch(supabaseClientProvider));
});
