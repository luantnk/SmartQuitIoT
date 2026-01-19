import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/mission_complete_state.dart';
import '../repositories/mission_complete_repository.dart';

class MissionCompleteViewModel extends StateNotifier<MissionCompleteState> {
  final MissionCompleteRepository _missionCompleteRepository;

  MissionCompleteViewModel(this._missionCompleteRepository) : super(const MissionCompleteState());

  /// Toggle trigger selection
  void toggleTrigger(String trigger) {
    final currentTriggers = List<String>.from(state.selectedTriggers);
    
    if (currentTriggers.contains(trigger)) {
      currentTriggers.remove(trigger);
    } else {
      currentTriggers.add(trigger);
    }
    
    state = state.copyWith(selectedTriggers: currentTriggers);
    print('🎯 [MissionCompleteViewModel] Selected triggers: $currentTriggers');
  }

  /// Clear selected triggers
  void clearTriggers() {
    state = state.copyWith(selectedTriggers: []);
  }

  /// Complete mission
  Future<bool> completeMission({
    required int phaseId,
    required int phaseDetailMissionId,
    bool requiresTriggers = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final triggers = requiresTriggers && state.selectedTriggers.isNotEmpty 
          ? state.selectedTriggers 
          : null;

      print('📡 [MissionCompleteViewModel] Completing mission: phaseId=$phaseId, missionId=$phaseDetailMissionId');
      print('🎯 [MissionCompleteViewModel] Using triggers: $triggers');

      final success = await _missionCompleteRepository.completeMission(
        phaseId: phaseId,
        phaseDetailMissionId: phaseDetailMissionId,
        triggers: triggers,
      );

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isCompleted: true,
          error: null,
        );
        print('✅ [MissionCompleteViewModel] Mission completed successfully');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to complete mission',
        );
      }

      return success;
    } catch (e, st) {
      print('🔥 [MissionCompleteViewModel] Error completing mission: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = const MissionCompleteState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod providers
final missionCompleteRepositoryProvider = Provider<MissionCompleteRepository>((ref) {
  return MissionCompleteRepository();
});

final missionCompleteViewModelProvider = StateNotifierProvider<MissionCompleteViewModel, MissionCompleteState>((ref) {
  final repository = ref.watch(missionCompleteRepositoryProvider);
  return MissionCompleteViewModel(repository);
});
