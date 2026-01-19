import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final Color? activeColor;
  final Color? inactiveColor;
  final double activeSize;
  final double inactiveSize;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
    this.activeSize = 12,
    this.inactiveSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? activeSize : inactiveSize,
          height: currentIndex == index ? activeSize : inactiveSize,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? (activeColor ?? const Color(0xFF00D09E))
                : (inactiveColor ?? Colors.grey),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
