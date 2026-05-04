// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_coach_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiCoachState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCoachState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AiCoachState()';
}


}

/// @nodoc
class $AiCoachStateCopyWith<$Res>  {
$AiCoachStateCopyWith(AiCoachState _, $Res Function(AiCoachState) __);
}


/// Adds pattern-matching-related methods to [AiCoachState].
extension AiCoachStatePatterns on AiCoachState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AiCoachStateInitial value)?  initial,TResult Function( AiCoachStateLoading value)?  loading,TResult Function( AiCoachStateSuccess value)?  success,TResult Function( AiCoachStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AiCoachStateInitial() when initial != null:
return initial(_that);case AiCoachStateLoading() when loading != null:
return loading(_that);case AiCoachStateSuccess() when success != null:
return success(_that);case AiCoachStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AiCoachStateInitial value)  initial,required TResult Function( AiCoachStateLoading value)  loading,required TResult Function( AiCoachStateSuccess value)  success,required TResult Function( AiCoachStateError value)  error,}){
final _that = this;
switch (_that) {
case AiCoachStateInitial():
return initial(_that);case AiCoachStateLoading():
return loading(_that);case AiCoachStateSuccess():
return success(_that);case AiCoachStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AiCoachStateInitial value)?  initial,TResult? Function( AiCoachStateLoading value)?  loading,TResult? Function( AiCoachStateSuccess value)?  success,TResult? Function( AiCoachStateError value)?  error,}){
final _that = this;
switch (_that) {
case AiCoachStateInitial() when initial != null:
return initial(_that);case AiCoachStateLoading() when loading != null:
return loading(_that);case AiCoachStateSuccess() when success != null:
return success(_that);case AiCoachStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( AiReport report)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AiCoachStateInitial() when initial != null:
return initial();case AiCoachStateLoading() when loading != null:
return loading();case AiCoachStateSuccess() when success != null:
return success(_that.report);case AiCoachStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( AiReport report)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case AiCoachStateInitial():
return initial();case AiCoachStateLoading():
return loading();case AiCoachStateSuccess():
return success(_that.report);case AiCoachStateError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( AiReport report)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case AiCoachStateInitial() when initial != null:
return initial();case AiCoachStateLoading() when loading != null:
return loading();case AiCoachStateSuccess() when success != null:
return success(_that.report);case AiCoachStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AiCoachStateInitial implements AiCoachState {
  const AiCoachStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCoachStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AiCoachState.initial()';
}


}




/// @nodoc


class AiCoachStateLoading implements AiCoachState {
  const AiCoachStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCoachStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AiCoachState.loading()';
}


}




/// @nodoc


class AiCoachStateSuccess implements AiCoachState {
  const AiCoachStateSuccess(this.report);
  

 final  AiReport report;

/// Create a copy of AiCoachState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiCoachStateSuccessCopyWith<AiCoachStateSuccess> get copyWith => _$AiCoachStateSuccessCopyWithImpl<AiCoachStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCoachStateSuccess&&(identical(other.report, report) || other.report == report));
}


@override
int get hashCode => Object.hash(runtimeType,report);

@override
String toString() {
  return 'AiCoachState.success(report: $report)';
}


}

/// @nodoc
abstract mixin class $AiCoachStateSuccessCopyWith<$Res> implements $AiCoachStateCopyWith<$Res> {
  factory $AiCoachStateSuccessCopyWith(AiCoachStateSuccess value, $Res Function(AiCoachStateSuccess) _then) = _$AiCoachStateSuccessCopyWithImpl;
@useResult
$Res call({
 AiReport report
});




}
/// @nodoc
class _$AiCoachStateSuccessCopyWithImpl<$Res>
    implements $AiCoachStateSuccessCopyWith<$Res> {
  _$AiCoachStateSuccessCopyWithImpl(this._self, this._then);

  final AiCoachStateSuccess _self;
  final $Res Function(AiCoachStateSuccess) _then;

/// Create a copy of AiCoachState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? report = null,}) {
  return _then(AiCoachStateSuccess(
null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as AiReport,
  ));
}


}

/// @nodoc


class AiCoachStateError implements AiCoachState {
  const AiCoachStateError(this.message);
  

 final  String message;

/// Create a copy of AiCoachState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiCoachStateErrorCopyWith<AiCoachStateError> get copyWith => _$AiCoachStateErrorCopyWithImpl<AiCoachStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCoachStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AiCoachState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $AiCoachStateErrorCopyWith<$Res> implements $AiCoachStateCopyWith<$Res> {
  factory $AiCoachStateErrorCopyWith(AiCoachStateError value, $Res Function(AiCoachStateError) _then) = _$AiCoachStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AiCoachStateErrorCopyWithImpl<$Res>
    implements $AiCoachStateErrorCopyWith<$Res> {
  _$AiCoachStateErrorCopyWithImpl(this._self, this._then);

  final AiCoachStateError _self;
  final $Res Function(AiCoachStateError) _then;

/// Create a copy of AiCoachState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AiCoachStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
