import 'package:SmartQuitIoT/views/screens/health_recovery/health_recovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/models/home_health_recovery.dart';

class HealthImprovementCard extends ConsumerWidget {
  const HealthImprovementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthRecoveryAsync = ref.watch(homeHealthRecoveryProvider);
    
    return healthRecoveryAsync.when(
      data: (healthRecovery) => _buildCard(context, healthRecovery),
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildCard(context, null),
    );
  }

  Widget _buildLoadingCard() {
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
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00D09E),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, HomeHealthRecovery? healthRecovery) {
    // Check if we have data
    final hasData = healthRecovery?.hasData ?? false;
    
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'health_improvement.title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthRecoveryScreen(),
                    ),
                  );
                },
                child: Text(
                  'health_improvement.view_more'.tr(),
                  style: const TextStyle(
                    color: Color(0xFF00D09E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Content - either data or empty state
          hasData
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProgressCircle(
                      title: 'health_improvement.pulse_rate'.tr(),
                      progress: _calculateProgress(healthRecovery!.pulseRate, 60, 100),
                      value: healthRecovery.pulseRate,
                      unit: 'bpm',
                      icon: Icons.favorite,
                      gradientColors: [Colors.redAccent, Colors.pink],
                    ),
                    _buildProgressCircle(
                      title: 'health_improvement.oxygen_levels'.tr(),
                      progress: _calculateProgress(healthRecovery.oxygenLevel, 95, 100),
                      value: healthRecovery.oxygenLevel,
                      unit: '%',
                      icon: Icons.air,
                      gradientColors: [Colors.blueAccent, Colors.cyan],
                    ),
                    _buildProgressCircle(
                      title: 'health_improvement.co_levels'.tr(),
                      progress: healthRecovery.carbonMonoxideLevel != null 
                          ? (1 - (healthRecovery.carbonMonoxideLevel! / 10).clamp(0.0, 1.0))
                          : 0.0,
                      value: healthRecovery.carbonMonoxideLevel,
                      unit: 'ppm',
                      icon: Icons.warning,
                      gradientColors: [Colors.orange, Colors.deepOrange],
                    ),
                  ],
                )
              : _buildEmptyState(),
        ],
      ),
    );
  }

  double _calculateProgress(double? value, double min, double max) {
    if (value == null) return 0.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              size: 48,
              color: Color(0xFF00D09E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Health Data Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Data not found yet. Please log your diary to track your health improvements!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required String title,
    required double progress,
    double? value,
    String? unit,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: CircleProgressPainter(
                progress: progress,
                gradientColors: gradientColors,
                backgroundColor: gradientColors.first.withOpacity(0.15),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(
                        icon,
                        color: gradientColors.last.withOpacity(0.9),
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value != null
                          ? '${value.toStringAsFixed(0)}${unit ?? ""}'
                          : '--',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: gradientColors.last,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: gradientColors.last,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final Color backgroundColor;

  CircleProgressPainter({
    required this.progress,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8;
    double radius = (size.width / 2) - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    // Background circle
    Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    SweepGradient gradient = SweepGradient(
      colors: gradientColors,
      startAngle: -math.pi / 2,
      endAngle: 1.5 * math.pi,
    );

    Paint fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
