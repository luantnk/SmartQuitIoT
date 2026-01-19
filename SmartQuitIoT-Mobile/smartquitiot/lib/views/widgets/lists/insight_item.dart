import 'package:flutter/material.dart';

class InsightItem extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const InsightItem({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconClr = iconColor ?? const Color(0xFF2196F3);
    final bgClr = backgroundColor ?? iconClr.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: bgClr, shape: BoxShape.circle),
            child: Icon(icon ?? Icons.check, size: 14, color: iconClr),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
