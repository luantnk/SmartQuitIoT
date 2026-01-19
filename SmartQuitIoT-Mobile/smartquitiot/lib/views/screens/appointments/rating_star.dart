// lib/features/coaching/widgets/rating_stars.dart
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 48,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: color,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}