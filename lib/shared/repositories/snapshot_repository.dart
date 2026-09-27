import '../models/snapshot.dart';

abstract interface class SnapshotRepository {
  /// Tutto lo storico con le righe, dal mese più vecchio.
  Future<List<Snapshot>> fetchAll();

  Future<Snapshot> fetch(String id);

  /// Salva in modo atomico un aggiornamento nuovo o modificato e ne
  /// restituisce l'id. Tocca solo quell'aggiornamento.
  Future<String> save(SnapshotDraft draft);

  Future<void> delete(String id);
}
