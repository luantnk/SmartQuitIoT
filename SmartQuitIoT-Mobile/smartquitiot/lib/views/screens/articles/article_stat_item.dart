import 'package:flutter/material.dart';

class ArticleStatItem extends StatelessWidget {
  final IconData icon;
  final String count;
  final Color color;

  const ArticleStatItem({
    super.key,
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
      ],
    );
  }
}
