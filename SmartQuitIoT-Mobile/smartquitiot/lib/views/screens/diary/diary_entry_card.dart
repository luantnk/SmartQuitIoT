import 'package:flutter/material.dart';

class DiaryEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback? onTap;

  const DiaryEntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasSmoked = entry['hasSmoked'] as bool;
    final streak = entry['streak'] as int;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: hasSmoked
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
              : Border.all(
                  color: const Color(0xFF00D09E).withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry['date'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasSmoked
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF00D09E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasSmoked ? 'Smoked' : 'Clean',
                    style: TextStyle(
                      color: hasSmoked ? Colors.red : const Color(0xFF00D09E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasSmoked) ...[_buildSmokedInfo()] else ...[_buildCleanInfo()],
            const SizedBox(height: 12),
            _buildStatsRow(),
            if (entry['notes'] != null && entry['notes'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry['notes'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmokedInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.smoke_free, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            'Cigarettes: ${entry['cigarettes']}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration, color: Color(0xFF00D09E), size: 20),
          const SizedBox(width: 8),
          Text(
            'Streak: ${entry['streak']} days',
            style: const TextStyle(
              color: Color(0xFF00D09E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(
          'Cravings',
          '${entry['cravings']}',
          Icons.psychology,
          Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          'Mood',
          '${entry['mood']}',
          Icons.sentiment_satisfied,
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          'Confidence',
          '${entry['confidence']}',
          Icons.psychology_alt,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          'Anxiety',
          '${entry['anxiety']}',
          Icons.psychology,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }
}
