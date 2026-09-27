import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/models/catalog.dart';
import '../../../shared/models/wealth_category.dart';
import '../../../shared/models/wealth_item.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/item_editor_sheet.dart';
import '../presentation/widgets/category_editor_sheet.dart';

/// Flussi della sezione Patrimonio: aprono i pannelli, chiedono conferma
/// dove serve e chiamano il controller del catalogo. Gli errori diventano
/// messaggi comprensibili.
class AssetsActions {
  const AssetsActions(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  CatalogController get _catalog => ref.read(catalogProvider.notifier);

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) showErrorSnackBar(context, error);
    }
  }

  Future<void> newCategory() async {
    final result = await showCategoryEditor(context);
    if (result == null || result.action != CategoryEditorAction.save) return;
    await _guard(
      () => _catalog.createCategory(
        name: result.name,
        kind: result.kind,
        isInvestment: result.isInvestment,
      ),
    );
  }

  Future<void> editCategory(WealthCategory category) async {
    final result = await showCategoryEditor(context, category: category);
    if (result == null || !context.mounted) return;
    final l10n = context.l10n;
    switch (result.action) {
      case CategoryEditorAction.save:
        await _guard(
          () => _catalog.updateCategory(
            category.copyWith(
              name: result.name,
              isInvestment: result.isInvestment,
            ),
          ),
        );
      case CategoryEditorAction.archive:
        await _guard(
          () => _catalog.updateCategory(category.copyWith(isActive: false)),
        );
      case CategoryEditorAction.restore:
        await _guard(
          () => _catalog.updateCategory(category.copyWith(isActive: true)),
        );
      case CategoryEditorAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.deleteCategoryTitle,
          message: l10n.deleteCategoryMessage,
          confirmLabel: l10n.actionDelete,
          destructive: true,
        );
        if (confirmed) await _guard(() => _catalog.deleteCategory(category.id));
    }
  }

  Future<void> newItem(Catalog catalog, {String? categoryId}) async {
    final categories = catalog.activeCategories;
    if (categories.isEmpty) {
      showAppSnackBar(context, context.l10n.itemCategoryMissing);
      return;
    }
    final result = await showItemEditor(
      context,
      categories: categories,
      initialCategoryId: categoryId,
    );
    if (result == null || result.action != ItemEditorAction.save) return;
    await _guard(
      () =>
          _catalog.createItem(categoryId: result.categoryId, name: result.name),
    );
  }

  Future<void> editItem(Catalog catalog, WealthItem item) async {
    final categories = [
      for (final c in catalog.categories)
        if (c.isActive || c.id == item.categoryId) c,
    ];
    final result = await showItemEditor(
      context,
      categories: categories,
      item: item,
    );
    if (result == null || !context.mounted) return;
    final l10n = context.l10n;
    switch (result.action) {
      case ItemEditorAction.save:
        await _guard(
          () => _catalog.updateItem(
            item.copyWith(name: result.name, categoryId: result.categoryId),
          ),
        );
      case ItemEditorAction.archive:
        await _guard(() => _catalog.updateItem(item.copyWith(isActive: false)));
      case ItemEditorAction.restore:
        await _guard(() => _catalog.updateItem(item.copyWith(isActive: true)));
      case ItemEditorAction.delete:
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.deleteItemTitle,
          message: l10n.deleteItemMessage,
          confirmLabel: l10n.actionDelete,
          destructive: true,
        );
        if (confirmed) await _guard(() => _catalog.deleteItem(item.id));
    }
  }

  Future<void> moveCategory(String id, int delta) =>
      _guard(() => _catalog.moveCategory(id, delta));

  Future<void> reorderItems(String categoryId, int oldIndex, int newIndex) =>
      _guard(() => _catalog.reorderItems(categoryId, oldIndex, newIndex));

  Future<void> restoreItem(WealthItem item) =>
      _guard(() => _catalog.updateItem(item.copyWith(isActive: true)));

  Future<void> restoreCategory(WealthCategory category) =>
      _guard(() => _catalog.updateCategory(category.copyWith(isActive: true)));
}
