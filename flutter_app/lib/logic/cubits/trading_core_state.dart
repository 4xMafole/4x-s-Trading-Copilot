import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models.dart';

part 'trading_core_state.freezed.dart';

@freezed
abstract class TradingCoreState with _$TradingCoreState {
  const factory TradingCoreState({
    required AppState appState,
    required DateTime nowEAT,
  }) = _TradingCoreState;
}
