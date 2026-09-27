import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/failure_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/time/month_labels.dart';
import '../../../core/time/year_month.dart';
import '../../../shared/models/item_kind.dart';
import '../../../shared/models/snapshot.dart';
import '../../../shared/providers/app_mode.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';
import '../../../shared/widgets/amount_field.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/delta_badge.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/item_editor_sheet.dart';
import '../../../shared/widgets/money_text.dart';
import '../application/update_form_controller.dart';
import 'widgets/month_picker.dart';

/// Aggiornamento mensile: nuovo ([initialMonth]) o modifica ([snapshotId]).
class UpdateScreen extends ConsumerWidget {
  const UpdateScreen({super.key, this.snapshotId, this.initialMonth});

  final String? snapshotId;
  final YearMonth? initialMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final snapshots = ref.watch(snapshotsProvider);
    if (catalog.hasValue && snapshots.hasValue) {
      return _UpdateForm(args: (snapshotId: snapshotId, month: initialMonth));
    }
    final error = catalog.error ?? snapshots.error;
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => _leave(context)),
        title: Text(context.l10n.updateTitle),
      ),
      body: error != null && !(catalog.isLoading || snapshots.isLoading)
          ? ErrorView(
              error: error,
              onRetry: () => ref
                ..invalidate(catalogProvider)
                ..invalidate(snapshotsProvider),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

void _leave(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.dashboard);
  }
}

class _UpdateForm extends ConsumerStatefulWidget {
  const _UpdateForm({required this.args});

  final UpdateFormArgs args;

  @override
  ConsumerState<_UpdateForm> createState() => _UpdateFormState();
}

class _UpdateFormState extends ConsumerState<_UpdateForm> {
  bool _allowPop = false;

  UpdateFormController get _controller =>
      ref.read(updateFormProvider(widget.args).notifier);

  UpdateFormState get _state => ref.read(updateFormProvider(widget.args));

  Future<bool> _confirmDiscard() => showConfirmDialog(
    context,
    title: context.l10n.unsavedChangesTitle,
    message: context.l10n.unsavedChangesMessage,
    confirmLabel: context.l10n.actionDiscard,
    cancelLabel: context.l10n.actionKeepEditing,
    destructive: true,
  );

  Future<void> _requestClose() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      await navigator.maybePop();
      return;
    }
    // Aperto direttamente da un indirizzo: non c'è una pagina sotto.
    if (_state.dirty && !await _confirmDiscard()) return;
    if (mounted) context.go(AppRoutes.dashboard);
  }

  void _closeNow() {
    setState(() => _allowPop = true);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_state.saving) return;
    if (_state.hasErrors) {
      showAppSnackBar(context, l10n.fixErrorsBeforeSaving);
      return;
    }
    if (_state.isAllZero) {
      showAppSnackBar(context, l10n.enterAtLeastOneAmount);
      return;
    }
    try {
      await _controller.save();
      messenger.showSnackBar(SnackBar(content: Text(l10n.savedMessage)));
      if (mounted) _closeNow();
    } catch (error) {
      if (!mounted) return;
      final kind = AppFailure.from(error).kind;
      final generic =
          kind == FailureKind.network ||
          kind == FailureKind.server ||
          kind == FailureKind.unknown;
      showAppSnackBar(
        context,
        generic ? l10n.saveFailed : failureMessage(l10n, error),
      );
    }
  }

  Future<void> _changeMonth(YearMonth month) async {
    if (_state.dirty) {
      final l10n = context.l10n;
      final ok = await showConfirmDialog(
        context,
        title: l10n.monthChangeTitle,
        message: l10n.monthChangeMessage,
        confirmLabel: l10n.changeMonth,
      );
      if (!ok) return;
    }
    _controller.selectMonth(month);
  }

  Future<void> _addItem() async {
    final l10n = context.l10n;
    final catalog = ref.read(catalogProvider).value;
    final categories = catalog?.activeCategories ?? const [];
    if (categories.isEmpty) {
      showAppSnackBar(context, l10n.itemCategoryMissing);
      return;
    }
    final result = await showItemEditor(context, categories: categories);
    if (result == null || result.action != ItemEditorAction.save) return;
    try {
      await _controller.addItem(
        name: result.name,
        categoryId: result.categoryId,
      );
    } catch (error) {
      if (mounted) showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateFormProvider(widget.args));
    final l10n = context.l10n;
    final isDemo = ref.watch(appModeProvider) == AppMode.demo;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    if (state.missing) {
      return Scaffold(
        appBar: AppBar(leading: CloseButton(onPressed: () => _leave(context))),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.updateNotFound,
          actionLabel: l10n.goHome,
          actionIcon: Icons.home_outlined,
          onAction: () => context.go(AppRoutes.dashboard),
        ),
      );
    }

    final form = _FormList(
      state: state,
      wide: wide,
      onAmountChanged: _controller.updateAmount,
      onChangeMonth: _changeMonth,
      onAddItem: _addItem,
    );

    return PopScope(
      canPop: !state.dirty || _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) _closeNow();
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _save,
          const SingleActivator(LogicalKeyboardKey.escape): _requestClose,
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: l10n.actionClose,
                icon: const Icon(Icons.close_rounded),
                onPressed: _requestClose,
              ),
              title: Text(
                state.isEditingSavedValues
                    ? l10n.editUpdateTitle
                    : l10n.updateTitle,
              ),
            ),
            body: Column(
              children: [
                if (isDemo) const DemoBanner(),
                Expanded(
                  child: wide
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: form),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    AppSpacing.xl,
                                    AppSpacing.xxl,
                                    AppSpacing.xl,
                                  ),
                                  child: SizedBox(
                                    width: 340,
                                    child: _SummaryPanel(
                                      state: state,
                                      onSave: _save,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : form,
                ),
              ],
            ),
            bottomNavigationBar: wide
                ? null
                : _SummaryBar(state: state, onSave: _save),
          ),
        ),
      ),
    );
  }
}

