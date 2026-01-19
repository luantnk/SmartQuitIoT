import 'package:flutter/material.dart';

class MoodSliderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final ValueChanged<double>? onChanged;
  final IconData icon;
  final Color color;

  const MoodSliderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('1', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Expanded(
              child: Slider(
                value: value,
                min: 1.0,
                max: 10.0,
                divisions: 90,
                activeColor: color,
                inactiveColor: color.withOpacity(0.2),
                thumbColor: color,
                onChanged: onChanged,
              ),
            ),
            Text('10', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
