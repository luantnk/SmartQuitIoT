import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final int daysQuit;
  final int cigarettesAvoided;
  final String moneySaved;

  const StatsRow({
    super.key,
    required this.daysQuit,
    required this.cigarettesAvoided,
    required this.moneySaved,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;

    Widget stat(IconData icon, String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: s.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );

    return Row(
      children: [
        stat(Icons.calendar_today, 'days quit', '$daysQuit'),
        const SizedBox(width: 12),
        stat(Icons.smoke_free, 'avoided', '$cigarettesAvoided'),
        const SizedBox(width: 12),
        stat(Icons.attach_money, 'saved', moneySaved),
      ],
    );
  }
}
