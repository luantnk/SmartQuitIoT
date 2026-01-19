// components/improvement_card.dart
import 'package:flutter/material.dart';

class ImprovementCard extends StatelessWidget {
  final int score;
  final String title;
  final String description;
  final bool isGood;

  const ImprovementCard({
    super.key,
    required this.score,
    required this.title,
    required this.description,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    Color scoreColor = _getScoreColor();
    Color indicatorColor = _getIndicatorColor();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score indicator
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 16),

          // Score circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: scoreColor, width: 2),
            ),
            child: Center(
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Status icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: indicatorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isGood ? Icons.check : Icons.warning,
              color: indicatorColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    if (score >= 80) {
      return Color(0xFF00C853);
    } else if (score >= 50) {
      return Color(0xFFFF9800);
    } else {
      return Color(0xFFF44336);
    }
  }

  Color _getIndicatorColor() {
    if (score >= 80) {
      return Color(0xFF00C853);
    } else if (score >= 50) {
      return Color(0xFFFF9800);
    } else {
      return Color(0xFFF44336);
    }
  }
}