import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quit_plan_time_service.dart';
import '../repositories/quit_plan_time_repository.dart';
import '../viewmodels/quit_plan_time_view_model.dart';
import 'auth_provider.dart';

// Service Provider
final quitPlanTimeServiceProvider = Provider<QuitPlanTimeService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return QuitPlanTimeService(authRepository);
});

// Repository Provider
final quitPlanTimeRepositoryProvider = Provider<QuitPlanTimeRepository>((ref) {
  final service = ref.watch(quitPlanTimeServiceProvider);
  return QuitPlanTimeRepository(service);
});

// ViewModel Provider
final quitPlanTimeViewModelProvider = 
    StateNotifierProvider<QuitPlanTimeViewModel, QuitPlanTimeState>((ref) {
  final repository = ref.watch(quitPlanTimeRepositoryProvider);
  return QuitPlanTimeViewModel(repository);
});
