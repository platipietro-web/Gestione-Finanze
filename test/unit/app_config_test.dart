import 'package:flutter_test/flutter_test.dart';
import 'package:patrimonio/core/config/app_config.dart';
import 'package:patrimonio/core/config/supabase_project.dart';

void main() {
  test('senza opzioni l\'app è già collegata al progetto Supabase', () {
    final config = AppConfig.fromEnvironment();
    expect(config.isSupabaseConfigured, isTrue);
    expect(config.supabaseUrl, SupabaseProject.url);
    expect(config.supabaseKey, SupabaseProject.publishableKey);
  });

  test('nel client c\'è solo la chiave pubblica', () {
    expect(SupabaseProject.publishableKey, startsWith('sb_publishable_'));
    expect(SupabaseProject.url, startsWith('https://'));
    expect(SupabaseProject.url, isNot(contains('/rest/v1')));
  });
}
