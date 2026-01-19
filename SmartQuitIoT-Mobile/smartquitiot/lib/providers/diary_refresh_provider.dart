import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to trigger diary history refresh after creating/updating diary
/// Uses counter to notify listeners when diary data changes
final diaryRefreshProvider = StateNotifierProvider<DiaryRefreshNotifier, int>((ref) {
  return DiaryRefreshNotifier();
});

class DiaryRefreshNotifier extends StateNotifier<int> {
  DiaryRefreshNotifier() : super(0);

  /// Trigger refresh for diary history
  void refreshDiaryHistory() {
    print('🔄 [DiaryRefresh] Triggering diary history refresh...');
    state = state + 1;
  }
}
