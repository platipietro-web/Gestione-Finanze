import 'package:freezed_annotation/freezed_annotation.dart';

import 'item_kind.dart';

part 'wealth_category.freezed.dart';

/// Categoria della configurazione corrente, per esempio "Liquidità".
///
/// Si chiama `WealthCategory` e non `Category` perché Flutter esporta già
/// una classe con quel nome.
@freezed
abstract class WealthCategory with _$WealthCategory {
  const factory WealthCategory({
    required String id,
    required String name,
    required ItemKind kind,
    @Default(false) bool isInvestment,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _WealthCategory;
}
