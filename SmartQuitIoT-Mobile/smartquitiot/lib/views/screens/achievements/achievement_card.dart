import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconUrl;
  final bool isCompleted;
  final double? progress;
  final Color categoryColor;
  final DateTime? completedAt;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isCompleted,
    this.progress,
    required this.categoryColor,
    this.completedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isCompleted
              ? Border.all(color: const Color(0xFF00D09E), width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF00D09E)
                    : categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D09E).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  iconUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events,
                      color: isCompleted ? Colors.white : categoryColor,
                      size: 32,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? const Color(0xFF00D09E)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  if (!isCompleted && progress != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress!,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                categoryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(progress! * 100).toInt()}%',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isCompleted) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00D09E),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Completed',
                                style: TextStyle(
                                  color: Color(0xFF00D09E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (completedAt != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _formatCompletedDate(completedAt!),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D09E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 22),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCompletedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // If completed today
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Completed just now';
        }
        return 'Completed ${difference.inMinutes}m ago';
      }
      return 'Completed ${difference.inHours}h ago';
    }
    
    // If completed yesterday
    if (difference.inDays == 1) {
      return 'Completed yesterday';
    }
    
    // If completed within a week
    if (difference.inDays < 7) {
      return 'Completed ${difference.inDays} days ago';
    }
    
    // Otherwise show full date
    final formatter = DateFormat('MMM dd, yyyy');
    return 'Completed on ${formatter.format(date)}';
  }
}
