// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trading_core_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TradingCoreState {

 AppState get appState; DateTime get nowEAT;
/// Create a copy of TradingCoreState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradingCoreStateCopyWith<TradingCoreState> get copyWith => _$TradingCoreStateCopyWithImpl<TradingCoreState>(this as TradingCoreState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradingCoreState&&(identical(other.appState, appState) || other.appState == appState)&&(identical(other.nowEAT, nowEAT) || other.nowEAT == nowEAT));
}


@override
int get hashCode => Object.hash(runtimeType,appState,nowEAT);

@override
String toString() {
  return 'TradingCoreState(appState: $appState, nowEAT: $nowEAT)';
}


}

/// @nodoc
abstract mixin class $TradingCoreStateCopyWith<$Res>  {
  factory $TradingCoreStateCopyWith(TradingCoreState value, $Res Function(TradingCoreState) _then) = _$TradingCoreStateCopyWithImpl;
@useResult
$Res call({
 AppState appState, DateTime nowEAT
});


$AppStateCopyWith<$Res> get appState;

}
/// @nodoc
class _$TradingCoreStateCopyWithImpl<$Res>
    implements $TradingCoreStateCopyWith<$Res> {
  _$TradingCoreStateCopyWithImpl(this._self, this._then);

  final TradingCoreState _self;
  final $Res Function(TradingCoreState) _then;

/// Create a copy of TradingCoreState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appState = null,Object? nowEAT = null,}) {
  return _then(_self.copyWith(
appState: null == appState ? _self.appState : appState // ignore: cast_nullable_to_non_nullable
as AppState,nowEAT: null == nowEAT ? _self.nowEAT : nowEAT // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TradingCoreState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppStateCopyWith<$Res> get appState {
  
  return $AppStateCopyWith<$Res>(_self.appState, (value) {
    return _then(_self.copyWith(appState: value));
  });
}
}


/// Adds pattern-matching-related methods to [TradingCoreState].
extension TradingCoreStatePatterns on TradingCoreState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradingCoreState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradingCoreState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradingCoreState value)  $default,){
final _that = this;
switch (_that) {
case _TradingCoreState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradingCoreState value)?  $default,){
final _that = this;
switch (_that) {
case _TradingCoreState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppState appState,  DateTime nowEAT)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradingCoreState() when $default != null:
return $default(_that.appState,_that.nowEAT);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppState appState,  DateTime nowEAT)  $default,) {final _that = this;
switch (_that) {
case _TradingCoreState():
return $default(_that.appState,_that.nowEAT);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppState appState,  DateTime nowEAT)?  $default,) {final _that = this;
switch (_that) {
case _TradingCoreState() when $default != null:
return $default(_that.appState,_that.nowEAT);case _:
  return null;

}
}

}

/// @nodoc


class _TradingCoreState implements TradingCoreState {
  const _TradingCoreState({required this.appState, required this.nowEAT});
  

@override final  AppState appState;
@override final  DateTime nowEAT;

/// Create a copy of TradingCoreState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradingCoreStateCopyWith<_TradingCoreState> get copyWith => __$TradingCoreStateCopyWithImpl<_TradingCoreState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradingCoreState&&(identical(other.appState, appState) || other.appState == appState)&&(identical(other.nowEAT, nowEAT) || other.nowEAT == nowEAT));
}


@override
int get hashCode => Object.hash(runtimeType,appState,nowEAT);

@override
String toString() {
  return 'TradingCoreState(appState: $appState, nowEAT: $nowEAT)';
}


}

/// @nodoc
abstract mixin class _$TradingCoreStateCopyWith<$Res> implements $TradingCoreStateCopyWith<$Res> {
  factory _$TradingCoreStateCopyWith(_TradingCoreState value, $Res Function(_TradingCoreState) _then) = __$TradingCoreStateCopyWithImpl;
@override @useResult
$Res call({
 AppState appState, DateTime nowEAT
});


@override $AppStateCopyWith<$Res> get appState;

}
/// @nodoc
class __$TradingCoreStateCopyWithImpl<$Res>
    implements _$TradingCoreStateCopyWith<$Res> {
  __$TradingCoreStateCopyWithImpl(this._self, this._then);

  final _TradingCoreState _self;
  final $Res Function(_TradingCoreState) _then;

/// Create a copy of TradingCoreState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appState = null,Object? nowEAT = null,}) {
  return _then(_TradingCoreState(
appState: null == appState ? _self.appState : appState // ignore: cast_nullable_to_non_nullable
as AppState,nowEAT: null == nowEAT ? _self.nowEAT : nowEAT // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TradingCoreState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppStateCopyWith<$Res> get appState {
  
  return $AppStateCopyWith<$Res>(_self.appState, (value) {
    return _then(_self.copyWith(appState: value));
  });
}
}

// dart format on
