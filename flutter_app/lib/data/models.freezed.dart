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

 String get id; String get date; String get time; String get sym; String get dir; double get lots; double get pnl; String get note; List<String> get violations; List<String> get tags; String? get htfImage; String? get ltfImage; bool get isHypothetical;/// Mandatory setup grade for new trades. One of: A+, B, C.
/// Nullable so historical trades imported before Sprint 2.1 still load.
 String? get setupQuality;/// Mandatory trigger that caused the trade. One of:
/// Plan, FOMO, Revenge, Boredom, News, Other.
 String? get trigger;/// Optional 30-second post-trade reflection (Sprint 2.2).
 TradeReflection? get reflection;/// Sprint 4.3 — planned $ risk at entry (from calculator). Nullable
/// so older trades still deserialize.
 double? get plannedRisk;// ── Rich broker fields (from MT5/CSV import) — all optional so older
//    trades and manually-logged trades still deserialize cleanly.
/// Broker ticket / position number (e.g. MT5 position id).
 String? get ticketId;/// Open date (yyyy-MM-dd) when distinct from `date` (which is the
/// close date used for daily grouping).
 String? get openDate;/// Open time (HH:mm) when distinct from `time`.
 String? get openTime;/// Entry price.
 double? get openPrice;/// Exit price.
 double? get closePrice;/// Stop-loss price at trade open.
 double? get stopLoss;/// Take-profit price at trade open.
 double? get takeProfit;/// Broker commission (typically negative).
 double? get commission;/// Overnight swap fees (positive or negative).
 double? get swap;
/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeCopyWith<Trade> get copyWith => _$TradeCopyWithImpl<Trade>(this as Trade, _$identity);

  /// Serializes this Trade to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trade&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.sym, sym) || other.sym == sym)&&(identical(other.dir, dir) || other.dir == dir)&&(identical(other.lots, lots) || other.lots == lots)&&(identical(other.pnl, pnl) || other.pnl == pnl)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.violations, violations)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.htfImage, htfImage) || other.htfImage == htfImage)&&(identical(other.ltfImage, ltfImage) || other.ltfImage == ltfImage)&&(identical(other.isHypothetical, isHypothetical) || other.isHypothetical == isHypothetical)&&(identical(other.setupQuality, setupQuality) || other.setupQuality == setupQuality)&&(identical(other.trigger, trigger) || other.trigger == trigger)&&(identical(other.reflection, reflection) || other.reflection == reflection)&&(identical(other.plannedRisk, plannedRisk) || other.plannedRisk == plannedRisk)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.openDate, openDate) || other.openDate == openDate)&&(identical(other.openTime, openTime) || other.openTime == openTime)&&(identical(other.openPrice, openPrice) || other.openPrice == openPrice)&&(identical(other.closePrice, closePrice) || other.closePrice == closePrice)&&(identical(other.stopLoss, stopLoss) || other.stopLoss == stopLoss)&&(identical(other.takeProfit, takeProfit) || other.takeProfit == takeProfit)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.swap, swap) || other.swap == swap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,date,time,sym,dir,lots,pnl,note,const DeepCollectionEquality().hash(violations),const DeepCollectionEquality().hash(tags),htfImage,ltfImage,isHypothetical,setupQuality,trigger,reflection,plannedRisk,ticketId,openDate,openTime,openPrice,closePrice,stopLoss,takeProfit,commission,swap]);

@override
String toString() {
  return 'Trade(id: $id, date: $date, time: $time, sym: $sym, dir: $dir, lots: $lots, pnl: $pnl, note: $note, violations: $violations, tags: $tags, htfImage: $htfImage, ltfImage: $ltfImage, isHypothetical: $isHypothetical, setupQuality: $setupQuality, trigger: $trigger, reflection: $reflection, plannedRisk: $plannedRisk, ticketId: $ticketId, openDate: $openDate, openTime: $openTime, openPrice: $openPrice, closePrice: $closePrice, stopLoss: $stopLoss, takeProfit: $takeProfit, commission: $commission, swap: $swap)';
}


}

/// @nodoc
abstract mixin class $TradeCopyWith<$Res>  {
  factory $TradeCopyWith(Trade value, $Res Function(Trade) _then) = _$TradeCopyWithImpl;
@useResult
$Res call({
 String id, String date, String time, String sym, String dir, double lots, double pnl, String note, List<String> violations, List<String> tags, String? htfImage, String? ltfImage, bool isHypothetical, String? setupQuality, String? trigger, TradeReflection? reflection, double? plannedRisk, String? ticketId, String? openDate, String? openTime, double? openPrice, double? closePrice, double? stopLoss, double? takeProfit, double? commission, double? swap
});


$TradeReflectionCopyWith<$Res>? get reflection;

}
/// @nodoc
class _$TradeCopyWithImpl<$Res>
    implements $TradeCopyWith<$Res> {
  _$TradeCopyWithImpl(this._self, this._then);

  final Trade _self;
  final $Res Function(Trade) _then;

/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? time = null,Object? sym = null,Object? dir = null,Object? lots = null,Object? pnl = null,Object? note = null,Object? violations = null,Object? tags = null,Object? htfImage = freezed,Object? ltfImage = freezed,Object? isHypothetical = null,Object? setupQuality = freezed,Object? trigger = freezed,Object? reflection = freezed,Object? plannedRisk = freezed,Object? ticketId = freezed,Object? openDate = freezed,Object? openTime = freezed,Object? openPrice = freezed,Object? closePrice = freezed,Object? stopLoss = freezed,Object? takeProfit = freezed,Object? commission = freezed,Object? swap = freezed,}) {
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
as bool,setupQuality: freezed == setupQuality ? _self.setupQuality : setupQuality // ignore: cast_nullable_to_non_nullable
as String?,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,reflection: freezed == reflection ? _self.reflection : reflection // ignore: cast_nullable_to_non_nullable
as TradeReflection?,plannedRisk: freezed == plannedRisk ? _self.plannedRisk : plannedRisk // ignore: cast_nullable_to_non_nullable
as double?,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,openDate: freezed == openDate ? _self.openDate : openDate // ignore: cast_nullable_to_non_nullable
as String?,openTime: freezed == openTime ? _self.openTime : openTime // ignore: cast_nullable_to_non_nullable
as String?,openPrice: freezed == openPrice ? _self.openPrice : openPrice // ignore: cast_nullable_to_non_nullable
as double?,closePrice: freezed == closePrice ? _self.closePrice : closePrice // ignore: cast_nullable_to_non_nullable
as double?,stopLoss: freezed == stopLoss ? _self.stopLoss : stopLoss // ignore: cast_nullable_to_non_nullable
as double?,takeProfit: freezed == takeProfit ? _self.takeProfit : takeProfit // ignore: cast_nullable_to_non_nullable
as double?,commission: freezed == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double?,swap: freezed == swap ? _self.swap : swap // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TradeReflectionCopyWith<$Res>? get reflection {
    if (_self.reflection == null) {
    return null;
  }

  return $TradeReflectionCopyWith<$Res>(_self.reflection!, (value) {
    return _then(_self.copyWith(reflection: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String date,  String time,  String sym,  String dir,  double lots,  double pnl,  String note,  List<String> violations,  List<String> tags,  String? htfImage,  String? ltfImage,  bool isHypothetical,  String? setupQuality,  String? trigger,  TradeReflection? reflection,  double? plannedRisk,  String? ticketId,  String? openDate,  String? openTime,  double? openPrice,  double? closePrice,  double? stopLoss,  double? takeProfit,  double? commission,  double? swap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trade() when $default != null:
return $default(_that.id,_that.date,_that.time,_that.sym,_that.dir,_that.lots,_that.pnl,_that.note,_that.violations,_that.tags,_that.htfImage,_that.ltfImage,_that.isHypothetical,_that.setupQuality,_that.trigger,_that.reflection,_that.plannedRisk,_that.ticketId,_that.openDate,_that.openTime,_that.openPrice,_that.closePrice,_that.stopLoss,_that.takeProfit,_that.commission,_that.swap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String date,  String time,  String sym,  String dir,  double lots,  double pnl,  String note,  List<String> violations,  List<String> tags,  String? htfImage,  String? ltfImage,  bool isHypothetical,  String? setupQuality,  String? trigger,  TradeReflection? reflection,  double? plannedRisk,  String? ticketId,  String? openDate,  String? openTime,  double? openPrice,  double? closePrice,  double? stopLoss,  double? takeProfit,  double? commission,  double? swap)  $default,) {final _that = this;
switch (_that) {
case _Trade():
return $default(_that.id,_that.date,_that.time,_that.sym,_that.dir,_that.lots,_that.pnl,_that.note,_that.violations,_that.tags,_that.htfImage,_that.ltfImage,_that.isHypothetical,_that.setupQuality,_that.trigger,_that.reflection,_that.plannedRisk,_that.ticketId,_that.openDate,_that.openTime,_that.openPrice,_that.closePrice,_that.stopLoss,_that.takeProfit,_that.commission,_that.swap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String date,  String time,  String sym,  String dir,  double lots,  double pnl,  String note,  List<String> violations,  List<String> tags,  String? htfImage,  String? ltfImage,  bool isHypothetical,  String? setupQuality,  String? trigger,  TradeReflection? reflection,  double? plannedRisk,  String? ticketId,  String? openDate,  String? openTime,  double? openPrice,  double? closePrice,  double? stopLoss,  double? takeProfit,  double? commission,  double? swap)?  $default,) {final _that = this;
switch (_that) {
case _Trade() when $default != null:
return $default(_that.id,_that.date,_that.time,_that.sym,_that.dir,_that.lots,_that.pnl,_that.note,_that.violations,_that.tags,_that.htfImage,_that.ltfImage,_that.isHypothetical,_that.setupQuality,_that.trigger,_that.reflection,_that.plannedRisk,_that.ticketId,_that.openDate,_that.openTime,_that.openPrice,_that.closePrice,_that.stopLoss,_that.takeProfit,_that.commission,_that.swap);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trade implements Trade {
  const _Trade({required this.id, required this.date, required this.time, this.sym = 'XAUUSD', this.dir = 'buy', this.lots = 0.0, this.pnl = 0.0, this.note = '', final  List<String> violations = const [], final  List<String> tags = const [], this.htfImage, this.ltfImage, this.isHypothetical = false, this.setupQuality, this.trigger, this.reflection, this.plannedRisk, this.ticketId, this.openDate, this.openTime, this.openPrice, this.closePrice, this.stopLoss, this.takeProfit, this.commission, this.swap}): _violations = violations,_tags = tags;
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
/// Mandatory setup grade for new trades. One of: A+, B, C.
/// Nullable so historical trades imported before Sprint 2.1 still load.
@override final  String? setupQuality;
/// Mandatory trigger that caused the trade. One of:
/// Plan, FOMO, Revenge, Boredom, News, Other.
@override final  String? trigger;
/// Optional 30-second post-trade reflection (Sprint 2.2).
@override final  TradeReflection? reflection;
/// Sprint 4.3 — planned $ risk at entry (from calculator). Nullable
/// so older trades still deserialize.
@override final  double? plannedRisk;
// ── Rich broker fields (from MT5/CSV import) — all optional so older
//    trades and manually-logged trades still deserialize cleanly.
/// Broker ticket / position number (e.g. MT5 position id).
@override final  String? ticketId;
/// Open date (yyyy-MM-dd) when distinct from `date` (which is the
/// close date used for daily grouping).
@override final  String? openDate;
/// Open time (HH:mm) when distinct from `time`.
@override final  String? openTime;
/// Entry price.
@override final  double? openPrice;
/// Exit price.
@override final  double? closePrice;
/// Stop-loss price at trade open.
@override final  double? stopLoss;
/// Take-profit price at trade open.
@override final  double? takeProfit;
/// Broker commission (typically negative).
@override final  double? commission;
/// Overnight swap fees (positive or negative).
@override final  double? swap;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trade&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.sym, sym) || other.sym == sym)&&(identical(other.dir, dir) || other.dir == dir)&&(identical(other.lots, lots) || other.lots == lots)&&(identical(other.pnl, pnl) || other.pnl == pnl)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._violations, _violations)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.htfImage, htfImage) || other.htfImage == htfImage)&&(identical(other.ltfImage, ltfImage) || other.ltfImage == ltfImage)&&(identical(other.isHypothetical, isHypothetical) || other.isHypothetical == isHypothetical)&&(identical(other.setupQuality, setupQuality) || other.setupQuality == setupQuality)&&(identical(other.trigger, trigger) || other.trigger == trigger)&&(identical(other.reflection, reflection) || other.reflection == reflection)&&(identical(other.plannedRisk, plannedRisk) || other.plannedRisk == plannedRisk)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.openDate, openDate) || other.openDate == openDate)&&(identical(other.openTime, openTime) || other.openTime == openTime)&&(identical(other.openPrice, openPrice) || other.openPrice == openPrice)&&(identical(other.closePrice, closePrice) || other.closePrice == closePrice)&&(identical(other.stopLoss, stopLoss) || other.stopLoss == stopLoss)&&(identical(other.takeProfit, takeProfit) || other.takeProfit == takeProfit)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.swap, swap) || other.swap == swap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,date,time,sym,dir,lots,pnl,note,const DeepCollectionEquality().hash(_violations),const DeepCollectionEquality().hash(_tags),htfImage,ltfImage,isHypothetical,setupQuality,trigger,reflection,plannedRisk,ticketId,openDate,openTime,openPrice,closePrice,stopLoss,takeProfit,commission,swap]);

@override
String toString() {
  return 'Trade(id: $id, date: $date, time: $time, sym: $sym, dir: $dir, lots: $lots, pnl: $pnl, note: $note, violations: $violations, tags: $tags, htfImage: $htfImage, ltfImage: $ltfImage, isHypothetical: $isHypothetical, setupQuality: $setupQuality, trigger: $trigger, reflection: $reflection, plannedRisk: $plannedRisk, ticketId: $ticketId, openDate: $openDate, openTime: $openTime, openPrice: $openPrice, closePrice: $closePrice, stopLoss: $stopLoss, takeProfit: $takeProfit, commission: $commission, swap: $swap)';
}


}

