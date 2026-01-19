import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/coach_repository.dart';
import '../models/coach.dart';

// Repository provider
final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository();
});

// Coach list state provider for manual refresh (keep this as-is, but add helper methods)
final coachListStateProvider =
StateNotifierProvider<CoachListNotifier, AsyncValue<List<Coach>>>((ref) {
  return CoachListNotifier(ref.read(coachRepositoryProvider));
});

class CoachListNotifier extends StateNotifier<AsyncValue<List<Coach>>> {
  final CoachRepository _repository;

  CoachListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCoaches(); // initial
  }

  Future<void> loadCoaches({bool force = false}) async {
    try {
      // debug print
      // ignore: avoid_print
      print('[CoachListNotifier] loadCoaches force=$force');

      state = const AsyncValue.loading();
      final response = await _repository.getCoaches(force: force);

      if (response.success) {
        // ensure we have List<Coach> (response.data might be List<Map> or List<Coach>)
        final List<dynamic> rawList = response.data ?? [];
        final List<Coach> coaches = rawList.map<Coach>((e) {
          if (e is Coach) return e;
          try {
            return Coach.fromJson(e as Map<String, dynamic>);
          } catch (_) {
            // fallback: try to construct minimally
            return Coach.fromJson(Map<String, dynamic>.from(e as Map));
          }
        }).toList();
        state = AsyncValue.data(coaches);
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

  Future<void> refresh() async => loadCoaches(force: true);

  /// For future realtime: add or update a single coach into current list (avoid duplicates)
  void addOrUpdateCoach(Coach c) {
    state = state.whenData((list) {
      final idx = list.indexWhere((e) => e.id == c.id);
      if (idx >= 0) {
        final newList = [...list];
        newList[idx] = c;
        return newList;
      } else {
        return [...list, c];
      }
    });
  }
}

// --- NEW: coachesProvider wrapper so existing UI (watching coachesProvider) keeps working ---
final coachesProvider = Provider<AsyncValue<List<Coach>>>((ref) {
  return ref.watch(coachListStateProvider);
});
