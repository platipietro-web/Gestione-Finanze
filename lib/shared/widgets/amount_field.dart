import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n.dart';
import '../../core/money/money_parser.dart';
import '../../core/theme/app_theme.dart';

/// Messaggio per un importo non valido.
String? amountErrorText(AppLocalizations l10n, MoneyParseError? error) =>
    switch (error) {
      null => null,
      MoneyParseError.invalid => l10n.amountInvalid,
      MoneyParseError.negative => l10n.amountNegative,
      MoneyParseError.tooManyDecimals => l10n.amountTooManyDecimals,
      MoneyParseError.tooLarge => l10n.amountTooLarge,
    };

/// Campo importo: allineato a destra, cifre fisse, tastiera numerica.
/// Al focus seleziona tutto, così si sovrascrive subito il valore.
class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.semanticLabel,
    this.errorText,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final String initialText;
  final ValueChanged<String> onChanged;
  final String semanticLabel;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_selectAllOnFocus);
  }

  void _selectAllOnFocus() {
    if (_focusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_selectAllOnFocus);
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: TextAlign.end,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: widget.textInputAction,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,€\s\-]')),
        ],
        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        onChanged: widget.onChanged,
        onSubmitted:
            widget.onSubmitted ??
            (_) {
              if (widget.textInputAction == TextInputAction.next) {
                FocusScope.of(context).nextFocus();
              }
            },
        decoration: InputDecoration(
          isDense: true,
          hintText: '0',
          prefixText: '€ ',
          errorText: widget.errorText,
          errorMaxLines: 3,
        ),
      ),
    );
  }
}
