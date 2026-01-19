import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/cards/stat_card.dart';

class TodayStatsSection extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const TodayStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // First row of stats
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: stats
              .take(2)
              .map(
                (stat) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: StatCard(
                      title: stat['title'],
                      value: stat['value'],
                      subtitle: stat['subtitle'],
                      icon: stat['icon'],
                      color: stat['color'],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        // Second row of stats
        if (stats.length > 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: stats
                .skip(2)
                .take(2)
                .map(
                  (stat) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: StatCard(
                        title: stat['title'],
                        value: stat['value'],
                        subtitle: stat['subtitle'],
                        icon: stat['icon'],
                        color: stat['color'],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
