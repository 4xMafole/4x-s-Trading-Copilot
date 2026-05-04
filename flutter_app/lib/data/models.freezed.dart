// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trade {

 String get id; String get date; String get time; String get sym; String get dir; double get lots; double get pnl; String get note; List<String> get violations; List<String> get tags; String? get htfImage; String? get ltfImage; bool get isHypothetical;
/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeCopyWith<Trade> get copyWith => _$TradeCopyWithImpl<Trade>(this as Trade, _$identity);

  /// Serializes this Trade to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trade&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.sym, sym) || other.sym == sym)&&(identical(other.dir, dir) || other.dir == dir)&&(identical(other.lots, lots) || other.lots == lots)&&(identical(other.pnl, pnl) || other.pnl == pnl)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.violations, violations)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.htfImage, htfImage) || other.htfImage == htfImage)&&(identical(other.ltfImage, ltfImage) || other.ltfImage == ltfImage)&&(identical(other.isHypothetical, isHypothetical) || other.isHypothetical == isHypothetical));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,time,sym,dir,lots,pnl,note,const DeepCollectionEquality().hash(violations),const DeepCollectionEquality().hash(tags),htfImage,ltfImage,isHypothetical);

@override
String toString() {
  return 'Trade(id: $id, date: $date, time: $time, sym: $sym, dir: $dir, lots: $lots, pnl: $pnl, note: $note, violations: $violations, tags: $tags, htfImage: $htfImage, ltfImage: $ltfImage, isHypothetical: $isHypothetical)';
}


}

/// @nodoc
abstract mixin class $TradeCopyWith<$Res>  {
  factory $TradeCopyWith(Trade value, $Res Function(Trade) _then) = _$TradeCopyWithImpl;
@useResult
$Res call({
 String id, String date, String time, String sym, String dir, double lots, double pnl, String note, List<String> violations, List<String> tags, String? htfImage, String? ltfImage, bool isHypothetical
});




}
/// @nodoc
class _$TradeCopyWithImpl<$Res>
    implements $TradeCopyWith<$Res> {
  _$TradeCopyWithImpl(this._self, this._then);

  final Trade _self;
  final $Res Function(Trade) _then;

/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? time = null,Object? sym = null,Object? dir = null,Object? lots = null,Object? pnl = null,Object? note = null,Object? violations = null,Object? tags = null,Object? htfImage = freezed,Object? ltfImage = freezed,Object? isHypothetical = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,sym: null == sym ? _self.sym : sym // ignore: cast_nullable_to_non_nullable
as String,dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as String,lots: null == lots ? _self.lots : lots // ignore: cast_nullable_to_non_nullable
as double,pnl: null == pnl ? _self.pnl : pnl // ignore: cast_nullable_to_non_nullable
as double,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,violations: null == violations ? _self.violations : violations // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,htfImage: freezed == htfImage ? _self.htfImage : htfImage // ignore: cast_nullable_to_non_nullable
as String?,ltfImage: freezed == ltfImage ? _self.ltfImage : ltfImage // ignore: cast_nullable_to_non_nullable
as String?,isHypothetical: null == isHypothetical ? _self.isHypothetical : isHypothetical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Trade].
extension TradePatterns on Trade {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trade value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trade() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trade value)  $default,){
final _that = this;
switch (_that) {
case _Trade():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trade value)?  $default,){
final _that = this;
switch (_that) {
case _Trade() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String date,  String time,  String sym,  String dir,  double lots,  double pnl,  String note,  List<String> violations,  List<String> tags,  String? htfImage,  String? ltfImage,  bool isHypothetical)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trade() when $default != null:
return $default(_that.id,_that.date,_that.time,_that.sym,_that.dir,_that.lots,_that.pnl,_that.note,_that.violations,_that.tags,_that.htfImage,_that.ltfImage,_that.isHypothetical);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String date,  String time,  String sym,  String dir,  double lots,  double pnl,  String note,  List<String> violations,  List<String> tags,  String? htfImage,  String? ltfImage,  bool isHypothetical)  $default,) {final _that = this;
switch (_that) {
case _Trade():
return $default(_that.id,_that.date,_that.time,_that.sym,_that.dir,_that.lots,_that.pnl,_that.note,_that.violations,_that.tags,_that.htfImage,_that.ltfImage,_that.isHypothetical);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String date,  String time,  String sym,  String dir,  double lots,  double pnl,  String note,  List<String> violations,  List<String> tags,  String? htfImage,  String? ltfImage,  bool isHypothetical)?  $default,) {final _that = this;
switch (_that) {
case _Trade() when $default != null:
return $default(_that.id,_that.date,_that.time,_that.sym,_that.dir,_that.lots,_that.pnl,_that.note,_that.violations,_that.tags,_that.htfImage,_that.ltfImage,_that.isHypothetical);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trade implements Trade {
  const _Trade({required this.id, required this.date, required this.time, this.sym = 'XAUUSD', this.dir = 'buy', this.lots = 0.0, this.pnl = 0.0, this.note = '', final  List<String> violations = const [], final  List<String> tags = const [], this.htfImage, this.ltfImage, this.isHypothetical = false}): _violations = violations,_tags = tags;
  factory _Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);

@override final  String id;
@override final  String date;
@override final  String time;
@override@JsonKey() final  String sym;
@override@JsonKey() final  String dir;
@override@JsonKey() final  double lots;
@override@JsonKey() final  double pnl;
@override@JsonKey() final  String note;
 final  List<String> _violations;
@override@JsonKey() List<String> get violations {
  if (_violations is EqualUnmodifiableListView) return _violations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_violations);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? htfImage;
@override final  String? ltfImage;
@override@JsonKey() final  bool isHypothetical;

/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeCopyWith<_Trade> get copyWith => __$TradeCopyWithImpl<_Trade>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trade&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.sym, sym) || other.sym == sym)&&(identical(other.dir, dir) || other.dir == dir)&&(identical(other.lots, lots) || other.lots == lots)&&(identical(other.pnl, pnl) || other.pnl == pnl)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._violations, _violations)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.htfImage, htfImage) || other.htfImage == htfImage)&&(identical(other.ltfImage, ltfImage) || other.ltfImage == ltfImage)&&(identical(other.isHypothetical, isHypothetical) || other.isHypothetical == isHypothetical));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,time,sym,dir,lots,pnl,note,const DeepCollectionEquality().hash(_violations),const DeepCollectionEquality().hash(_tags),htfImage,ltfImage,isHypothetical);

