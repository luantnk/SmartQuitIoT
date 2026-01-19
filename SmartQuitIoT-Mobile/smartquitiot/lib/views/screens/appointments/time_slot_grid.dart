// lib/features/coaching/widgets/time_slot_grid.dart
import 'package:SmartQuitIoT/views/screens/appointments/time_slot_item.dart';
import 'package:flutter/material.dart';

import 'coach_list_items.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final String? selectedSlot;
  final Function(String) onSlotSelected;

  const TimeSlotGrid({
    Key? key,
    required this.timeSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        return TimeSlotItem(
          slot: slot,
          isSelected: selectedSlot == slot.time,
          onTap: slot.available ? () => onSlotSelected(slot.time) : null,
        );
      },
    );
  }
}
