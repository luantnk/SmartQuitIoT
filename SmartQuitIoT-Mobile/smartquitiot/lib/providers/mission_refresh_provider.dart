import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to notify when missions and quit plan need to be refreshed
class MissionRefreshNotifier extends StateNotifier<int> {
  MissionRefreshNotifier() : super(0);

  /// Trigger refresh for today missions
  void refreshTodayMissions() {
    state = state + 1;
    print('🔄 [MissionRefreshNotifier] Triggering today missions refresh: $state');
  }

  /// Trigger refresh for quit plan (when created/updated)
  void refreshQuitPlan() {
    state = state + 1;
    print('🔄 [MissionRefreshNotifier] Triggering quit plan refresh: $state');
  }

  /// Trigger refresh for all (missions + quit plan)
  void refreshAll() {
    state = state + 1;
    print('🔄 [MissionRefreshNotifier] Triggering all refresh (missions + quit plan): $state');
  }
}

final missionRefreshProvider = StateNotifierProvider<MissionRefreshNotifier, int>((ref) {
  return MissionRefreshNotifier();
});
