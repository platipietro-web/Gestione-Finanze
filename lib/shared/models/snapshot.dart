import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/money/money.dart';
import '../../core/time/year_month.dart';
import 'item_kind.dart';

part 'snapshot.freezed.dart';

/// Aggiornamento mensile: la fotografia del patrimonio in un mese.
@freezed
abstract class Snapshot with _$Snapshot {
  const factory Snapshot({
    required String id,
    required YearMonth month,
    required List<SnapshotItem> items,
    DateTime? updatedAt,
  }) = _Snapshot;
}

/// Riga di un aggiornamento. Conserva una copia di nomi, categoria e tipo:
/// rinominare o archiviare una voce oggi non cambia i mesi passati.
@freezed
abstract class SnapshotItem with _$SnapshotItem {
  const SnapshotItem._();

  const factory SnapshotItem({
    /// Legame con la voce attuale; `null` se la voce è stata eliminata.
    String? itemId,
    String? categoryId,
    required String itemName,
    required String categoryName,
    required ItemKind kind,
    @Default(false) bool isInvestment,
    @Default(0) int categoryOrder,
    @Default(0) int itemOrder,
    required Money amount,
  }) = _SnapshotItem;

  bool get isAsset => kind == ItemKind.asset;
  bool get isLiability => kind == ItemKind.liability;

  /// Chiave stabile della categoria anche se è stata eliminata.
  String get categoryKey => categoryId ?? 'name:$categoryName';
}

/// Dati da salvare: nuovo aggiornamento ([snapshotId] nullo) o modifica.
@immutable
class SnapshotDraft {
  const SnapshotDraft({
    required this.month,
    required this.items,
    this.snapshotId,
  });

  final YearMonth month;
  final List<SnapshotItem> items;
  final String? snapshotId;
}
