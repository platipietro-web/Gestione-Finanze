import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/snapshot.dart';
import '../repositories/snapshot_repository.dart';
import '../services/wealth_calculator.dart';
import 'repository_providers.dart';
import 'session_providers.dart';

final snapshotsProvider =
    AsyncNotifierProvider<SnapshotsController, List<Snapshot>>(
      SnapshotsController.new,
    );

/// Tutto lo storico, caricato una volta per sessione.
class SnapshotsController extends AsyncNotifier<List<Snapshot>> {
  @override
  Future<List<Snapshot>> build() async {
    final scope = ref.watch(dataScopeProvider);
    if (scope == null) return const [];
    final snapshots = await ref.watch(snapshotRepositoryProvider).fetchAll();
    return _sorted(snapshots);
  }

  SnapshotRepository get _repository => ref.read(snapshotRepositoryProvider);

  /// Salva e rilegge solo l'aggiornamento salvato. Dashboard, grafici e
  /// storico si ricalcolano da soli perché derivano da questo provider.
  Future<Snapshot> save(SnapshotDraft draft) async {
    final id = await _repository.save(draft);
    final saved = await _repository.fetch(id);
    final current = state.value ?? const [];
    state = AsyncData(
      _sorted([
        for (final s in current)
          if (s.id != saved.id) s,
        saved,
      ]),
    );
    return saved;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    final current = state.value ?? const [];
    state = AsyncData([
      for (final s in current)
        if (s.id != id) s,
    ]);
  }

  static List<Snapshot> _sorted(Iterable<Snapshot> snapshots) =>
      [...snapshots]..sort((a, b) => a.month.compareTo(b.month));
}

/// Totali e variazioni di ogni mese, calcolati una sola volta per versione
/// dello storico.
final timelineProvider = Provider<AsyncValue<Timeline>>(
  (ref) => ref.watch(snapshotsProvider).whenData(WealthCalculator.timeline),
);

final updateReminderProvider = Provider<bool>((ref) {
  final timeline = ref.watch(timelineProvider).value;
  if (timeline == null) return false;
  return WealthCalculator.needsReminder(
    timeline,
    ref.watch(currentMonthProvider),
  );
});
