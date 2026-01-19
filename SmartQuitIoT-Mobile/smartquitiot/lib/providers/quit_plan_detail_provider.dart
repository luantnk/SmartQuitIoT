import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quit_plan_detail.dart';
import '../services/quit_plan_detail_service.dart';
import '../repositories/quit_plan_detail_repository.dart';
import '../viewmodels/quit_plan_detail_view_model.dart';
import 'quit_plan_history_provider.dart';

// Service Provider
final quitPlanDetailServiceProvider = Provider<QuitPlanDetailService>((ref) {
  final dio = ref.watch(dioProvider);
  return QuitPlanDetailService(dio: dio);
});

// Repository Provider
final quitPlanDetailRepositoryProvider = Provider<QuitPlanDetailRepository>((ref) {
  final service = ref.watch(quitPlanDetailServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return QuitPlanDetailRepository(
    service: service,
    tokenStorage: tokenStorage,
  );
});

// ViewModel Provider
final quitPlanDetailViewModelProvider =
    StateNotifierProvider<QuitPlanDetailViewModel, AsyncValue<QuitPlanDetail?>>((ref) {
  final repository = ref.watch(quitPlanDetailRepositoryProvider);
  return QuitPlanDetailViewModel(repository: repository);
});
