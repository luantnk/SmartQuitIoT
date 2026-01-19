// lib/features/coaching/widgets/rating_display.dart
import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviews;
  final double iconSize;
  final double fontSize;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.reviews,
    this.iconSize = 18,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviews đánh giá)',
          style: TextStyle(
            fontSize: fontSize - 2,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}