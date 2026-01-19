import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final Widget icon; // nhận Widget (Lottie / Icon)
  final String title;
  final String value;

  const StatItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ⬅️ giúp không overflow
      children: [
        icon,
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D09E),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
