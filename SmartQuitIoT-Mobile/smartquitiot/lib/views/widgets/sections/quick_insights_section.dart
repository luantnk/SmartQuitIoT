import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/lists/insight_item.dart';

class QuickInsightsSection extends StatelessWidget {
  final List<String> insights;
  final String title;
  final IconData icon;
  final Color color;

  const QuickInsightsSection({
    super.key,
    required this.insights,
    this.title = 'Quick Insights',
    this.icon = Icons.insights,
    this.color = const Color(0xFF2196F3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InsightItem(text: insight),
            ),
          ),
        ],
      ),
    );
  }
}