/// @nodoc
abstract mixin class _$TradeCopyWith<$Res> implements $TradeCopyWith<$Res> {
  factory _$TradeCopyWith(_Trade value, $Res Function(_Trade) _then) = __$TradeCopyWithImpl;
@override @useResult
$Res call({
 String id, String date, String time, String sym, String dir, double lots, double pnl, String note, List<String> violations, List<String> tags, String? htfImage, String? ltfImage, bool isHypothetical, String? setupQuality, String? trigger, TradeReflection? reflection, double? plannedRisk, String? ticketId, String? openDate, String? openTime, double? openPrice, double? closePrice, double? stopLoss, double? takeProfit, double? commission, double? swap
});


@override $TradeReflectionCopyWith<$Res>? get reflection;

}
/// @nodoc
class __$TradeCopyWithImpl<$Res>
    implements _$TradeCopyWith<$Res> {
  __$TradeCopyWithImpl(this._self, this._then);

  final _Trade _self;
  final $Res Function(_Trade) _then;

/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? time = null,Object? sym = null,Object? dir = null,Object? lots = null,Object? pnl = null,Object? note = null,Object? violations = null,Object? tags = null,Object? htfImage = freezed,Object? ltfImage = freezed,Object? isHypothetical = null,Object? setupQuality = freezed,Object? trigger = freezed,Object? reflection = freezed,Object? plannedRisk = freezed,Object? ticketId = freezed,Object? openDate = freezed,Object? openTime = freezed,Object? openPrice = freezed,Object? closePrice = freezed,Object? stopLoss = freezed,Object? takeProfit = freezed,Object? commission = freezed,Object? swap = freezed,}) {
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
as bool,setupQuality: freezed == setupQuality ? _self.setupQuality : setupQuality // ignore: cast_nullable_to_non_nullable
as String?,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,reflection: freezed == reflection ? _self.reflection : reflection // ignore: cast_nullable_to_non_nullable
as TradeReflection?,plannedRisk: freezed == plannedRisk ? _self.plannedRisk : plannedRisk // ignore: cast_nullable_to_non_nullable
as double?,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,openDate: freezed == openDate ? _self.openDate : openDate // ignore: cast_nullable_to_non_nullable
as String?,openTime: freezed == openTime ? _self.openTime : openTime // ignore: cast_nullable_to_non_nullable
as String?,openPrice: freezed == openPrice ? _self.openPrice : openPrice // ignore: cast_nullable_to_non_nullable
as double?,closePrice: freezed == closePrice ? _self.closePrice : closePrice // ignore: cast_nullable_to_non_nullable
as double?,stopLoss: freezed == stopLoss ? _self.stopLoss : stopLoss // ignore: cast_nullable_to_non_nullable
as double?,takeProfit: freezed == takeProfit ? _self.takeProfit : takeProfit // ignore: cast_nullable_to_non_nullable
as double?,commission: freezed == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double?,swap: freezed == swap ? _self.swap : swap // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of Trade
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TradeReflectionCopyWith<$Res>? get reflection {
    if (_self.reflection == null) {
    return null;
  }

  return $TradeReflectionCopyWith<$Res>(_self.reflection!, (value) {
    return _then(_self.copyWith(reflection: value));
  });
}
}


/// @nodoc
mixin _$TradeReflection {

 bool get followedPlan;/// One of: TP, SL, Manual, Time.
 String get exitReason;/// 1 (terrible) — 10 (locked-in).
 int get emotionalState;
/// Create a copy of TradeReflection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeReflectionCopyWith<TradeReflection> get copyWith => _$TradeReflectionCopyWithImpl<TradeReflection>(this as TradeReflection, _$identity);

  /// Serializes this TradeReflection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeReflection&&(identical(other.followedPlan, followedPlan) || other.followedPlan == followedPlan)&&(identical(other.exitReason, exitReason) || other.exitReason == exitReason)&&(identical(other.emotionalState, emotionalState) || other.emotionalState == emotionalState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followedPlan,exitReason,emotionalState);

@override
String toString() {
  return 'TradeReflection(followedPlan: $followedPlan, exitReason: $exitReason, emotionalState: $emotionalState)';
}


}

