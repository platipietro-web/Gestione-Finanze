import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/money/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/time/month_labels.dart';
import '../../../../shared/models/snapshot.dart';
import '../../../../shared/providers/snapshot_providers.dart';
import '../../../../shared/services/wealth_calculator.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/delta_badge.dart';
import '../../../../shared/widgets/dialogs.dart';
import '../../../../shared/widgets/feedback_views.dart';
import '../../../../shared/widgets/money_text.dart';

class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.point,
    required this.onTap,
    this.selected = false,
  });

  final TimelinePoint point;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final colors = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.primaryContainer : Colors.transparent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            // Con testo molto grande l'importo va sotto il mese.
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xxs,
                children: [
                  Text(
                    MonthLabels.long(point.month),
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MoneyText(point.totals.netWorth, style: text.titleSmall),
                      DeltaBadge(
                        change: point.netWorthChange,
                        showAmount: false,
                        percentDecimals: 1,
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dettaglio di un aggiornamento: totali e righe con i nomi di allora.
class SnapshotDetailView extends ConsumerWidget {
  const SnapshotDetailView({
    super.key,
    required this.point,
    this.showActions = true,
  });

  final TimelinePoint point;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final totals = point.totals;
    final comparedTo = point.netWorthChange.comparedTo;
    final groups = _groups(point.snapshot);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  MonthLabels.long(point.month),
                  style: text.headlineSmall,
                ),
              ),
            ),
            if (showActions) ...[
              FilledButton.tonalIcon(
                onPressed: () => context.push(AppRoutes.editSnapshot(point.id)),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.actionEdit),
              ),
              const SizedBox(width: AppSpacing.xxs),
              SnapshotMenu(point: point),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.netWorth, style: text.labelMedium),
        MoneyText(totals.netWorth, style: text.displaySmall, fit: true),
        DeltaBadge(
          change: point.netWorthChange,
          suffix: comparedTo == null
              ? null
              : MonthLabels.comparedTo(comparedTo),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.xs,
          children: [
            _Figure(
              label: l10n.totalAssets,
              child: MoneyText(totals.assets, style: text.titleSmall),
            ),
            _Figure(
              label: l10n.totalLiabilities,
              child: MoneyText(-totals.liabilities, style: text.titleSmall),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final group in groups) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name.toUpperCase(),
                        style: text.labelMedium?.copyWith(letterSpacing: 0.6),
                      ),
                    ),
                    MoneyText(
                      group.isLiability ? -group.total : group.total,
                      whole: false,
                      style: text.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final item in group.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(item.itemName, style: text.bodyMedium),
                        ),
                        MoneyText(
                          item.amount,
                          whole: false,
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  static List<_Group> _groups(Snapshot snapshot) {
    final byKey = <String, _Group>{};
    for (final item in snapshot.items) {
      byKey
          .putIfAbsent(
            item.categoryKey,
            () =>
                _Group(item.categoryName, item.isLiability, item.categoryOrder),
          )
          .items
          .add(item);
    }
    final groups = byKey.values.toList()
      ..sort((a, b) {
        if (a.isLiability != b.isLiability) return a.isLiability ? 1 : -1;
        return a.order.compareTo(b.order);
      });
    for (final group in groups) {
      group.items.sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
    }
    return groups;
  }
}

class _Group {
  _Group(this.name, this.isLiability, this.order);

  final String name;
  final bool isLiability;
  final int order;
  final List<SnapshotItem> items = [];

  Money get total => Money.sum(items.map((item) => item.amount));
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textStyles.labelSmall),
      child,
    ],
  );
}

/// Menu con l'eliminazione dell'aggiornamento.
class SnapshotMenu extends ConsumerWidget {
  const SnapshotMenu({super.key, required this.point});

  final TimelinePoint point;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      tooltip: l10n.actionMore,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (_) => deleteSnapshot(context, ref, point),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: context.colors.negative,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(child: Text(l10n.deleteUpdate)),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> deleteSnapshot(
  BuildContext context,
  WidgetRef ref,
  TimelinePoint point,
) async {
  final l10n = context.l10n;
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.deleteUpdateTitle(MonthLabels.name(point.month)),
    message: l10n.deleteUpdateMessage,
    confirmLabel: l10n.actionDelete,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  try {
    await ref.read(snapshotsProvider.notifier).delete(point.id);
    if (!context.mounted) return;
    showAppSnackBar(context, l10n.updateDeleted);
    context.go(AppRoutes.history);
  } catch (error) {
    if (context.mounted) showErrorSnackBar(context, error);
  }
}
