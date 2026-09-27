// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wealth_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WealthCategory {

 String get id; String get name; ItemKind get kind; bool get isInvestment; int get sortOrder; bool get isActive;
/// Create a copy of WealthCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WealthCategoryCopyWith<WealthCategory> get copyWith => _$WealthCategoryCopyWithImpl<WealthCategory>(this as WealthCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WealthCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WealthCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.isInvestment, _this.isInvestment) || other.isInvestment == _this.isInvestment)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}


@override
int get hashCode {
  final _this = this as WealthCategory;
  return Object.hash(runtimeType,_this.id,_this.name,_this.kind,_this.isInvestment,_this.sortOrder,_this.isActive);
}

@override
String toString() {
  final _this = this as WealthCategory;
  return 'WealthCategory(id: ${_this.id}, name: ${_this.name}, kind: ${_this.kind}, isInvestment: ${_this.isInvestment}, sortOrder: ${_this.sortOrder}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $WealthCategoryCopyWith<$Res>  {
  factory $WealthCategoryCopyWith(WealthCategory value, $Res Function(WealthCategory) _then) = _$WealthCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, ItemKind kind, bool isInvestment, int sortOrder, bool isActive
});




}
/// @nodoc
class _$WealthCategoryCopyWithImpl<$Res>
    implements $WealthCategoryCopyWith<$Res> {
  _$WealthCategoryCopyWithImpl(this._self, this._then);

  final WealthCategory _self;
  final $Res Function(WealthCategory) _then;

/// Create a copy of WealthCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? isInvestment = null,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(WealthCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ItemKind,isInvestment: null == isInvestment ? _self.isInvestment : isInvestment // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WealthCategory].
extension WealthCategoryPatterns on WealthCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WealthCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WealthCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WealthCategory value)  $default,){
final _that = this;
switch (_that) {
case _WealthCategory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WealthCategory value)?  $default,){
final _that = this;
switch (_that) {
case _WealthCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ItemKind kind,  bool isInvestment,  int sortOrder,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WealthCategory() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.isInvestment,_that.sortOrder,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ItemKind kind,  bool isInvestment,  int sortOrder,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _WealthCategory():
return $default(_that.id,_that.name,_that.kind,_that.isInvestment,_that.sortOrder,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ItemKind kind,  bool isInvestment,  int sortOrder,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _WealthCategory() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.isInvestment,_that.sortOrder,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _WealthCategory implements WealthCategory {
  const _WealthCategory({required this.id, required this.name, required this.kind, this.isInvestment = false, this.sortOrder = 0, this.isActive = true});
  

@override final  String id;
@override final  String name;
@override final  ItemKind kind;
@override@JsonKey() final  bool isInvestment;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isActive;

/// Create a copy of WealthCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WealthCategoryCopyWith<_WealthCategory> get copyWith => __$WealthCategoryCopyWithImpl<_WealthCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WealthCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.isInvestment, isInvestment) || other.isInvestment == isInvestment)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,kind,isInvestment,sortOrder,isActive);
}

@override
String toString() {
    return 'WealthCategory(id: $id, name: $name, kind: $kind, isInvestment: $isInvestment, sortOrder: $sortOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$WealthCategoryCopyWith<$Res> implements $WealthCategoryCopyWith<$Res> {
  factory _$WealthCategoryCopyWith(_WealthCategory value, $Res Function(_WealthCategory) _then) = __$WealthCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ItemKind kind, bool isInvestment, int sortOrder, bool isActive
});




}
/// @nodoc
class __$WealthCategoryCopyWithImpl<$Res>
    implements _$WealthCategoryCopyWith<$Res> {
  __$WealthCategoryCopyWithImpl(this._self, this._then);

  final _WealthCategory _self;
  final $Res Function(_WealthCategory) _then;

/// Create a copy of WealthCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? isInvestment = null,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(_WealthCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ItemKind,isInvestment: null == isInvestment ? _self.isInvestment : isInvestment // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
