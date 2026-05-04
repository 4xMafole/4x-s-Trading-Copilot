// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 ThemeMode get themeMode; bool get biometricLockEnabled; bool get sessionAlertsEnabled; Map<String, String> get sessionAlertTimes; bool get hasSeenWalkthrough; bool get isLoading;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.biometricLockEnabled, biometricLockEnabled) || other.biometricLockEnabled == biometricLockEnabled)&&(identical(other.sessionAlertsEnabled, sessionAlertsEnabled) || other.sessionAlertsEnabled == sessionAlertsEnabled)&&const DeepCollectionEquality().equals(other.sessionAlertTimes, sessionAlertTimes)&&(identical(other.hasSeenWalkthrough, hasSeenWalkthrough) || other.hasSeenWalkthrough == hasSeenWalkthrough)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,biometricLockEnabled,sessionAlertsEnabled,const DeepCollectionEquality().hash(sessionAlertTimes),hasSeenWalkthrough,isLoading);

@override
String toString() {
  return 'SettingsState(themeMode: $themeMode, biometricLockEnabled: $biometricLockEnabled, sessionAlertsEnabled: $sessionAlertsEnabled, sessionAlertTimes: $sessionAlertTimes, hasSeenWalkthrough: $hasSeenWalkthrough, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, bool biometricLockEnabled, bool sessionAlertsEnabled, Map<String, String> sessionAlertTimes, bool hasSeenWalkthrough, bool isLoading
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? biometricLockEnabled = null,Object? sessionAlertsEnabled = null,Object? sessionAlertTimes = null,Object? hasSeenWalkthrough = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,biometricLockEnabled: null == biometricLockEnabled ? _self.biometricLockEnabled : biometricLockEnabled // ignore: cast_nullable_to_non_nullable
as bool,sessionAlertsEnabled: null == sessionAlertsEnabled ? _self.sessionAlertsEnabled : sessionAlertsEnabled // ignore: cast_nullable_to_non_nullable
as bool,sessionAlertTimes: null == sessionAlertTimes ? _self.sessionAlertTimes : sessionAlertTimes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hasSeenWalkthrough: null == hasSeenWalkthrough ? _self.hasSeenWalkthrough : hasSeenWalkthrough // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode themeMode,  bool biometricLockEnabled,  bool sessionAlertsEnabled,  Map<String, String> sessionAlertTimes,  bool hasSeenWalkthrough,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.themeMode,_that.biometricLockEnabled,_that.sessionAlertsEnabled,_that.sessionAlertTimes,_that.hasSeenWalkthrough,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode themeMode,  bool biometricLockEnabled,  bool sessionAlertsEnabled,  Map<String, String> sessionAlertTimes,  bool hasSeenWalkthrough,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.themeMode,_that.biometricLockEnabled,_that.sessionAlertsEnabled,_that.sessionAlertTimes,_that.hasSeenWalkthrough,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode themeMode,  bool biometricLockEnabled,  bool sessionAlertsEnabled,  Map<String, String> sessionAlertTimes,  bool hasSeenWalkthrough,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.themeMode,_that.biometricLockEnabled,_that.sessionAlertsEnabled,_that.sessionAlertTimes,_that.hasSeenWalkthrough,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.themeMode = ThemeMode.system, this.biometricLockEnabled = false, this.sessionAlertsEnabled = false, final  Map<String, String> sessionAlertTimes = const <String, String>{}, this.hasSeenWalkthrough = false, this.isLoading = true}): _sessionAlertTimes = sessionAlertTimes;
  

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  bool biometricLockEnabled;
@override@JsonKey() final  bool sessionAlertsEnabled;
 final  Map<String, String> _sessionAlertTimes;
@override@JsonKey() Map<String, String> get sessionAlertTimes {
  if (_sessionAlertTimes is EqualUnmodifiableMapView) return _sessionAlertTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionAlertTimes);
}

@override@JsonKey() final  bool hasSeenWalkthrough;
@override@JsonKey() final  bool isLoading;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.biometricLockEnabled, biometricLockEnabled) || other.biometricLockEnabled == biometricLockEnabled)&&(identical(other.sessionAlertsEnabled, sessionAlertsEnabled) || other.sessionAlertsEnabled == sessionAlertsEnabled)&&const DeepCollectionEquality().equals(other._sessionAlertTimes, _sessionAlertTimes)&&(identical(other.hasSeenWalkthrough, hasSeenWalkthrough) || other.hasSeenWalkthrough == hasSeenWalkthrough)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,themeMode,biometricLockEnabled,sessionAlertsEnabled,const DeepCollectionEquality().hash(_sessionAlertTimes),hasSeenWalkthrough,isLoading);

@override
String toString() {
  return 'SettingsState(themeMode: $themeMode, biometricLockEnabled: $biometricLockEnabled, sessionAlertsEnabled: $sessionAlertsEnabled, sessionAlertTimes: $sessionAlertTimes, hasSeenWalkthrough: $hasSeenWalkthrough, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, bool biometricLockEnabled, bool sessionAlertsEnabled, Map<String, String> sessionAlertTimes, bool hasSeenWalkthrough, bool isLoading
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? biometricLockEnabled = null,Object? sessionAlertsEnabled = null,Object? sessionAlertTimes = null,Object? hasSeenWalkthrough = null,Object? isLoading = null,}) {
  return _then(_SettingsState(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,biometricLockEnabled: null == biometricLockEnabled ? _self.biometricLockEnabled : biometricLockEnabled // ignore: cast_nullable_to_non_nullable
as bool,sessionAlertsEnabled: null == sessionAlertsEnabled ? _self.sessionAlertsEnabled : sessionAlertsEnabled // ignore: cast_nullable_to_non_nullable
as bool,sessionAlertTimes: null == sessionAlertTimes ? _self._sessionAlertTimes : sessionAlertTimes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hasSeenWalkthrough: null == hasSeenWalkthrough ? _self.hasSeenWalkthrough : hasSeenWalkthrough // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
