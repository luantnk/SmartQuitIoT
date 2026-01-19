import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../services/achievement_service.dart';
import '../repositories/leaderboard_repository.dart';
import '../viewmodels/leaderboard_view_model.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Achievement Service Provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AchievementService(authRepository);
});

/// Leaderboard Repository Provider
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final achievementService = ref.read(achievementServiceProvider);
  return LeaderboardRepository(achievementService);
});

/// Leaderboard ViewModel Provider
final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>((ref) {
  final repository = ref.read(leaderboardRepositoryProvider);
  return LeaderboardViewModel(repository);
});
