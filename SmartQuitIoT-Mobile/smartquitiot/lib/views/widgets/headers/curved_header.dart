import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final Widget child;
  final double height;
  const CurvedHeader({super.key, required this.child, this.height = 220});

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Material(
        color: s.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: Center(child: child),
      ),
    );
  }
}


