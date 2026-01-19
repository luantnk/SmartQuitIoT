import 'package:flutter/material.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'analysis_title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'view_more'.tr(),
                      style: const TextStyle(
                        color: Color(0xFF00D09E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== Charts =====
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FFF3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // ===== Line Chart =====
                Text(
                  'cig_trend'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 160, child: _AnimatedLineChart()),
                const SizedBox(height: 16),

                // ===== Bar Chart =====
                Text(
                  'weekly_activity'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 120, child: _AnimatedBarChart()),
                const SizedBox(height: 16),

                // ===== Pie Chart =====
                Text(
                  'daily_habit'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(height: 160, child: _AnimatedPieChart()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== Explore Button =====
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'explore'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Animated Line Chart =====
class _AnimatedLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _LineChartPainter(animationValue: value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final double animationValue;
  _LineChartPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final data = [2, 3, 5, 4, 6, 5, 7, 6, 8, 7, 6, 5, 4, 3, 2];
    final maxData = data.reduce(max);

    for (int i = 0; i < data.length; i++) {
      final dx = i * (size.width / (data.length - 1));
      final dy = size.height - (data[i] / maxData * size.height);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final pathMetrics = path.computeMetrics().toList();
    final extractLength = pathMetrics.first.length * animationValue;
    final extractPath = pathMetrics.first.extractPath(0, extractLength);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// ===== Animated Bar Chart =====
class _AnimatedBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _BarChartPainter(animationValue: value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final double animationValue;
  _BarChartPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent;
    final data = [3, 5, 2, 6, 4, 7, 5];
    final maxData = data.reduce(max);
    final barWidth = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxData) * size.height * animationValue;
      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - barHeight,
          barWidth - 8,
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// ===== Animated Pie Chart =====
class _AnimatedPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = min(constraints.maxWidth, constraints.maxHeight);
            return Center(
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _PieChartPainter(animationValue: value),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double animationValue;
  _PieChartPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final data = [0.3, 0.4, 0.3];
    final colors = [Colors.green, Colors.redAccent, Colors.orange];
    double startAngle = -pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweep = 2 * pi * data[i] * animationValue;
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += 2 * pi * data[i];
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
