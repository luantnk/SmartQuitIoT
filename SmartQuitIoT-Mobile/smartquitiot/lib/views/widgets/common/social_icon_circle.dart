import 'package:flutter/material.dart';

class SocialIconCircle extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final Color background;
  final Color borderColor;

  const SocialIconCircle({
    super.key,
    required this.asset,
    required this.onTap,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Image.asset(asset, width: 28, height: 28)),
      ),
    );
  }
}
