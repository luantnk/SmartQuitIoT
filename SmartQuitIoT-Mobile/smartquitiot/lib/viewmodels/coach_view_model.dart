import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach.dart';
import '../repositories/coach_repository.dart';

class CoachViewModel extends StateNotifier<AsyncValue<List<Coach>>> {
  final CoachRepository _repository;

  CoachViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadCoaches();
  }

  Future<void> loadCoaches() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getCoaches();
      state = AsyncValue.data(response.data); // lấy list Coach từ response
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => loadCoaches();
}
