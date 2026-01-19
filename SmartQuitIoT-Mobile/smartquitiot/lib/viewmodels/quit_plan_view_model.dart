import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request/create_new_quit_plan_request.dart';
import '../models/request/create_quit_plan_request.dart';
import '../providers/quit_plan_provider.dart';
import '../repositories/quit_plan_repository.dart';
import '../models/phase.dart';

class QuitPlanViewModel extends StateNotifier<AsyncValue<Phase?>> {
  final QuitPlanRepository repository;
  QuitPlanViewModel(this.repository) : super(const AsyncData(null));

  Future<void> createPlan(CreateQuitPlanRequest request) async {
    state = const AsyncValue.loading();
    try {
      final phase = await repository.createPlan(request);
      state = AsyncValue.data(phase);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createNewPlan(CreateNewQuitPlanRequest request) async {
    state = const AsyncValue.loading();
    try {
      final phase = await repository.createNewPlan(request);
      state = AsyncValue.data(phase);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Provider
  final quitPlanViewModelProvider =
      StateNotifierProvider<QuitPlanViewModel, AsyncValue<Phase?>>((ref) {
        final repo = ref.watch(quitPlanRepositoryProvider);
        return QuitPlanViewModel(repo);
      });
}
