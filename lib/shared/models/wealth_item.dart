import 'package:freezed_annotation/freezed_annotation.dart';

part 'wealth_item.freezed.dart';

/// Voce della configurazione corrente, per esempio "Conto corrente".
/// Il tipo (attività o passività) lo dà la categoria.
@freezed
abstract class WealthItem with _$WealthItem {
  const factory WealthItem({
    required String id,
    required String categoryId,
    required String name,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _WealthItem;
}
