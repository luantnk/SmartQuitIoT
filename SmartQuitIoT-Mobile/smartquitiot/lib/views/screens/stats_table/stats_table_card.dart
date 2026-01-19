import 'package:SmartQuitIoT/views/screens/health_recovery/health_recovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/models/home_metrics.dart';

class StatsTableCard extends ConsumerStatefulWidget {
  const StatsTableCard({super.key});

  @override
  ConsumerState<StatsTableCard> createState() => _StatsTableCardState();
}

class _StatsTableCardState extends ConsumerState<StatsTableCard>
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
    final homeMetricsAsync = ref.watch(homeMetricsProvider);

    // Listen for diary changes to refresh metrics
    ref.listen(metricsRefreshProvider, (previous, next) {
      if (previous != next) {
        ref.invalidate(homeMetricsProvider);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: homeMetricsAsync.when(
            data: (homeMetrics) => _buildContent(context, homeMetrics),
            loading: () => _buildLoading(),
            error: (error, stack) => _buildError(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: Color(0xFF00D09E)),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Color(0xFF00D09E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start Your Journey!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Log your first diary entry to unlock your progress dashboard and track your amazing journey!',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(homeMetricsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Start Logging',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeMetrics homeMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: const Text(
                'View More',
                style: TextStyle(
                  color: Color(0xFF00D09E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Streak Display with Fire Animation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.15),
                const Color(0xFFF7931E).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: Lottie.asset(
                  'lib/assets/animations/fire.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${homeMetrics.metric.streaks} Day Streak',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats Grid
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Money Saved',
              _formatMoney(homeMetrics.metric.moneySaved),
              Icons.attach_money,
              const Color(0xFF4CAF50),
            ),
            _buildStatCard(
              'Annual Saved',
              _formatMoney(homeMetrics.metric.annualSaved),
              Icons.savings,
              const Color(0xFF2196F3),
            ),
            _buildStatCard(
              'Reduction',
              '${homeMetrics.metric.reductionPercentage.toStringAsFixed(1)}%',
              Icons.trending_down,
              const Color(0xFFFF9800),
            ),
            _buildStatCard(
              'Smoke-Free Days',
              '${homeMetrics.metric.smokeFreeDayPercentage.toStringAsFixed(1)}%',
              Icons.smoke_free,
              const Color(0xFF9C27B0),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Craving Level Chart
        if (homeMetrics.cravingLevelChart.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Craving Level Trend',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildSimpleCravingChart(homeMetrics.cravingLevelChart),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getAnimationForTitle(String title) {
    switch (title) {
      case 'Money Saved':
        return 'lib/assets/animations/money-2.json';
      case 'Annual Saved':
        return 'lib/assets/animations/savings.json';
      case 'Reduction':
        return 'lib/assets/animations/trophy.json';
      case 'Smoke-Free Days':
        return 'lib/assets/animations/fire.json';
      default:
        return 'lib/assets/animations/trophy.json';
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Lottie.asset(
                    _getAnimationForTitle(title),
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleCravingChart(List<CravingLevelChart> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Take last 7 days
    final chartData = data.take(7).toList();

    return Column(
      children: [
        // Bar Chart
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: chartData.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildCravingBar(item),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE91E63), Color(0xFFFF6B9D)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Craving Level (0-10)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCravingBar(CravingLevelChart item) {
    final maxLevel = 10.0;
    final heightPercent = (item.cravingLevel / maxLevel).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: heightPercent),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value label
            if (animValue > 0.05)
              Text(
                item.cravingLevel.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            const SizedBox(height: 4),
            // Bar
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: animValue * 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE91E63).withOpacity(0.8),
                        const Color(0xFFFF6B9D),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Date label
            Text(
              DateFormat('E').format(DateTime.parse(item.date)),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatMoney(double amount) {
    // if (amount < 0) return '0';
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
}
