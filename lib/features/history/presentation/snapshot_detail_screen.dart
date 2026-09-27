import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/skeleton.dart';
import 'widgets/history_widgets.dart';

/// Dettaglio su smartphone e tablet verticale.
class SnapshotDetailScreen extends ConsumerWidget {
  const SnapshotDetailScreen({super.key, required this.snapshotId});

  final String snapshotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final timeline = ref.watch(timelineProvider);
    final point = timeline.value?.byId(snapshotId);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          if (point != null) ...[
            IconButton(
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(AppRoutes.editSnapshot(point.id)),
            ),
            SnapshotMenu(point: point),
          ],
        ],
      ),
      body: AsyncView(
        value: timeline,
        onRetry: () => ref.invalidate(snapshotsProvider),
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SkeletonList(),
        ),
        data: (timeline) {
          final point = timeline.byId(snapshotId);
          if (point == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.updateNotFound,
              actionLabel: l10n.historyTitle,
              actionIcon: Icons.history_rounded,
              onAction: () => context.go(AppRoutes.history),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              SnapshotDetailView(point: point, showActions: false),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.editSnapshot(point.id)),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editValues),
              ),
            ],
          );
        },
      ),
    );
  }
}
