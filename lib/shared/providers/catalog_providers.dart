import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog.dart';
import '../models/item_kind.dart';
import '../models/wealth_category.dart';
import '../models/wealth_item.dart';
import '../repositories/catalog_repository.dart';
import 'repository_providers.dart';
import 'session_providers.dart';

final catalogProvider = AsyncNotifierProvider<CatalogController, Catalog>(
  CatalogController.new,
);

/// Configurazione corrente in cache per tutta la sessione. Ogni modifica
/// passa dal repository e poi aggiorna la cache senza ricaricare tutto.
class CatalogController extends AsyncNotifier<Catalog> {
  @override
  Future<Catalog> build() async {
    final scope = ref.watch(dataScopeProvider);
    if (scope == null) return Catalog.empty;
    return ref.watch(catalogRepositoryProvider).fetch();
  }

  CatalogRepository get _repository => ref.read(catalogRepositoryProvider);

  Catalog get _current => state.value ?? Catalog.empty;

  void _set(Catalog catalog) => state = AsyncData(catalog);

  Future<WealthCategory> createCategory({
    required String name,
    required ItemKind kind,
    bool isInvestment = false,
  }) async {
    final category = await _repository.createCategory(
      name: name,
      kind: kind,
      isInvestment: isInvestment,
      sortOrder: _current.nextCategoryOrder,
    );
    _set(_current.upsertCategory(category));
    return category;
  }

  Future<WealthCategory> updateCategory(WealthCategory category) async {
    final updated = await _repository.updateCategory(category);
    _set(_current.upsertCategory(updated));
    return updated;
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    _set(_current.removeCategory(id));
  }

  Future<WealthItem> createItem({
    required String categoryId,
    required String name,
  }) async {
    final item = await _repository.createItem(
      categoryId: categoryId,
      name: name,
      sortOrder: _current.nextItemOrder(categoryId),
    );
    _set(_current.upsertItem(item));
    return item;
  }

  Future<WealthItem> updateItem(WealthItem item) async {
    final current = _current.itemById(item.id);
    // Spostata in un'altra categoria: finisce in fondo.
    final toSave = current != null && current.categoryId != item.categoryId
        ? item.copyWith(sortOrder: _current.nextItemOrder(item.categoryId))
        : item;
    final updated = await _repository.updateItem(toSave);
    _set(_current.upsertItem(updated));
    return updated;
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    _set(_current.removeItem(id));
  }

  /// Sposta una categoria di una posizione ([delta] = -1 su, +1 giù).
  Future<void> moveCategory(String id, int delta) async {
    final ordered = [..._current.categories];
    final index = ordered.indexWhere((c) => c.id == id);
    final target = index + delta;
    if (index < 0 || target < 0 || target >= ordered.length) return;
    final moved = ordered.removeAt(index);
    ordered.insert(target, moved);
    final previous = _current;
    _set(
      Catalog(
        categories: [
          for (var i = 0; i < ordered.length; i++)
            ordered[i].copyWith(sortOrder: i),
        ],
        items: previous.items,
      ),
    );
    try {
      await _repository.reorderCategories([for (final c in ordered) c.id]);
    } catch (_) {
      _set(previous);
      rethrow;
    }
  }

  /// Riordina le voci di una categoria. [newIndex] è la posizione finale,
  /// già corretta per la rimozione (come `onReorderItem`).
  Future<void> reorderItems(
    String categoryId,
    int oldIndex,
    int newIndex,
  ) async {
    final siblings = _current.itemsOf(categoryId);
    if (oldIndex < 0 || oldIndex >= siblings.length) return;
    final ordered = [...siblings];
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex.clamp(0, ordered.length), moved);
    final previous = _current;
    final reordered = {
      for (var i = 0; i < ordered.length; i++)
        ordered[i].id: ordered[i].copyWith(sortOrder: i),
    };
    _set(
      Catalog(
        categories: previous.categories,
        items: [for (final item in previous.items) reordered[item.id] ?? item],
      ),
    );
    try {
      await _repository.reorderItems([for (final i in ordered) i.id]);
    } catch (_) {
      _set(previous);
      rethrow;
    }
  }
}
