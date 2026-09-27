import 'package:supabase_flutter/supabase_flutter.dart' hide Snapshot;

import '../../../core/errors/app_failure.dart';
import '../../../core/money/money.dart';
import '../../../core/time/year_month.dart';
import '../../models/item_kind.dart';
import '../../models/snapshot.dart';
import '../snapshot_repository.dart';
import 'supabase_errors.dart';

class SupabaseSnapshotRepository implements SnapshotRepository {
  SupabaseSnapshotRepository(this._client);

  final SupabaseClient _client;

  static const _select =
      'id, period_month, updated_at, '
      'snapshot_items(item_id, category_id, item_name, category_name, kind, '
      'is_investment, category_order, item_order, amount_cents)';

  @override
  Future<List<Snapshot>> fetchAll() => guardSupabase(() async {
    final rows = await _client
        .from('monthly_snapshots')
        .select(_select)
        .order('period_month', ascending: true);
    return [for (final row in rows) _map(row)];
  });

  @override
  Future<Snapshot> fetch(String id) => guardSupabase(() async {
    final row = await _client
        .from('monthly_snapshots')
        .select(_select)
        .eq('id', id)
        .maybeSingle();
    if (row == null) throw const AppFailure(FailureKind.notFound);
    return _map(row);
  });

  @override
  Future<String> save(SnapshotDraft draft) => guardSupabase(() async {
    // Funzione PostgreSQL: aggiornamento e righe in un'unica transazione.
    final id = await _client.rpc<String>(
      'save_snapshot',
      params: {
        'p_period_month': draft.month.dbDate,
        'p_snapshot_id': draft.snapshotId,
        'p_items': [
          for (final item in draft.items)
            {
              'item_id': item.itemId,
              'category_id': item.categoryId,
              'item_name': item.itemName,
              'category_name': item.categoryName,
              'kind': item.kind.dbValue,
              'is_investment': item.isInvestment,
              'category_order': item.categoryOrder,
              'item_order': item.itemOrder,
              'amount_cents': item.amount.cents,
            },
        ],
      },
    );
    return id;
  });

  @override
  Future<void> delete(String id) => guardSupabase(
    () => _client.from('monthly_snapshots').delete().eq('id', id),
  );

  Snapshot _map(Map<String, dynamic> row) {
    final month = YearMonth.tryParse(row['period_month'] as String);
    if (month == null) throw const AppFailure(FailureKind.invalidData);
    final items = [
      for (final raw in (row['snapshot_items'] as List<dynamic>? ?? const []))
        _mapItem(raw as Map<String, dynamic>),
    ]..sort(_byOrder);
    final updatedAt = row['updated_at'] as String?;
    return Snapshot(
      id: row['id'] as String,
      month: month,
      items: items,
      updatedAt: updatedAt == null ? null : DateTime.tryParse(updatedAt),
    );
  }

  SnapshotItem _mapItem(Map<String, dynamic> row) => SnapshotItem(
    itemId: row['item_id'] as String?,
    categoryId: row['category_id'] as String?,
    itemName: row['item_name'] as String,
    categoryName: row['category_name'] as String,
    kind: ItemKind.fromDb(row['kind'] as String),
    isInvestment: row['is_investment'] as bool? ?? false,
    categoryOrder: row['category_order'] as int? ?? 0,
    itemOrder: row['item_order'] as int? ?? 0,
    // bigint arriva come int (o come stringa per valori molto grandi).
    amount: Money(switch (row['amount_cents']) {
      final int value => value,
      final String value => int.parse(value),
      final num value => value.toInt(),
      _ => 0,
    }),
  );
}

int _byOrder(SnapshotItem a, SnapshotItem b) {
  final byCategory = a.categoryOrder.compareTo(b.categoryOrder);
  return byCategory != 0 ? byCategory : a.itemOrder.compareTo(b.itemOrder);
}
