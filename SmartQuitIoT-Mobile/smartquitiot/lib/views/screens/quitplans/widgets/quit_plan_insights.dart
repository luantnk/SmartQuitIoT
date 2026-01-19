import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/quit_plan_detail.dart';

class QuitPlanInsights extends StatelessWidget {
  final QuitPlanDetail plan;

  const QuitPlanInsights({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final formMetric = plan.formMetricDTO;
    final currentMetric = plan.currentMetricDTO;
    final hasLifestyleInfo = (formMetric?.interests.isNotEmpty ?? false) ||
        (formMetric?.triggered.isNotEmpty ?? false);

    if (formMetric == null && currentMetric == null && !hasLifestyleInfo) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (formMetric != null) _buildBaselineMetricsCard(formMetric),
        if (formMetric != null) _buildHabitAndFinanceCard(formMetric),
        if (hasLifestyleInfo) _buildLifestyleChipsCard(formMetric!),
        if (currentMetric != null) _buildCurrentMetricCard(currentMetric),
      ],
    );
  }

  Widget _buildBaselineMetricsCard(FormMetricDTO metrics) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _insightCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightHeader(
            icon: Icons.insights,
            title: 'Baseline Insights',
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          _buildMetricLine(
            icon: Icons.smoking_rooms,
            label: 'Avg cigarettes per day',
            value: metrics.smokeAvgPerDay.toString(),
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.calendar_month,
            label: 'Years of smoking',
            value: metrics.numberOfYearsOfSmoking.toString(),
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.timer,
            label: 'Minutes to first cigarette',
            value: '${metrics.minutesAfterWakingToSmoke} mins',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.inventory_2_outlined,
            label: 'Cigarettes per pack',
            value: metrics.cigarettesPerPackage.toString(),
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.science,
            label: 'Nicotine per cig',
            value: '${metrics.amountOfNicotinePerCigarettes.toStringAsFixed(2)} mg',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.bolt,
            label: 'Estimated nicotine per day',
            value: '${metrics.estimatedNicotineIntakePerDay.toStringAsFixed(2)} mg',
            iconColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitAndFinanceCard(FormMetricDTO metrics) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _insightCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightHeader(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Habits & Savings',
            color: const Color(0xFF047857),
          ),
          const SizedBox(height: 12),
          _buildMetricLine(
            icon: Icons.payments,
            label: 'Money per pack',
            value: _formatCurrency(metrics.moneyPerPackage),
            iconColor: const Color(0xFF047857),
          ),
          _buildMetricLine(
            icon: Icons.savings_outlined,
            label: 'Estimated savings this plan',
            value: _formatCurrency(metrics.estimatedMoneySavedOnPlan),
            iconColor: const Color(0xFF047857),
          ),
          _buildMetricLine(
            icon: Icons.gavel,
            label: 'Smoke in forbidden places',
            value: _formatBoolLabel(metrics.smokingInForbiddenPlaces),
            iconColor: const Color(0xFF047857),
          ),
          _buildMetricLine(
            icon: Icons.mood_bad_outlined,
            label: 'Hardest cigarette to give up',
            value: _formatBoolLabel(metrics.cigaretteHateToGiveUp),
            iconColor: const Color(0xFF047857),
          ),
          _buildMetricLine(
            icon: Icons.wb_sunny_outlined,
            label: 'Smoke frequently in morning',
            value: _formatBoolLabel(metrics.morningSmokingFrequency),
            iconColor: const Color(0xFF047857),
          ),
          _buildMetricLine(
            icon: Icons.sick_outlined,
            label: 'Still smoke when sick',
            value: _formatBoolLabel(metrics.smokeWhenSick),
            iconColor: const Color(0xFF047857),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleChipsCard(FormMetricDTO metrics) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _insightCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightHeader(
            icon: Icons.self_improvement,
            title: 'Lifestyle & Triggers',
            color: const Color(0xFF9333EA),
          ),
          if (metrics.interests.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Motivations & Interests',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildChipWrap(metrics.interests, const Color(0xFF9333EA)),
          ],
          if (metrics.triggered.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Smoking Triggers',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildChipWrap(metrics.triggered, const Color(0xFFDB2777)),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentMetricCard(CurrentMetricDTO metrics) {
    final hasAnyData = [
      metrics.avgCravingLevel,
      metrics.avgCigarettesPerDay,
      metrics.avgMood,
      metrics.avgAnxiety,
      metrics.avgConfidentLevel,
    ].any((value) => value != null);

    if (!hasAnyData) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _insightCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightHeader(
            icon: Icons.auto_graph,
            title: 'Current Check-in',
            color: const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 12),
          if (metrics.avgCravingLevel != null)
            _buildMetricProgressRow(
              label: 'Craving level',
              value: metrics.avgCravingLevel!,
              color: Colors.redAccent,
            ),
          if (metrics.avgCigarettesPerDay != null)
            _buildMetricLine(
              icon: Icons.smoke_free,
              label: 'Avg cigarettes per day (current)',
              value: metrics.avgCigarettesPerDay!.toStringAsFixed(1),
              iconColor: const Color(0xFF0EA5E9),
            ),
          if (metrics.avgMood != null)
            _buildMetricProgressRow(
              label: 'Mood',
              value: metrics.avgMood!,
              color: const Color(0xFF0EA5E9),
            ),
          if (metrics.avgAnxiety != null)
            _buildMetricProgressRow(
              label: 'Anxiety',
              value: metrics.avgAnxiety!,
              color: const Color(0xFFF59E0B),
            ),
          if (metrics.avgConfidentLevel != null)
            _buildMetricProgressRow(
              label: 'Confidence',
              value: metrics.avgConfidentLevel!,
              color: const Color(0xFF10B981),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricProgressRow({
    required String label,
    required double value,
    required Color color,
  }) {
    final normalized = (value / 10).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLine({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF00D09E)).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? const Color(0xFF00D09E), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipWrap(List<String> items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  BoxDecoration _insightCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(
        color: const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildInsightHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatBoolLabel(bool value) {
    return value ? 'Yes' : 'No';
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }
}

