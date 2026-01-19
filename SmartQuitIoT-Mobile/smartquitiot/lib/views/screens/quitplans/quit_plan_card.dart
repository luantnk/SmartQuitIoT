import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/quit_plan_homepage.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../../../utils/phase_theme.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';
import 'quit_plan_screen.dart';

class QuitPlanCard extends ConsumerStatefulWidget {
  const QuitPlanCard({super.key});

  @override
  ConsumerState<QuitPlanCard> createState() => _QuitPlanCardState();
}

class _QuitPlanCardState extends ConsumerState<QuitPlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Animation cho glow effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Delay để tránh race condition khi navigate từ onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('⏳ [QuitPlanCard] Waiting 500ms before initial load...');
      await Future.delayed(const Duration(milliseconds: 500));
      print('🚀 [QuitPlanCard] Auto-loading quit plan...');
      ref
          .read(quitPlanHomepageViewModelProvider.notifier)
          .loadQuitPlanHomePage();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quitPlanHomepageViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    // Only load data if user is authenticated
    if (!authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    // Listen for mission refresh trigger (includes quit plan refresh)
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print('🔄 [QuitPlanCard] Refresh triggered - reloading quit plan...');
        ref
            .read(quitPlanHomepageViewModelProvider.notifier)
            .loadQuitPlanHomePage();
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      );
    }

    if (state.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (!state.hasQuitPlan) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag,
                  color: Color(0xFF00D09E),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today Quit Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'No active plan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Reload button
              IconButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        print('🔄 [QuitPlanCard] Manual reload triggered');
                        ref
                            .read(quitPlanHomepageViewModelProvider.notifier)
                            .loadQuitPlanHomePage();
                      },
                icon: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00D09E),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Color(0xFF00D09E),
                        size: 20,
                      ),
                tooltip: 'Reload data',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Empty state content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D09E).withOpacity(0.1),
                  const Color(0xFF00B894).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D09E).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: const Color(0xFF00D09E),
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ready to Start Your Journey?',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first quit plan and take the first step towards a healthier, smoke-free life!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final quitPlan = state.quitPlan!;
    final phaseTheme = resolvePhaseTheme(quitPlan.name);
    final currentPhaseTheme = resolvePhaseTheme(
      quitPlan.currentPhaseDetail.name,
    );
    final isCompleted = _isQuitPlanCompleted(quitPlan);
    final isPhaseCompleted = _isPhaseCompleted(quitPlan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Congratulations Banner for completed quit plan
        if (isCompleted) _buildCongratulationsBanner(quitPlan, phaseTheme),
        // Phase completion banner (show when phase is completed but not the whole plan)
        if (!isCompleted && isPhaseCompleted)
          _buildPhaseCompletionBanner(quitPlan, currentPhaseTheme),
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: phaseTheme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                phaseTheme.icon,
                color: phaseTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quit Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    quitPlan.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: phaseTheme.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuitPlanScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: phaseTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'View More',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildMetaInfoChips(quitPlan, phaseTheme),
        const SizedBox(height: 16),

        // Duration and Date Info
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.calendar_today,
                label: 'Duration',
                value: '${quitPlan.durationDay} days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.flag,
                label: 'Start Date',
                value: _formatDate(quitPlan.startDate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 📊 Statistics Section (only visible when status is COMPLETED)
        if (quitPlan.status == 'COMPLETED') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: phaseTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 18,
                      color: phaseTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phase Statistics',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: phaseTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'Avg Craving',
                        value: quitPlan.avgCravingLevel.toStringAsFixed(1),
                        icon: Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Avg Cigarettes',
                        value: quitPlan.avgCigarettes.toStringAsFixed(1),
                        icon: Icons.smoking_rooms,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStatItem(
                  label: 'Total Cigarettes',
                  value: quitPlan.fmCigarettesTotal.toStringAsFixed(0),
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 🎯 Conditions to Pass Section
        if (quitPlan.condition.rules.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: phaseTheme.gradient
                    .map((color) => color.withOpacity(0.12))
                    .toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: phaseTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: phaseTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Conditions to Pass',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: phaseTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildConditionRules(
                  quitPlan.condition,
                  quitPlan.fmCigarettesTotal,
                  phaseTheme,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // 🔥 Styled Phase Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: phaseTheme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: phaseTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(phaseTheme.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quitPlan.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Day ${quitPlan.currentPhaseDetail.dayIndex}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Today (${quitPlan.currentPhaseDetail.name}): ${quitPlan.currentPhaseDetail.missionProgress} missions',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 🌈 Styled Progress Bar with Glow
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const Text(
        //       'Overall Progress',
        //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        //     ),
        //     const SizedBox(height: 10),
        //     Stack(
        //       alignment: Alignment.centerLeft,
        //       children: [
        //         Container(
        //           height: 12,
        //           decoration: BoxDecoration(
        //             color: phaseTheme.primaryColor.withOpacity(0.1),
        //             borderRadius: BorderRadius.circular(6),
        //           ),
        //         ),
        //         AnimatedBuilder(
        //           animation: _glowController,
        //           builder: (context, _) {
        //             final glow = 4 + (_glowController.value * 6);
        //             return Container(
        //               height: 12,
        //               width:
        //                   MediaQuery.of(context).size.width *
        //                   0.7 *
        //                   quitPlan.progressPercentage,
        //               decoration: BoxDecoration(
        //                 gradient: LinearGradient(
        //                   colors: phaseTheme.gradient,
        //                   begin: Alignment.centerLeft,
        //                   end: Alignment.centerRight,
        //                 ),
        //                 borderRadius: BorderRadius.circular(6),
        //                 boxShadow: [
        //                   BoxShadow(
        //                     color: phaseTheme.primaryColor.withOpacity(0.5),
        //                     blurRadius: glow,
        //                     spreadRadius: 1,
        //                   ),
        //                 ],
        //               ),
        //             );
        //           },
        //         ),
        //         Positioned(
        //           right: 0,
        //           child: Text(
        //             '${quitPlan.progressPercent}%',
        //             style: TextStyle(
        //               fontSize: 12,
        //               fontWeight: FontWeight.bold,
        //               color: phaseTheme.primaryColor,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildMetaInfoChips(QuitPlanHomePage quitPlan, PhaseTheme phaseTheme) {
    final chips = <Widget>[
      _buildMetaChip(
        icon: Icons.speed,
        label: 'Status',
        value: _formatStatus(quitPlan.status),
        theme: phaseTheme,
      ),
      if (quitPlan.createdAt != null && quitPlan.createdAt!.isNotEmpty)
        _buildMetaChip(
          icon: Icons.schedule,
          label: 'Created',
          value: _formatDateTime(quitPlan.createdAt),
          theme: phaseTheme,
        ),
    ];

    return Wrap(spacing: 10, runSpacing: 10, children: chips);
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required String value,
    required PhaseTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.chipBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.chipTextColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.chipTextColor.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.chipTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionRules(
    QuitPlanCondition condition,
    double fmCigarettesTotal,
    PhaseTheme phaseTheme,
  ) {
    final rules = condition.rules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (condition.logic.trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: phaseTheme.primaryColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Logic: ${condition.logic}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: phaseTheme.primaryColor,
              ),
            ),
          ),
        if (fmCigarettesTotal > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: phaseTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Baseline total cigarettes: ${fmCigarettesTotal.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: phaseTheme.primaryColor,
              ),
            ),
          ),
        const SizedBox(height: 8),
        ...rules
            .map<Widget>(
              (rule) => _buildRule(
                rule,
                theme: phaseTheme,
                fmCigarettesTotal: fmCigarettesTotal,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildRule(
    QuitPlanRule rule, {
    int indent = 0,
    required PhaseTheme theme,
    required double fmCigarettesTotal,
  }) {
    return Container(
      margin: EdgeInsets.only(left: indent * 16.0, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If this rule has nested rules (OR logic)
          if (rule.rules != null && rule.rules!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.alt_route, size: 14, color: theme.primaryColor),
                const SizedBox(width: 6),
                Text(
                  'Logic: ${rule.logic ?? "AND"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...rule.rules!.map<Widget>(
              (nestedRule) => _buildRule(
                nestedRule,
                indent: indent + 1,
                theme: theme,
                fmCigarettesTotal: fmCigarettesTotal,
              ),
            ),
          ] else ...[
            // Single rule display
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatFieldName(rule.field),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatRuleCondition(
                          rule,
                          fmCigarettesTotal: fmCigarettesTotal,
                        ),
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatFieldName(String? field) {
    if (field == null) return '';
    switch (field) {
      case 'progress':
        return 'Mission Progress';
      case 'craving_level_avg':
        return 'Average Craving Level';
      case 'avg_cigarettes':
        return 'Average Cigarettes';
      default:
        return field.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatRuleCondition(
    QuitPlanRule rule, {
    required double fmCigarettesTotal,
  }) {
    final operator = rule.operator ?? '';

    // Handle formula-based rules
    if (rule.formula != null) {
      final formula = rule.formula!;
      final base = (formula['base'] ?? '').toString();
      final percent = (formula['percent'] ?? 0) as num;
      final op = (formula['operator'] ?? '').toString();
      final percentLabel = (percent * 100).toStringAsFixed(
        percent * 100 % 1 == 0 ? 0 : 1,
      );

      if (base == 'fm_cigarettes_total' && fmCigarettesTotal > 0) {
        final computed = fmCigarettesTotal * percent;
        return 'Must be $operator $percentLabel% $op ${_formatFormulaBase(base)} (≤ ${computed.toStringAsFixed(1)})';
      }

      return 'Must be $operator $percentLabel% $op ${_formatFormulaBase(base)}';
    }

    // Simple value-based rules
    final value = rule.value;
    if (value == null) {
      return 'Must be $operator value';
    }

    String valueDisplay = value.toString();
    if (rule.field == 'progress' && value is num) {
      valueDisplay = '${value.toString()}%';
    }

    return 'Must be $operator $valueDisplay';
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    final normalized = status.replaceAll('_', ' ').toLowerCase();
    return _toTitleCase(normalized);
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'N/A';
    }
    try {
      final parsed = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return dateTimeString;
    }
  }

  String _formatFormulaBase(String base) {
    switch (base) {
      case 'fm_cigarettes_total':
        return 'baseline total cigarettes';
      case 'progress':
        return 'mission progress';
      default:
        return base.replaceAll('_', ' ');
    }
  }

  String _toTitleCase(String input) {
    if (input.isEmpty) return input;
    final words = input.split(' ');
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Check if current phase is completed
  /// Returns true when all missions in current phase are completed
  bool _isPhaseCompleted(QuitPlanHomePage plan) {
    final currentPhase = plan.currentPhaseDetail;
    return currentPhase.missionCompleted >= currentPhase.totalMission &&
        currentPhase.totalMission > 0;
  }

  /// Check if quit plan is completed
  /// Only returns true when Maintenance phase is completed
  bool _isQuitPlanCompleted(QuitPlanHomePage plan) {
    // Only consider quit plan completed when Maintenance phase is completed
    final currentPhase = plan.currentPhaseDetail;
    final isMaintenancePhase = currentPhase.name.toLowerCase().contains(
      'maintenance',
    );
    final allMissionsCompleted =
        currentPhase.missionCompleted >= currentPhase.totalMission &&
        currentPhase.totalMission > 0;

    // Quit plan is only completed when:
    // 1. Current phase is Maintenance
    // 2. All missions in Maintenance phase are completed
    return isMaintenancePhase && allMissionsCompleted;
  }

  /// Build phase completion banner when a phase is completed
  Widget _buildPhaseCompletionBanner(QuitPlanHomePage plan, PhaseTheme theme) {
    final phaseName = plan.currentPhaseDetail.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(theme.icon, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text('', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text('✨', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mission Completed!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Congratulations on completing the $phaseName phase!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Keep up the great work! You\'re making amazing progress! 💪',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build congratulations banner when quit plan is completed
  Widget _buildCongratulationsBanner(QuitPlanHomePage plan, PhaseTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('🎆', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text('✨', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You have successfully completed your quit plan!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'You are now smoke-free! Keep up the amazing work! 💪',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
