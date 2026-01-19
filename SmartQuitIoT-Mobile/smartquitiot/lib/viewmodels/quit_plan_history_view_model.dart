import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/quit_plan_history.dart';
import '../repositories/quit_plan_history_repository.dart';

class QuitPlanHistoryViewModel extends StateNotifier<AsyncValue<List<QuitPlanHistory>>> {
  final QuitPlanHistoryRepository _repository;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  QuitPlanHistoryViewModel({required QuitPlanHistoryRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    _logger.d('📜 [QuitPlanHistoryViewModel] Initialized');
  }

  /// Load all quit plans
  Future<void> loadAllQuitPlans() async {
    try {
      _logger.i('📜 [QuitPlanHistoryViewModel] Loading all quit plans...');
      state = const AsyncValue.loading();

      final quitPlans = await _repository.getAllQuitPlans();

      _logger.i('✅ [QuitPlanHistoryViewModel] Loaded ${quitPlans.length} quit plans');
      state = AsyncValue.data(quitPlans);
    } catch (e, stackTrace) {
      _logger.e('❌ [QuitPlanHistoryViewModel] Error loading quit plans: $e');
      _logger.e('📊 [QuitPlanHistoryViewModel] Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh quit plans
  Future<void> refresh() async {
    _logger.d('🔄 [QuitPlanHistoryViewModel] Refreshing quit plans...');
    await loadAllQuitPlans();
  }

  /// Clear all quit plans data (used when user logs out or switches)
  void clear() {
    _logger.i('🗑️ [QuitPlanHistoryViewModel] Clearing quit plan history data...');
    state = const AsyncValue.loading();
    _logger.d('✅ [QuitPlanHistoryViewModel] Quit plan history cleared');
  }

  /// Filter quit plans by status
  List<QuitPlanHistory> filterByStatus(String status) {
    return state.whenData((quitPlans) {
      return quitPlans.where((plan) => plan.status == status).toList();
    }).value ?? [];
  }

  /// Get active quit plan
  QuitPlanHistory? getActiveQuitPlan() {
    return state.whenData((quitPlans) {
      try {
        return quitPlans.firstWhere((plan) => plan.active);
      } catch (e) {
        _logger.w('⚠️ [QuitPlanHistoryViewModel] No active quit plan found');
        return null;
      }
    }).value;
  }

  /// Get quit plans statistics
  Map<String, int> getStatistics() {
    return state.whenData((quitPlans) {
      final inProgress = quitPlans.where((p) => p.isInProgress).length;
      final completed = quitPlans.where((p) => p.isCompleted).length;
      final canceled = quitPlans.where((p) => p.isCanceled).length;

      return {
        'total': quitPlans.length,
        'inProgress': inProgress,
        'completed': completed,
        'canceled': canceled,
      };
    }).value ?? {
      'total': 0,
      'inProgress': 0,
      'completed': 0,
      'canceled': 0,
    };
  }
}
