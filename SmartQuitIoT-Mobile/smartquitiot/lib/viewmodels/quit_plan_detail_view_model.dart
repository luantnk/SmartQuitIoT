import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/quit_plan_detail.dart';
import '../repositories/quit_plan_detail_repository.dart';

class QuitPlanDetailViewModel extends StateNotifier<AsyncValue<QuitPlanDetail?>> {
  final QuitPlanDetailRepository _repository;
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

  QuitPlanDetailViewModel({required QuitPlanDetailRepository repository})
      : _repository = repository,
        super(const AsyncValue.data(null)) {
    _logger.d('📋 [QuitPlanDetailViewModel] Initialized');
  }

  /// Load quit plan detail by ID
  Future<void> loadQuitPlanDetail(int quitPlanId) async {
    try {
      _logger.i('📋 [QuitPlanDetailViewModel] Loading quit plan detail for ID: $quitPlanId');
      state = const AsyncValue.loading();

      final quitPlan = await _repository.getQuitPlanDetail(quitPlanId);

      _logger.i('✅ [QuitPlanDetailViewModel] Loaded quit plan: ${quitPlan.name}');
      state = AsyncValue.data(quitPlan);
    } catch (e, stackTrace) {
      _logger.e('❌ [QuitPlanDetailViewModel] Error loading quit plan: $e');
      _logger.e('📊 [QuitPlanDetailViewModel] Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh quit plan detail
  Future<void> refresh(int quitPlanId) async {
    _logger.d('🔄 [QuitPlanDetailViewModel] Refreshing quit plan detail...');
    await loadQuitPlanDetail(quitPlanId);
  }

  /// Clear current quit plan
  void clear() {
    _logger.d('🗑️ [QuitPlanDetailViewModel] Clearing quit plan detail');
    state = const AsyncValue.data(null);
  }
}