@override
String toString() {
  return 'Trade(id: $id, date: $date, time: $time, sym: $sym, dir: $dir, lots: $lots, pnl: $pnl, note: $note, violations: $violations, tags: $tags, htfImage: $htfImage, ltfImage: $ltfImage, isHypothetical: $isHypothetical)';
}


}

/// @nodoc
abstract mixin class _$TradeCopyWith<$Res> implements $TradeCopyWith<$Res> {
  factory _$TradeCopyWith(_Trade value, $Res Function(_Trade) _then) = __$TradeCopyWithImpl;
@override @useResult
$Res call({
 String id, String date, String time, String sym, String dir, double lots, double pnl, String note, List<String> violations, List<String> tags, String? htfImage, String? ltfImage, bool isHypothetical
});




}
/// @nodoc
class __$TradeCopyWithImpl<$Res>
    implements _$TradeCopyWith<$Res> {
  __$TradeCopyWithImpl(this._self, this._then);

  final _Trade _self;
  final $Res Function(_Trade) _then;

/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? time = null,Object? sym = null,Object? dir = null,Object? lots = null,Object? pnl = null,Object? note = null,Object? violations = null,Object? tags = null,Object? htfImage = freezed,Object? ltfImage = freezed,Object? isHypothetical = null,}) {
  return _then(_Trade(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,sym: null == sym ? _self.sym : sym // ignore: cast_nullable_to_non_nullable
as String,dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as String,lots: null == lots ? _self.lots : lots // ignore: cast_nullable_to_non_nullable
as double,pnl: null == pnl ? _self.pnl : pnl // ignore: cast_nullable_to_non_nullable
as double,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,violations: null == violations ? _self._violations : violations // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,htfImage: freezed == htfImage ? _self.htfImage : htfImage // ignore: cast_nullable_to_non_nullable
as String?,ltfImage: freezed == ltfImage ? _self.ltfImage : ltfImage // ignore: cast_nullable_to_non_nullable
as String?,isHypothetical: null == isHypothetical ? _self.isHypothetical : isHypothetical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AppState {

 int get schemaVersion; double get balance; String get startDate; double get priorPnl; Map<String, bool> get checks; List<Trade> get allTrades; bool get lock; int? get lockUntil; bool get preloaded;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.priorPnl, priorPnl) || other.priorPnl == priorPnl)&&const DeepCollectionEquality().equals(other.checks, checks)&&const DeepCollectionEquality().equals(other.allTrades, allTrades)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.lockUntil, lockUntil) || other.lockUntil == lockUntil)&&(identical(other.preloaded, preloaded) || other.preloaded == preloaded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,balance,startDate,priorPnl,const DeepCollectionEquality().hash(checks),const DeepCollectionEquality().hash(allTrades),lock,lockUntil,preloaded);

