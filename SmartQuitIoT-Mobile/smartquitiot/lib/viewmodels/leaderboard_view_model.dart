import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_member.dart';
import '../repositories/leaderboard_repository.dart';

/// Leaderboard state
class LeaderboardState {
  final List<LeaderboardMember> members;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<LeaderboardMember>? members,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Leaderboard ViewModel
class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final LeaderboardRepository _repository;

  LeaderboardViewModel(this._repository) : super(const LeaderboardState());

  /// Load top leaderboards
  Future<void> loadTopLeaderBoards() async {
    try {
      print('🏆 [LeaderboardViewModel] Loading top leaderboards...');
      
      state = state.copyWith(isLoading: true, error: null);

      final leaderboard = await _repository.getTopLeaderBoards();

      print('✅ [LeaderboardViewModel] Loaded ${leaderboard.length} members');

      state = state.copyWith(
        members: leaderboard,
        isLoading: false,
      );
    } catch (e) {
      print('❌ [LeaderboardViewModel] Error loading leaderboards: $e');
      
      state = state.copyWith(
        error: 'Failed to load leaderboard: $e',
        isLoading: false,
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
