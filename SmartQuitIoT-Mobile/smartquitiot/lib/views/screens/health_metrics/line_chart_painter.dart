import 'dart:math' as math;

import 'package:flutter/material.dart';

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00C853)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF00C853).withOpacity(0.3),
          Color(0xFF00C853).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Generate sample data points
    final points = <Offset>[];
    final fillPoints = <Offset>[];

    fillPoints.add(Offset(0, size.height));

    for (int i = 0; i < 30; i++) {
      final x = (i / 29) * size.width;
      final baseY = size.height * 0.7;
      final variation = math.sin(i * 0.3) * 30 + math.cos(i * 0.2) * 20;
      final y = baseY + variation;

      points.add(Offset(x, y));
      fillPoints.add(Offset(x, y));
    }

    fillPoints.add(Offset(size.width, size.height));
    fillPoints.add(Offset(0, size.height));

    // Draw fill area
    final fillPath = Path();
    fillPath.addPolygon(fillPoints, true);
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 3,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        points[i].dx - (points[i].dx - points[i - 1].dx) / 3,
        points[i].dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Color(0xFF00C853)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i += 5) {
      canvas.drawCircle(points[i], 4, pointPaint);
      canvas.drawCircle(points[i], 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}