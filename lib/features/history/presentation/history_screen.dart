import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton.dart';
import 'widgets/history_widgets.dart';

/// Storico degli aggiornamenti. Su schermi larghi elenco e dettaglio
/// stanno affiancati; [selectedId] è l'aggiornamento aperto a destra.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final timeline = ref.watch(timelineProvider);
    final wide = context.windowSize.isWide;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncView(
          value: timeline,
          onRetry: () => ref.invalidate(snapshotsProvider),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: SkeletonList(),
          ),
          data: (timeline) {
            if (timeline.isEmpty) {
              return EmptyState(
                icon: Icons.history_rounded,
                title: l10n.historyEmptyTitle,
                message: l10n.historyEmptyMessage,
                actionLabel: l10n.emptyDashboardAction,
                onAction: () => context.push(AppRoutes.update),
              );
            }
            final list = _HistoryList(
              points: timeline.newestFirst,
              selectedId: wide ? selectedId : null,
            );
            if (!wide) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  PageTitle(l10n.historyTitle),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: list,
                  ),
                ],
              );
            }
            final selected = selectedId == null
                ? null
                : timeline.byId(selectedId!);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 400,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    children: [
                      PageTitle(l10n.historyTitle),
                      const SizedBox(height: AppSpacing.lg),
                      list,
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: context.colors.border),
                Expanded(
                  child: _DetailPane(
                    selectedId: selectedId,
                    selected: selected,
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

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.points, required this.selectedId});

  final List<TimelinePoint> points;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < points.length; i++) ...[
          if (i > 0)
            const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          HistoryRow(
            point: points[i],
            selected: points[i].id == selectedId,
            onTap: () => context.go(AppRoutes.historyDetail(points[i].id)),
          ),
        ],
      ],
    );
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.selectedId, required this.selected});

  final String? selectedId;
  final TimelinePoint? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final point = selected;
    if (point == null) {
      return EmptyState(
        icon: selectedId == null
            ? Icons.touch_app_outlined
            : Icons.search_off_rounded,
        title: selectedId == null ? l10n.selectUpdateHint : l10n.updateNotFound,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SnapshotDetailView(point: point),
        ),
      ),
    );
  }
}
