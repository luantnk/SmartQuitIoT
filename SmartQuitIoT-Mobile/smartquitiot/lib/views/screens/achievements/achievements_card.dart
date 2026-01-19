import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/achievement_provider.dart';
import 'package:SmartQuitIoT/providers/websocket_provider.dart';
import 'package:SmartQuitIoT/providers/achievement_refresh_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class AchievementsCard extends ConsumerWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(homeAchievementsProvider);

    // Listen for achievement refresh triggers
    ref.listen(achievementRefreshProvider, (previous, next) {
      if (previous != next) {
        print(
          '🔄 [AchievementsCard] Refresh triggered, invalidating home achievements provider...',
        );
        ref.invalidate(homeAchievementsProvider);
      }
    });

    // Keep the old listener for backward compatibility
    ref.listen(achievementNotificationsProvider, (previous, next) {
      if (previous != next && next.isNotEmpty) {
        // Refresh achievements when new achievement is earned
        ref.invalidate(homeAchievementsProvider);
      }
    });
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'achievements'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go('/achievements');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'View more',
                        style: TextStyle(
                          color: Color(0xFF00D09E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF00D09E),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Achievements content
          achievementsAsync.when(
            data: (achievements) {
              if (achievements.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No achievements yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Display achievements in 2x2 grid
              return Column(
                children: [
                  // Row 1
                  Row(
                    children: [
                      if (achievements.length > 0)
                        Expanded(
                          child: _buildAchievementBadgeFromData(
                            achievement: achievements[0],
                          ),
                        ),
                      if (achievements.length > 1) ...[
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildAchievementBadgeFromData(
                            achievement: achievements[1],
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Row 2
                  if (achievements.length > 2) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAchievementBadgeFromData(
                            achievement: achievements[2],
                          ),
                        ),
                        if (achievements.length > 3) ...[
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildAchievementBadgeFromData(
                              achievement: achievements[3],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                ),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Failed to load achievements',
                  style: TextStyle(color: Colors.red[300]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadgeFromData({required achievement}) {
    final bool isUnlocked = achievement.unlocked;
    final Color color = _getAchievementTypeColor(achievement.type);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? color.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? color.withOpacity(0.4)
              : Colors.grey.withOpacity(0.3),
          width: isUnlocked ? 2 : 1.2,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Achievement Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  achievement.icon,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  color: isUnlocked ? null : Colors.grey,
                  colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.emoji_events,
                    color: isUnlocked ? color : Colors.grey,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isUnlocked
                      ? const Color(0xFF111827)
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 10,
                  color: isUnlocked ? Colors.grey[700] : Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Locked overlay
          if (!isUnlocked)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.lock, size: 20, color: Colors.grey[400]),
            ),
          // Unlocked badge
          if (isUnlocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Color _getAchievementTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SOCIAL':
        return Colors.blue;
      case 'PROGRESS':
        return Colors.purple;
      case 'STREAK':
        return Colors.orangeAccent;
      case 'HEALTH':
        return Colors.green;
      case 'MILESTONE':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