class _FormList extends ConsumerWidget {
  const _FormList({
    required this.state,
    required this.wide,
    required this.onAmountChanged,
    required this.onChangeMonth,
    required this.onAddItem,
  });

  final UpdateFormState state;
  final bool wide;
  final void Function(String key, String text) onAmountChanged;
  final ValueChanged<YearMonth> onChangeMonth;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final colors = context.colors;
    final currentMonth = ref.watch(currentMonthProvider);
    final month = state.month;

    final String hint;
    if (state.prefilledFrom != null) {
      hint = l10n.prefilledHint(MonthLabels.inSentence(state.prefilledFrom!));
    } else if (state.isEditing) {
      hint = l10n.editingExistingHint(MonthLabels.name(month));
    } else {
      hint = l10n.firstUpdateHint;
    }

    final groups = state.groups;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        wide ? AppSpacing.xxl : AppSpacing.md,
        AppSpacing.md,
        wide ? AppSpacing.xl : AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          mainAxisAlignment: wide
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            if (!state.lockMonth)
              IconButton(
                tooltip: l10n.previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => onChangeMonth(month.previous),
              ),
            Flexible(
              child: state.lockMonth
                  ? Semantics(
                      liveRegion: true,
                      child: Text(
                        MonthLabels.long(month),
                        style: text.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : MonthButton(
                      month: month,
                      currentMonth: currentMonth,
                      savedMonths: {
                        for (final s
                            in ref.watch(snapshotsProvider).value ??
                                const <Snapshot>[])
                          if (!WealthCalculator.isEmpty(s)) s.month,
                      },
                      onSelected: onChangeMonth,
                    ),
            ),
            if (!state.lockMonth)
              IconButton(
                tooltip: l10n.nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: month.isBefore(currentMonth)
                    ? () => onChangeMonth(month.next)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hint,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(
              l10n.noItemsToUpdate,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ),
        for (final group in groups) ...[
          _GroupCard(
            group: group,
            month: month,
            fieldWidth: wide ? 220 : 152,
            onAmountChanged: onAmountChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Align(
          alignment: wide ? AlignmentDirectional.centerStart : Alignment.center,
          child: TextButton.icon(
            onPressed: onAddItem,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addItem),
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.month,
    required this.fieldWidth,
    required this.onAmountChanged,
  });

  final DraftGroup group;
  final YearMonth month;
  final double fieldWidth;
  final void Function(String key, String text) onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final isLiability = group.kind == ItemKind.liability;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      group.name.toUpperCase(),
                      style: text.labelMedium?.copyWith(letterSpacing: 0.6),
                    ),
                  ),
                ),
                MoneyText(
                  isLiability ? -group.total : group.total,
                  whole: false,
                  style: text.labelLarge,
                ),
              ],
            ),
          ),
          for (final line in group.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(line.itemName, style: text.bodyMedium),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: fieldWidth,
                    child: AmountField(
                      key: ValueKey('${month.isoMonth}-${line.key}'),
                      initialText: line.text,
                      semanticLabel: l10n.amountFieldLabel(line.itemName),
                      errorText: amountErrorText(l10n, line.error),
                      onChanged: (value) => onAmountChanged(line.key, value),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.state, required this.onSave});

  final UpdateFormState state;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final colors = context.colors;
    final previousMonth = state.previousMonth;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                children: [
                  Text(l10n.netWorth, style: text.labelMedium),
                  MoneyText(state.totals.netWorth, style: text.titleLarge),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: DeltaBadge(
                  change: state.change,
                  style: text.bodySmall,
                  suffix: previousMonth == null
                      ? null
                      : MonthLabels.comparedTo(previousMonth),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SaveButton(saving: state.saving, onSave: onSave),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.state, required this.onSave});

  final UpdateFormState state;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final totals = state.totals;
    final previousMonth = state.previousMonth;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${l10n.summaryTitle} · ${MonthLabels.long(state.month)}',
            style: text.labelMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.netWorth, style: text.bodySmall),
          const SizedBox(height: AppSpacing.xxs),
          MoneyText(totals.netWorth, style: text.displaySmall, fit: true),
          const SizedBox(height: AppSpacing.xxs),
          DeltaBadge(
            change: state.change,
            style: text.bodySmall,
            suffix: previousMonth == null
                ? null
                : MonthLabels.comparedTo(previousMonth),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _TotalRow(
            label: l10n.totalAssets,
            child: MoneyText(totals.assets, style: text.bodyMedium),
          ),
          const SizedBox(height: AppSpacing.xs),
          _TotalRow(
            label: l10n.totalLiabilities,
            child: MoneyText(-totals.liabilities, style: text.bodyMedium),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SaveButton(saving: state.saving, onSave: onSave),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.keyboardHints,
            style: text.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: context.textStyles.bodyMedium)),
      child,
    ],
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: saving ? null : onSave,
      child: saving
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(context.l10n.saveUpdate),
    );
  }
}
