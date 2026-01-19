import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String icon; // path asset icon
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Image.asset(icon, width: 32, height: 32, fit: BoxFit.contain),
        const SizedBox(height: 8),

        // Title
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Value
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D09E),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
