import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/quit_plan_homepage_state.dart';
import '../repositories/quit_plan_homepage_repository.dart';

class QuitPlanHomepageViewModel extends StateNotifier<QuitPlanHomepageState> {
  final QuitPlanHomepageRepository _quitPlanHomepageRepository;

  QuitPlanHomepageViewModel(this._quitPlanHomepageRepository)
    : super(const QuitPlanHomepageState());

  /// Load quit plan home page data
  Future<void> loadQuitPlanHomePage() async {
    print('🔄 [QuitPlanHomepageViewModel] Starting to load quit plan...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📞 [QuitPlanHomepageViewModel] Calling repository...');
      final quitPlan = await _quitPlanHomepageRepository.getQuitPlanHomePage();

      print('✅ [QuitPlanHomepageViewModel] Quit plan received from repository');
      print('📋 [QuitPlanHomepageViewModel] Plan details:');
      print('   - ID: ${quitPlan.id}');
      print('   - Name: ${quitPlan.name}');
      print('   - Total Missions: ${quitPlan.totalMissions}');
      print('   - Completed Missions: ${quitPlan.completedMissions}');
      print('   - Progress: ${quitPlan.progress}%');
      print('   - Current Phase: ${quitPlan.currentPhaseDetail.name}');
      print('   - Day Index: ${quitPlan.currentPhaseDetail.dayIndex}');

      state = state.copyWith(quitPlan: quitPlan, isLoading: false, error: null);

      print('✅ [QuitPlanHomepageViewModel] State updated successfully');
      print('📊 [QuitPlanHomepageViewModel] hasQuitPlan: ${state.hasQuitPlan}');
    } catch (e, st) {
      final errorString = e.toString();
      print(
        '🔥 [QuitPlanHomepageViewModel] Load quit plan error: $errorString',
      );
      print('🧩 [QuitPlanHomepageViewModel] Stack trace: $st');

      // Handle 400 as empty state for new users without quit plan
      if (errorString.contains('status: 400') ||
          errorString.contains('Bad request (400)') ||
          errorString.contains('not found')) {
        print(
          'ℹ️ [QuitPlanHomepageViewModel] Detected 400 error - treating as empty state',
        );
        print(
          '💡 [QuitPlanHomepageViewModel] This likely means user has no quit plan yet',
        );
        state = state.copyWith(
          quitPlan: null,
          isLoading: false,
          error: null, // No error, just empty
        );
        print('✅ [QuitPlanHomepageViewModel] State set to empty (no error)');
      } else {
        // Real errors (network, server, etc.)
        print(
          '❌ [QuitPlanHomepageViewModel] Real error detected, showing error state',
        );
        state = state.copyWith(isLoading: false, error: errorString);
      }
    }
  }

  /// Refresh quit plan data
  Future<void> refreshQuitPlan() async {
    await loadQuitPlanHomePage();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear/reset quit plan data (call when user logs out)
  void clear() {
    print('🧹 [QuitPlanHomepageViewModel] Clearing quit plan data');
    state = const QuitPlanHomepageState();
  }
}

// Riverpod providers
final quitPlanHomepageRepositoryProvider = Provider<QuitPlanHomepageRepository>(
  (ref) {
    return QuitPlanHomepageRepository();
  },
);

final quitPlanHomepageViewModelProvider =
    StateNotifierProvider<QuitPlanHomepageViewModel, QuitPlanHomepageState>((
      ref,
    ) {
      final repository = ref.watch(quitPlanHomepageRepositoryProvider);
      return QuitPlanHomepageViewModel(repository);
    });
