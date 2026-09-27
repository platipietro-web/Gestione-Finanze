import '../models/catalog.dart';
import '../models/item_kind.dart';
import '../models/wealth_category.dart';
import '../models/wealth_item.dart';

/// Configurazione corrente: categorie e voci.
abstract interface class CatalogRepository {
  Future<Catalog> fetch();

  Future<WealthCategory> createCategory({
    required String name,
    required ItemKind kind,
    required bool isInvestment,
    required int sortOrder,
  });

  /// Aggiorna nome, flag investimento, ordine e stato. Il tipo non cambia.
  Future<WealthCategory> updateCategory(WealthCategory category);

  /// Fallisce con `categoryNotEmpty` se la categoria contiene voci.
  Future<void> deleteCategory(String id);

  Future<WealthItem> createItem({
    required String categoryId,
    required String name,
    required int sortOrder,
  });

  Future<WealthItem> updateItem(WealthItem item);

  /// Lo storico resta: le righe degli aggiornamenti conservano il nome.
  Future<void> deleteItem(String id);

  /// Salva il nuovo ordine: la posizione nella lista diventa `sortOrder`.
  Future<void> reorderCategories(List<String> orderedIds);

  Future<void> reorderItems(List<String> orderedIds);
}
