import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/quit_plan_history.dart';
import '../models/state/auth_state.dart';
import '../services/quit_plan_history_service.dart';
import '../services/token_storage_service.dart';
import '../repositories/quit_plan_history_repository.dart';
import '../viewmodels/quit_plan_history_view_model.dart';
import 'auth_provider.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// Service Provider
final quitPlanHistoryServiceProvider = Provider<QuitPlanHistoryService>((ref) {
  final dio = ref.watch(dioProvider);
  return QuitPlanHistoryService(dio: dio);
});

// Repository Provider
final quitPlanHistoryRepositoryProvider = Provider<QuitPlanHistoryRepository>((ref) {
  final service = ref.watch(quitPlanHistoryServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return QuitPlanHistoryRepository(
    service: service,
    tokenStorage: tokenStorage,
  );
});

// ViewModel Provider
final quitPlanHistoryViewModelProvider =
    StateNotifierProvider<QuitPlanHistoryViewModel, AsyncValue<List<QuitPlanHistory>>>((ref) {
  final repository = ref.watch(quitPlanHistoryRepositoryProvider);
  final viewModel = QuitPlanHistoryViewModel(repository: repository);
  
  // Listen to auth state changes to clear data when user logs out or switches
  ref.listen<AuthState>(authViewModelProvider, (previous, next) {
    if (previous != null) {
      final wasAuthenticated = previous.isAuthenticated;
      final isAuthenticated = next.isAuthenticated;
      final previousUsername = previous.username;
      final currentUsername = next.username;

      // Case 1: User logged out (from authenticated to not authenticated)
      if (wasAuthenticated && !isAuthenticated) {
        print('🔒 [QuitPlanHistoryProvider] User logged out - clearing quit plan history...');
        viewModel.clear();
      }
      // Case 2: User switched (username changed while authenticated)
      else if (isAuthenticated &&
          previousUsername != null &&
          currentUsername != null &&
          previousUsername != currentUsername) {
        print('🔄 [QuitPlanHistoryProvider] User switched from $previousUsername to $currentUsername - clearing quit plan history...');
        viewModel.clear();
        // Load new user's data after clearing
        Future.microtask(() => viewModel.loadAllQuitPlans());
      }
    }
  });
  
  // Auto-load data when provider is first created (only if authenticated)
  final authState = ref.read(authViewModelProvider);
  if (authState.isAuthenticated) {
    Future.microtask(() => viewModel.loadAllQuitPlans());
  } else {
    // If not authenticated, set to loading state (will show empty state)
    Future.microtask(() => viewModel.clear());
  }
  
  return viewModel;
});
