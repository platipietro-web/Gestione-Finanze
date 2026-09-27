import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/money/money.dart';
import '../../../shared/models/catalog.dart';
import '../../../shared/models/item_kind.dart';
import '../../../shared/models/snapshot.dart';
import '../../../shared/models/wealth_category.dart';
import '../../../shared/models/wealth_item.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/session_providers.dart';
import '../../../shared/providers/snapshot_providers.dart';

@immutable
class SuggestedItem {
  const SuggestedItem({
    required this.key,
    required this.name,
    this.preselected = false,
  });

  final String key;
  final String name;
  final bool preselected;
}

@immutable
class SuggestedCategory {
  const SuggestedCategory({
    required this.key,
    required this.name,
    required this.kind,
    required this.items,
    this.isInvestment = false,
  });

  final String key;
  final String name;
  final ItemKind kind;
  final bool isInvestment;
  final List<SuggestedItem> items;
}

/// Categorie e voci proposte al primo avvio. Crypto è una voce degli
/// investimenti; l'utente può crearne una categoria a sé in seguito.
List<SuggestedCategory> defaultSuggestions(AppLocalizations l10n) => [
  SuggestedCategory(
    key: 'liquidity',
    name: l10n.catLiquidity,
    kind: ItemKind.asset,
    items: [
      SuggestedItem(
        key: 'current',
        name: l10n.itemCurrentAccount,
        preselected: true,
      ),
      SuggestedItem(key: 'deposit', name: l10n.itemDepositAccount),
      SuggestedItem(key: 'cash', name: l10n.itemCash),
    ],
  ),
  SuggestedCategory(
    key: 'investments',
    name: l10n.catInvestments,
    kind: ItemKind.asset,
    isInvestment: true,
    items: [
      SuggestedItem(key: 'etf', name: l10n.itemEtf, preselected: true),
      SuggestedItem(key: 'stocks', name: l10n.itemStocks),
      SuggestedItem(key: 'bonds', name: l10n.itemBonds),
      SuggestedItem(key: 'crypto', name: l10n.itemCrypto),
      SuggestedItem(key: 'pension', name: l10n.itemPensionFund),
    ],
  ),
  SuggestedCategory(
    key: 'real-estate',
    name: l10n.catRealEstate,
    kind: ItemKind.asset,
    items: [SuggestedItem(key: 'home', name: l10n.itemHome)],
  ),
  SuggestedCategory(
    key: 'other-assets',
    name: l10n.catOtherAssets,
    kind: ItemKind.asset,
    items: [SuggestedItem(key: 'car', name: l10n.itemCar)],
  ),
  SuggestedCategory(
    key: 'debts',
    name: l10n.catDebts,
    kind: ItemKind.liability,
    items: [
      SuggestedItem(key: 'mortgage', name: l10n.itemMortgage),
      SuggestedItem(key: 'loan', name: l10n.itemLoan),
      SuggestedItem(key: 'card', name: l10n.itemCreditCard),
    ],
  ),
];

/// Cosa creare alla fine dell'onboarding.
@immutable
class OnboardingPlan {
  const OnboardingPlan(this.categories);

  final List<PlannedCategory> categories;
}

@immutable
class PlannedCategory {
  const PlannedCategory({
    required this.name,
    required this.kind,
    required this.isInvestment,
    required this.items,
  });

  final String name;
  final ItemKind kind;
  final bool isInvestment;
  final List<({String name, Money amount})> items;
}

final onboardingControllerProvider =
    NotifierProvider.autoDispose<OnboardingController, AsyncValue<void>>(
      OnboardingController.new,
    );

class OnboardingController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Crea categorie e voci, salva il primo aggiornamento e segna
  /// l'onboarding come completato. Si può ripetere senza creare doppioni:
  /// categorie e voci già presenti vengono riusate.
  Future<bool> finish(OnboardingPlan plan) async {
    state = const AsyncLoading();
    try {
      final catalogController = ref.read(catalogProvider.notifier);
      var catalog = await ref.read(catalogProvider.future);
      final lines = <SnapshotItem>[];

      for (final planned in plan.categories) {
        final WealthCategory category =
            _findCategory(catalog, planned) ??
            await catalogController.createCategory(
              name: planned.name,
              kind: planned.kind,
              isInvestment: planned.isInvestment,
            );
        catalog = ref.read(catalogProvider).value ?? catalog;
        for (final plannedItem in planned.items) {
          final WealthItem item =
              catalog
                  .itemsOf(category.id)
                  .where((i) => i.name == plannedItem.name)
                  .firstOrNull ??
              await catalogController.createItem(
                categoryId: category.id,
                name: plannedItem.name,
              );
          catalog = ref.read(catalogProvider).value ?? catalog;
          lines.add(
            SnapshotItem(
              itemId: item.id,
              categoryId: category.id,
              itemName: item.name,
              categoryName: category.name,
              kind: category.kind,
              isInvestment: category.isInvestment,
              categoryOrder: category.sortOrder,
              itemOrder: item.sortOrder,
              amount: plannedItem.amount,
            ),
          );
        }
      }
      if (lines.isEmpty || lines.every((l) => l.amount.isZero)) {
        throw const AppFailure(FailureKind.invalidData);
      }

      final month = ref.read(currentMonthProvider);
      final snapshots = await ref.read(snapshotsProvider.future);
      final existing = snapshots.where((s) => s.month == month).firstOrNull;
      await ref
          .read(snapshotsProvider.notifier)
          .save(
            SnapshotDraft(month: month, snapshotId: existing?.id, items: lines),
          );
      await ref.read(profileProvider.notifier).completeOnboarding();
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(AppFailure.from(error), stackTrace);
      return false;
    }
  }

  WealthCategory? _findCategory(Catalog catalog, PlannedCategory planned) =>
      catalog.categories
          .where((c) => c.name == planned.name && c.kind == planned.kind)
          .firstOrNull;
}
