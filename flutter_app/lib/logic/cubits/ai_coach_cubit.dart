import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models.dart';
import '../../services/ai_service.dart';
import 'ai_coach_state.dart';

class AiCoachCubit extends Cubit<AiCoachState> {
  AiCoachCubit() : super(const AiCoachState.initial());

  Future<void> analyzeEdge(List<Trade> trades) async {
    if (trades.isEmpty) {
      emit(
        const AiCoachState.error(
          'No trades available to analyze. Log some data first.',
        ),
      );
      return;
    }

    emit(const AiCoachState.loading());
    try {
      final report = await AiService.generateEdgeReport(trades);
      emit(AiCoachState.success(report));
    } catch (e) {
      emit(AiCoachState.error(e.toString()));
    }
  }

  void reset() {
    emit(const AiCoachState.initial());
  }
}
