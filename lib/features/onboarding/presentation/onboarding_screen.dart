import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/layout/breakpoints.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_parser.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/item_kind.dart';
import '../../../shared/services/wealth_calculator.dart';
import '../../../shared/widgets/amount_field.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/feedback_views.dart';
import '../../../shared/widgets/money_text.dart';
import '../application/onboarding_controller.dart';

/// Primo avvio in tre passi: benvenuto, voci da seguire, valori di oggi.
/// Poi la dashboard. Obiettivo: meno di due minuti.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 3;

  int _step = 0;
  List<SuggestedCategory>? _suggestions;
  final Set<String> _selected = {};
  final Map<String, String> _amountTexts = {};
  final Map<String, MoneyParseError?> _errors = {};
  final List<({String key, String name, String categoryKey})> _custom = [];
  bool _showSelectionError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_suggestions == null) {
      final suggestions = defaultSuggestions(context.l10n);
      _suggestions = suggestions;
      for (final category in suggestions) {
        for (final item in category.items) {
          if (item.preselected) _selected.add(item.key);
        }
      }
    }
  }

  List<SuggestedCategory> get _categories => _suggestions ?? const [];

  /// Voci scelte per categoria, nell'ordine proposto.
  List<(SuggestedCategory, List<({String key, String name})>)> get _chosen => [
    for (final category in _categories)
      (
        category,
        [
          for (final item in category.items)
            if (_selected.contains(item.key)) (key: item.key, name: item.name),
          for (final custom in _custom)
            if (custom.categoryKey == category.key &&
                _selected.contains(custom.key))
              (key: custom.key, name: custom.name),
        ],
      ),
  ].where((entry) => entry.$2.isNotEmpty).toList();

  Money _amount(String key) {
    try {
      return MoneyParser.parse(_amountTexts[key] ?? '');
    } on MoneyParseException {
      return Money.zero;
    }
  }

  SnapshotTotals get _totals {
    var assets = Money.zero;
    var liabilities = Money.zero;
    for (final (category, items) in _chosen) {
      for (final item in items) {
        if (category.kind == ItemKind.liability) {
          liabilities += _amount(item.key);
        } else {
          assets += _amount(item.key);
        }
      }
    }
    return SnapshotTotals(
      assets: assets,
      liabilities: liabilities,
      investments: Money.zero,
    );
  }

  void _next() {
    if (_step == 1 && _selected.isEmpty) {
      setState(() => _showSelectionError = true);
      return;
    }
    setState(() {
      _showSelectionError = false;
      _step = (_step + 1).clamp(0, _steps - 1);
    });
  }

  void _back() => setState(() => _step = (_step - 1).clamp(0, _steps - 1));

  Future<void> _addCustomItem() async {
    final result = await showAdaptiveSheet<({String name, String categoryKey})>(
      context,
      builder: (context) => _CustomItemForm(categories: _categories),
    );
    if (result == null) return;
    final key = 'custom-${_custom.length + 1}';
    setState(() {
      _custom.add((
        key: key,
        name: result.name,
        categoryKey: result.categoryKey,
      ));
      _selected.add(key);
      _showSelectionError = false;
    });
  }

  Future<void> _finish() async {
    if (_errors.values.any((e) => e != null)) {
      showAppSnackBar(context, context.l10n.fixErrorsBeforeSaving);
      return;
    }
    // Un primo aggiornamento tutto a zero farebbe risultare il patrimonio
    // "perso al 100%" al mese successivo.
    final allZero = _chosen.every(
      (entry) => entry.$2.every((item) => _amount(item.key).isZero),
    );
    if (allZero) {
      showAppSnackBar(context, context.l10n.enterAtLeastOneAmount);
      return;
    }
    final plan = OnboardingPlan([
      for (final (category, items) in _chosen)
        PlannedCategory(
          name: category.name,
          kind: category.kind,
          isInvestment: category.isInvestment,
          items: [
            for (final item in items)
              (name: item.name, amount: _amount(item.key)),
          ],
        ),
    ]);
    // Se riesce, il router porta alla dashboard.
    await ref.read(onboardingControllerProvider.notifier).finish(plan);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(onboardingControllerProvider);
    final compact = context.windowSize.isCompact;
    final body = switch (_step) {
      0 => _WelcomeStep(onStart: _next),
      1 => _ChooseStep(
        categories: _categories,
        custom: _custom,
        selected: _selected,
        showError: _showSelectionError,
        onToggle: (key, value) => setState(() {
          value ? _selected.add(key) : _selected.remove(key);
          if (value) _showSelectionError = false;
        }),
        onAddCustom: _addCustomItem,
        onContinue: _next,
      ),
      _ => _ValuesStep(
        chosen: _chosen,
        amountTexts: _amountTexts,
        errors: _errors,
        totals: _totals,
        busy: state.isLoading,
        error: state.error,
        onChanged: (key, text) => setState(() {
          _amountTexts[key] = text;
          _errors[key] = MoneyParser.validate(text);
        }),
        onFinish: _finish,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        leading: _step > 0 && !state.isLoading
            ? IconButton(
                tooltip: l10n.actionBack,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _back,
              )
            : null,
        title: Text(
          l10n.stepOf(_step + 1, _steps),
          style: context.textStyles.labelMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: compact ? double.infinity : 600,
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.medium),
              child: KeyedSubtree(key: ValueKey(_step), child: body),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Align(
            alignment: Alignment.centerLeft,
            child: AppLogo(size: 64),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Semantics(
            header: true,
            child: Text(l10n.welcomeTitle, style: text.displaySmall),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.appTagline,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
          const Spacer(flex: 2),
          FilledButton(onPressed: onStart, child: Text(l10n.start)),
        ],
      ),
    );
  }
}

