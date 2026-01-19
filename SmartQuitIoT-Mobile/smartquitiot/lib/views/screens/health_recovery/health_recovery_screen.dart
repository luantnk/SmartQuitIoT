import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/models/health_recovery.dart';

class HealthRecoveryScreen extends ConsumerWidget {
  const HealthRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthRecoveriesAsync = ref.watch(healthRecoveriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Health Recovery Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: healthRecoveriesAsync.when(
        data: (healthRecoveryResponse) =>
            _buildContent(context, healthRecoveryResponse),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
        error: (error, stack) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildColorfulComparisonStat({
    required String title,
    required IconData icon,
    required int currentValue,
    required String currentSuffix,
    required double avgValue,
    required String avgSuffix,
    required Color startColor,
    required Color endColor,
  }) {
    final currentText = currentValue > 0 ? '$currentValue$currentSuffix' : '-';
    final avgText = avgValue > 0
        ? '${avgValue.toStringAsFixed(1)}$avgSuffix'
        : '-';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: startColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Current: $currentText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Avg: $avgText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Health Recovery Data Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Start logging your diary entries to track your health improvements and recovery milestones!',
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(healthRecoveriesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HealthRecoveryResponse response) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress Card
          _buildOverallProgressCard(response.metrics),
          const SizedBox(height: 20),

          _buildSectionHeader(
            icon: Icons.monitor_heart,
            title: 'Health Vitals',
          ),
          const SizedBox(height: 16),
          _buildVitalsGrid(response.metrics),
          const SizedBox(height: 24),

          // _buildSectionHeader(icon: Icons.insights, title: 'Current State'),
          // const SizedBox(height: 16),

          // _buildCurrentStateGrid(response.metrics),
          // const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.payments,
            title: 'Financial & Impact',
          ),
          const SizedBox(height: 16),
          _buildFinancialImpactGrid(response.metrics),
          const SizedBox(height: 24),

          // Health Recoveries List
          const Text(
            'Health Recovery Milestones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),

          if (response.healthRecoveries.isEmpty)
            _buildEmptyRecoveries()
          else
            ...response.healthRecoveries.map(
              (recovery) => _buildRecoveryCard(recovery),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D09E), size: 26),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallProgressCard(DetailedMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.trending_up, color: Color(0xFF00D09E), size: 28),
            SizedBox(width: 12),
            Text(
              'Your Progress Overview',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildColorfulProgressStat(
              'Streak Days',
              '${metrics.streaks}',
              Icons.local_fire_department,
              const Color(0xFFFF6B6B),
              const Color(0xFFEE5A6F),
            ),
            _buildColorfulProgressStat(
              'Missions',
              '${metrics.totalMissionCompleted}',
              Icons.checklist,
              const Color(0xFF00B894),
              const Color(0xFF00A085),
            ),
            _buildColorfulProgressStat(
              'Avg Craving',
              '${metrics.avgCravingLevel.toStringAsFixed(1)}/10',
              Icons.psychology,
              const Color(0xFF4ECDC4),
              const Color(0xFF44A9A0),
            ),
            _buildColorfulProgressStat(
              'Avg Mood',
              '${metrics.avgMood.toStringAsFixed(1)}/10',
              Icons.sentiment_satisfied,
              const Color(0xFFFFA500),
              const Color(0xFFFF8C00),
            ),
            _buildColorfulProgressStat(
              'Confidence',
              '${metrics.avgConfidentLevel.toStringAsFixed(1)}/10',
              Icons.psychology_alt,
              const Color(0xFF9B59B6),
              const Color(0xFF8E44AD),
            ),
            _buildColorfulProgressStat(
              'Avg Anxiety',
              '${metrics.avgAnxiety.toStringAsFixed(1)}/10',
              Icons.self_improvement,
              const Color(0xFF5DADE2),
              const Color(0xFF2E86C1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalsGrid(DetailedMetrics metrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: [
        _buildColorfulProgressStat(
          'Heart Rate',
          metrics.heartRate > 0 ? '${metrics.heartRate} bpm' : '-',
          Icons.favorite,
          const Color(0xFFE74C3C),
          const Color(0xFFC0392B),
        ),
        _buildColorfulProgressStat(
          'SpO₂',
          metrics.spo2 > 0 ? '${metrics.spo2}%' : '-',
          Icons.air,
          const Color(0xFF3498DB),
          const Color(0xFF2E86C1),
        ),
        _buildColorfulProgressStat(
          'Steps',
          metrics.steps > 0 ? _formatNumber(metrics.steps) : '-',
          Icons.directions_walk,
          const Color(0xFF2ECC71),
          const Color(0xFF27AE60),
        ),
        _buildColorfulProgressStat(
          'Sleep',
          metrics.sleepDuration > 0
              ? '${metrics.sleepDuration.toStringAsFixed(1)} h'
              : '-',
          Icons.bedtime,
          const Color(0xFF9B59B6),
          const Color(0xFF8E44AD),
        ),
      ],
    );
  }

  Widget _buildCurrentStateGrid(DetailedMetrics metrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _buildColorfulComparisonStat(
          title: 'Craving',
          icon: Icons.psychology,
          currentValue: metrics.currentCravingLevel,
          currentSuffix: '/10',
          avgValue: metrics.avgCravingLevel,
          avgSuffix: '/10',
          startColor: const Color(0xFF4ECDC4),
          endColor: const Color(0xFF44A9A0),
        ),
        _buildColorfulComparisonStat(
          title: 'Mood',
          icon: Icons.sentiment_satisfied,
          currentValue: metrics.currentMoodLevel,
          currentSuffix: '/10',
          avgValue: metrics.avgMood,
          avgSuffix: '/10',
          startColor: const Color(0xFFFFA500),
          endColor: const Color(0xFFFF8C00),
        ),
        _buildColorfulComparisonStat(
          title: 'Confidence',
          icon: Icons.psychology_alt,
          currentValue: metrics.currentConfidenceLevel,
          currentSuffix: '/10',
          avgValue: metrics.avgConfidentLevel,
          avgSuffix: '/10',
          startColor: const Color(0xFF9B59B6),
          endColor: const Color(0xFF8E44AD),
        ),
        _buildColorfulComparisonStat(
          title: 'Anxiety',
          icon: Icons.self_improvement,
          currentValue: metrics.currentAnxietyLevel,
          currentSuffix: '/10',
          avgValue: metrics.avgAnxiety,
          avgSuffix: '/10',
          startColor: const Color(0xFF5DADE2),
          endColor: const Color(0xFF2E86C1),
        ),
      ],
    );
  }

  Widget _buildFinancialImpactGrid(DetailedMetrics metrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildColorfulProgressStat(
          'Avg Nicotine (mg/day)',
          metrics.avgNicotineMgPerDay > 0
              ? metrics.avgNicotineMgPerDay.toStringAsFixed(2)
              : '-',
          Icons.science,
          const Color(0xFF00D09E),
          const Color(0xFF00B894),
        ),
        _buildColorfulProgressStat(
          'Money Saved',
          _formatCurrency(metrics.moneySaved),
          Icons.savings,
          const Color(0xFF00B894),
          const Color(0xFF00A085),
        ),
        _buildColorfulProgressStat(
          'Annual Saved',
          _formatCurrency(metrics.annualSaved),
          Icons.account_balance_wallet,
          const Color(0xFF16A085),
          const Color(0xFF0E6655),
        ),
        _buildColorfulProgressStat(
          'Smoke-Free %',
          '${metrics.smokeFreeDayPercentage.toStringAsFixed(0)}%',
          Icons.verified,
          const Color(0xFF2ECC71),
          const Color(0xFF27AE60),
        ),
        _buildColorfulProgressStat(
          'Reduction %',
          '${metrics.reductionInLastSmoked.toStringAsFixed(1)}%',
          Icons.trending_down,
          const Color(0xFF6C5CE7),
          const Color(0xFF5A4FCF),
        ),
      ],
    );
  }

