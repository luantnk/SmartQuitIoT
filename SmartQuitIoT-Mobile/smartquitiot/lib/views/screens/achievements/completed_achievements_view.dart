import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/cards/completed_achievement_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/achievement_provider.dart';
import 'package:SmartQuitIoT/providers/achievement_refresh_provider.dart';

class CompletedAchievementsView extends ConsumerWidget {
  const CompletedAchievementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for achievement refresh triggers
    ref.listen(achievementRefreshProvider, (previous, next) {
      if (previous != next) {
        print('🔄 [CompletedAchievementsView] Refresh triggered, invalidating achievements provider...');
        ref.invalidate(allAchievementsProvider);
      }
    });

    final achievementsAsync = ref.watch(allAchievementsProvider);

    return achievementsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00D09E),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(allAchievementsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      data: (achievements) {
        final completedAchievements = achievements.where((a) => a.unlocked).toList();

        if (completedAchievements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed achievements yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep going! Complete challenges to unlock achievements',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedAchievements.length,
          itemBuilder: (context, index) {
            final achievement = completedAchievements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CompletedAchievementCard(achievement: achievement),
            );
          },
        );
      },
    );
  }
}
