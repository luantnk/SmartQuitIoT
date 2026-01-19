import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach.dart';
import '../repositories/coach_repository.dart';

class CoachListNotifier extends StateNotifier<AsyncValue<List<Coach>>> {
  final CoachRepository _repository;

  CoachListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCoaches();
  }

  Future<void> loadCoaches() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getCoaches();
      if (response.success) {
        state = AsyncValue.data(response.data);
      } else {
        state = AsyncValue.error(
          Exception(response.message),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async => loadCoaches();
}