class _ChooseStep extends StatelessWidget {
  const _ChooseStep({
    required this.categories,
    required this.custom,
    required this.selected,
    required this.showError,
    required this.onToggle,
    required this.onAddCustom,
    required this.onContinue,
  });

  final List<SuggestedCategory> categories;
  final List<({String key, String name, String categoryKey})> custom;
  final Set<String> selected;
  final bool showError;
  final void Function(String key, bool selected) onToggle;
  final VoidCallback onAddCustom;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Semantics(
                header: true,
                child: Text(l10n.chooseItemsTitle, style: text.headlineMedium),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.chooseItemsMessage,
                style: text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final category in categories) ...[
                Text(
                  category.name.toUpperCase(),
                  style: text.labelMedium?.copyWith(letterSpacing: 0.6),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final item in [
                      ...category.items.map((i) => (key: i.key, name: i.name)),
                      ...custom
                          .where((c) => c.categoryKey == category.key)
                          .map((c) => (key: c.key, name: c.name)),
                    ])
                      FilterChip(
                        label: Text(item.name),
                        selected: selected.contains(item.key),
                        onSelected: (value) => onToggle(item.key, value),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onAddCustom,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addItem),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    l10n.chooseAtLeastOne,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: context.colors.negative,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: onContinue,
                child: Text(l10n.actionContinue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ValuesStep extends StatelessWidget {
  const _ValuesStep({
    required this.chosen,
    required this.amountTexts,
    required this.errors,
    required this.totals,
    required this.busy,
    required this.error,
    required this.onChanged,
    required this.onFinish,
  });

  final List<(SuggestedCategory, List<({String key, String name})>)> chosen;
  final Map<String, String> amountTexts;
  final Map<String, MoneyParseError?> errors;
  final SnapshotTotals totals;
  final bool busy;
  final Object? error;
  final void Function(String key, String text) onChanged;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final colors = context.colors;
    final error = this.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Semantics(
                header: true,
                child: Text(l10n.firstValuesTitle, style: text.headlineMedium),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.firstValuesMessage,
                style: text.bodyMedium?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final (category, items) in chosen) ...[
                Text(
                  category.name.toUpperCase(),
                  style: text.labelMedium?.copyWith(letterSpacing: 0.6),
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(item.name, style: text.bodyMedium),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 168,
                          child: AmountField(
                            key: ValueKey(item.key),
                            initialText: amountTexts[item.key] ?? '',
                            semanticLabel: l10n.amountFieldLabel(item.name),
                            errorText: amountErrorText(l10n, errors[item.key]),
                            onChanged: (value) => onChanged(item.key, value),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      l10n.saveFailed,
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: colors.negative),
                    ),
                  ),
                Row(
                  children: [
                    Text(l10n.netWorth, style: text.labelMedium),
                    const Spacer(),
                    MoneyText(totals.netWorth, style: text.titleLarge),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: busy ? null : onFinish,
                  child: busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.finishOnboarding),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomItemForm extends StatefulWidget {
  const _CustomItemForm({required this.categories});

  final List<SuggestedCategory> categories;

  @override
  State<_CustomItemForm> createState() => _CustomItemFormState();
}

class _CustomItemFormState extends State<_CustomItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late String _categoryKey = widget.categories.first.key;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(
      context,
    ).pop((name: _name.text.trim(), categoryKey: _categoryKey));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addItem, style: context.textStyles.headlineSmall),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: Validators.maxNameLength,
            onFieldSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              hintText: l10n.itemNameHint,
              counterText: '',
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? l10n.validationRequired : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _categoryKey,
            decoration: InputDecoration(labelText: l10n.categoryLabel),
            items: [
              for (final category in widget.categories)
                DropdownMenuItem(
                  value: category.key,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) =>
                setState(() => _categoryKey = value ?? _categoryKey),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.actionCancel),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilledButton(onPressed: _save, child: Text(l10n.actionAdd)),
            ],
          ),
        ],
      ),
    );
  }
}
