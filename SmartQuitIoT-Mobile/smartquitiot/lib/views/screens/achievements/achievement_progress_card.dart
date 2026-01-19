import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // add in pubspec.yaml

class AchievementProgressCard extends StatelessWidget {
  final String title;          // e.g. "Achievements"
  final String subtitle;       // e.g. "5 of 17 Achievements"
  final double percent;        // 0.0 - 1.0
  final Widget icon;

  const AchievementProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00B48A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon bên trái
          SizedBox(width: 56, height: 56, child: icon),
          const SizedBox(width: 12),

          // Title + subtitle ở giữa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold, // bold phần subtitle
                  ),
                ),
              ],
            ),
          ),

          // Vòng tròn progress bên phải
          CircularPercentIndicator(
            radius: 28,
            lineWidth: 6,
            percent: percent,
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
            center: Text(
              "${(percent * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
