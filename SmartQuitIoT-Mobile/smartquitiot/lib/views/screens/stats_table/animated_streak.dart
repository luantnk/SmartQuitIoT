import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // import Lottie

class AnimatedStreak extends StatefulWidget {
  const AnimatedStreak({super.key});

  @override
  State<AnimatedStreak> createState() => _AnimatedStreakState();
}

class _AnimatedStreakState extends State<AnimatedStreak>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glow = 0.3 + (_controller.value * 0.5);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFEF5350)], // cam -> đỏ
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(glow),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 Lottie fire animation
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Lottie.asset(
                    'lib/assets/animations/fire.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Streak: 7 days',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