@override
String toString() {
  return 'AppState(schemaVersion: $schemaVersion, balance: $balance, startDate: $startDate, priorPnl: $priorPnl, checks: $checks, allTrades: $allTrades, lock: $lock, lockUntil: $lockUntil, preloaded: $preloaded)';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, double balance, String startDate, double priorPnl, Map<String, bool> checks, List<Trade> allTrades, bool lock, int? lockUntil, bool preloaded
});




}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? balance = null,Object? startDate = null,Object? priorPnl = null,Object? checks = null,Object? allTrades = null,Object? lock = null,Object? lockUntil = freezed,Object? preloaded = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,priorPnl: null == priorPnl ? _self.priorPnl : priorPnl // ignore: cast_nullable_to_non_nullable
as double,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,allTrades: null == allTrades ? _self.allTrades : allTrades // ignore: cast_nullable_to_non_nullable
as List<Trade>,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,lockUntil: freezed == lockUntil ? _self.lockUntil : lockUntil // ignore: cast_nullable_to_non_nullable
as int?,preloaded: null == preloaded ? _self.preloaded : preloaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppState value)  $default,){
final _that = this;
switch (_that) {
case _AppState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppState value)?  $default,){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  double balance,  String startDate,  double priorPnl,  Map<String, bool> checks,  List<Trade> allTrades,  bool lock,  int? lockUntil,  bool preloaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.schemaVersion,_that.balance,_that.startDate,_that.priorPnl,_that.checks,_that.allTrades,_that.lock,_that.lockUntil,_that.preloaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  double balance,  String startDate,  double priorPnl,  Map<String, bool> checks,  List<Trade> allTrades,  bool lock,  int? lockUntil,  bool preloaded)  $default,) {final _that = this;
switch (_that) {
case _AppState():
return $default(_that.schemaVersion,_that.balance,_that.startDate,_that.priorPnl,_that.checks,_that.allTrades,_that.lock,_that.lockUntil,_that.preloaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  double balance,  String startDate,  double priorPnl,  Map<String, bool> checks,  List<Trade> allTrades,  bool lock,  int? lockUntil,  bool preloaded)?  $default,) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.schemaVersion,_that.balance,_that.startDate,_that.priorPnl,_that.checks,_that.allTrades,_that.lock,_that.lockUntil,_that.preloaded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppState extends AppState {
  const _AppState({this.schemaVersion = kCurrentSchemaVersion, this.balance = 25000.0, this.startDate = '2026-04-20', this.priorPnl = 0.0, final  Map<String, bool> checks = const {}, final  List<Trade> allTrades = const [], this.lock = false, this.lockUntil, this.preloaded = false}): _checks = checks,_allTrades = allTrades,super._();
  factory _AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  double balance;
@override@JsonKey() final  String startDate;
@override@JsonKey() final  double priorPnl;
 final  Map<String, bool> _checks;
@override@JsonKey() Map<String, bool> get checks {
  if (_checks is EqualUnmodifiableMapView) return _checks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_checks);
}

 final  List<Trade> _allTrades;
@override@JsonKey() List<Trade> get allTrades {
  if (_allTrades is EqualUnmodifiableListView) return _allTrades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allTrades);
}

@override@JsonKey() final  bool lock;
@override final  int? lockUntil;
@override@JsonKey() final  bool preloaded;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStateCopyWith<_AppState> get copyWith => __$AppStateCopyWithImpl<_AppState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.priorPnl, priorPnl) || other.priorPnl == priorPnl)&&const DeepCollectionEquality().equals(other._checks, _checks)&&const DeepCollectionEquality().equals(other._allTrades, _allTrades)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.lockUntil, lockUntil) || other.lockUntil == lockUntil)&&(identical(other.preloaded, preloaded) || other.preloaded == preloaded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,balance,startDate,priorPnl,const DeepCollectionEquality().hash(_checks),const DeepCollectionEquality().hash(_allTrades),lock,lockUntil,preloaded);

@override
String toString() {
  return 'AppState(schemaVersion: $schemaVersion, balance: $balance, startDate: $startDate, priorPnl: $priorPnl, checks: $checks, allTrades: $allTrades, lock: $lock, lockUntil: $lockUntil, preloaded: $preloaded)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, double balance, String startDate, double priorPnl, Map<String, bool> checks, List<Trade> allTrades, bool lock, int? lockUntil, bool preloaded
});




}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? balance = null,Object? startDate = null,Object? priorPnl = null,Object? checks = null,Object? allTrades = null,Object? lock = null,Object? lockUntil = freezed,Object? preloaded = null,}) {
  return _then(_AppState(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,priorPnl: null == priorPnl ? _self.priorPnl : priorPnl // ignore: cast_nullable_to_non_nullable
as double,checks: null == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,allTrades: null == allTrades ? _self._allTrades : allTrades // ignore: cast_nullable_to_non_nullable
as List<Trade>,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,lockUntil: freezed == lockUntil ? _self.lockUntil : lockUntil // ignore: cast_nullable_to_non_nullable
as int?,preloaded: null == preloaded ? _self.preloaded : preloaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
