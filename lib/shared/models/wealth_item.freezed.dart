// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wealth_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WealthItem {

 String get id; String get categoryId; String get name; int get sortOrder; bool get isActive;
/// Create a copy of WealthItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WealthItemCopyWith<WealthItem> get copyWith => _$WealthItemCopyWithImpl<WealthItem>(this as WealthItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WealthItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WealthItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}


@override
int get hashCode {
  final _this = this as WealthItem;
  return Object.hash(runtimeType,_this.id,_this.categoryId,_this.name,_this.sortOrder,_this.isActive);
}

@override
String toString() {
  final _this = this as WealthItem;
  return 'WealthItem(id: ${_this.id}, categoryId: ${_this.categoryId}, name: ${_this.name}, sortOrder: ${_this.sortOrder}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $WealthItemCopyWith<$Res>  {
  factory $WealthItemCopyWith(WealthItem value, $Res Function(WealthItem) _then) = _$WealthItemCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, String name, int sortOrder, bool isActive
});




}
/// @nodoc
class _$WealthItemCopyWithImpl<$Res>
    implements $WealthItemCopyWith<$Res> {
  _$WealthItemCopyWithImpl(this._self, this._then);

  final WealthItem _self;
  final $Res Function(WealthItem) _then;

/// Create a copy of WealthItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? name = null,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(WealthItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WealthItem].
extension WealthItemPatterns on WealthItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WealthItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WealthItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WealthItem value)  $default,){
final _that = this;
switch (_that) {
case _WealthItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WealthItem value)?  $default,){
final _that = this;
switch (_that) {
case _WealthItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  String name,  int sortOrder,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WealthItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.name,_that.sortOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  String name,  int sortOrder,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _WealthItem():
return $default(_that.id,_that.categoryId,_that.name,_that.sortOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  String name,  int sortOrder,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _WealthItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.name,_that.sortOrder,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _WealthItem implements WealthItem {
  const _WealthItem({required this.id, required this.categoryId, required this.name, this.sortOrder = 0, this.isActive = true});
  

@override final  String id;
@override final  String categoryId;
@override final  String name;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isActive;

/// Create a copy of WealthItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WealthItemCopyWith<_WealthItem> get copyWith => __$WealthItemCopyWithImpl<_WealthItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WealthItem&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,categoryId,name,sortOrder,isActive);
}

@override
String toString() {
    return 'WealthItem(id: $id, categoryId: $categoryId, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$WealthItemCopyWith<$Res> implements $WealthItemCopyWith<$Res> {
  factory _$WealthItemCopyWith(_WealthItem value, $Res Function(_WealthItem) _then) = __$WealthItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, String name, int sortOrder, bool isActive
});




}
/// @nodoc
class __$WealthItemCopyWithImpl<$Res>
    implements _$WealthItemCopyWith<$Res> {
  __$WealthItemCopyWithImpl(this._self, this._then);

  final _WealthItem _self;
  final $Res Function(_WealthItem) _then;

/// Create a copy of WealthItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? name = null,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(_WealthItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
