import 'package:flutter/material.dart';

class HeroTimerCard extends StatelessWidget {
  final String userName;
  final String timerText;
  final IconData? icon;

  const HeroTimerCard({
    super.key,
    this.userName = 'Hello, User…',
    this.timerText = '1 h 30 m 20 s',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.access_time_filled, size: 64, color: s.onPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: s.onPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  timerText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: s.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
