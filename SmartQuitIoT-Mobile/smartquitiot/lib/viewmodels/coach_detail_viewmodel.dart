import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach_detail.dart';
import '../models/slot_available.dart';
import '../repositories/coach_detail_repository.dart';

class CoachDetailState {
  final bool isLoading;
  final CoachDetail? coach;
  final List<SlotAvailable>? slots;
  final String? error;

  const CoachDetailState({
    this.isLoading = false,
    this.coach,
    this.slots,
    this.error,
  });

  CoachDetailState copyWith({
    bool? isLoading,
    CoachDetail? coach,
    List<SlotAvailable>? slots,
    String? error,
  }) {
    return CoachDetailState(
      isLoading: isLoading ?? this.isLoading,
      coach: coach ?? this.coach,
      slots: slots ?? this.slots,
      error: error,
    );
  }
}

class CoachDetailViewModel extends StateNotifier<CoachDetailState> {
  final CoachDetailRepository _repository;

  CoachDetailViewModel(this._repository) : super(const CoachDetailState());

  Future<void> loadCoachDetail(int coachId, String date) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final coach = await _repository.getCoachDetail(coachId);
      final slots = await _repository.getAvailableSlots(coachId, date);

      state = state.copyWith(isLoading: false, coach: coach, slots: slots);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
