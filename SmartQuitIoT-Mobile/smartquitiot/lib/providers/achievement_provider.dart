import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/achievement.dart';
import 'package:SmartQuitIoT/repositories/achievement_repository.dart';
import 'package:SmartQuitIoT/services/achievement_service.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';

// Service Provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService(ref.read(authRepositoryProvider));
});

// Repository Provider
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository(
    ref.read(achievementServiceProvider),
  );
});

// All Achievements Provider
final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repository = ref.read(achievementRepositoryProvider);
  return await repository.getAllMyAchievements();
});

// Home Achievements Provider (random 4 achievements for home screen)
final homeAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final repository = ref.read(achievementRepositoryProvider);
  return await repository.getHomeAchievements();
});

// Completed Achievements Provider
final completedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final asyncAchievements = ref.watch(allAchievementsProvider);
  
  return asyncAchievements.when(
    data: (achievements) => achievements.where((a) => a.unlocked).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// In Progress Achievements Provider
final inProgressAchievementsProvider = Provider<List<Achievement>>((ref) {
  final asyncAchievements = ref.watch(allAchievementsProvider);
  
  return asyncAchievements.when(
    data: (achievements) => achievements.where((a) => !a.unlocked).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Achievements by Type Provider
final achievementsByTypeProvider = Provider.family<List<Achievement>, String>((ref, type) {
  final asyncAchievements = ref.watch(allAchievementsProvider);
  
  return asyncAchievements.when(
    data: (achievements) => achievements.where((a) => a.type == type).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
