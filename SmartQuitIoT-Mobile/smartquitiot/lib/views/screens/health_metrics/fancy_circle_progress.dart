import 'package:flutter/material.dart';

class FancyProgressCircle extends StatelessWidget {
  final double progress; // 0 → 1
  const FancyProgressCircle({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _FancyCirclePainter(progress),
    );
  }
}

class _FancyCirclePainter extends CustomPainter {
  final double progress;
  _FancyCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Nền mờ
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, bgPaint);

    // Vòng tiến trình
    final sweepAngle = 2 * 3.1415926 * progress;
    final gradient = SweepGradient(
      colors: [Colors.white, Colors.white.withOpacity(0.6)],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // bo đầu
      ..strokeWidth = 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926 / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Text % ở giữa
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
        canvas,
        center -
            Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
