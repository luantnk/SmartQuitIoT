import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mission_complete_request.dart';
import '../../viewmodels/mission_complete_view_model.dart';

class TriggerSelectionWidget extends ConsumerWidget {
  final String missionName;
  final VoidCallback? onSelectionChanged;

  const TriggerSelectionWidget({
    super.key,
    required this.missionName,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionCompleteViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Smoking Triggers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the situations that trigger your smoking habit:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MissionTriggers.availableTriggers.map((trigger) {
            final isSelected = state.selectedTriggers.contains(trigger);
            
            return GestureDetector(
              onTap: () {
                ref.read(missionCompleteViewModelProvider.notifier).toggleTrigger(trigger);
                onSelectionChanged?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00D09E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00D09E) : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF00D09E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                    ] else ...[
                      Icon(
                        _getTriggerIcon(trigger),
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      trigger,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (state.selectedTriggers.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00D09E).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00D09E),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${state.selectedTriggers.length} trigger(s) selected',
                    style: const TextStyle(
                      color: Color(0xFF00D09E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (state.selectedTriggers.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      ref.read(missionCompleteViewModelProvider.notifier).clearTriggers();
                      onSelectionChanged?.call();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Color(0xFF00D09E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getTriggerIcon(String trigger) {
    switch (trigger.toLowerCase()) {
      case 'morning':
        return Icons.wb_sunny;
      case 'after meal':
        return Icons.restaurant;
      case 'gaming':
        return Icons.sports_esports;
      case 'party':
        return Icons.celebration;
      case 'coffee':
        return Icons.local_cafe;
      case 'stress':
        return Icons.psychology;
      case 'boredom':
        return Icons.sentiment_neutral;
      case 'driving':
        return Icons.directions_car;
      case 'sadness':
        return Icons.sentiment_dissatisfied;
      case 'work':
        return Icons.work;
      default:
        return Icons.circle;
    }
  }
}
