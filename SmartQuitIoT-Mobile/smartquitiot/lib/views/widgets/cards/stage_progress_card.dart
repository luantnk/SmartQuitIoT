import 'package:flutter/material.dart';

class StageProgressCard extends StatelessWidget {
  final String stageName;
  final String dateRange;
  final double progress;
  final double target;
  final Color color;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  const StageProgressCard({
    super.key,
    required this.stageName,
    required this.dateRange,
    required this.progress,
    required this.target,
    required this.color,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? color
                : isCompleted
                ? const Color(0xFF00D09E)
                : Colors.grey.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF00D09E)
                        : isActive
                        ? color
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stageName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? color
                          : isCompleted
                          ? const Color(0xFF00D09E)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00D09E),
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateRange,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: isCompleted ? const Color(0xFF00D09E) : color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? const Color(0xFF00D09E) : color,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target: ${(target * 100).toInt()}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (progress >= target)
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFF00D09E),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Target Achieved!',
                    style: const TextStyle(
                      color: Color(0xFF00D09E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
