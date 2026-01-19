import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/quit_plan_repository.dart';
import '../models/quit_phase.dart';

class QuitPhaseViewModel extends StateNotifier<AsyncValue<QuitPhase?>> {
  final QuitPlanRepository repository;

  QuitPhaseViewModel(this.repository) : super(const AsyncValue.loading());

  Future<void> loadQuitPlan() async {
    try {
      state = const AsyncValue.loading();
      final result = await repository.getQuitPlan();
      final phase = QuitPhase.fromJson(result);
      state = AsyncValue.data(phase);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> keepPhase({
    required int quitPlanId,
    required int phaseId,
  }) async {
    final previousState = state;
    try {
      await repository.keepPhase(quitPlanId: quitPlanId, phaseId: phaseId);
      await loadQuitPlan();
    } catch (e, st) {
      state = previousState;
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> redoPhase({
    required int phaseId,
    required String anchorStart,
  }) async {
    final previousState = state;
    try {
      await repository.redoPhase(phaseId: phaseId, anchorStart: anchorStart);
      await loadQuitPlan();
    } catch (e, st) {
      state = previousState;
      Error.throwWithStackTrace(e, st);
    }
  }
}
