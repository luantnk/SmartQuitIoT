// lib/features/coaching/widgets/tag_selector.dart
import 'package:SmartQuitIoT/views/screens/appointments/tag_chip.dart';
import 'package:flutter/material.dart';

class TagSelector extends StatelessWidget {
  final List<String> tags;
  final List<String> selectedTags;
  final Function(String) onTagToggle;

  const TagSelector({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return TagChip(
          label: tag,
          isSelected: isSelected,
          onTap: () => onTagToggle(tag),
        );
      }).toList(),
    );
  }
}