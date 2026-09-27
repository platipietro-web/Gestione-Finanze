// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Snapshot {

 String get id; YearMonth get month; List<SnapshotItem> get items; DateTime? get updatedAt;
/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotCopyWith<Snapshot> get copyWith => _$SnapshotCopyWithImpl<Snapshot>(this as Snapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Snapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Snapshot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.month, _this.month) || other.month == _this.month)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as Snapshot;
  return Object.hash(runtimeType,_this.id,_this.month,const DeepCollectionEquality().hash(_this.items),_this.updatedAt);
}

@override
String toString() {
  final _this = this as Snapshot;
  return 'Snapshot(id: ${_this.id}, month: ${_this.month}, items: ${_this.items}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SnapshotCopyWith<$Res>  {
  factory $SnapshotCopyWith(Snapshot value, $Res Function(Snapshot) _then) = _$SnapshotCopyWithImpl;
@useResult
$Res call({
 String id, YearMonth month, List<SnapshotItem> items, DateTime? updatedAt
});




}
/// @nodoc
class _$SnapshotCopyWithImpl<$Res>
    implements $SnapshotCopyWith<$Res> {
  _$SnapshotCopyWithImpl(this._self, this._then);

  final Snapshot _self;
  final $Res Function(Snapshot) _then;

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? month = null,Object? items = null,Object? updatedAt = freezed,}) {
  return _then(Snapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SnapshotItem>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Snapshot].
extension SnapshotPatterns on Snapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Snapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Snapshot value)  $default,){
final _that = this;
switch (_that) {
case _Snapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Snapshot value)?  $default,){
final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  YearMonth month,  List<SnapshotItem> items,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
return $default(_that.id,_that.month,_that.items,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  YearMonth month,  List<SnapshotItem> items,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Snapshot():
return $default(_that.id,_that.month,_that.items,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  YearMonth month,  List<SnapshotItem> items,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Snapshot() when $default != null:
return $default(_that.id,_that.month,_that.items,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Snapshot implements Snapshot {
  const _Snapshot({required this.id, required this.month, required  List<SnapshotItem> items, this.updatedAt}): _items = items;
  

@override final  String id;
@override final  YearMonth month;
 final  List<SnapshotItem> _items;
@override List<SnapshotItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  DateTime? updatedAt;

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnapshotCopyWith<_Snapshot> get copyWith => __$SnapshotCopyWithImpl<_Snapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Snapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.month, month) || other.month == month)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,month,const DeepCollectionEquality().hash(_items),updatedAt);
}

@override
String toString() {
    return 'Snapshot(id: $id, month: $month, items: $items, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnapshotCopyWith<$Res> implements $SnapshotCopyWith<$Res> {
  factory _$SnapshotCopyWith(_Snapshot value, $Res Function(_Snapshot) _then) = __$SnapshotCopyWithImpl;
@override @useResult
$Res call({
 String id, YearMonth month, List<SnapshotItem> items, DateTime? updatedAt
});




}
/// @nodoc
class __$SnapshotCopyWithImpl<$Res>
    implements _$SnapshotCopyWith<$Res> {
  __$SnapshotCopyWithImpl(this._self, this._then);

  final _Snapshot _self;
  final $Res Function(_Snapshot) _then;

/// Create a copy of Snapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? month = null,Object? items = null,Object? updatedAt = freezed,}) {
  return _then(_Snapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SnapshotItem>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$SnapshotItem {

/// Legame con la voce attuale; `null` se la voce è stata eliminata.
 String? get itemId; String? get categoryId; String get itemName; String get categoryName; ItemKind get kind; bool get isInvestment; int get categoryOrder; int get itemOrder; Money get amount;
/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotItemCopyWith<SnapshotItem> get copyWith => _$SnapshotItemCopyWithImpl<SnapshotItem>(this as SnapshotItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SnapshotItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapshotItem&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.itemName, _this.itemName) || other.itemName == _this.itemName)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.isInvestment, _this.isInvestment) || other.isInvestment == _this.isInvestment)&&(identical(other.categoryOrder, _this.categoryOrder) || other.categoryOrder == _this.categoryOrder)&&(identical(other.itemOrder, _this.itemOrder) || other.itemOrder == _this.itemOrder)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}


@override
int get hashCode {
  final _this = this as SnapshotItem;
  return Object.hash(runtimeType,_this.itemId,_this.categoryId,_this.itemName,_this.categoryName,_this.kind,_this.isInvestment,_this.categoryOrder,_this.itemOrder,_this.amount);
}

