import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final double height;
  final Color backgroundColor;

  const AuthHeader({
    super.key,
    required this.title,
    this.height = 120,
    this.backgroundColor = const Color(0xFF00D09E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: backgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