/// @nodoc
abstract mixin class $TradeReflectionCopyWith<$Res>  {
  factory $TradeReflectionCopyWith(TradeReflection value, $Res Function(TradeReflection) _then) = _$TradeReflectionCopyWithImpl;
@useResult
$Res call({
 bool followedPlan, String exitReason, int emotionalState
});




}
/// @nodoc
class _$TradeReflectionCopyWithImpl<$Res>
    implements $TradeReflectionCopyWith<$Res> {
  _$TradeReflectionCopyWithImpl(this._self, this._then);

  final TradeReflection _self;
  final $Res Function(TradeReflection) _then;

/// Create a copy of TradeReflection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? followedPlan = null,Object? exitReason = null,Object? emotionalState = null,}) {
  return _then(_self.copyWith(
followedPlan: null == followedPlan ? _self.followedPlan : followedPlan // ignore: cast_nullable_to_non_nullable
as bool,exitReason: null == exitReason ? _self.exitReason : exitReason // ignore: cast_nullable_to_non_nullable
as String,emotionalState: null == emotionalState ? _self.emotionalState : emotionalState // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeReflection].
extension TradeReflectionPatterns on TradeReflection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeReflection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeReflection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeReflection value)  $default,){
final _that = this;
switch (_that) {
case _TradeReflection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeReflection value)?  $default,){
final _that = this;
switch (_that) {
case _TradeReflection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool followedPlan,  String exitReason,  int emotionalState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeReflection() when $default != null:
return $default(_that.followedPlan,_that.exitReason,_that.emotionalState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool followedPlan,  String exitReason,  int emotionalState)  $default,) {final _that = this;
switch (_that) {
case _TradeReflection():
return $default(_that.followedPlan,_that.exitReason,_that.emotionalState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool followedPlan,  String exitReason,  int emotionalState)?  $default,) {final _that = this;
switch (_that) {
case _TradeReflection() when $default != null:
return $default(_that.followedPlan,_that.exitReason,_that.emotionalState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeReflection implements TradeReflection {
  const _TradeReflection({required this.followedPlan, required this.exitReason, required this.emotionalState});
  factory _TradeReflection.fromJson(Map<String, dynamic> json) => _$TradeReflectionFromJson(json);

@override final  bool followedPlan;
/// One of: TP, SL, Manual, Time.
@override final  String exitReason;
/// 1 (terrible) — 10 (locked-in).
@override final  int emotionalState;

/// Create a copy of TradeReflection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeReflectionCopyWith<_TradeReflection> get copyWith => __$TradeReflectionCopyWithImpl<_TradeReflection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeReflectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeReflection&&(identical(other.followedPlan, followedPlan) || other.followedPlan == followedPlan)&&(identical(other.exitReason, exitReason) || other.exitReason == exitReason)&&(identical(other.emotionalState, emotionalState) || other.emotionalState == emotionalState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followedPlan,exitReason,emotionalState);

@override
String toString() {
  return 'TradeReflection(followedPlan: $followedPlan, exitReason: $exitReason, emotionalState: $emotionalState)';
}


}

/// @nodoc
abstract mixin class _$TradeReflectionCopyWith<$Res> implements $TradeReflectionCopyWith<$Res> {
  factory _$TradeReflectionCopyWith(_TradeReflection value, $Res Function(_TradeReflection) _then) = __$TradeReflectionCopyWithImpl;
@override @useResult
$Res call({
 bool followedPlan, String exitReason, int emotionalState
});




}
/// @nodoc
class __$TradeReflectionCopyWithImpl<$Res>
    implements _$TradeReflectionCopyWith<$Res> {
  __$TradeReflectionCopyWithImpl(this._self, this._then);

  final _TradeReflection _self;
  final $Res Function(_TradeReflection) _then;

/// Create a copy of TradeReflection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? followedPlan = null,Object? exitReason = null,Object? emotionalState = null,}) {
  return _then(_TradeReflection(
followedPlan: null == followedPlan ? _self.followedPlan : followedPlan // ignore: cast_nullable_to_non_nullable
as bool,exitReason: null == exitReason ? _self.exitReason : exitReason // ignore: cast_nullable_to_non_nullable
as String,emotionalState: null == emotionalState ? _self.emotionalState : emotionalState // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WizardDraft {

 int get step; String get instrument; String get stopLoss; String get entries;/// Planned take-profit, expressed in the same units as [stopLoss]
/// (i.e. price-move/pips per the instrument). Optional.
 String? get takeProfit;/// Optional path to a pre-trade chart screenshot the trader attached
/// during the Plan step.
 String? get planImagePath;
/// Create a copy of WizardDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WizardDraftCopyWith<WizardDraft> get copyWith => _$WizardDraftCopyWithImpl<WizardDraft>(this as WizardDraft, _$identity);

  /// Serializes this WizardDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WizardDraft&&(identical(other.step, step) || other.step == step)&&(identical(other.instrument, instrument) || other.instrument == instrument)&&(identical(other.stopLoss, stopLoss) || other.stopLoss == stopLoss)&&(identical(other.entries, entries) || other.entries == entries)&&(identical(other.takeProfit, takeProfit) || other.takeProfit == takeProfit)&&(identical(other.planImagePath, planImagePath) || other.planImagePath == planImagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,step,instrument,stopLoss,entries,takeProfit,planImagePath);

@override
String toString() {
  return 'WizardDraft(step: $step, instrument: $instrument, stopLoss: $stopLoss, entries: $entries, takeProfit: $takeProfit, planImagePath: $planImagePath)';
}


}

/// @nodoc
abstract mixin class $WizardDraftCopyWith<$Res>  {
  factory $WizardDraftCopyWith(WizardDraft value, $Res Function(WizardDraft) _then) = _$WizardDraftCopyWithImpl;
@useResult
$Res call({
 int step, String instrument, String stopLoss, String entries, String? takeProfit, String? planImagePath
});




}
/// @nodoc
class _$WizardDraftCopyWithImpl<$Res>
    implements $WizardDraftCopyWith<$Res> {
  _$WizardDraftCopyWithImpl(this._self, this._then);

  final WizardDraft _self;
  final $Res Function(WizardDraft) _then;

/// Create a copy of WizardDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? instrument = null,Object? stopLoss = null,Object? entries = null,Object? takeProfit = freezed,Object? planImagePath = freezed,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,instrument: null == instrument ? _self.instrument : instrument // ignore: cast_nullable_to_non_nullable
as String,stopLoss: null == stopLoss ? _self.stopLoss : stopLoss // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as String,takeProfit: freezed == takeProfit ? _self.takeProfit : takeProfit // ignore: cast_nullable_to_non_nullable
as String?,planImagePath: freezed == planImagePath ? _self.planImagePath : planImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WizardDraft].
extension WizardDraftPatterns on WizardDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WizardDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WizardDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WizardDraft value)  $default,){
final _that = this;
switch (_that) {
case _WizardDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WizardDraft value)?  $default,){
final _that = this;
switch (_that) {
case _WizardDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int step,  String instrument,  String stopLoss,  String entries,  String? takeProfit,  String? planImagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WizardDraft() when $default != null:
return $default(_that.step,_that.instrument,_that.stopLoss,_that.entries,_that.takeProfit,_that.planImagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int step,  String instrument,  String stopLoss,  String entries,  String? takeProfit,  String? planImagePath)  $default,) {final _that = this;
switch (_that) {
case _WizardDraft():
return $default(_that.step,_that.instrument,_that.stopLoss,_that.entries,_that.takeProfit,_that.planImagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int step,  String instrument,  String stopLoss,  String entries,  String? takeProfit,  String? planImagePath)?  $default,) {final _that = this;
switch (_that) {
case _WizardDraft() when $default != null:
return $default(_that.step,_that.instrument,_that.stopLoss,_that.entries,_that.takeProfit,_that.planImagePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WizardDraft implements WizardDraft {
  const _WizardDraft({this.step = 0, this.instrument = 'XAUUSD', this.stopLoss = '7', this.entries = '1', this.takeProfit, this.planImagePath});
  factory _WizardDraft.fromJson(Map<String, dynamic> json) => _$WizardDraftFromJson(json);

@override@JsonKey() final  int step;
@override@JsonKey() final  String instrument;
@override@JsonKey() final  String stopLoss;
@override@JsonKey() final  String entries;
/// Planned take-profit, expressed in the same units as [stopLoss]
/// (i.e. price-move/pips per the instrument). Optional.
@override final  String? takeProfit;
/// Optional path to a pre-trade chart screenshot the trader attached
/// during the Plan step.
@override final  String? planImagePath;

/// Create a copy of WizardDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WizardDraftCopyWith<_WizardDraft> get copyWith => __$WizardDraftCopyWithImpl<_WizardDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WizardDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WizardDraft&&(identical(other.step, step) || other.step == step)&&(identical(other.instrument, instrument) || other.instrument == instrument)&&(identical(other.stopLoss, stopLoss) || other.stopLoss == stopLoss)&&(identical(other.entries, entries) || other.entries == entries)&&(identical(other.takeProfit, takeProfit) || other.takeProfit == takeProfit)&&(identical(other.planImagePath, planImagePath) || other.planImagePath == planImagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,step,instrument,stopLoss,entries,takeProfit,planImagePath);

@override
String toString() {
  return 'WizardDraft(step: $step, instrument: $instrument, stopLoss: $stopLoss, entries: $entries, takeProfit: $takeProfit, planImagePath: $planImagePath)';
}


}

/// @nodoc
abstract mixin class _$WizardDraftCopyWith<$Res> implements $WizardDraftCopyWith<$Res> {
  factory _$WizardDraftCopyWith(_WizardDraft value, $Res Function(_WizardDraft) _then) = __$WizardDraftCopyWithImpl;
@override @useResult
$Res call({
 int step, String instrument, String stopLoss, String entries, String? takeProfit, String? planImagePath
});




}
/// @nodoc
class __$WizardDraftCopyWithImpl<$Res>
    implements _$WizardDraftCopyWith<$Res> {
  __$WizardDraftCopyWithImpl(this._self, this._then);

  final _WizardDraft _self;
  final $Res Function(_WizardDraft) _then;

/// Create a copy of WizardDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? instrument = null,Object? stopLoss = null,Object? entries = null,Object? takeProfit = freezed,Object? planImagePath = freezed,}) {
  return _then(_WizardDraft(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,instrument: null == instrument ? _self.instrument : instrument // ignore: cast_nullable_to_non_nullable
as String,stopLoss: null == stopLoss ? _self.stopLoss : stopLoss // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as String,takeProfit: freezed == takeProfit ? _self.takeProfit : takeProfit // ignore: cast_nullable_to_non_nullable
as String?,planImagePath: freezed == planImagePath ? _self.planImagePath : planImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DailyMood {

/// One of: Tired, Neutral, Sharp, Frustrated, Hyped.
 String get mood; String get note; int get timestamp;
/// Create a copy of DailyMood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyMoodCopyWith<DailyMood> get copyWith => _$DailyMoodCopyWithImpl<DailyMood>(this as DailyMood, _$identity);

  /// Serializes this DailyMood to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyMood&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.note, note) || other.note == note)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mood,note,timestamp);

@override
String toString() {
  return 'DailyMood(mood: $mood, note: $note, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $DailyMoodCopyWith<$Res>  {
  factory $DailyMoodCopyWith(DailyMood value, $Res Function(DailyMood) _then) = _$DailyMoodCopyWithImpl;
@useResult
$Res call({
 String mood, String note, int timestamp
});




}
/// @nodoc
class _$DailyMoodCopyWithImpl<$Res>
    implements $DailyMoodCopyWith<$Res> {
  _$DailyMoodCopyWithImpl(this._self, this._then);

  final DailyMood _self;
  final $Res Function(DailyMood) _then;

/// Create a copy of DailyMood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mood = null,Object? note = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyMood].
extension DailyMoodPatterns on DailyMood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyMood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyMood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyMood value)  $default,){
final _that = this;
switch (_that) {
case _DailyMood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyMood value)?  $default,){
final _that = this;
switch (_that) {
case _DailyMood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mood,  String note,  int timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyMood() when $default != null:
return $default(_that.mood,_that.note,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mood,  String note,  int timestamp)  $default,) {final _that = this;
switch (_that) {
case _DailyMood():
return $default(_that.mood,_that.note,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mood,  String note,  int timestamp)?  $default,) {final _that = this;
switch (_that) {
case _DailyMood() when $default != null:
return $default(_that.mood,_that.note,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyMood implements DailyMood {
  const _DailyMood({required this.mood, this.note = '', required this.timestamp});
  factory _DailyMood.fromJson(Map<String, dynamic> json) => _$DailyMoodFromJson(json);

/// One of: Tired, Neutral, Sharp, Frustrated, Hyped.
@override final  String mood;
@override@JsonKey() final  String note;
@override final  int timestamp;

/// Create a copy of DailyMood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyMoodCopyWith<_DailyMood> get copyWith => __$DailyMoodCopyWithImpl<_DailyMood>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyMoodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyMood&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.note, note) || other.note == note)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mood,note,timestamp);

@override
String toString() {
  return 'DailyMood(mood: $mood, note: $note, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$DailyMoodCopyWith<$Res> implements $DailyMoodCopyWith<$Res> {
  factory _$DailyMoodCopyWith(_DailyMood value, $Res Function(_DailyMood) _then) = __$DailyMoodCopyWithImpl;
@override @useResult
$Res call({
 String mood, String note, int timestamp
});




}
/// @nodoc
class __$DailyMoodCopyWithImpl<$Res>
    implements _$DailyMoodCopyWith<$Res> {
  __$DailyMoodCopyWithImpl(this._self, this._then);

  final _DailyMood _self;
  final $Res Function(_DailyMood) _then;

/// Create a copy of DailyMood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mood = null,Object? note = null,Object? timestamp = null,}) {
  return _then(_DailyMood(
mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WeeklyDigest {

 String get weekId;// ISO week label e.g. "2026-W18"
 int get generatedAt;// ms since epoch
 String get win;// "Your A+ setups produced +$340 this week."
 String get worstHabit;// "60% of trades were FOMO. Worst day: Wed."
 String get oneFix;// "Skip trades after 2 losses..."
 bool get seen;
/// Create a copy of WeeklyDigest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyDigestCopyWith<WeeklyDigest> get copyWith => _$WeeklyDigestCopyWithImpl<WeeklyDigest>(this as WeeklyDigest, _$identity);

  /// Serializes this WeeklyDigest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyDigest&&(identical(other.weekId, weekId) || other.weekId == weekId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.win, win) || other.win == win)&&(identical(other.worstHabit, worstHabit) || other.worstHabit == worstHabit)&&(identical(other.oneFix, oneFix) || other.oneFix == oneFix)&&(identical(other.seen, seen) || other.seen == seen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekId,generatedAt,win,worstHabit,oneFix,seen);

@override
String toString() {
  return 'WeeklyDigest(weekId: $weekId, generatedAt: $generatedAt, win: $win, worstHabit: $worstHabit, oneFix: $oneFix, seen: $seen)';
}


}

/// @nodoc
abstract mixin class $WeeklyDigestCopyWith<$Res>  {
  factory $WeeklyDigestCopyWith(WeeklyDigest value, $Res Function(WeeklyDigest) _then) = _$WeeklyDigestCopyWithImpl;
@useResult
$Res call({
 String weekId, int generatedAt, String win, String worstHabit, String oneFix, bool seen
});




}
/// @nodoc
class _$WeeklyDigestCopyWithImpl<$Res>
    implements $WeeklyDigestCopyWith<$Res> {
  _$WeeklyDigestCopyWithImpl(this._self, this._then);

  final WeeklyDigest _self;
  final $Res Function(WeeklyDigest) _then;

/// Create a copy of WeeklyDigest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekId = null,Object? generatedAt = null,Object? win = null,Object? worstHabit = null,Object? oneFix = null,Object? seen = null,}) {
  return _then(_self.copyWith(
weekId: null == weekId ? _self.weekId : weekId // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,win: null == win ? _self.win : win // ignore: cast_nullable_to_non_nullable
as String,worstHabit: null == worstHabit ? _self.worstHabit : worstHabit // ignore: cast_nullable_to_non_nullable
as String,oneFix: null == oneFix ? _self.oneFix : oneFix // ignore: cast_nullable_to_non_nullable
as String,seen: null == seen ? _self.seen : seen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyDigest].
extension WeeklyDigestPatterns on WeeklyDigest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyDigest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyDigest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyDigest value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyDigest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyDigest value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyDigest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String weekId,  int generatedAt,  String win,  String worstHabit,  String oneFix,  bool seen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyDigest() when $default != null:
return $default(_that.weekId,_that.generatedAt,_that.win,_that.worstHabit,_that.oneFix,_that.seen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String weekId,  int generatedAt,  String win,  String worstHabit,  String oneFix,  bool seen)  $default,) {final _that = this;
switch (_that) {
case _WeeklyDigest():
return $default(_that.weekId,_that.generatedAt,_that.win,_that.worstHabit,_that.oneFix,_that.seen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String weekId,  int generatedAt,  String win,  String worstHabit,  String oneFix,  bool seen)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyDigest() when $default != null:
return $default(_that.weekId,_that.generatedAt,_that.win,_that.worstHabit,_that.oneFix,_that.seen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyDigest implements WeeklyDigest {
  const _WeeklyDigest({required this.weekId, required this.generatedAt, required this.win, required this.worstHabit, required this.oneFix, this.seen = false});
  factory _WeeklyDigest.fromJson(Map<String, dynamic> json) => _$WeeklyDigestFromJson(json);

@override final  String weekId;
// ISO week label e.g. "2026-W18"
@override final  int generatedAt;
// ms since epoch
@override final  String win;
// "Your A+ setups produced +$340 this week."
@override final  String worstHabit;
// "60% of trades were FOMO. Worst day: Wed."
@override final  String oneFix;
// "Skip trades after 2 losses..."
@override@JsonKey() final  bool seen;

/// Create a copy of WeeklyDigest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyDigestCopyWith<_WeeklyDigest> get copyWith => __$WeeklyDigestCopyWithImpl<_WeeklyDigest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyDigestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyDigest&&(identical(other.weekId, weekId) || other.weekId == weekId)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.win, win) || other.win == win)&&(identical(other.worstHabit, worstHabit) || other.worstHabit == worstHabit)&&(identical(other.oneFix, oneFix) || other.oneFix == oneFix)&&(identical(other.seen, seen) || other.seen == seen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekId,generatedAt,win,worstHabit,oneFix,seen);

@override
String toString() {
  return 'WeeklyDigest(weekId: $weekId, generatedAt: $generatedAt, win: $win, worstHabit: $worstHabit, oneFix: $oneFix, seen: $seen)';
}


}

/// @nodoc
abstract mixin class _$WeeklyDigestCopyWith<$Res> implements $WeeklyDigestCopyWith<$Res> {
  factory _$WeeklyDigestCopyWith(_WeeklyDigest value, $Res Function(_WeeklyDigest) _then) = __$WeeklyDigestCopyWithImpl;
@override @useResult
$Res call({
 String weekId, int generatedAt, String win, String worstHabit, String oneFix, bool seen
});




}
/// @nodoc
class __$WeeklyDigestCopyWithImpl<$Res>
    implements _$WeeklyDigestCopyWith<$Res> {
  __$WeeklyDigestCopyWithImpl(this._self, this._then);

  final _WeeklyDigest _self;
  final $Res Function(_WeeklyDigest) _then;

/// Create a copy of WeeklyDigest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekId = null,Object? generatedAt = null,Object? win = null,Object? worstHabit = null,Object? oneFix = null,Object? seen = null,}) {
  return _then(_WeeklyDigest(
weekId: null == weekId ? _self.weekId : weekId // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as int,win: null == win ? _self.win : win // ignore: cast_nullable_to_non_nullable
as String,worstHabit: null == worstHabit ? _self.worstHabit : worstHabit // ignore: cast_nullable_to_non_nullable
as String,oneFix: null == oneFix ? _self.oneFix : oneFix // ignore: cast_nullable_to_non_nullable
as String,seen: null == seen ? _self.seen : seen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PropFirmRules {

/// Max single-day loss the firm tolerates (e.g. $1000 on a $25k account).
 double get maxDailyDrawdown;/// Max trailing drawdown from peak balance (e.g. $2000).
 double get maxTotalDrawdown;/// Optional firm name for display ("FTMO", "MyForexFunds", etc).
 String get firmName;/// Whether the user has opted in to prop-firm enforcement.
 bool get enabled;
/// Create a copy of PropFirmRules
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropFirmRulesCopyWith<PropFirmRules> get copyWith => _$PropFirmRulesCopyWithImpl<PropFirmRules>(this as PropFirmRules, _$identity);

  /// Serializes this PropFirmRules to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropFirmRules&&(identical(other.maxDailyDrawdown, maxDailyDrawdown) || other.maxDailyDrawdown == maxDailyDrawdown)&&(identical(other.maxTotalDrawdown, maxTotalDrawdown) || other.maxTotalDrawdown == maxTotalDrawdown)&&(identical(other.firmName, firmName) || other.firmName == firmName)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxDailyDrawdown,maxTotalDrawdown,firmName,enabled);

@override
String toString() {
  return 'PropFirmRules(maxDailyDrawdown: $maxDailyDrawdown, maxTotalDrawdown: $maxTotalDrawdown, firmName: $firmName, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $PropFirmRulesCopyWith<$Res>  {
  factory $PropFirmRulesCopyWith(PropFirmRules value, $Res Function(PropFirmRules) _then) = _$PropFirmRulesCopyWithImpl;
@useResult
$Res call({
 double maxDailyDrawdown, double maxTotalDrawdown, String firmName, bool enabled
});




}
/// @nodoc
class _$PropFirmRulesCopyWithImpl<$Res>
    implements $PropFirmRulesCopyWith<$Res> {
  _$PropFirmRulesCopyWithImpl(this._self, this._then);

  final PropFirmRules _self;
  final $Res Function(PropFirmRules) _then;

/// Create a copy of PropFirmRules
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxDailyDrawdown = null,Object? maxTotalDrawdown = null,Object? firmName = null,Object? enabled = null,}) {
  return _then(_self.copyWith(
maxDailyDrawdown: null == maxDailyDrawdown ? _self.maxDailyDrawdown : maxDailyDrawdown // ignore: cast_nullable_to_non_nullable
as double,maxTotalDrawdown: null == maxTotalDrawdown ? _self.maxTotalDrawdown : maxTotalDrawdown // ignore: cast_nullable_to_non_nullable
as double,firmName: null == firmName ? _self.firmName : firmName // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PropFirmRules].
extension PropFirmRulesPatterns on PropFirmRules {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropFirmRules value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropFirmRules() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropFirmRules value)  $default,){
final _that = this;
switch (_that) {
case _PropFirmRules():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropFirmRules value)?  $default,){
final _that = this;
switch (_that) {
case _PropFirmRules() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double maxDailyDrawdown,  double maxTotalDrawdown,  String firmName,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropFirmRules() when $default != null:
return $default(_that.maxDailyDrawdown,_that.maxTotalDrawdown,_that.firmName,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double maxDailyDrawdown,  double maxTotalDrawdown,  String firmName,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _PropFirmRules():
return $default(_that.maxDailyDrawdown,_that.maxTotalDrawdown,_that.firmName,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double maxDailyDrawdown,  double maxTotalDrawdown,  String firmName,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _PropFirmRules() when $default != null:
return $default(_that.maxDailyDrawdown,_that.maxTotalDrawdown,_that.firmName,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PropFirmRules implements PropFirmRules {
  const _PropFirmRules({this.maxDailyDrawdown = 0.0, this.maxTotalDrawdown = 0.0, this.firmName = '', this.enabled = false});
  factory _PropFirmRules.fromJson(Map<String, dynamic> json) => _$PropFirmRulesFromJson(json);

/// Max single-day loss the firm tolerates (e.g. $1000 on a $25k account).
@override@JsonKey() final  double maxDailyDrawdown;
/// Max trailing drawdown from peak balance (e.g. $2000).
@override@JsonKey() final  double maxTotalDrawdown;
/// Optional firm name for display ("FTMO", "MyForexFunds", etc).
@override@JsonKey() final  String firmName;
/// Whether the user has opted in to prop-firm enforcement.
@override@JsonKey() final  bool enabled;

/// Create a copy of PropFirmRules
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropFirmRulesCopyWith<_PropFirmRules> get copyWith => __$PropFirmRulesCopyWithImpl<_PropFirmRules>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropFirmRulesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropFirmRules&&(identical(other.maxDailyDrawdown, maxDailyDrawdown) || other.maxDailyDrawdown == maxDailyDrawdown)&&(identical(other.maxTotalDrawdown, maxTotalDrawdown) || other.maxTotalDrawdown == maxTotalDrawdown)&&(identical(other.firmName, firmName) || other.firmName == firmName)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxDailyDrawdown,maxTotalDrawdown,firmName,enabled);

@override
String toString() {
  return 'PropFirmRules(maxDailyDrawdown: $maxDailyDrawdown, maxTotalDrawdown: $maxTotalDrawdown, firmName: $firmName, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$PropFirmRulesCopyWith<$Res> implements $PropFirmRulesCopyWith<$Res> {
  factory _$PropFirmRulesCopyWith(_PropFirmRules value, $Res Function(_PropFirmRules) _then) = __$PropFirmRulesCopyWithImpl;
@override @useResult
$Res call({
 double maxDailyDrawdown, double maxTotalDrawdown, String firmName, bool enabled
});




}
/// @nodoc
class __$PropFirmRulesCopyWithImpl<$Res>
    implements _$PropFirmRulesCopyWith<$Res> {
  __$PropFirmRulesCopyWithImpl(this._self, this._then);

  final _PropFirmRules _self;
  final $Res Function(_PropFirmRules) _then;

/// Create a copy of PropFirmRules
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxDailyDrawdown = null,Object? maxTotalDrawdown = null,Object? firmName = null,Object? enabled = null,}) {
  return _then(_PropFirmRules(
maxDailyDrawdown: null == maxDailyDrawdown ? _self.maxDailyDrawdown : maxDailyDrawdown // ignore: cast_nullable_to_non_nullable
as double,maxTotalDrawdown: null == maxTotalDrawdown ? _self.maxTotalDrawdown : maxTotalDrawdown // ignore: cast_nullable_to_non_nullable
as double,firmName: null == firmName ? _self.firmName : firmName // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WeeklyRiskBudget {

 bool get enabled; double get rUnitUsd; double get weeklyBudgetR;
/// Create a copy of WeeklyRiskBudget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyRiskBudgetCopyWith<WeeklyRiskBudget> get copyWith => _$WeeklyRiskBudgetCopyWithImpl<WeeklyRiskBudget>(this as WeeklyRiskBudget, _$identity);

  /// Serializes this WeeklyRiskBudget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyRiskBudget&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.rUnitUsd, rUnitUsd) || other.rUnitUsd == rUnitUsd)&&(identical(other.weeklyBudgetR, weeklyBudgetR) || other.weeklyBudgetR == weeklyBudgetR));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,rUnitUsd,weeklyBudgetR);

@override
String toString() {
  return 'WeeklyRiskBudget(enabled: $enabled, rUnitUsd: $rUnitUsd, weeklyBudgetR: $weeklyBudgetR)';
}


}

/// @nodoc
abstract mixin class $WeeklyRiskBudgetCopyWith<$Res>  {
  factory $WeeklyRiskBudgetCopyWith(WeeklyRiskBudget value, $Res Function(WeeklyRiskBudget) _then) = _$WeeklyRiskBudgetCopyWithImpl;
@useResult
$Res call({
 bool enabled, double rUnitUsd, double weeklyBudgetR
});




}
/// @nodoc
class _$WeeklyRiskBudgetCopyWithImpl<$Res>
    implements $WeeklyRiskBudgetCopyWith<$Res> {
  _$WeeklyRiskBudgetCopyWithImpl(this._self, this._then);

  final WeeklyRiskBudget _self;
  final $Res Function(WeeklyRiskBudget) _then;

/// Create a copy of WeeklyRiskBudget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? rUnitUsd = null,Object? weeklyBudgetR = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,rUnitUsd: null == rUnitUsd ? _self.rUnitUsd : rUnitUsd // ignore: cast_nullable_to_non_nullable
as double,weeklyBudgetR: null == weeklyBudgetR ? _self.weeklyBudgetR : weeklyBudgetR // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyRiskBudget].
extension WeeklyRiskBudgetPatterns on WeeklyRiskBudget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyRiskBudget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyRiskBudget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyRiskBudget value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyRiskBudget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyRiskBudget value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyRiskBudget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  double rUnitUsd,  double weeklyBudgetR)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyRiskBudget() when $default != null:
return $default(_that.enabled,_that.rUnitUsd,_that.weeklyBudgetR);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  double rUnitUsd,  double weeklyBudgetR)  $default,) {final _that = this;
switch (_that) {
case _WeeklyRiskBudget():
return $default(_that.enabled,_that.rUnitUsd,_that.weeklyBudgetR);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  double rUnitUsd,  double weeklyBudgetR)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyRiskBudget() when $default != null:
return $default(_that.enabled,_that.rUnitUsd,_that.weeklyBudgetR);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyRiskBudget implements WeeklyRiskBudget {
  const _WeeklyRiskBudget({this.enabled = false, this.rUnitUsd = 125.0, this.weeklyBudgetR = 10.0});
  factory _WeeklyRiskBudget.fromJson(Map<String, dynamic> json) => _$WeeklyRiskBudgetFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  double rUnitUsd;
@override@JsonKey() final  double weeklyBudgetR;

/// Create a copy of WeeklyRiskBudget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyRiskBudgetCopyWith<_WeeklyRiskBudget> get copyWith => __$WeeklyRiskBudgetCopyWithImpl<_WeeklyRiskBudget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyRiskBudgetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyRiskBudget&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.rUnitUsd, rUnitUsd) || other.rUnitUsd == rUnitUsd)&&(identical(other.weeklyBudgetR, weeklyBudgetR) || other.weeklyBudgetR == weeklyBudgetR));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,rUnitUsd,weeklyBudgetR);

@override
String toString() {
  return 'WeeklyRiskBudget(enabled: $enabled, rUnitUsd: $rUnitUsd, weeklyBudgetR: $weeklyBudgetR)';
}


}

/// @nodoc
abstract mixin class _$WeeklyRiskBudgetCopyWith<$Res> implements $WeeklyRiskBudgetCopyWith<$Res> {
  factory _$WeeklyRiskBudgetCopyWith(_WeeklyRiskBudget value, $Res Function(_WeeklyRiskBudget) _then) = __$WeeklyRiskBudgetCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, double rUnitUsd, double weeklyBudgetR
});




}
/// @nodoc
class __$WeeklyRiskBudgetCopyWithImpl<$Res>
    implements _$WeeklyRiskBudgetCopyWith<$Res> {
  __$WeeklyRiskBudgetCopyWithImpl(this._self, this._then);

  final _WeeklyRiskBudget _self;
  final $Res Function(_WeeklyRiskBudget) _then;

/// Create a copy of WeeklyRiskBudget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? rUnitUsd = null,Object? weeklyBudgetR = null,}) {
  return _then(_WeeklyRiskBudget(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,rUnitUsd: null == rUnitUsd ? _self.rUnitUsd : rUnitUsd // ignore: cast_nullable_to_non_nullable
as double,weeklyBudgetR: null == weeklyBudgetR ? _self.weeklyBudgetR : weeklyBudgetR // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$IntegrityEvent {

 String get id; int get timestamp;// ms since epoch
 String get type;// reset_today | reset_all | balance_changed | lock_override
 String get detail;
/// Create a copy of IntegrityEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntegrityEventCopyWith<IntegrityEvent> get copyWith => _$IntegrityEventCopyWithImpl<IntegrityEvent>(this as IntegrityEvent, _$identity);

  /// Serializes this IntegrityEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntegrityEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.type, type) || other.type == type)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,type,detail);

@override
String toString() {
  return 'IntegrityEvent(id: $id, timestamp: $timestamp, type: $type, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $IntegrityEventCopyWith<$Res>  {
  factory $IntegrityEventCopyWith(IntegrityEvent value, $Res Function(IntegrityEvent) _then) = _$IntegrityEventCopyWithImpl;
@useResult
$Res call({
 String id, int timestamp, String type, String detail
});




}
/// @nodoc
class _$IntegrityEventCopyWithImpl<$Res>
    implements $IntegrityEventCopyWith<$Res> {
  _$IntegrityEventCopyWithImpl(this._self, this._then);

  final IntegrityEvent _self;
  final $Res Function(IntegrityEvent) _then;

/// Create a copy of IntegrityEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? type = null,Object? detail = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IntegrityEvent].
extension IntegrityEventPatterns on IntegrityEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntegrityEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntegrityEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntegrityEvent value)  $default,){
final _that = this;
switch (_that) {
case _IntegrityEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntegrityEvent value)?  $default,){
final _that = this;
switch (_that) {
case _IntegrityEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int timestamp,  String type,  String detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntegrityEvent() when $default != null:
return $default(_that.id,_that.timestamp,_that.type,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int timestamp,  String type,  String detail)  $default,) {final _that = this;
switch (_that) {
case _IntegrityEvent():
return $default(_that.id,_that.timestamp,_that.type,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int timestamp,  String type,  String detail)?  $default,) {final _that = this;
switch (_that) {
case _IntegrityEvent() when $default != null:
return $default(_that.id,_that.timestamp,_that.type,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IntegrityEvent implements IntegrityEvent {
  const _IntegrityEvent({required this.id, required this.timestamp, required this.type, this.detail = ''});
  factory _IntegrityEvent.fromJson(Map<String, dynamic> json) => _$IntegrityEventFromJson(json);

@override final  String id;
@override final  int timestamp;
// ms since epoch
@override final  String type;
// reset_today | reset_all | balance_changed | lock_override
@override@JsonKey() final  String detail;

/// Create a copy of IntegrityEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntegrityEventCopyWith<_IntegrityEvent> get copyWith => __$IntegrityEventCopyWithImpl<_IntegrityEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntegrityEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntegrityEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.type, type) || other.type == type)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,type,detail);

@override
String toString() {
  return 'IntegrityEvent(id: $id, timestamp: $timestamp, type: $type, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$IntegrityEventCopyWith<$Res> implements $IntegrityEventCopyWith<$Res> {
  factory _$IntegrityEventCopyWith(_IntegrityEvent value, $Res Function(_IntegrityEvent) _then) = __$IntegrityEventCopyWithImpl;
@override @useResult
$Res call({
 String id, int timestamp, String type, String detail
});




}
/// @nodoc
class __$IntegrityEventCopyWithImpl<$Res>
    implements _$IntegrityEventCopyWith<$Res> {
  __$IntegrityEventCopyWithImpl(this._self, this._then);

  final _IntegrityEvent _self;
  final $Res Function(_IntegrityEvent) _then;

/// Create a copy of IntegrityEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? type = null,Object? detail = null,}) {
  return _then(_IntegrityEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TradingAccount {

 String get id; String get name; double get balance; String get startDate; double get priorPnl; List<Trade> get allTrades; bool get lock; int? get lockUntil; PropFirmRules get propFirmRules; WeeklyRiskBudget get weeklyRiskBudget; int get dailyTradeCap;
/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradingAccountCopyWith<TradingAccount> get copyWith => _$TradingAccountCopyWithImpl<TradingAccount>(this as TradingAccount, _$identity);

  /// Serializes this TradingAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradingAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.priorPnl, priorPnl) || other.priorPnl == priorPnl)&&const DeepCollectionEquality().equals(other.allTrades, allTrades)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.lockUntil, lockUntil) || other.lockUntil == lockUntil)&&(identical(other.propFirmRules, propFirmRules) || other.propFirmRules == propFirmRules)&&(identical(other.weeklyRiskBudget, weeklyRiskBudget) || other.weeklyRiskBudget == weeklyRiskBudget)&&(identical(other.dailyTradeCap, dailyTradeCap) || other.dailyTradeCap == dailyTradeCap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,startDate,priorPnl,const DeepCollectionEquality().hash(allTrades),lock,lockUntil,propFirmRules,weeklyRiskBudget,dailyTradeCap);

@override
String toString() {
  return 'TradingAccount(id: $id, name: $name, balance: $balance, startDate: $startDate, priorPnl: $priorPnl, allTrades: $allTrades, lock: $lock, lockUntil: $lockUntil, propFirmRules: $propFirmRules, weeklyRiskBudget: $weeklyRiskBudget, dailyTradeCap: $dailyTradeCap)';
}


}

/// @nodoc
abstract mixin class $TradingAccountCopyWith<$Res>  {
  factory $TradingAccountCopyWith(TradingAccount value, $Res Function(TradingAccount) _then) = _$TradingAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, double balance, String startDate, double priorPnl, List<Trade> allTrades, bool lock, int? lockUntil, PropFirmRules propFirmRules, WeeklyRiskBudget weeklyRiskBudget, int dailyTradeCap
});


$PropFirmRulesCopyWith<$Res> get propFirmRules;$WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget;

}
/// @nodoc
class _$TradingAccountCopyWithImpl<$Res>
    implements $TradingAccountCopyWith<$Res> {
  _$TradingAccountCopyWithImpl(this._self, this._then);

  final TradingAccount _self;
  final $Res Function(TradingAccount) _then;

/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? startDate = null,Object? priorPnl = null,Object? allTrades = null,Object? lock = null,Object? lockUntil = freezed,Object? propFirmRules = null,Object? weeklyRiskBudget = null,Object? dailyTradeCap = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,priorPnl: null == priorPnl ? _self.priorPnl : priorPnl // ignore: cast_nullable_to_non_nullable
as double,allTrades: null == allTrades ? _self.allTrades : allTrades // ignore: cast_nullable_to_non_nullable
as List<Trade>,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,lockUntil: freezed == lockUntil ? _self.lockUntil : lockUntil // ignore: cast_nullable_to_non_nullable
as int?,propFirmRules: null == propFirmRules ? _self.propFirmRules : propFirmRules // ignore: cast_nullable_to_non_nullable
as PropFirmRules,weeklyRiskBudget: null == weeklyRiskBudget ? _self.weeklyRiskBudget : weeklyRiskBudget // ignore: cast_nullable_to_non_nullable
as WeeklyRiskBudget,dailyTradeCap: null == dailyTradeCap ? _self.dailyTradeCap : dailyTradeCap // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropFirmRulesCopyWith<$Res> get propFirmRules {
  
  return $PropFirmRulesCopyWith<$Res>(_self.propFirmRules, (value) {
    return _then(_self.copyWith(propFirmRules: value));
  });
}/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget {
  
  return $WeeklyRiskBudgetCopyWith<$Res>(_self.weeklyRiskBudget, (value) {
    return _then(_self.copyWith(weeklyRiskBudget: value));
  });
}
}


/// Adds pattern-matching-related methods to [TradingAccount].
extension TradingAccountPatterns on TradingAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradingAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradingAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradingAccount value)  $default,){
final _that = this;
switch (_that) {
case _TradingAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradingAccount value)?  $default,){
final _that = this;
switch (_that) {
case _TradingAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double balance,  String startDate,  double priorPnl,  List<Trade> allTrades,  bool lock,  int? lockUntil,  PropFirmRules propFirmRules,  WeeklyRiskBudget weeklyRiskBudget,  int dailyTradeCap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradingAccount() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.startDate,_that.priorPnl,_that.allTrades,_that.lock,_that.lockUntil,_that.propFirmRules,_that.weeklyRiskBudget,_that.dailyTradeCap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double balance,  String startDate,  double priorPnl,  List<Trade> allTrades,  bool lock,  int? lockUntil,  PropFirmRules propFirmRules,  WeeklyRiskBudget weeklyRiskBudget,  int dailyTradeCap)  $default,) {final _that = this;
switch (_that) {
case _TradingAccount():
return $default(_that.id,_that.name,_that.balance,_that.startDate,_that.priorPnl,_that.allTrades,_that.lock,_that.lockUntil,_that.propFirmRules,_that.weeklyRiskBudget,_that.dailyTradeCap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double balance,  String startDate,  double priorPnl,  List<Trade> allTrades,  bool lock,  int? lockUntil,  PropFirmRules propFirmRules,  WeeklyRiskBudget weeklyRiskBudget,  int dailyTradeCap)?  $default,) {final _that = this;
switch (_that) {
case _TradingAccount() when $default != null:
return $default(_that.id,_that.name,_that.balance,_that.startDate,_that.priorPnl,_that.allTrades,_that.lock,_that.lockUntil,_that.propFirmRules,_that.weeklyRiskBudget,_that.dailyTradeCap);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradingAccount implements TradingAccount {
  const _TradingAccount({required this.id, required this.name, this.balance = 25000.0, this.startDate = '2026-04-20', this.priorPnl = 0.0, final  List<Trade> allTrades = const [], this.lock = false, this.lockUntil, this.propFirmRules = const PropFirmRules(), this.weeklyRiskBudget = const WeeklyRiskBudget(), this.dailyTradeCap = 2}): _allTrades = allTrades;
  factory _TradingAccount.fromJson(Map<String, dynamic> json) => _$TradingAccountFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  double balance;
@override@JsonKey() final  String startDate;
@override@JsonKey() final  double priorPnl;
 final  List<Trade> _allTrades;
@override@JsonKey() List<Trade> get allTrades {
  if (_allTrades is EqualUnmodifiableListView) return _allTrades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allTrades);
}

@override@JsonKey() final  bool lock;
@override final  int? lockUntil;
@override@JsonKey() final  PropFirmRules propFirmRules;
@override@JsonKey() final  WeeklyRiskBudget weeklyRiskBudget;
@override@JsonKey() final  int dailyTradeCap;

/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradingAccountCopyWith<_TradingAccount> get copyWith => __$TradingAccountCopyWithImpl<_TradingAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradingAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradingAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.priorPnl, priorPnl) || other.priorPnl == priorPnl)&&const DeepCollectionEquality().equals(other._allTrades, _allTrades)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.lockUntil, lockUntil) || other.lockUntil == lockUntil)&&(identical(other.propFirmRules, propFirmRules) || other.propFirmRules == propFirmRules)&&(identical(other.weeklyRiskBudget, weeklyRiskBudget) || other.weeklyRiskBudget == weeklyRiskBudget)&&(identical(other.dailyTradeCap, dailyTradeCap) || other.dailyTradeCap == dailyTradeCap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,startDate,priorPnl,const DeepCollectionEquality().hash(_allTrades),lock,lockUntil,propFirmRules,weeklyRiskBudget,dailyTradeCap);

@override
String toString() {
  return 'TradingAccount(id: $id, name: $name, balance: $balance, startDate: $startDate, priorPnl: $priorPnl, allTrades: $allTrades, lock: $lock, lockUntil: $lockUntil, propFirmRules: $propFirmRules, weeklyRiskBudget: $weeklyRiskBudget, dailyTradeCap: $dailyTradeCap)';
}


}

/// @nodoc
abstract mixin class _$TradingAccountCopyWith<$Res> implements $TradingAccountCopyWith<$Res> {
  factory _$TradingAccountCopyWith(_TradingAccount value, $Res Function(_TradingAccount) _then) = __$TradingAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double balance, String startDate, double priorPnl, List<Trade> allTrades, bool lock, int? lockUntil, PropFirmRules propFirmRules, WeeklyRiskBudget weeklyRiskBudget, int dailyTradeCap
});


@override $PropFirmRulesCopyWith<$Res> get propFirmRules;@override $WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget;

}
/// @nodoc
class __$TradingAccountCopyWithImpl<$Res>
    implements _$TradingAccountCopyWith<$Res> {
  __$TradingAccountCopyWithImpl(this._self, this._then);

  final _TradingAccount _self;
  final $Res Function(_TradingAccount) _then;

/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? startDate = null,Object? priorPnl = null,Object? allTrades = null,Object? lock = null,Object? lockUntil = freezed,Object? propFirmRules = null,Object? weeklyRiskBudget = null,Object? dailyTradeCap = null,}) {
  return _then(_TradingAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,priorPnl: null == priorPnl ? _self.priorPnl : priorPnl // ignore: cast_nullable_to_non_nullable
as double,allTrades: null == allTrades ? _self._allTrades : allTrades // ignore: cast_nullable_to_non_nullable
as List<Trade>,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,lockUntil: freezed == lockUntil ? _self.lockUntil : lockUntil // ignore: cast_nullable_to_non_nullable
as int?,propFirmRules: null == propFirmRules ? _self.propFirmRules : propFirmRules // ignore: cast_nullable_to_non_nullable
as PropFirmRules,weeklyRiskBudget: null == weeklyRiskBudget ? _self.weeklyRiskBudget : weeklyRiskBudget // ignore: cast_nullable_to_non_nullable
as WeeklyRiskBudget,dailyTradeCap: null == dailyTradeCap ? _self.dailyTradeCap : dailyTradeCap // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropFirmRulesCopyWith<$Res> get propFirmRules {
  
  return $PropFirmRulesCopyWith<$Res>(_self.propFirmRules, (value) {
    return _then(_self.copyWith(propFirmRules: value));
  });
}/// Create a copy of TradingAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget {
  
  return $WeeklyRiskBudgetCopyWith<$Res>(_self.weeklyRiskBudget, (value) {
    return _then(_self.copyWith(weeklyRiskBudget: value));
  });
}
}


/// @nodoc
mixin _$NotificationPrefs {

/// Master kill-switch. When false, every category is suppressed
/// regardless of its individual flag.
 bool get master; bool get drawdown; bool get riskBudget; bool get lock; bool get streak; bool get dailyCap; bool get newsImminent; bool get moodReminder; bool get backupReminder;
/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<NotificationPrefs> get copyWith => _$NotificationPrefsCopyWithImpl<NotificationPrefs>(this as NotificationPrefs, _$identity);

  /// Serializes this NotificationPrefs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPrefs&&(identical(other.master, master) || other.master == master)&&(identical(other.drawdown, drawdown) || other.drawdown == drawdown)&&(identical(other.riskBudget, riskBudget) || other.riskBudget == riskBudget)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.dailyCap, dailyCap) || other.dailyCap == dailyCap)&&(identical(other.newsImminent, newsImminent) || other.newsImminent == newsImminent)&&(identical(other.moodReminder, moodReminder) || other.moodReminder == moodReminder)&&(identical(other.backupReminder, backupReminder) || other.backupReminder == backupReminder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,master,drawdown,riskBudget,lock,streak,dailyCap,newsImminent,moodReminder,backupReminder);

@override
String toString() {
  return 'NotificationPrefs(master: $master, drawdown: $drawdown, riskBudget: $riskBudget, lock: $lock, streak: $streak, dailyCap: $dailyCap, newsImminent: $newsImminent, moodReminder: $moodReminder, backupReminder: $backupReminder)';
}


}

/// @nodoc
abstract mixin class $NotificationPrefsCopyWith<$Res>  {
  factory $NotificationPrefsCopyWith(NotificationPrefs value, $Res Function(NotificationPrefs) _then) = _$NotificationPrefsCopyWithImpl;
@useResult
$Res call({
 bool master, bool drawdown, bool riskBudget, bool lock, bool streak, bool dailyCap, bool newsImminent, bool moodReminder, bool backupReminder
});




}
/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._self, this._then);

  final NotificationPrefs _self;
  final $Res Function(NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? master = null,Object? drawdown = null,Object? riskBudget = null,Object? lock = null,Object? streak = null,Object? dailyCap = null,Object? newsImminent = null,Object? moodReminder = null,Object? backupReminder = null,}) {
  return _then(_self.copyWith(
master: null == master ? _self.master : master // ignore: cast_nullable_to_non_nullable
as bool,drawdown: null == drawdown ? _self.drawdown : drawdown // ignore: cast_nullable_to_non_nullable
as bool,riskBudget: null == riskBudget ? _self.riskBudget : riskBudget // ignore: cast_nullable_to_non_nullable
as bool,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as bool,dailyCap: null == dailyCap ? _self.dailyCap : dailyCap // ignore: cast_nullable_to_non_nullable
as bool,newsImminent: null == newsImminent ? _self.newsImminent : newsImminent // ignore: cast_nullable_to_non_nullable
as bool,moodReminder: null == moodReminder ? _self.moodReminder : moodReminder // ignore: cast_nullable_to_non_nullable
as bool,backupReminder: null == backupReminder ? _self.backupReminder : backupReminder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPrefs].
extension NotificationPrefsPatterns on NotificationPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPrefs value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool master,  bool drawdown,  bool riskBudget,  bool lock,  bool streak,  bool dailyCap,  bool newsImminent,  bool moodReminder,  bool backupReminder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.master,_that.drawdown,_that.riskBudget,_that.lock,_that.streak,_that.dailyCap,_that.newsImminent,_that.moodReminder,_that.backupReminder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool master,  bool drawdown,  bool riskBudget,  bool lock,  bool streak,  bool dailyCap,  bool newsImminent,  bool moodReminder,  bool backupReminder)  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that.master,_that.drawdown,_that.riskBudget,_that.lock,_that.streak,_that.dailyCap,_that.newsImminent,_that.moodReminder,_that.backupReminder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool master,  bool drawdown,  bool riskBudget,  bool lock,  bool streak,  bool dailyCap,  bool newsImminent,  bool moodReminder,  bool backupReminder)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.master,_that.drawdown,_that.riskBudget,_that.lock,_that.streak,_that.dailyCap,_that.newsImminent,_that.moodReminder,_that.backupReminder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPrefs implements NotificationPrefs {
  const _NotificationPrefs({this.master = true, this.drawdown = true, this.riskBudget = true, this.lock = true, this.streak = true, this.dailyCap = true, this.newsImminent = true, this.moodReminder = true, this.backupReminder = true});
  factory _NotificationPrefs.fromJson(Map<String, dynamic> json) => _$NotificationPrefsFromJson(json);

/// Master kill-switch. When false, every category is suppressed
/// regardless of its individual flag.
@override@JsonKey() final  bool master;
@override@JsonKey() final  bool drawdown;
@override@JsonKey() final  bool riskBudget;
@override@JsonKey() final  bool lock;
@override@JsonKey() final  bool streak;
@override@JsonKey() final  bool dailyCap;
@override@JsonKey() final  bool newsImminent;
@override@JsonKey() final  bool moodReminder;
@override@JsonKey() final  bool backupReminder;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPrefsCopyWith<_NotificationPrefs> get copyWith => __$NotificationPrefsCopyWithImpl<_NotificationPrefs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPrefsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPrefs&&(identical(other.master, master) || other.master == master)&&(identical(other.drawdown, drawdown) || other.drawdown == drawdown)&&(identical(other.riskBudget, riskBudget) || other.riskBudget == riskBudget)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.dailyCap, dailyCap) || other.dailyCap == dailyCap)&&(identical(other.newsImminent, newsImminent) || other.newsImminent == newsImminent)&&(identical(other.moodReminder, moodReminder) || other.moodReminder == moodReminder)&&(identical(other.backupReminder, backupReminder) || other.backupReminder == backupReminder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,master,drawdown,riskBudget,lock,streak,dailyCap,newsImminent,moodReminder,backupReminder);

@override
String toString() {
  return 'NotificationPrefs(master: $master, drawdown: $drawdown, riskBudget: $riskBudget, lock: $lock, streak: $streak, dailyCap: $dailyCap, newsImminent: $newsImminent, moodReminder: $moodReminder, backupReminder: $backupReminder)';
}


}

/// @nodoc
abstract mixin class _$NotificationPrefsCopyWith<$Res> implements $NotificationPrefsCopyWith<$Res> {
  factory _$NotificationPrefsCopyWith(_NotificationPrefs value, $Res Function(_NotificationPrefs) _then) = __$NotificationPrefsCopyWithImpl;
@override @useResult
$Res call({
 bool master, bool drawdown, bool riskBudget, bool lock, bool streak, bool dailyCap, bool newsImminent, bool moodReminder, bool backupReminder
});




}
/// @nodoc
class __$NotificationPrefsCopyWithImpl<$Res>
    implements _$NotificationPrefsCopyWith<$Res> {
  __$NotificationPrefsCopyWithImpl(this._self, this._then);

  final _NotificationPrefs _self;
  final $Res Function(_NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? master = null,Object? drawdown = null,Object? riskBudget = null,Object? lock = null,Object? streak = null,Object? dailyCap = null,Object? newsImminent = null,Object? moodReminder = null,Object? backupReminder = null,}) {
  return _then(_NotificationPrefs(
master: null == master ? _self.master : master // ignore: cast_nullable_to_non_nullable
as bool,drawdown: null == drawdown ? _self.drawdown : drawdown // ignore: cast_nullable_to_non_nullable
as bool,riskBudget: null == riskBudget ? _self.riskBudget : riskBudget // ignore: cast_nullable_to_non_nullable
as bool,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as bool,dailyCap: null == dailyCap ? _self.dailyCap : dailyCap // ignore: cast_nullable_to_non_nullable
as bool,newsImminent: null == newsImminent ? _self.newsImminent : newsImminent // ignore: cast_nullable_to_non_nullable
as bool,moodReminder: null == moodReminder ? _self.moodReminder : moodReminder // ignore: cast_nullable_to_non_nullable
as bool,backupReminder: null == backupReminder ? _self.backupReminder : backupReminder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AppState {

 int get schemaVersion; double get balance; String get startDate; double get priorPnl; Map<String, bool> get checks; Map<String, String> get gateProofs; List<Trade> get allTrades; bool get lock; int? get lockUntil; bool get preloaded; List<IntegrityEvent> get integrityLog; int? get lastResetAt;/// Map of `YYYY-MM-DD` (EAT) → mood check-in for that day.
 Map<String, DailyMood> get dailyMoods;/// Most recent generated weekly digests (newest first). Capped at ~12.
 List<WeeklyDigest> get weeklyDigests;/// Sprint 4.1 — optional prop-firm drawdown rules.
 PropFirmRules get propFirmRules;/// Sprint 4.2 — optional weekly risk budget (R-units per week).
 WeeklyRiskBudget get weeklyRiskBudget;/// Sprint 4.4 — block trade logging within ±15 min of high-impact news.
 bool get blockTradesAroundNews;/// Sprint 5.3 — Local-only AI mode. When true, all Gemini cloud calls
/// are short-circuited and rule-based fallbacks are used instead.
 bool get localOnlyAiMode;/// Sprint 6.3 — User-configurable daily trade cap (default 2).
/// Allowed values: 1, 2, 3, 5.
 int get dailyTradeCap;/// Sprint 6.5 — Multi-account support. Snapshots of inactive accounts.
/// The currently-active account always lives in the top-level fields
/// above; switching packs current values into `accounts` and unpacks
/// the target snapshot in their place.
 List<TradingAccount> get accounts; String? get activeAccountId;/// Post-Tier-1 — per-category local-notification toggles.
 NotificationPrefs get notificationPrefs;/// Configurable risk cap in USD per single trade. Drives lot/risk
/// calculation in Trade Flow → Size step. Default 100 USD.
 double get riskCapUsd;/// In-flight wizard draft so the Trade Flow tab can be left and
/// returned to without losing inputs. Cleared after the trade is
/// logged successfully.
 WizardDraft? get wizardDraft;/// User-configured gates (replaces hardcoded kGates). When empty,
/// falls back to kGates for backward compatibility.
 List<UserGate> get userGates;/// User-selected instruments with metadata. Keys are symbols (e.g.
/// 'XAUUSD'). When empty, falls back to kInstruments.
 Map<String, Instrument> get userInstruments;/// User's IANA timezone identifier (e.g. 'Africa/Nairobi', 'UTC').
/// When null, falls back to EAT (UTC+3).
 String? get userTimezone;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.priorPnl, priorPnl) || other.priorPnl == priorPnl)&&const DeepCollectionEquality().equals(other.checks, checks)&&const DeepCollectionEquality().equals(other.gateProofs, gateProofs)&&const DeepCollectionEquality().equals(other.allTrades, allTrades)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.lockUntil, lockUntil) || other.lockUntil == lockUntil)&&(identical(other.preloaded, preloaded) || other.preloaded == preloaded)&&const DeepCollectionEquality().equals(other.integrityLog, integrityLog)&&(identical(other.lastResetAt, lastResetAt) || other.lastResetAt == lastResetAt)&&const DeepCollectionEquality().equals(other.dailyMoods, dailyMoods)&&const DeepCollectionEquality().equals(other.weeklyDigests, weeklyDigests)&&(identical(other.propFirmRules, propFirmRules) || other.propFirmRules == propFirmRules)&&(identical(other.weeklyRiskBudget, weeklyRiskBudget) || other.weeklyRiskBudget == weeklyRiskBudget)&&(identical(other.blockTradesAroundNews, blockTradesAroundNews) || other.blockTradesAroundNews == blockTradesAroundNews)&&(identical(other.localOnlyAiMode, localOnlyAiMode) || other.localOnlyAiMode == localOnlyAiMode)&&(identical(other.dailyTradeCap, dailyTradeCap) || other.dailyTradeCap == dailyTradeCap)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&(identical(other.activeAccountId, activeAccountId) || other.activeAccountId == activeAccountId)&&(identical(other.notificationPrefs, notificationPrefs) || other.notificationPrefs == notificationPrefs)&&(identical(other.riskCapUsd, riskCapUsd) || other.riskCapUsd == riskCapUsd)&&(identical(other.wizardDraft, wizardDraft) || other.wizardDraft == wizardDraft)&&const DeepCollectionEquality().equals(other.userGates, userGates)&&const DeepCollectionEquality().equals(other.userInstruments, userInstruments)&&(identical(other.userTimezone, userTimezone) || other.userTimezone == userTimezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,schemaVersion,balance,startDate,priorPnl,const DeepCollectionEquality().hash(checks),const DeepCollectionEquality().hash(gateProofs),const DeepCollectionEquality().hash(allTrades),lock,lockUntil,preloaded,const DeepCollectionEquality().hash(integrityLog),lastResetAt,const DeepCollectionEquality().hash(dailyMoods),const DeepCollectionEquality().hash(weeklyDigests),propFirmRules,weeklyRiskBudget,blockTradesAroundNews,localOnlyAiMode,dailyTradeCap,const DeepCollectionEquality().hash(accounts),activeAccountId,notificationPrefs,riskCapUsd,wizardDraft,const DeepCollectionEquality().hash(userGates),const DeepCollectionEquality().hash(userInstruments),userTimezone]);

@override
String toString() {
  return 'AppState(schemaVersion: $schemaVersion, balance: $balance, startDate: $startDate, priorPnl: $priorPnl, checks: $checks, gateProofs: $gateProofs, allTrades: $allTrades, lock: $lock, lockUntil: $lockUntil, preloaded: $preloaded, integrityLog: $integrityLog, lastResetAt: $lastResetAt, dailyMoods: $dailyMoods, weeklyDigests: $weeklyDigests, propFirmRules: $propFirmRules, weeklyRiskBudget: $weeklyRiskBudget, blockTradesAroundNews: $blockTradesAroundNews, localOnlyAiMode: $localOnlyAiMode, dailyTradeCap: $dailyTradeCap, accounts: $accounts, activeAccountId: $activeAccountId, notificationPrefs: $notificationPrefs, riskCapUsd: $riskCapUsd, wizardDraft: $wizardDraft, userGates: $userGates, userInstruments: $userInstruments, userTimezone: $userTimezone)';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, double balance, String startDate, double priorPnl, Map<String, bool> checks, Map<String, String> gateProofs, List<Trade> allTrades, bool lock, int? lockUntil, bool preloaded, List<IntegrityEvent> integrityLog, int? lastResetAt, Map<String, DailyMood> dailyMoods, List<WeeklyDigest> weeklyDigests, PropFirmRules propFirmRules, WeeklyRiskBudget weeklyRiskBudget, bool blockTradesAroundNews, bool localOnlyAiMode, int dailyTradeCap, List<TradingAccount> accounts, String? activeAccountId, NotificationPrefs notificationPrefs, double riskCapUsd, WizardDraft? wizardDraft, List<UserGate> userGates, Map<String, Instrument> userInstruments, String? userTimezone
});


$PropFirmRulesCopyWith<$Res> get propFirmRules;$WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget;$NotificationPrefsCopyWith<$Res> get notificationPrefs;$WizardDraftCopyWith<$Res>? get wizardDraft;

}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? balance = null,Object? startDate = null,Object? priorPnl = null,Object? checks = null,Object? gateProofs = null,Object? allTrades = null,Object? lock = null,Object? lockUntil = freezed,Object? preloaded = null,Object? integrityLog = null,Object? lastResetAt = freezed,Object? dailyMoods = null,Object? weeklyDigests = null,Object? propFirmRules = null,Object? weeklyRiskBudget = null,Object? blockTradesAroundNews = null,Object? localOnlyAiMode = null,Object? dailyTradeCap = null,Object? accounts = null,Object? activeAccountId = freezed,Object? notificationPrefs = null,Object? riskCapUsd = null,Object? wizardDraft = freezed,Object? userGates = null,Object? userInstruments = null,Object? userTimezone = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,priorPnl: null == priorPnl ? _self.priorPnl : priorPnl // ignore: cast_nullable_to_non_nullable
as double,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,gateProofs: null == gateProofs ? _self.gateProofs : gateProofs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,allTrades: null == allTrades ? _self.allTrades : allTrades // ignore: cast_nullable_to_non_nullable
as List<Trade>,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,lockUntil: freezed == lockUntil ? _self.lockUntil : lockUntil // ignore: cast_nullable_to_non_nullable
as int?,preloaded: null == preloaded ? _self.preloaded : preloaded // ignore: cast_nullable_to_non_nullable
as bool,integrityLog: null == integrityLog ? _self.integrityLog : integrityLog // ignore: cast_nullable_to_non_nullable
as List<IntegrityEvent>,lastResetAt: freezed == lastResetAt ? _self.lastResetAt : lastResetAt // ignore: cast_nullable_to_non_nullable
as int?,dailyMoods: null == dailyMoods ? _self.dailyMoods : dailyMoods // ignore: cast_nullable_to_non_nullable
as Map<String, DailyMood>,weeklyDigests: null == weeklyDigests ? _self.weeklyDigests : weeklyDigests // ignore: cast_nullable_to_non_nullable
as List<WeeklyDigest>,propFirmRules: null == propFirmRules ? _self.propFirmRules : propFirmRules // ignore: cast_nullable_to_non_nullable
as PropFirmRules,weeklyRiskBudget: null == weeklyRiskBudget ? _self.weeklyRiskBudget : weeklyRiskBudget // ignore: cast_nullable_to_non_nullable
as WeeklyRiskBudget,blockTradesAroundNews: null == blockTradesAroundNews ? _self.blockTradesAroundNews : blockTradesAroundNews // ignore: cast_nullable_to_non_nullable
as bool,localOnlyAiMode: null == localOnlyAiMode ? _self.localOnlyAiMode : localOnlyAiMode // ignore: cast_nullable_to_non_nullable
as bool,dailyTradeCap: null == dailyTradeCap ? _self.dailyTradeCap : dailyTradeCap // ignore: cast_nullable_to_non_nullable
as int,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<TradingAccount>,activeAccountId: freezed == activeAccountId ? _self.activeAccountId : activeAccountId // ignore: cast_nullable_to_non_nullable
as String?,notificationPrefs: null == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as NotificationPrefs,riskCapUsd: null == riskCapUsd ? _self.riskCapUsd : riskCapUsd // ignore: cast_nullable_to_non_nullable
as double,wizardDraft: freezed == wizardDraft ? _self.wizardDraft : wizardDraft // ignore: cast_nullable_to_non_nullable
as WizardDraft?,userGates: null == userGates ? _self.userGates : userGates // ignore: cast_nullable_to_non_nullable
as List<UserGate>,userInstruments: null == userInstruments ? _self.userInstruments : userInstruments // ignore: cast_nullable_to_non_nullable
as Map<String, Instrument>,userTimezone: freezed == userTimezone ? _self.userTimezone : userTimezone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropFirmRulesCopyWith<$Res> get propFirmRules {
  
  return $PropFirmRulesCopyWith<$Res>(_self.propFirmRules, (value) {
    return _then(_self.copyWith(propFirmRules: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget {
  
  return $WeeklyRiskBudgetCopyWith<$Res>(_self.weeklyRiskBudget, (value) {
    return _then(_self.copyWith(weeklyRiskBudget: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<$Res> get notificationPrefs {
  
  return $NotificationPrefsCopyWith<$Res>(_self.notificationPrefs, (value) {
    return _then(_self.copyWith(notificationPrefs: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WizardDraftCopyWith<$Res>? get wizardDraft {
    if (_self.wizardDraft == null) {
    return null;
  }

  return $WizardDraftCopyWith<$Res>(_self.wizardDraft!, (value) {
    return _then(_self.copyWith(wizardDraft: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  double balance,  String startDate,  double priorPnl,  Map<String, bool> checks,  Map<String, String> gateProofs,  List<Trade> allTrades,  bool lock,  int? lockUntil,  bool preloaded,  List<IntegrityEvent> integrityLog,  int? lastResetAt,  Map<String, DailyMood> dailyMoods,  List<WeeklyDigest> weeklyDigests,  PropFirmRules propFirmRules,  WeeklyRiskBudget weeklyRiskBudget,  bool blockTradesAroundNews,  bool localOnlyAiMode,  int dailyTradeCap,  List<TradingAccount> accounts,  String? activeAccountId,  NotificationPrefs notificationPrefs,  double riskCapUsd,  WizardDraft? wizardDraft,  List<UserGate> userGates,  Map<String, Instrument> userInstruments,  String? userTimezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.schemaVersion,_that.balance,_that.startDate,_that.priorPnl,_that.checks,_that.gateProofs,_that.allTrades,_that.lock,_that.lockUntil,_that.preloaded,_that.integrityLog,_that.lastResetAt,_that.dailyMoods,_that.weeklyDigests,_that.propFirmRules,_that.weeklyRiskBudget,_that.blockTradesAroundNews,_that.localOnlyAiMode,_that.dailyTradeCap,_that.accounts,_that.activeAccountId,_that.notificationPrefs,_that.riskCapUsd,_that.wizardDraft,_that.userGates,_that.userInstruments,_that.userTimezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  double balance,  String startDate,  double priorPnl,  Map<String, bool> checks,  Map<String, String> gateProofs,  List<Trade> allTrades,  bool lock,  int? lockUntil,  bool preloaded,  List<IntegrityEvent> integrityLog,  int? lastResetAt,  Map<String, DailyMood> dailyMoods,  List<WeeklyDigest> weeklyDigests,  PropFirmRules propFirmRules,  WeeklyRiskBudget weeklyRiskBudget,  bool blockTradesAroundNews,  bool localOnlyAiMode,  int dailyTradeCap,  List<TradingAccount> accounts,  String? activeAccountId,  NotificationPrefs notificationPrefs,  double riskCapUsd,  WizardDraft? wizardDraft,  List<UserGate> userGates,  Map<String, Instrument> userInstruments,  String? userTimezone)  $default,) {final _that = this;
switch (_that) {
case _AppState():
return $default(_that.schemaVersion,_that.balance,_that.startDate,_that.priorPnl,_that.checks,_that.gateProofs,_that.allTrades,_that.lock,_that.lockUntil,_that.preloaded,_that.integrityLog,_that.lastResetAt,_that.dailyMoods,_that.weeklyDigests,_that.propFirmRules,_that.weeklyRiskBudget,_that.blockTradesAroundNews,_that.localOnlyAiMode,_that.dailyTradeCap,_that.accounts,_that.activeAccountId,_that.notificationPrefs,_that.riskCapUsd,_that.wizardDraft,_that.userGates,_that.userInstruments,_that.userTimezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  double balance,  String startDate,  double priorPnl,  Map<String, bool> checks,  Map<String, String> gateProofs,  List<Trade> allTrades,  bool lock,  int? lockUntil,  bool preloaded,  List<IntegrityEvent> integrityLog,  int? lastResetAt,  Map<String, DailyMood> dailyMoods,  List<WeeklyDigest> weeklyDigests,  PropFirmRules propFirmRules,  WeeklyRiskBudget weeklyRiskBudget,  bool blockTradesAroundNews,  bool localOnlyAiMode,  int dailyTradeCap,  List<TradingAccount> accounts,  String? activeAccountId,  NotificationPrefs notificationPrefs,  double riskCapUsd,  WizardDraft? wizardDraft,  List<UserGate> userGates,  Map<String, Instrument> userInstruments,  String? userTimezone)?  $default,) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.schemaVersion,_that.balance,_that.startDate,_that.priorPnl,_that.checks,_that.gateProofs,_that.allTrades,_that.lock,_that.lockUntil,_that.preloaded,_that.integrityLog,_that.lastResetAt,_that.dailyMoods,_that.weeklyDigests,_that.propFirmRules,_that.weeklyRiskBudget,_that.blockTradesAroundNews,_that.localOnlyAiMode,_that.dailyTradeCap,_that.accounts,_that.activeAccountId,_that.notificationPrefs,_that.riskCapUsd,_that.wizardDraft,_that.userGates,_that.userInstruments,_that.userTimezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppState extends AppState {
  const _AppState({this.schemaVersion = kCurrentSchemaVersion, this.balance = 0.0, this.startDate = '', this.priorPnl = 0.0, final  Map<String, bool> checks = const {}, final  Map<String, String> gateProofs = const {}, final  List<Trade> allTrades = const [], this.lock = false, this.lockUntil, this.preloaded = false, final  List<IntegrityEvent> integrityLog = const [], this.lastResetAt, final  Map<String, DailyMood> dailyMoods = const {}, final  List<WeeklyDigest> weeklyDigests = const [], this.propFirmRules = const PropFirmRules(), this.weeklyRiskBudget = const WeeklyRiskBudget(), this.blockTradesAroundNews = false, this.localOnlyAiMode = false, this.dailyTradeCap = 2, final  List<TradingAccount> accounts = const [], this.activeAccountId, this.notificationPrefs = const NotificationPrefs(), this.riskCapUsd = 100.0, this.wizardDraft, final  List<UserGate> userGates = const [], final  Map<String, Instrument> userInstruments = const {}, this.userTimezone}): _checks = checks,_gateProofs = gateProofs,_allTrades = allTrades,_integrityLog = integrityLog,_dailyMoods = dailyMoods,_weeklyDigests = weeklyDigests,_accounts = accounts,_userGates = userGates,_userInstruments = userInstruments,super._();
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

 final  Map<String, String> _gateProofs;
@override@JsonKey() Map<String, String> get gateProofs {
  if (_gateProofs is EqualUnmodifiableMapView) return _gateProofs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_gateProofs);
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
 final  List<IntegrityEvent> _integrityLog;
@override@JsonKey() List<IntegrityEvent> get integrityLog {
  if (_integrityLog is EqualUnmodifiableListView) return _integrityLog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_integrityLog);
}

@override final  int? lastResetAt;
/// Map of `YYYY-MM-DD` (EAT) → mood check-in for that day.
 final  Map<String, DailyMood> _dailyMoods;
/// Map of `YYYY-MM-DD` (EAT) → mood check-in for that day.
@override@JsonKey() Map<String, DailyMood> get dailyMoods {
  if (_dailyMoods is EqualUnmodifiableMapView) return _dailyMoods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dailyMoods);
}

/// Most recent generated weekly digests (newest first). Capped at ~12.
 final  List<WeeklyDigest> _weeklyDigests;
/// Most recent generated weekly digests (newest first). Capped at ~12.
@override@JsonKey() List<WeeklyDigest> get weeklyDigests {
  if (_weeklyDigests is EqualUnmodifiableListView) return _weeklyDigests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklyDigests);
}

/// Sprint 4.1 — optional prop-firm drawdown rules.
@override@JsonKey() final  PropFirmRules propFirmRules;
/// Sprint 4.2 — optional weekly risk budget (R-units per week).
@override@JsonKey() final  WeeklyRiskBudget weeklyRiskBudget;
/// Sprint 4.4 — block trade logging within ±15 min of high-impact news.
@override@JsonKey() final  bool blockTradesAroundNews;
/// Sprint 5.3 — Local-only AI mode. When true, all Gemini cloud calls
/// are short-circuited and rule-based fallbacks are used instead.
@override@JsonKey() final  bool localOnlyAiMode;
/// Sprint 6.3 — User-configurable daily trade cap (default 2).
/// Allowed values: 1, 2, 3, 5.
@override@JsonKey() final  int dailyTradeCap;
/// Sprint 6.5 — Multi-account support. Snapshots of inactive accounts.
/// The currently-active account always lives in the top-level fields
/// above; switching packs current values into `accounts` and unpacks
/// the target snapshot in their place.
 final  List<TradingAccount> _accounts;
/// Sprint 6.5 — Multi-account support. Snapshots of inactive accounts.
/// The currently-active account always lives in the top-level fields
/// above; switching packs current values into `accounts` and unpacks
/// the target snapshot in their place.
@override@JsonKey() List<TradingAccount> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

@override final  String? activeAccountId;
/// Post-Tier-1 — per-category local-notification toggles.
@override@JsonKey() final  NotificationPrefs notificationPrefs;
/// Configurable risk cap in USD per single trade. Drives lot/risk
/// calculation in Trade Flow → Size step. Default 100 USD.
@override@JsonKey() final  double riskCapUsd;
/// In-flight wizard draft so the Trade Flow tab can be left and
/// returned to without losing inputs. Cleared after the trade is
/// logged successfully.
@override final  WizardDraft? wizardDraft;
/// User-configured gates (replaces hardcoded kGates). When empty,
/// falls back to kGates for backward compatibility.
 final  List<UserGate> _userGates;
/// User-configured gates (replaces hardcoded kGates). When empty,
/// falls back to kGates for backward compatibility.
@override@JsonKey() List<UserGate> get userGates {
  if (_userGates is EqualUnmodifiableListView) return _userGates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userGates);
}

/// User-selected instruments with metadata. Keys are symbols (e.g.
/// 'XAUUSD'). When empty, falls back to kInstruments.
 final  Map<String, Instrument> _userInstruments;
/// User-selected instruments with metadata. Keys are symbols (e.g.
/// 'XAUUSD'). When empty, falls back to kInstruments.
@override@JsonKey() Map<String, Instrument> get userInstruments {
  if (_userInstruments is EqualUnmodifiableMapView) return _userInstruments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userInstruments);
}

/// User's IANA timezone identifier (e.g. 'Africa/Nairobi', 'UTC').
/// When null, falls back to EAT (UTC+3).
@override final  String? userTimezone;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.priorPnl, priorPnl) || other.priorPnl == priorPnl)&&const DeepCollectionEquality().equals(other._checks, _checks)&&const DeepCollectionEquality().equals(other._gateProofs, _gateProofs)&&const DeepCollectionEquality().equals(other._allTrades, _allTrades)&&(identical(other.lock, lock) || other.lock == lock)&&(identical(other.lockUntil, lockUntil) || other.lockUntil == lockUntil)&&(identical(other.preloaded, preloaded) || other.preloaded == preloaded)&&const DeepCollectionEquality().equals(other._integrityLog, _integrityLog)&&(identical(other.lastResetAt, lastResetAt) || other.lastResetAt == lastResetAt)&&const DeepCollectionEquality().equals(other._dailyMoods, _dailyMoods)&&const DeepCollectionEquality().equals(other._weeklyDigests, _weeklyDigests)&&(identical(other.propFirmRules, propFirmRules) || other.propFirmRules == propFirmRules)&&(identical(other.weeklyRiskBudget, weeklyRiskBudget) || other.weeklyRiskBudget == weeklyRiskBudget)&&(identical(other.blockTradesAroundNews, blockTradesAroundNews) || other.blockTradesAroundNews == blockTradesAroundNews)&&(identical(other.localOnlyAiMode, localOnlyAiMode) || other.localOnlyAiMode == localOnlyAiMode)&&(identical(other.dailyTradeCap, dailyTradeCap) || other.dailyTradeCap == dailyTradeCap)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&(identical(other.activeAccountId, activeAccountId) || other.activeAccountId == activeAccountId)&&(identical(other.notificationPrefs, notificationPrefs) || other.notificationPrefs == notificationPrefs)&&(identical(other.riskCapUsd, riskCapUsd) || other.riskCapUsd == riskCapUsd)&&(identical(other.wizardDraft, wizardDraft) || other.wizardDraft == wizardDraft)&&const DeepCollectionEquality().equals(other._userGates, _userGates)&&const DeepCollectionEquality().equals(other._userInstruments, _userInstruments)&&(identical(other.userTimezone, userTimezone) || other.userTimezone == userTimezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,schemaVersion,balance,startDate,priorPnl,const DeepCollectionEquality().hash(_checks),const DeepCollectionEquality().hash(_gateProofs),const DeepCollectionEquality().hash(_allTrades),lock,lockUntil,preloaded,const DeepCollectionEquality().hash(_integrityLog),lastResetAt,const DeepCollectionEquality().hash(_dailyMoods),const DeepCollectionEquality().hash(_weeklyDigests),propFirmRules,weeklyRiskBudget,blockTradesAroundNews,localOnlyAiMode,dailyTradeCap,const DeepCollectionEquality().hash(_accounts),activeAccountId,notificationPrefs,riskCapUsd,wizardDraft,const DeepCollectionEquality().hash(_userGates),const DeepCollectionEquality().hash(_userInstruments),userTimezone]);

@override
String toString() {
  return 'AppState(schemaVersion: $schemaVersion, balance: $balance, startDate: $startDate, priorPnl: $priorPnl, checks: $checks, gateProofs: $gateProofs, allTrades: $allTrades, lock: $lock, lockUntil: $lockUntil, preloaded: $preloaded, integrityLog: $integrityLog, lastResetAt: $lastResetAt, dailyMoods: $dailyMoods, weeklyDigests: $weeklyDigests, propFirmRules: $propFirmRules, weeklyRiskBudget: $weeklyRiskBudget, blockTradesAroundNews: $blockTradesAroundNews, localOnlyAiMode: $localOnlyAiMode, dailyTradeCap: $dailyTradeCap, accounts: $accounts, activeAccountId: $activeAccountId, notificationPrefs: $notificationPrefs, riskCapUsd: $riskCapUsd, wizardDraft: $wizardDraft, userGates: $userGates, userInstruments: $userInstruments, userTimezone: $userTimezone)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, double balance, String startDate, double priorPnl, Map<String, bool> checks, Map<String, String> gateProofs, List<Trade> allTrades, bool lock, int? lockUntil, bool preloaded, List<IntegrityEvent> integrityLog, int? lastResetAt, Map<String, DailyMood> dailyMoods, List<WeeklyDigest> weeklyDigests, PropFirmRules propFirmRules, WeeklyRiskBudget weeklyRiskBudget, bool blockTradesAroundNews, bool localOnlyAiMode, int dailyTradeCap, List<TradingAccount> accounts, String? activeAccountId, NotificationPrefs notificationPrefs, double riskCapUsd, WizardDraft? wizardDraft, List<UserGate> userGates, Map<String, Instrument> userInstruments, String? userTimezone
});


@override $PropFirmRulesCopyWith<$Res> get propFirmRules;@override $WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget;@override $NotificationPrefsCopyWith<$Res> get notificationPrefs;@override $WizardDraftCopyWith<$Res>? get wizardDraft;

}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? balance = null,Object? startDate = null,Object? priorPnl = null,Object? checks = null,Object? gateProofs = null,Object? allTrades = null,Object? lock = null,Object? lockUntil = freezed,Object? preloaded = null,Object? integrityLog = null,Object? lastResetAt = freezed,Object? dailyMoods = null,Object? weeklyDigests = null,Object? propFirmRules = null,Object? weeklyRiskBudget = null,Object? blockTradesAroundNews = null,Object? localOnlyAiMode = null,Object? dailyTradeCap = null,Object? accounts = null,Object? activeAccountId = freezed,Object? notificationPrefs = null,Object? riskCapUsd = null,Object? wizardDraft = freezed,Object? userGates = null,Object? userInstruments = null,Object? userTimezone = freezed,}) {
  return _then(_AppState(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,priorPnl: null == priorPnl ? _self.priorPnl : priorPnl // ignore: cast_nullable_to_non_nullable
as double,checks: null == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,gateProofs: null == gateProofs ? _self._gateProofs : gateProofs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,allTrades: null == allTrades ? _self._allTrades : allTrades // ignore: cast_nullable_to_non_nullable
as List<Trade>,lock: null == lock ? _self.lock : lock // ignore: cast_nullable_to_non_nullable
as bool,lockUntil: freezed == lockUntil ? _self.lockUntil : lockUntil // ignore: cast_nullable_to_non_nullable
as int?,preloaded: null == preloaded ? _self.preloaded : preloaded // ignore: cast_nullable_to_non_nullable
as bool,integrityLog: null == integrityLog ? _self._integrityLog : integrityLog // ignore: cast_nullable_to_non_nullable
as List<IntegrityEvent>,lastResetAt: freezed == lastResetAt ? _self.lastResetAt : lastResetAt // ignore: cast_nullable_to_non_nullable
as int?,dailyMoods: null == dailyMoods ? _self._dailyMoods : dailyMoods // ignore: cast_nullable_to_non_nullable
as Map<String, DailyMood>,weeklyDigests: null == weeklyDigests ? _self._weeklyDigests : weeklyDigests // ignore: cast_nullable_to_non_nullable
as List<WeeklyDigest>,propFirmRules: null == propFirmRules ? _self.propFirmRules : propFirmRules // ignore: cast_nullable_to_non_nullable
as PropFirmRules,weeklyRiskBudget: null == weeklyRiskBudget ? _self.weeklyRiskBudget : weeklyRiskBudget // ignore: cast_nullable_to_non_nullable
as WeeklyRiskBudget,blockTradesAroundNews: null == blockTradesAroundNews ? _self.blockTradesAroundNews : blockTradesAroundNews // ignore: cast_nullable_to_non_nullable
as bool,localOnlyAiMode: null == localOnlyAiMode ? _self.localOnlyAiMode : localOnlyAiMode // ignore: cast_nullable_to_non_nullable
as bool,dailyTradeCap: null == dailyTradeCap ? _self.dailyTradeCap : dailyTradeCap // ignore: cast_nullable_to_non_nullable
as int,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<TradingAccount>,activeAccountId: freezed == activeAccountId ? _self.activeAccountId : activeAccountId // ignore: cast_nullable_to_non_nullable
as String?,notificationPrefs: null == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as NotificationPrefs,riskCapUsd: null == riskCapUsd ? _self.riskCapUsd : riskCapUsd // ignore: cast_nullable_to_non_nullable
as double,wizardDraft: freezed == wizardDraft ? _self.wizardDraft : wizardDraft // ignore: cast_nullable_to_non_nullable
as WizardDraft?,userGates: null == userGates ? _self._userGates : userGates // ignore: cast_nullable_to_non_nullable
as List<UserGate>,userInstruments: null == userInstruments ? _self._userInstruments : userInstruments // ignore: cast_nullable_to_non_nullable
as Map<String, Instrument>,userTimezone: freezed == userTimezone ? _self.userTimezone : userTimezone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropFirmRulesCopyWith<$Res> get propFirmRules {
  
  return $PropFirmRulesCopyWith<$Res>(_self.propFirmRules, (value) {
    return _then(_self.copyWith(propFirmRules: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyRiskBudgetCopyWith<$Res> get weeklyRiskBudget {
  
  return $WeeklyRiskBudgetCopyWith<$Res>(_self.weeklyRiskBudget, (value) {
    return _then(_self.copyWith(weeklyRiskBudget: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<$Res> get notificationPrefs {
  
  return $NotificationPrefsCopyWith<$Res>(_self.notificationPrefs, (value) {
    return _then(_self.copyWith(notificationPrefs: value));
  });
}/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WizardDraftCopyWith<$Res>? get wizardDraft {
    if (_self.wizardDraft == null) {
    return null;
  }

  return $WizardDraftCopyWith<$Res>(_self.wizardDraft!, (value) {
    return _then(_self.copyWith(wizardDraft: value));
  });
}
}


/// @nodoc
mixin _$UserGate {

 String get id; bool get auto; String get label; String get sub; List<String>? get symbols; int get sortOrder;
/// Create a copy of UserGate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserGateCopyWith<UserGate> get copyWith => _$UserGateCopyWithImpl<UserGate>(this as UserGate, _$identity);

  /// Serializes this UserGate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserGate&&(identical(other.id, id) || other.id == id)&&(identical(other.auto, auto) || other.auto == auto)&&(identical(other.label, label) || other.label == label)&&(identical(other.sub, sub) || other.sub == sub)&&const DeepCollectionEquality().equals(other.symbols, symbols)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,auto,label,sub,const DeepCollectionEquality().hash(symbols),sortOrder);

@override
String toString() {
  return 'UserGate(id: $id, auto: $auto, label: $label, sub: $sub, symbols: $symbols, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $UserGateCopyWith<$Res>  {
  factory $UserGateCopyWith(UserGate value, $Res Function(UserGate) _then) = _$UserGateCopyWithImpl;
@useResult
$Res call({
 String id, bool auto, String label, String sub, List<String>? symbols, int sortOrder
});




}
/// @nodoc
class _$UserGateCopyWithImpl<$Res>
    implements $UserGateCopyWith<$Res> {
  _$UserGateCopyWithImpl(this._self, this._then);

  final UserGate _self;
  final $Res Function(UserGate) _then;

/// Create a copy of UserGate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? auto = null,Object? label = null,Object? sub = null,Object? symbols = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,auto: null == auto ? _self.auto : auto // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,sub: null == sub ? _self.sub : sub // ignore: cast_nullable_to_non_nullable
as String,symbols: freezed == symbols ? _self.symbols : symbols // ignore: cast_nullable_to_non_nullable
as List<String>?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserGate].
extension UserGatePatterns on UserGate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserGate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserGate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserGate value)  $default,){
final _that = this;
switch (_that) {
case _UserGate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserGate value)?  $default,){
final _that = this;
switch (_that) {
case _UserGate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool auto,  String label,  String sub,  List<String>? symbols,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserGate() when $default != null:
return $default(_that.id,_that.auto,_that.label,_that.sub,_that.symbols,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool auto,  String label,  String sub,  List<String>? symbols,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _UserGate():
return $default(_that.id,_that.auto,_that.label,_that.sub,_that.symbols,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool auto,  String label,  String sub,  List<String>? symbols,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _UserGate() when $default != null:
return $default(_that.id,_that.auto,_that.label,_that.sub,_that.symbols,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserGate implements UserGate {
  const _UserGate({required this.id, this.auto = false, required this.label, this.sub = '', final  List<String>? symbols = null, this.sortOrder = 0}): _symbols = symbols;
  factory _UserGate.fromJson(Map<String, dynamic> json) => _$UserGateFromJson(json);

@override final  String id;
@override@JsonKey() final  bool auto;
@override final  String label;
@override@JsonKey() final  String sub;
 final  List<String>? _symbols;
@override@JsonKey() List<String>? get symbols {
  final value = _symbols;
  if (value == null) return null;
  if (_symbols is EqualUnmodifiableListView) return _symbols;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  int sortOrder;

/// Create a copy of UserGate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserGateCopyWith<_UserGate> get copyWith => __$UserGateCopyWithImpl<_UserGate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserGateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserGate&&(identical(other.id, id) || other.id == id)&&(identical(other.auto, auto) || other.auto == auto)&&(identical(other.label, label) || other.label == label)&&(identical(other.sub, sub) || other.sub == sub)&&const DeepCollectionEquality().equals(other._symbols, _symbols)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,auto,label,sub,const DeepCollectionEquality().hash(_symbols),sortOrder);

@override
String toString() {
  return 'UserGate(id: $id, auto: $auto, label: $label, sub: $sub, symbols: $symbols, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$UserGateCopyWith<$Res> implements $UserGateCopyWith<$Res> {
  factory _$UserGateCopyWith(_UserGate value, $Res Function(_UserGate) _then) = __$UserGateCopyWithImpl;
@override @useResult
$Res call({
 String id, bool auto, String label, String sub, List<String>? symbols, int sortOrder
});




}
/// @nodoc
class __$UserGateCopyWithImpl<$Res>
    implements _$UserGateCopyWith<$Res> {
  __$UserGateCopyWithImpl(this._self, this._then);

  final _UserGate _self;
  final $Res Function(_UserGate) _then;

/// Create a copy of UserGate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? auto = null,Object? label = null,Object? sub = null,Object? symbols = freezed,Object? sortOrder = null,}) {
  return _then(_UserGate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,auto: null == auto ? _self.auto : auto // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,sub: null == sub ? _self.sub : sub // ignore: cast_nullable_to_non_nullable
as String,symbols: freezed == symbols ? _self._symbols : symbols // ignore: cast_nullable_to_non_nullable
as List<String>?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Instrument {

 String get unit; double get pipVal; String get desc; String get category;
/// Create a copy of Instrument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstrumentCopyWith<Instrument> get copyWith => _$InstrumentCopyWithImpl<Instrument>(this as Instrument, _$identity);

  /// Serializes this Instrument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Instrument&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.pipVal, pipVal) || other.pipVal == pipVal)&&(identical(other.desc, desc) || other.desc == desc)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unit,pipVal,desc,category);

@override
String toString() {
  return 'Instrument(unit: $unit, pipVal: $pipVal, desc: $desc, category: $category)';
}


}

/// @nodoc
abstract mixin class $InstrumentCopyWith<$Res>  {
  factory $InstrumentCopyWith(Instrument value, $Res Function(Instrument) _then) = _$InstrumentCopyWithImpl;
@useResult
$Res call({
 String unit, double pipVal, String desc, String category
});




}
/// @nodoc
class _$InstrumentCopyWithImpl<$Res>
    implements $InstrumentCopyWith<$Res> {
  _$InstrumentCopyWithImpl(this._self, this._then);

  final Instrument _self;
  final $Res Function(Instrument) _then;

/// Create a copy of Instrument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unit = null,Object? pipVal = null,Object? desc = null,Object? category = null,}) {
  return _then(_self.copyWith(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,pipVal: null == pipVal ? _self.pipVal : pipVal // ignore: cast_nullable_to_non_nullable
as double,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Instrument].
extension InstrumentPatterns on Instrument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Instrument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Instrument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Instrument value)  $default,){
final _that = this;
switch (_that) {
case _Instrument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Instrument value)?  $default,){
final _that = this;
switch (_that) {
case _Instrument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String unit,  double pipVal,  String desc,  String category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Instrument() when $default != null:
return $default(_that.unit,_that.pipVal,_that.desc,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String unit,  double pipVal,  String desc,  String category)  $default,) {final _that = this;
switch (_that) {
case _Instrument():
return $default(_that.unit,_that.pipVal,_that.desc,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String unit,  double pipVal,  String desc,  String category)?  $default,) {final _that = this;
switch (_that) {
case _Instrument() when $default != null:
return $default(_that.unit,_that.pipVal,_that.desc,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Instrument implements Instrument {
  const _Instrument({required this.unit, this.pipVal = 1.0, this.desc = '', this.category = ''});
  factory _Instrument.fromJson(Map<String, dynamic> json) => _$InstrumentFromJson(json);

@override final  String unit;
@override@JsonKey() final  double pipVal;
@override@JsonKey() final  String desc;
@override@JsonKey() final  String category;

/// Create a copy of Instrument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstrumentCopyWith<_Instrument> get copyWith => __$InstrumentCopyWithImpl<_Instrument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstrumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Instrument&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.pipVal, pipVal) || other.pipVal == pipVal)&&(identical(other.desc, desc) || other.desc == desc)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unit,pipVal,desc,category);

@override
String toString() {
  return 'Instrument(unit: $unit, pipVal: $pipVal, desc: $desc, category: $category)';
}


}

/// @nodoc
abstract mixin class _$InstrumentCopyWith<$Res> implements $InstrumentCopyWith<$Res> {
  factory _$InstrumentCopyWith(_Instrument value, $Res Function(_Instrument) _then) = __$InstrumentCopyWithImpl;
@override @useResult
$Res call({
 String unit, double pipVal, String desc, String category
});




}
/// @nodoc
class __$InstrumentCopyWithImpl<$Res>
    implements _$InstrumentCopyWith<$Res> {
  __$InstrumentCopyWithImpl(this._self, this._then);

  final _Instrument _self;
  final $Res Function(_Instrument) _then;

/// Create a copy of Instrument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unit = null,Object? pipVal = null,Object? desc = null,Object? category = null,}) {
  return _then(_Instrument(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,pipVal: null == pipVal ? _self.pipVal : pipVal // ignore: cast_nullable_to_non_nullable
as double,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
