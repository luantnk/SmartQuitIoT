import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const QuestionCard({
    super.key,
    required this.question,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // background trắng
        borderRadius: BorderRadius.circular(16), // bo nhẹ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // shadow mờ nhẹ
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}