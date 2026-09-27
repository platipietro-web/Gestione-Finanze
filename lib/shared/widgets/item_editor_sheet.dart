import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../models/wealth_category.dart';
import '../models/wealth_item.dart';
import 'dialogs.dart';

enum ItemEditorAction { save, archive, restore, delete }

@immutable
class ItemEditorResult {
  const ItemEditorResult(this.action, {this.name = '', this.categoryId = ''});

  final ItemEditorAction action;
  final String name;
  final String categoryId;
}

/// Crea o modifica una voce: nome e categoria. Le azioni vere le esegue
/// chi apre il pannello.
Future<ItemEditorResult?> showItemEditor(
  BuildContext context, {
  required List<WealthCategory> categories,
  WealthItem? item,
  String? initialCategoryId,
}) => showAdaptiveSheet<ItemEditorResult>(
  context,
  builder: (context) => _ItemEditor(
    categories: categories,
    item: item,
    initialCategoryId: initialCategoryId,
  ),
);

class _ItemEditor extends StatefulWidget {
  const _ItemEditor({
    required this.categories,
    required this.item,
    required this.initialCategoryId,
  });

  final List<WealthCategory> categories;
  final WealthItem? item;
  final String? initialCategoryId;

  @override
  State<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<_ItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late String? _categoryId =
      widget.item?.categoryId ??
      widget.initialCategoryId ??
      (widget.categories.isEmpty ? null : widget.categories.first.id);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ItemEditorResult(
        ItemEditorAction.save,
        name: _name.text.trim(),
        categoryId: _categoryId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = widget.item;
    final isEditing = item != null;
    // Chi apre il pannello include anche la categoria attuale della voce,
    // se archiviata, così resta selezionata.
    final categories = widget.categories;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? l10n.editItem : l10n.newItem,
            style: context.textStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _name,
            autofocus: !isEditing,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
            maxLength: Validators.maxNameLength,
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
            initialValue: _categoryId,
            decoration: InputDecoration(labelText: l10n.categoryLabel),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
            validator: (value) =>
                value == null ? l10n.itemCategoryMissing : null,
          ),
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l10n.archiveHint, style: context.textStyles.bodySmall),
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
                    ItemEditorResult(
                      item.isActive
                          ? ItemEditorAction.archive
                          : ItemEditorAction.restore,
                    ),
                  ),
                  icon: Icon(
                    item.isActive
                        ? Icons.archive_outlined
                        : Icons.unarchive_outlined,
                  ),
                  label: Text(
                    item.isActive ? l10n.actionArchive : l10n.actionRestore,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.negative,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(const ItemEditorResult(ItemEditorAction.delete)),
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
