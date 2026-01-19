import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievement_card.dart';
import 'package:SmartQuitIoT/models/achievement.dart';

class AchievementSection extends StatelessWidget {
  final String title;
  final List<Achievement> achievements;
  final Color sectionColor;

  const AchievementSection({
    super.key,
    required this.title,
    required this.achievements,
    required this.sectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...achievements.map(
          (achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AchievementCard(
              title: achievement.name,
              description: achievement.description,
              iconUrl: achievement.icon,
              isCompleted: achievement.unlocked,
              progress: null, // API doesn't provide progress yet
              categoryColor: sectionColor,
              completedAt: achievement.completedAt,
            ),
          ),
        ),
      ],
    );
  }
}
