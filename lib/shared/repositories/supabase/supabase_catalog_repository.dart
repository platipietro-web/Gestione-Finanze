import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/catalog.dart';
import '../../models/item_kind.dart';
import '../../models/wealth_category.dart';
import '../../models/wealth_item.dart';
import '../catalog_repository.dart';
import 'supabase_errors.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  static const _categoryColumns =
      'id, name, kind, is_investment, sort_order, is_active';
  static const _itemColumns = 'id, category_id, name, sort_order, is_active';

  @override
  Future<Catalog> fetch() => guardSupabase(() async {
    // Una sola richiesta: categorie con le loro voci.
    final rows = await _client
        .from('categories')
        .select('$_categoryColumns, items($_itemColumns)')
        .order('sort_order', ascending: true)
        .order('sort_order', ascending: true, referencedTable: 'items');
    final categories = <WealthCategory>[];
    final items = <WealthItem>[];
    for (final row in rows) {
      categories.add(_mapCategory(row));
      for (final itemRow in (row['items'] as List<dynamic>? ?? const [])) {
        items.add(_mapItem(itemRow as Map<String, dynamic>));
      }
    }
    return Catalog(categories: categories, items: items);
  });

  @override
  Future<WealthCategory> createCategory({
    required String name,
    required ItemKind kind,
    required bool isInvestment,
    required int sortOrder,
  }) => guardSupabase(() async {
    final row = await _client
        .from('categories')
        .insert({
          'name': name.trim(),
          'kind': kind.dbValue,
          'is_investment': kind == ItemKind.asset && isInvestment,
          'sort_order': sortOrder,
        })
        .select(_categoryColumns)
        .single();
    return _mapCategory(row);
  });

  @override
  Future<WealthCategory> updateCategory(WealthCategory category) =>
      guardSupabase(() async {
        final row = await _client
            .from('categories')
            .update({
              'name': category.name.trim(),
              'is_investment':
                  category.kind == ItemKind.asset && category.isInvestment,
              'sort_order': category.sortOrder,
              'is_active': category.isActive,
            })
            .eq('id', category.id)
            .select(_categoryColumns)
            .single();
        return _mapCategory(row);
      });

  @override
  Future<void> deleteCategory(String id) =>
      guardSupabase(() => _client.from('categories').delete().eq('id', id));

  @override
  Future<WealthItem> createItem({
    required String categoryId,
    required String name,
    required int sortOrder,
  }) => guardSupabase(() async {
    final row = await _client
        .from('items')
        .insert({
          'category_id': categoryId,
          'name': name.trim(),
          'sort_order': sortOrder,
        })
        .select(_itemColumns)
        .single();
    return _mapItem(row);
  });

  @override
  Future<WealthItem> updateItem(WealthItem item) => guardSupabase(() async {
    final row = await _client
        .from('items')
        .update({
          'category_id': item.categoryId,
          'name': item.name.trim(),
          'sort_order': item.sortOrder,
          'is_active': item.isActive,
        })
        .eq('id', item.id)
        .select(_itemColumns)
        .single();
    return _mapItem(row);
  });

  @override
  Future<void> deleteItem(String id) =>
      guardSupabase(() => _client.from('items').delete().eq('id', id));

  @override
  Future<void> reorderCategories(List<String> orderedIds) =>
      _reorder('categories', orderedIds);

  @override
  Future<void> reorderItems(List<String> orderedIds) =>
      _reorder('items', orderedIds);

  Future<void> _reorder(String table, List<String> orderedIds) => guardSupabase(
    () async {
      await Future.wait([
        for (var i = 0; i < orderedIds.length; i++)
          _client.from(table).update({'sort_order': i}).eq('id', orderedIds[i]),
      ]);
    },
  );

  WealthCategory _mapCategory(Map<String, dynamic> row) => WealthCategory(
    id: row['id'] as String,
    name: row['name'] as String,
    kind: ItemKind.fromDb(row['kind'] as String),
    isInvestment: row['is_investment'] as bool? ?? false,
    sortOrder: row['sort_order'] as int? ?? 0,
    isActive: row['is_active'] as bool? ?? true,
  );

  WealthItem _mapItem(Map<String, dynamic> row) => WealthItem(
    id: row['id'] as String,
    categoryId: row['category_id'] as String,
    name: row['name'] as String,
    sortOrder: row['sort_order'] as int? ?? 0,
    isActive: row['is_active'] as bool? ?? true,
  );
}
