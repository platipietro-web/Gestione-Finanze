import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/item_kind.dart';
import '../../../../shared/models/wealth_category.dart';
import '../../../../shared/widgets/dialogs.dart';

enum CategoryEditorAction { save, archive, restore, delete }

@immutable
class CategoryEditorResult {
  const CategoryEditorResult(
    this.action, {
    this.name = '',
    this.kind = ItemKind.asset,
    this.isInvestment = false,
  });

  final CategoryEditorAction action;
  final String name;
  final ItemKind kind;
  final bool isInvestment;
}

Future<CategoryEditorResult?> showCategoryEditor(
  BuildContext context, {
  WealthCategory? category,
}) => showAdaptiveSheet<CategoryEditorResult>(
  context,
  builder: (context) => _CategoryEditor(category: category),
);

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({required this.category});

  final WealthCategory? category;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late ItemKind _kind = widget.category?.kind ?? ItemKind.asset;
  late bool _isInvestment = widget.category?.isInvestment ?? false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CategoryEditorResult(
        CategoryEditorAction.save,
        name: _name.text.trim(),
        kind: _kind,
        isInvestment: _kind == ItemKind.asset && _isInvestment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final category = widget.category;
    final isEditing = category != null;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? l10n.editCategory : l10n.newCategory,
            style: text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _name,
            autofocus: !isEditing,
            textCapitalization: TextCapitalization.sentences,
            maxLength: Validators.maxCategoryNameLength,
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              hintText: l10n.categoryNameHint,
              counterText: '',
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? l10n.validationRequired : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.categoryKindLabel, style: text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<ItemKind>(
            segments: [
              ButtonSegment(value: ItemKind.asset, label: Text(l10n.kindAsset)),
              ButtonSegment(
                value: ItemKind.liability,
                label: Text(l10n.kindLiability),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: isEditing
                ? null
                : (selection) => setState(() => _kind = selection.first),
          ),
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(l10n.kindLockedHelp, style: text.bodySmall),
            ),
          if (_kind == ItemKind.asset) ...[
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isInvestment,
              onChanged: (value) => setState(() => _isInvestment = value),
              title: Text(l10n.isInvestmentLabel),
              subtitle: Text(l10n.isInvestmentHelp),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: Text(l10n.actionSave),
                ),
              ),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(
                    CategoryEditorResult(
                      category.isActive
                          ? CategoryEditorAction.archive
                          : CategoryEditorAction.restore,
                    ),
                  ),
                  icon: Icon(
                    category.isActive
                        ? Icons.archive_outlined
                        : Icons.unarchive_outlined,
                  ),
                  label: Text(
                    category.isActive ? l10n.actionArchive : l10n.actionRestore,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.negative,
                  ),
                  onPressed: () => Navigator.of(context).pop(
                    const CategoryEditorResult(CategoryEditorAction.delete),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.actionDelete),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
