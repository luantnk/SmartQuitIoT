import 'package:SmartQuitIoT/views/screens/achievements/achievement_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievement_section.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/achievement_provider.dart';
import 'package:SmartQuitIoT/providers/achievement_refresh_provider.dart';

class AllAchievementsView extends ConsumerWidget {
  const AllAchievementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for achievement refresh triggers
    ref.listen(achievementRefreshProvider, (previous, next) {
      if (previous != next) {
        print('🔄 [AllAchievementsView] Refresh triggered, invalidating achievements provider...');
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
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
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
        final streakAchievements = achievements.where((a) => a.type == 'STREAK').toList();
        final activityAchievements = achievements.where((a) => a.type == 'ACTIVITY').toList();
        final financeAchievements = achievements.where((a) => a.type == 'FINANCE').toList();
        final socialAchievements = achievements.where((a) => a.type == 'SOCIAL').toList();
        final progressAchievements = achievements.where((a) => a.type == 'PROGRESS').toList();

        final totalAchievements = achievements.length;
        final completedCount = achievements.where((a) => a.unlocked).length;
        final progress = totalAchievements > 0 ? completedCount / totalAchievements : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AchievementProgressCard(
                title: 'Achievement Progress',
                subtitle: '$completedCount of $totalAchievements achievements completed',
                percent: progress,
                icon: SizedBox(
                  width: 56,
                  height: 56,
                  child: Lottie.asset('lib/assets/animations/event.json'),
                ),
              ),
              const SizedBox(height: 24),
              if (streakAchievements.isNotEmpty) ...[
                AchievementSection(
                  title: 'Streak Achievements',
                  achievements: streakAchievements,
                  sectionColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 24),
              ],
              if (activityAchievements.isNotEmpty) ...[
                AchievementSection(
                  title: 'Activity Achievements',
                  achievements: activityAchievements,
                  sectionColor: const Color(0xFFE91E63),
                ),
                const SizedBox(height: 24),
              ],
              if (financeAchievements.isNotEmpty) ...[
                AchievementSection(
                  title: 'Finance Achievements',
                  achievements: financeAchievements,
                  sectionColor: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 24),
              ],
              if (socialAchievements.isNotEmpty) ...[
                AchievementSection(
                  title: 'Social Achievements',
                  achievements: socialAchievements,
                  sectionColor: const Color(0xFFFF9800),
                ),
                const SizedBox(height: 24),
              ],
              if (progressAchievements.isNotEmpty) ...[
                AchievementSection(
                  title: 'Progress Achievements',
                  achievements: progressAchievements,
                  sectionColor: const Color(0xFF9C27B0),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
