import '../../../core/errors/app_failure.dart';
import '../../models/catalog.dart';
import '../../models/item_kind.dart';
import '../../models/profile.dart';
import '../../models/snapshot.dart';
import '../../models/wealth_category.dart';
import '../../models/wealth_item.dart';
import '../auth_repository.dart';
import '../catalog_repository.dart';
import '../profile_repository.dart';
import '../snapshot_repository.dart';
import 'demo_store.dart';

/// Base comune: una piccola attesa rende la demo realistica e mostra gli
/// stati di caricamento. Nei test l'attesa è zero.
abstract class _DemoRepository {
  _DemoRepository(this.store, this.latency);

  final DemoStore store;
  final Duration latency;

  Future<void> wait() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);
}

class DemoProfileRepository extends _DemoRepository
    implements ProfileRepository {
  DemoProfileRepository(super.store, super.latency);

  @override
  Future<Profile> fetch(AuthUser user) async {
    await wait();
    return store.profile;
  }

  @override
  Future<Profile> updateDisplayName(
    Profile profile,
    String? displayName,
  ) async {
    await wait();
    final name = displayName?.trim();
    store.profile = store.profile.copyWith(
      displayName: (name == null || name.isEmpty) ? null : name,
    );
    return store.profile;
  }

  @override
  Future<Profile> completeOnboarding(Profile profile) async {
    await wait();
    store.profile = store.profile.copyWith(onboardingCompleted: true);
    return store.profile;
  }
}

class DemoCatalogRepository extends _DemoRepository
    implements CatalogRepository {
  DemoCatalogRepository(super.store, super.latency);

  @override
  Future<Catalog> fetch() async {
    await wait();
    return Catalog(categories: store.categories, items: store.items);
  }

  @override
  Future<WealthCategory> createCategory({
    required String name,
    required ItemKind kind,
    required bool isInvestment,
    required int sortOrder,
  }) async {
    await wait();
    final category = WealthCategory(
      id: store.nextId('cat'),
      name: name.trim(),
      kind: kind,
      isInvestment: kind == ItemKind.asset && isInvestment,
      sortOrder: sortOrder,
    );
    store.categories.add(category);
    return category;
  }

  @override
  Future<WealthCategory> updateCategory(WealthCategory category) async {
    await wait();
    final index = store.categories.indexWhere((c) => c.id == category.id);
    if (index < 0) throw const AppFailure(FailureKind.notFound);
    final updated = category.copyWith(
      name: category.name.trim(),
      kind: store.categories[index].kind,
      isInvestment: category.kind == ItemKind.asset && category.isInvestment,
    );
    store.categories[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await wait();
    // Come nel database (ON DELETE RESTRICT).
    if (store.items.any((i) => i.categoryId == id)) {
      throw const AppFailure(FailureKind.categoryNotEmpty);
    }
    store.categories.removeWhere((c) => c.id == id);
    _detachFromHistory(categoryId: id);
  }

  @override
  Future<WealthItem> createItem({
    required String categoryId,
    required String name,
    required int sortOrder,
  }) async {
    await wait();
    if (!store.categories.any((c) => c.id == categoryId)) {
      throw const AppFailure(FailureKind.invalidData);
    }
    final item = WealthItem(
      id: store.nextId('item'),
      categoryId: categoryId,
      name: name.trim(),
      sortOrder: sortOrder,
    );
    store.items.add(item);
    return item;
  }

  @override
  Future<WealthItem> updateItem(WealthItem item) async {
    await wait();
    final index = store.items.indexWhere((i) => i.id == item.id);
    if (index < 0) throw const AppFailure(FailureKind.notFound);
    final updated = item.copyWith(name: item.name.trim());
    store.items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteItem(String id) async {
    await wait();
    store.items.removeWhere((i) => i.id == id);
    _detachFromHistory(itemId: id);
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await wait();
    for (var i = 0; i < orderedIds.length; i++) {
      final index = store.categories.indexWhere((c) => c.id == orderedIds[i]);
      if (index >= 0) {
        store.categories[index] = store.categories[index].copyWith(
          sortOrder: i,
        );
      }
    }
  }

  @override
  Future<void> reorderItems(List<String> orderedIds) async {
    await wait();
    for (var i = 0; i < orderedIds.length; i++) {
      final index = store.items.indexWhere((item) => item.id == orderedIds[i]);
      if (index >= 0) {
        store.items[index] = store.items[index].copyWith(sortOrder: i);
      }
    }
  }

  /// Come `ON DELETE SET NULL`: lo storico conserva i nomi copiati.
  void _detachFromHistory({String? itemId, String? categoryId}) {
    for (var s = 0; s < store.snapshots.length; s++) {
      final snapshot = store.snapshots[s];
      store.snapshots[s] = snapshot.copyWith(
        items: [
          for (final item in snapshot.items)
            item.copyWith(
              itemId: itemId != null && item.itemId == itemId
                  ? null
                  : item.itemId,
              categoryId: categoryId != null && item.categoryId == categoryId
                  ? null
                  : item.categoryId,
            ),
        ],
      );
    }
  }
}

class DemoSnapshotRepository extends _DemoRepository
    implements SnapshotRepository {
  DemoSnapshotRepository(super.store, super.latency);

  @override
  Future<List<Snapshot>> fetchAll() async {
    await wait();
    return [...store.snapshots]..sort((a, b) => a.month.compareTo(b.month));
  }

  @override
  Future<Snapshot> fetch(String id) async {
    await wait();
    return store.snapshots.firstWhere(
      (s) => s.id == id,
      orElse: () => throw const AppFailure(FailureKind.notFound),
    );
  }

  @override
  Future<String> save(SnapshotDraft draft) async {
    await wait();
    final monthTaken = store.snapshots.any(
      (s) => s.month == draft.month && s.id != draft.snapshotId,
    );
    if (monthTaken) throw const AppFailure(FailureKind.monthAlreadyExists);
    if (draft.items.any((i) => i.amount.isNegative)) {
      throw const AppFailure(FailureKind.invalidData);
    }

    final snapshotId = draft.snapshotId;
    if (snapshotId == null) {
      final created = Snapshot(
        id: store.nextId('snap'),
        month: draft.month,
        items: draft.items,
        updatedAt: DateTime.now(),
      );
      store.snapshots.add(created);
      return created.id;
    }
    final index = store.snapshots.indexWhere((s) => s.id == snapshotId);
    if (index < 0) throw const AppFailure(FailureKind.notFound);
    // Tocca solo questo aggiornamento.
    store.snapshots[index] = store.snapshots[index].copyWith(
      month: draft.month,
      items: draft.items,
      updatedAt: DateTime.now(),
    );
    return snapshotId;
  }

  @override
  Future<void> delete(String id) async {
    await wait();
    store.snapshots.removeWhere((s) => s.id == id);
  }
}
