import 'package:flutter/foundation.dart';

import 'item_kind.dart';
import 'wealth_category.dart';
import 'wealth_item.dart';

/// Configurazione corrente: categorie e voci, già ordinate.
@immutable
class Catalog {
  Catalog({
    required List<WealthCategory> categories,
    required List<WealthItem> items,
  }) : categories = List<WealthCategory>.unmodifiable(
         <WealthCategory>[...categories]
           ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
       ),
       items = List<WealthItem>.unmodifiable(
         <WealthItem>[...items]
           ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
       );

  static final empty = Catalog(categories: const [], items: const []);

  final List<WealthCategory> categories;
  final List<WealthItem> items;

  bool get isEmpty => categories.isEmpty;

  List<WealthCategory> get activeCategories =>
      categories.where((c) => c.isActive).toList();

  List<WealthCategory> get archivedCategories =>
      categories.where((c) => !c.isActive).toList();

  List<WealthItem> itemsOf(String categoryId, {bool includeArchived = false}) =>
      items
          .where(
            (i) =>
                i.categoryId == categoryId && (includeArchived || i.isActive),
          )
          .toList();

  List<WealthItem> get archivedItems =>
      items.where((i) => !i.isActive).toList();

  WealthCategory? categoryById(String? id) {
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  WealthItem? itemById(String? id) {
    if (id == null) return null;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Voci attive in categorie attive, nell'ordine di visualizzazione.
  List<WealthItem> get activeItemsInOrder => [
    for (final category in activeCategories) ...itemsOf(category.id),
  ];

  bool get hasInvestmentCategories =>
      categories.any((c) => c.isInvestment && c.isActive);

  /// Posizione del colore di una categoria di attività nei grafici.
  ///
  /// Deriva dall'ordine nel catalogo completo, archiviate comprese: così
  /// archiviare una categoria non ricolora le altre. `-1` se sconosciuta.
  int colorSlotOf(String? categoryId) {
    if (categoryId == null) return -1;
    final assets = categories.where((c) => c.kind == ItemKind.asset).toList();
    return assets.indexWhere((c) => c.id == categoryId);
  }

  int get nextCategoryOrder =>
      categories.isEmpty ? 0 : categories.last.sortOrder + 1;

  int nextItemOrder(String categoryId) {
    final siblings = itemsOf(categoryId, includeArchived: true);
    if (siblings.isEmpty) return 0;
    return siblings.map((i) => i.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  Catalog upsertCategory(WealthCategory category) => Catalog(
    categories: [
      for (final c in categories)
        if (c.id != category.id) c,
      category,
    ],
    items: items,
  );

  Catalog removeCategory(String id) => Catalog(
    categories: categories.where((c) => c.id != id).toList(),
    items: items,
  );

  Catalog upsertItem(WealthItem item) => Catalog(
    categories: categories,
    items: [
      for (final i in items)
        if (i.id != item.id) i,
      item,
    ],
  );

  Catalog removeItem(String id) => Catalog(
    categories: categories,
    items: items.where((i) => i.id != id).toList(),
  );
}
