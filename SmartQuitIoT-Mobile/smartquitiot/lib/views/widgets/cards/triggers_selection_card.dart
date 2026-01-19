import 'package:flutter/material.dart';

class TriggersSelectionCard extends StatefulWidget {
  final List<String> selectedTriggers;
  final Function(List<String>) onChanged;

  const TriggersSelectionCard({
    super.key,
    required this.selectedTriggers,
    required this.onChanged,
  });

  @override
  State<TriggersSelectionCard> createState() => _TriggersSelectionCardState();
}

class _TriggersSelectionCardState extends State<TriggersSelectionCard> {
  final List<String> _availableTriggers = [
    'Stress',
    'Work pressure',
    'Social situations',
    'Alcohol',
    'Coffee',
    'Boredom',
    'Anger',
    'Sadness',
    'Celebration',
    'After meals',
    'While driving',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  color: Color(0xFFFF6B6B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Triggers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What triggered your urge to smoke?',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTriggers.map((trigger) {
              final isSelected = widget.selectedTriggers.contains(trigger);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      widget.selectedTriggers.remove(trigger);
                    } else {
                      widget.selectedTriggers.add(trigger);
                    }
                    widget.onChanged(List.from(widget.selectedTriggers));
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFFFF6B6B).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    trigger,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
