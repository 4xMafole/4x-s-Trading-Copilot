import 'package:freezed_annotation/freezed_annotation.dart';
import '../../services/ai_service.dart';

part 'ai_coach_state.freezed.dart';

@freezed
abstract class AiCoachState with _$AiCoachState {
  const factory AiCoachState.initial() = AiCoachStateInitial;
  const factory AiCoachState.loading() = AiCoachStateLoading;
  const factory AiCoachState.success(AiReport report) = AiCoachStateSuccess;
  const factory AiCoachState.error(String message) = AiCoachStateError;
}
