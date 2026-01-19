import 'package:flutter/material.dart';

class MultiSelectInterests extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;
  const MultiSelectInterests({super.key, required this.onSelectionChanged});

  @override
  State<MultiSelectInterests> createState() => _MultiSelectInterestsState();
}

class _MultiSelectInterestsState extends State<MultiSelectInterests> {
  final List<String> options = [
    "All Interests",
    "Sports and Exercise",
    "Art and Creativity",
    "Cooking and Food",
    "Reading, Learning and Writing",
    "Music and Entertainment",
    "Nature and Outdoor Activities",
  ];

  final List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select your interests",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  widget.onSelectionChanged(selected);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