  Widget _buildColorfulProgressStat(
    String title,
    String value,
    IconData icon,
    Color startColor,
    Color endColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: startColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  Widget _buildEmptyRecoveries() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.health_and_safety_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Recovery Data Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Keep logging your diary entries to unlock health recovery milestones!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCard(HealthRecovery recovery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(recovery.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(recovery.status),
                  color: _getStatusColor(recovery.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatRecoveryName(recovery.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recovery.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (recovery.value != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(recovery.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recovery.value?.toInt() ?? 0}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Recovery Time: ${recovery.formattedRecoveryTime}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                _getStatusText(recovery.status),
                style: TextStyle(
                  fontSize: 13,
                  color: _getStatusColor(recovery.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (recovery.targetTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Target: ${_formatDateTime(recovery.targetTime)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],

          if (recovery.value != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: recovery.value! / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(recovery.status),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime.toLocal());
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(symbol: '₫', decimalDigits: 0);
    return formatter.format(value);
  }

  String _formatNumber(int value) {
    return NumberFormat.decimalPattern().format(value);
  }

  String _formatRecoveryName(String name) {
    return name
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getStatusColor(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.completed:
        return const Color(0xFF4CAF50);
      case RecoveryStatus.inProgress:
        return const Color(0xFF2196F3);
      case RecoveryStatus.started:
        return const Color(0xFFFF9800);
      case RecoveryStatus.upcoming:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.completed:
        return Icons.check_circle;
      case RecoveryStatus.inProgress:
        return Icons.hourglass_empty;
      case RecoveryStatus.started:
        return Icons.play_circle;
      case RecoveryStatus.upcoming:
        return Icons.schedule;
    }
  }

  String _getStatusText(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.completed:
        return 'Completed';
      case RecoveryStatus.inProgress:
        return 'In Progress';
      case RecoveryStatus.started:
        return 'Started';
      case RecoveryStatus.upcoming:
        return 'Upcoming';
    }
  }
}
