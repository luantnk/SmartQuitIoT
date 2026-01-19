import 'package:flutter/material.dart';
import 'coach_list_items.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotItem({
    super.key,
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use Material + InkWell so ripple + hit testing work correctly inside scroll views
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor(), width: 1.5),
          ),
          child: Center(
            child: Text(
              slot.time ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (slot.available == false) return Colors.grey[200]!;
    if (isSelected) return const Color(0xFF00D09E);
    return Colors.white;
  }

  Color _getBorderColor() {
    if (slot.available == false) return Colors.grey[300]!;
    if (isSelected) return const Color(0xFF00D09E);
    return Colors.grey[300]!;
  }

  Color _getTextColor() {
    if (slot.available == false) return Colors.grey[400]!;
    if (isSelected) return Colors.white;
    return Colors.black87;
  }
}
