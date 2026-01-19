import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProgressCard extends StatelessWidget {
  final String animationPath; // Lottie file path
  final String title;
  final String value;
  final Color borderColor; // Màu viền
  final Color valueColor;  // Màu chữ value

  const ProgressCard({
    super.key,
    required this.animationPath,
    required this.title,
    required this.value,
    this.borderColor = const Color(0xFF00D09E), // mặc định xanh mint
    this.valueColor = Colors.black,             // mặc định đen
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE0F2F1), // xanh mint nhạt
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          // Lottie animation
          SizedBox(
            height: 60,
            width: 60,
            child: Lottie.asset(animationPath, repeat: true),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
