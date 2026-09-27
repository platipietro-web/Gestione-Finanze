import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/time/month_labels.dart';
import '../../../shared/models/catalog.dart';
import '../../../shared/models/item_kind.dart';
import '../../../shared/models/wealth_category.dart';
import '../../../shared/models/wealth_item.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton.dart';
import '../application/assets_actions.dart';

/// Sezione "Patrimonio": categorie e voci della configurazione corrente,
/// con i valori dell'ultimo aggiornamento.
class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = ref.watch(catalogProvider);
    final latest = ref.watch(timelineProvider).value?.latest;
    final actions = AssetsActions(context, ref);
    final compact = context.windowSize.isCompact;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncView(
          value: catalog,
          onRetry: () => ref.invalidate(catalogProvider),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: SkeletonList(rows: 8),
          ),
          data: (catalog) {
            if (catalog.isEmpty) {
              return EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.emptyCatalogTitle,
                message: l10n.emptyCatalogMessage,
                actionLabel: l10n.newCategory,
                onAction: actions.newCategory,
              );
            }
            final amounts = <String, Money>{
              if (latest != null)
                for (final item in latest.snapshot.items)
                  if (item.itemId != null) item.itemId!: item.amount,
            };
            final padding = compact ? AppSpacing.md : AppSpacing.xxl;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                padding,
                AppSpacing.md,
                padding,
                AppSpacing.huge,
              ),
              children: [
                PageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageTitle(
                        l10n.assetsTitle,
                        subtitle: latest == null
                            ? l10n.assetsSubtitleNone
                            : l10n.assetsSubtitle(
                                MonthLabels.inSentence(latest.month),
                              ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _editing = !_editing),
                            child: Text(
                              _editing ? l10n.actionDone : l10n.actionEdit,
                            ),
                          ),
                        ],
                      ),
                      if (latest != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _Totals(totals: latest.totals),
                      ],
                      if (_editing) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.reorderHint,
                          style: context.textStyles.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      _CategoryColumns(
                        sections: [
                          for (final (index, category)
                              in catalog.activeCategories.indexed)
                            _CategorySection(
                              catalog: catalog,
                              category: category,
                              amounts: amounts,
                              editing: _editing,
                              isFirst: index == 0,
                              isLast:
                                  index == catalog.activeCategories.length - 1,
                              actions: actions,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => actions.newItem(catalog),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.newItem),
                          ),
                          OutlinedButton.icon(
                            onPressed: actions.newCategory,
                            icon: const Icon(Icons.create_new_folder_outlined),
                            label: Text(l10n.newCategory),
                          ),
                        ],
                      ),
                      if (catalog.archivedItems.isNotEmpty ||
                          catalog.archivedCategories.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _ArchivedSection(catalog: catalog, actions: actions),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Una colonna su smartphone e tablet, due su schermi larghi. Le categorie
/// si leggono da sinistra a destra, riga per riga.
class _CategoryColumns extends StatelessWidget {
  const _CategoryColumns({required this.sections});

  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    const gap = AppSpacing.sm;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 960) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final section in sections) ...[
                section,
                const SizedBox(height: gap),
              ],
            ],
          );
        }
        Widget column(int parity) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = parity; i < sections.length; i += 2) ...[
                sections[i],
                const SizedBox(height: gap),
              ],
            ],
          ),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            column(0),
            const SizedBox(width: gap),
            column(1),
          ],
        );
      },
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.totals});

  final SnapshotTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    Widget figure(String label, Money value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelSmall),
        MoneyText(value, style: text.titleMedium),
      ],
    );
    return Wrap(
      spacing: AppSpacing.xxl,
      runSpacing: AppSpacing.sm,
      children: [
        figure(l10n.totalAssets, totals.assets),
        figure(l10n.totalLiabilities, -totals.liabilities),
        figure(l10n.netWorth, totals.netWorth),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.catalog,
    required this.category,
    required this.amounts,
    required this.editing,
    required this.isFirst,
    required this.isLast,
    required this.actions,
  });

  final Catalog catalog;
  final WealthCategory category;
  final Map<String, Money> amounts;
  final bool editing;
  final bool isFirst;
  final bool isLast;
  final AssetsActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final colors = context.colors;
    final items = catalog.itemsOf(category.id);
    final isLiability = category.kind == ItemKind.liability;
    final total = Money.sum([
      for (final i in items) amounts[i.id] ?? Money.zero,
    ]);

    final header = Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(
                    category.name.toUpperCase(),
                    style: text.labelMedium?.copyWith(letterSpacing: 0.6),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (category.isInvestment) ...[
                const SizedBox(width: AppSpacing.xs),
                Tooltip(
                  message: l10n.investmentBadge,
                  child: Icon(
                    Icons.show_chart_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                ),
              ],
              IconButton(
                tooltip: l10n.editCategory,
                visualDensity: VisualDensity.compact,
                onPressed: () => actions.editCategory(category),
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (editing) ...[
          IconButton(
            tooltip: l10n.moveUp,
            visualDensity: VisualDensity.compact,
            onPressed: isFirst
                ? null
                : () => actions.moveCategory(category.id, -1),
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
          ),
          IconButton(
            tooltip: l10n.moveDown,
            visualDensity: VisualDensity.compact,
            onPressed: isLast
                ? null
                : () => actions.moveCategory(category.id, 1),
            icon: const Icon(Icons.arrow_downward_rounded, size: 20),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: MoneyText(
              isLiability ? -total : total,
              style: text.labelLarge,
            ),
          ),
      ],
    );

    Widget row(WealthItem item, {Widget? leading}) => ListTile(
      key: ValueKey(item.id),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      dense: true,
      leading: leading,
      title: Text(item.name, style: text.bodyMedium),
      trailing: amounts[item.id] == null
          ? Text(
              '—',
              style: text.bodyMedium?.copyWith(color: colors.textTertiary),
            )
          : MoneyText(amounts[item.id]!, whole: false, style: text.bodyMedium),
      onTap: editing ? null : () => actions.editItem(catalog, item),
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
                top: AppSpacing.xxs,
              ),
              child: Text(l10n.categoryEmptyItems, style: text.bodySmall),
            )
          else if (editing)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: (oldIndex, newIndex) =>
                  actions.reorderItems(category.id, oldIndex, newIndex),
              children: [
                for (final (index, item) in items.indexed)
                  row(
                    item,
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: Tooltip(
                        message: l10n.dragToReorder,
                        child: const Icon(Icons.drag_indicator_rounded),
                      ),
                    ),
                  ),
              ],
            )
          else
            for (final item in items) row(item),
          if (!editing)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () =>
                    actions.newItem(catalog, categoryId: category.id),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addItem),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArchivedSection extends StatelessWidget {
  const _ArchivedSection({required this.catalog, required this.actions});

  final Catalog catalog;
  final AssetsActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final count =
        catalog.archivedItems.length + catalog.archivedCategories.length;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text('${l10n.archivedTitle} ($count)', style: text.titleSmall),
          childrenPadding: const EdgeInsets.only(bottom: AppSpacing.xs),
          children: [
            for (final category in catalog.archivedCategories)
              ListTile(
                dense: true,
                title: Text(category.name, style: text.bodyMedium),
                subtitle: Text(l10n.categoryLabel),
                trailing: TextButton(
                  onPressed: () => actions.restoreCategory(category),
                  child: Text(l10n.actionRestore),
                ),
                onLongPress: () => actions.editCategory(category),
              ),
            for (final item in catalog.archivedItems)
              ListTile(
                dense: true,
                title: Text(item.name, style: text.bodyMedium),
                subtitle: Text(
                  catalog.categoryById(item.categoryId)?.name ?? '',
                ),
                trailing: TextButton(
                  onPressed: () => actions.restoreItem(item),
                  child: Text(l10n.actionRestore),
                ),
                onTap: () => actions.editItem(catalog, item),
              ),
          ],
        ),
      ),
    );
  }
}
