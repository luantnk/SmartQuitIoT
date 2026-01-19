import 'package:flutter/material.dart';
import '../../../../models/quit_phase.dart';
import '../../../../utils/phase_theme.dart';

class PhaseSelectorBar extends StatelessWidget {
  final List<QuitPhaseDetail> phases;
  final int selectedIndex;
  final Function(int) onPhaseSelected;
  final String planName;

  const PhaseSelectorBar({
    super.key,
    required this.phases,
    required this.selectedIndex,
    required this.onPhaseSelected,
    required this.planName,
  });

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    final normalized = status.replaceAll('_', ' ').toLowerCase();
    return normalized
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  bool _isFailedStatus(String? status) =>
      status != null && status.toUpperCase() == 'FAILED';

  @override
  Widget build(BuildContext context) {
    if (phases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: phases.length,
        itemBuilder: (context, index) {
          final phase = phases[index];
          final phaseName = (phase.name ?? '').trim();
          final fallbackName = planName.trim();
          final themeKey = phaseName.isNotEmpty
              ? phaseName
              : (fallbackName.isNotEmpty ? fallbackName : 'Quit Plan');
          final phaseTheme = resolvePhaseTheme(themeKey);
          final isSelected = selectedIndex == index;
          final isFailed = _isFailedStatus(phase.status);

          // Calculate progress
          final totalMissions = phase.totalMissions ?? 0;
          final completedMissions = phase.completedMissions ?? 0;
          final phaseProgress = (totalMissions > 0)
              ? (completedMissions / totalMissions)
              : 0.0;
          final phasePercent = (phaseProgress * 100).toInt();

          return GestureDetector(
            onTap: () => onPhaseSelected(index),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? phaseTheme.primaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? phaseTheme.primaryColor
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: phaseTheme.primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: phaseTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          phaseTheme.icon,
                          color: phaseTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phase.name ?? 'Phase',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? phaseTheme.primaryColor
                                : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDate(phase.startDate)} → ${_formatDate(phase.endDate)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isFailed
                              ? Colors.redAccent.withOpacity(0.15)
                              : phaseTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatStatus(phase.status),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isFailed
                                ? Colors.redAccent
                                : phaseTheme.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$phasePercent%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: phaseTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

