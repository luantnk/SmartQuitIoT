import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  final String text;
  final Color? lineColor;
  final Color? textColor;

  const AuthDivider({
    super.key,
    this.text = 'or',
    this.lineColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: lineColor ?? Colors.black26),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(color: textColor ?? Colors.black54),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: lineColor ?? Colors.black26),
        ),
      ],
    );
  }
}