@override
String toString() {
  final _this = this as SnapshotItem;
  return 'SnapshotItem(itemId: ${_this.itemId}, categoryId: ${_this.categoryId}, itemName: ${_this.itemName}, categoryName: ${_this.categoryName}, kind: ${_this.kind}, isInvestment: ${_this.isInvestment}, categoryOrder: ${_this.categoryOrder}, itemOrder: ${_this.itemOrder}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $SnapshotItemCopyWith<$Res>  {
  factory $SnapshotItemCopyWith(SnapshotItem value, $Res Function(SnapshotItem) _then) = _$SnapshotItemCopyWithImpl;
@useResult
$Res call({
 String? itemId, String? categoryId, String itemName, String categoryName, ItemKind kind, bool isInvestment, int categoryOrder, int itemOrder, Money amount
});




}
/// @nodoc
class _$SnapshotItemCopyWithImpl<$Res>
    implements $SnapshotItemCopyWith<$Res> {
  _$SnapshotItemCopyWithImpl(this._self, this._then);

  final SnapshotItem _self;
  final $Res Function(SnapshotItem) _then;

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = freezed,Object? categoryId = freezed,Object? itemName = null,Object? categoryName = null,Object? kind = null,Object? isInvestment = null,Object? categoryOrder = null,Object? itemOrder = null,Object? amount = null,}) {
  return _then(SnapshotItem(
itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ItemKind,isInvestment: null == isInvestment ? _self.isInvestment : isInvestment // ignore: cast_nullable_to_non_nullable
as bool,categoryOrder: null == categoryOrder ? _self.categoryOrder : categoryOrder // ignore: cast_nullable_to_non_nullable
as int,itemOrder: null == itemOrder ? _self.itemOrder : itemOrder // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [SnapshotItem].
extension SnapshotItemPatterns on SnapshotItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnapshotItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnapshotItem value)  $default,){
final _that = this;
switch (_that) {
case _SnapshotItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnapshotItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? itemId,  String? categoryId,  String itemName,  String categoryName,  ItemKind kind,  bool isInvestment,  int categoryOrder,  int itemOrder,  Money amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
return $default(_that.itemId,_that.categoryId,_that.itemName,_that.categoryName,_that.kind,_that.isInvestment,_that.categoryOrder,_that.itemOrder,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? itemId,  String? categoryId,  String itemName,  String categoryName,  ItemKind kind,  bool isInvestment,  int categoryOrder,  int itemOrder,  Money amount)  $default,) {final _that = this;
switch (_that) {
case _SnapshotItem():
return $default(_that.itemId,_that.categoryId,_that.itemName,_that.categoryName,_that.kind,_that.isInvestment,_that.categoryOrder,_that.itemOrder,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? itemId,  String? categoryId,  String itemName,  String categoryName,  ItemKind kind,  bool isInvestment,  int categoryOrder,  int itemOrder,  Money amount)?  $default,) {final _that = this;
switch (_that) {
case _SnapshotItem() when $default != null:
return $default(_that.itemId,_that.categoryId,_that.itemName,_that.categoryName,_that.kind,_that.isInvestment,_that.categoryOrder,_that.itemOrder,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _SnapshotItem extends SnapshotItem {
  const _SnapshotItem({this.itemId, this.categoryId, required this.itemName, required this.categoryName, required this.kind, this.isInvestment = false, this.categoryOrder = 0, this.itemOrder = 0, required this.amount}): super._();
  

/// Legame con la voce attuale; `null` se la voce è stata eliminata.
@override final  String? itemId;
@override final  String? categoryId;
@override final  String itemName;
@override final  String categoryName;
@override final  ItemKind kind;
@override@JsonKey() final  bool isInvestment;
@override@JsonKey() final  int categoryOrder;
@override@JsonKey() final  int itemOrder;
@override final  Money amount;

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnapshotItemCopyWith<_SnapshotItem> get copyWith => __$SnapshotItemCopyWithImpl<_SnapshotItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnapshotItem&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.isInvestment, isInvestment) || other.isInvestment == isInvestment)&&(identical(other.categoryOrder, categoryOrder) || other.categoryOrder == categoryOrder)&&(identical(other.itemOrder, itemOrder) || other.itemOrder == itemOrder)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemId,categoryId,itemName,categoryName,kind,isInvestment,categoryOrder,itemOrder,amount);
}

@override
String toString() {
    return 'SnapshotItem(itemId: $itemId, categoryId: $categoryId, itemName: $itemName, categoryName: $categoryName, kind: $kind, isInvestment: $isInvestment, categoryOrder: $categoryOrder, itemOrder: $itemOrder, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$SnapshotItemCopyWith<$Res> implements $SnapshotItemCopyWith<$Res> {
  factory _$SnapshotItemCopyWith(_SnapshotItem value, $Res Function(_SnapshotItem) _then) = __$SnapshotItemCopyWithImpl;
@override @useResult
$Res call({
 String? itemId, String? categoryId, String itemName, String categoryName, ItemKind kind, bool isInvestment, int categoryOrder, int itemOrder, Money amount
});




}
/// @nodoc
class __$SnapshotItemCopyWithImpl<$Res>
    implements _$SnapshotItemCopyWith<$Res> {
  __$SnapshotItemCopyWithImpl(this._self, this._then);

  final _SnapshotItem _self;
  final $Res Function(_SnapshotItem) _then;

/// Create a copy of SnapshotItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = freezed,Object? categoryId = freezed,Object? itemName = null,Object? categoryName = null,Object? kind = null,Object? isInvestment = null,Object? categoryOrder = null,Object? itemOrder = null,Object? amount = null,}) {
  return _then(_SnapshotItem(
itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ItemKind,isInvestment: null == isInvestment ? _self.isInvestment : isInvestment // ignore: cast_nullable_to_non_nullable
as bool,categoryOrder: null == categoryOrder ? _self.categoryOrder : categoryOrder // ignore: cast_nullable_to_non_nullable
as int,itemOrder: null == itemOrder ? _self.itemOrder : itemOrder // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
