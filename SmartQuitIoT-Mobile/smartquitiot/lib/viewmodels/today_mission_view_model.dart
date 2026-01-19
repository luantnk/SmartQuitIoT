import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/today_mission_state.dart';
import '../repositories/today_mission_repository.dart';

class TodayMissionViewModel extends StateNotifier<TodayMissionState> {
  final TodayMissionRepository _todayMissionRepository;

  TodayMissionViewModel(this._todayMissionRepository) : super(const TodayMissionState());

  /// Load today's missions (only incompleted ones)
  Future<void> loadTodayMissions() async {
    print('🔄 [TodayMissionViewModel] Starting to load today missions...');
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // First check if all missions are completed
      print('📞 [TodayMissionViewModel] Checking if all missions completed...');
      final allCompleted = await _todayMissionRepository.areAllMissionsCompleted();
      print('📊 [TodayMissionViewModel] All completed: $allCompleted');
      
      if (allCompleted) {
        // If all completed, set empty missions list and flag
        state = state.copyWith(
          missions: [],
          isLoading: false,
          clearError: true,
          allMissionsCompleted: true,
        );
        print('✅ [TodayMissionViewModel] All missions completed - showing congratulations');
      } else {
        // Load incompleted missions
        print('📞 [TodayMissionViewModel] Loading incompleted missions...');
        final missions = await _todayMissionRepository.getTodayMissions();
        
        print('✅ [TodayMissionViewModel] Missions received: ${missions.length}');
        for (var i = 0; i < missions.length; i++) {
          print('   ${i + 1}. ${missions[i].name} - ${missions[i].description}');
        }
        
        state = state.copyWith(
          missions: missions,
          isLoading: false,
          clearError: true,
          allMissionsCompleted: false,
        );
        print('✅ [TodayMissionViewModel] State updated with ${missions.length} missions');
        print('📊 [TodayMissionViewModel] hasMissions: ${state.hasMissions}');
      }
    } catch (e, st) {
      final errorString = e.toString();
      print('🔥 [TodayMissionViewModel] Load missions error: $errorString');
      print('🧩 [TodayMissionViewModel] Stack trace: $st');
      
      // Handle 400 as empty state for new users without missions
      if (errorString.contains('status: 400') || errorString.contains('Bad request (400)') || errorString.contains('not found')) {
        print('ℹ️ [TodayMissionViewModel] Detected 400 error - treating as empty state');
        print('💡 [TodayMissionViewModel] This likely means user has no missions yet');
        state = state.copyWith(
          missions: [],
          isLoading: false,
          clearError: true, // Clear error for empty state
          allMissionsCompleted: false,
        );
        print('✅ [TodayMissionViewModel] State set to empty (no error)');
      } else {
        // Real errors (network, server, etc.)
        print('❌ [TodayMissionViewModel] Real error detected, showing error state');
        state = state.copyWith(
          isLoading: false,
          error: errorString,
          allMissionsCompleted: false,
        );
      }
    }
  }

  /// Refresh missions
  Future<void> refreshMissions() async {
    await loadTodayMissions();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Riverpod providers
final todayMissionRepositoryProvider = Provider<TodayMissionRepository>((ref) {
  return TodayMissionRepository();
});

final todayMissionViewModelProvider = StateNotifierProvider<TodayMissionViewModel, TodayMissionState>((ref) {
  final repository = ref.watch(todayMissionRepositoryProvider);
  return TodayMissionViewModel(repository);
});
