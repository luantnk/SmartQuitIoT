import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to notify when achievements need to be refreshed
class AchievementRefreshNotifier extends StateNotifier<int> {
  AchievementRefreshNotifier() : super(0);

  /// Trigger refresh for all achievements
  void refreshAchievements() {
    state = state + 1;
    print('🔄 [AchievementRefreshNotifier] Triggering achievements refresh: $state');
  }

  /// Trigger refresh when new achievement is unlocked
  void refreshOnAchievementUnlocked() {
    state = state + 1;
    print('🏆 [AchievementRefreshNotifier] Achievement unlocked, refreshing: $state');
  }

  /// Trigger refresh when achievement progress is updated
  void refreshOnProgressUpdate() {
    state = state + 1;
    print('📊 [AchievementRefreshNotifier] Achievement progress updated, refreshing: $state');
  }
}

final achievementRefreshProvider = StateNotifierProvider<AchievementRefreshNotifier, int>((ref) {
  return AchievementRefreshNotifier();
});
