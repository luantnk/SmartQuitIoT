import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/quit_plan_time_repository.dart';

class QuitPlanTimeState {
  final DateTime? startTime;
  final bool isLoading;
  final String? error;

  QuitPlanTimeState({this.startTime, this.isLoading = false, this.error});

  QuitPlanTimeState copyWith({
    DateTime? startTime,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return QuitPlanTimeState(
      startTime: startTime ?? this.startTime,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class QuitPlanTimeViewModel extends StateNotifier<QuitPlanTimeState> {
  final QuitPlanTimeRepository _repository;

  QuitPlanTimeViewModel(this._repository) : super(QuitPlanTimeState());

  Future<void> loadStartTime() async {
    if (state.isLoading) return;

    // Always clear previous error when starting a new load
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final startTime = await _repository.getStartTime();
      state = state.copyWith(
        startTime: startTime,
        isLoading: false,
        clearError: true, // Explicitly clear error on success
      );
      print('✅ [QuitPlanTimeViewModel] Start time loaded: $startTime');
    } catch (e) {
      // Extract error message, handling both Exception and String
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      state = state.copyWith(isLoading: false, error: errorMessage);
      print('❌ [QuitPlanTimeViewModel] Error: $errorMessage');
    }
  }

  void refresh() {
    loadStartTime();
  }

  /// Reset state to initial state (used on logout)
  void reset() {
    print('🔄 [QuitPlanTimeViewModel] Resetting state...');
    state = QuitPlanTimeState(startTime: null, isLoading: false, error: null);
    print('✅ [QuitPlanTimeViewModel] State reset complete');
  }
}
