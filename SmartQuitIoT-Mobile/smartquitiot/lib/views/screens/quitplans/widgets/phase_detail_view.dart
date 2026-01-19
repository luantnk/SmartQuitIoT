import 'package:flutter/material.dart';
import '../../../../models/quit_plan_detail.dart';
import '../../../../models/quit_phase.dart';
import '../../../../utils/phase_theme.dart';

class PhaseDetailView extends StatefulWidget {
  final QuitPlanDetail plan;
  final QuitPhaseDetail phase;
  final PhaseTheme theme;
  final Set<int> locallyCompletedMissionIds;
  final bool isReadOnly;
  final VoidCallback? onKeepPhase;
  final VoidCallback? onRedoPhase;
  final Function(QuitMissionItem, int) onMissionCompleted;
  final bool keepLoading;
  final bool redoLoading;
  final bool hasPhaseActionInProgress;

  const PhaseDetailView({
    super.key,
    required this.plan,
    required this.phase,
    required this.theme,
    required this.locallyCompletedMissionIds,
    this.isReadOnly = false,
    this.onKeepPhase,
    this.onRedoPhase,
    required this.onMissionCompleted,
    this.keepLoading = false,
    this.redoLoading = false,
    this.hasPhaseActionInProgress = false,
  });

  @override
  State<PhaseDetailView> createState() => _PhaseDetailViewState();
}

class _PhaseDetailViewState extends State<PhaseDetailView> {
  int _selectedDayIndex = 0;

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }

  bool _isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (_) {
      return false;
    }
  }

  bool _isPastOrToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    try {
      final date = DateTime.parse(dateString);
      final targetDate = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      return targetDate.isBefore(todayDate) ||
          targetDate.isAtSameMomentAs(todayDate);
    } catch (_) {
      return false;
    }
  }

  bool _isFailedStatus(String? status) =>
      status != null && status.toUpperCase() == 'FAILED';

  bool _areAllMissionsCompleted(List<QuitMissionItem> missions) {
    if (missions.isEmpty) return false;
    return missions.every((mission) {
      final missionId = mission.id ?? -1;
      return mission.status == 'COMPLETED' ||
          widget.locallyCompletedMissionIds.contains(missionId);
    });
  }

  bool _hasNewPhaseAfterFailed(
    QuitPhaseDetail failedPhase,
    List<QuitPhaseDetail> allPhases,
  ) {
    if (!_isFailedStatus(failedPhase.status)) return false;

    final failedPhaseName = failedPhase.name ?? '';
    final failedPhaseId = failedPhase.id;
    if (failedPhaseName.isEmpty || failedPhaseId == null) return false;

    for (final phase in allPhases) {
      if (phase.id == failedPhaseId) continue;
      if (phase.name != failedPhaseName) continue;

      final isNewPhase =
          phase.status == 'CREATED' || phase.status == 'IN_PROGRESS';
      if (isNewPhase) {
        try {
          if (failedPhase.endDate != null && phase.startDate != null) {
            final failedEndDate = DateTime.parse(failedPhase.endDate!);
            final newStartDate = DateTime.parse(phase.startDate!);
            if (newStartDate.isAfter(failedEndDate) ||
                newStartDate.isAtSameMomentAs(failedEndDate)) {
              return true;
            }
          }
          if (failedPhase.createdAt != null && phase.createdAt != null) {
            final failedCreatedAt = DateTime.parse(failedPhase.createdAt!);
            final newCreatedAt = DateTime.parse(phase.createdAt!);
            if (newCreatedAt.isAfter(failedCreatedAt)) {
              return true;
            }
          }
        } catch (e) {
          if (isNewPhase) return true;
        }
      }
    }
    return false;
  }

  int _getSmokeAvgPerDay(
    int? formMetricSmokeAvgPerDay,
    double fmCigarettesTotal,
    int durationDay,
  ) {
    if (formMetricSmokeAvgPerDay != null && formMetricSmokeAvgPerDay > 0) {
      return formMetricSmokeAvgPerDay;
    }
    if (durationDay > 0 && fmCigarettesTotal > 0) {
      return (fmCigarettesTotal / durationDay).round();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.phase.details ?? [];
    final isFailed = _isFailedStatus(widget.phase.status);
    final allPhases = widget.plan.phases ?? [];
    final hasNewPhaseAfterFailed = _hasNewPhaseAfterFailed(widget.phase, allPhases);
    final shouldShowFailedActions =
        isFailed && !(widget.phase.keepPhase ?? false) && !widget.isReadOnly;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Failed Phase Banner
          if (isFailed && !hasNewPhaseAfterFailed)
            _buildFailedPhaseBanner(),
          // Failed Phase Actions
          if (shouldShowFailedActions) ...[
            const SizedBox(height: 12),
            _buildFailedPhaseActions(),
          ],
          // Kept Phase Banner
          if (isFailed && (widget.phase.keepPhase ?? false)) ...[
            const SizedBox(height: 12),
            _buildKeptPhaseBanner(),
          ],
          // Phase Reason
          if ((widget.phase.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: widget.theme.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.phase.reason ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Phase Statistics
          if (widget.phase.avgCravingLevel != null ||
              widget.phase.avgCigarettes != null ||
              widget.phase.fmCigarettesTotal != null) ...[
            const SizedBox(height: 12),
            _buildPhaseStatistics(),
          ],
          // Phase Conditions
          if (widget.phase.condition != null &&
              (widget.phase.condition!.rules?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            _buildPhaseConditions(),
          ],
          // Days and Missions
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No missions available yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else ...[
            const SizedBox(height: 16),
            const Text(
              'Days:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, dayIdx) {
                  final day = days[dayIdx];
                  final isSelected = _selectedDayIndex == dayIdx;
                  final missions = day.missions ?? [];
                  final completed = missions
                      .where((m) => m.status == 'COMPLETED')
                      .length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = dayIdx),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.theme.primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: widget.theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Day ${day.dayIndex}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(day.date),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completed/${missions.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white70
                                  : widget.theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedDayIndex < days.length)
              _buildMissionsList(days[_selectedDayIndex]),
          ],
        ],
      ),
    );
  }

  Widget _buildFailedPhaseBanner() {
    final planName = widget.plan.name.trim();
    final displayPlanName = planName.isEmpty ? 'Quit Plan' : planName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('😞', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Oh no! Phase failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This phase did not meet the exit criteria. Review the statistics and conditions below to understand what happened.',
            style: TextStyle(fontSize: 13),
          ),
          if ((widget.phase.reason ?? '').isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Plan: $displayPlanName',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFailedPhaseActions() {
    final phaseId = widget.phase.id;
    final actionsDisabled = widget.hasPhaseActionInProgress || phaseId == null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  color: Colors.redAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: Colors.redAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phase failed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose how you want to continue your quit journey.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Action required',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.redAccent.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              if (widget.onKeepPhase != null)
                _buildActionCard(
                  title: 'Keep Phase',
                  description: 'Preserve all missions and continue',
                  icon: Icons.layers_outlined,
                  color: const Color(0xFF10B981),
                  onTap: actionsDisabled ? null : widget.onKeepPhase,
                  isLoading: widget.keepLoading,
                ),
              if (widget.onRedoPhase != null)
                _buildActionCard(
                  title: 'Redo Phase',
                  description: 'Restart with a fresh anchor date',
                  icon: Icons.restart_alt,
                  color: const Color(0xFF0EA5E9),
                  onTap: actionsDisabled ? null : widget.onRedoPhase,
                  isLoading: widget.redoLoading,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    final effectiveBorderColor = isLoading
        ? Colors.grey.shade300
        : color.withOpacity(0.4);
    final titleColor = color;
    final descriptionColor = color.withOpacity(0.75);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 0.6 : 1,
        child: Container(
          width: 260,
          constraints: const BoxConstraints(minHeight: 130),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: effectiveBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 26),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: descriptionColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeptPhaseBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.theme.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.theme.primaryColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.done_all, color: widget.theme.primaryColor),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phase kept',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Continue with your saved progress. Actions are no longer needed.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseStatistics() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FFFE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.theme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: widget.theme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Phase Statistics',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.phase.avgCravingLevel != null)
                Expanded(
                  child: _buildSmallStat(
                    label: 'Avg Craving',
                    value: widget.phase.avgCravingLevel!.toStringAsFixed(1),
                    color: Colors.red,
                  ),
                ),
              if (widget.phase.avgCigarettes != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallStat(
                    label: 'Avg Cigs',
                    value: widget.phase.avgCigarettes!.toStringAsFixed(1),
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
          if (widget.phase.fmCigarettesTotal != null) ...[
            const SizedBox(height: 6),
            _buildSmallStat(
              label: 'Total Cigarettes',
              value: widget.phase.fmCigarettesTotal!.toStringAsFixed(0),
              color: Colors.deepOrange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseConditions() {
    final condition = widget.phase.condition!;
    final rules = condition.rules ?? [];
    final fmCigarettesTotal = widget.phase.fmCigarettesTotal ?? 0;
    final smokeAvgPerDay = _getSmokeAvgPerDay(
      widget.plan.formMetricDTO?.smokeAvgPerDay,
      fmCigarettesTotal,
      widget.phase.durationDay ?? 0,
    );
    final durationDay = widget.phase.durationDay ?? 0;

    double baselineTotal = fmCigarettesTotal;
    if (baselineTotal <= 0 && smokeAvgPerDay >= 0 && durationDay >= 0) {
      baselineTotal = (smokeAvgPerDay * durationDay).toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.theme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 16,
                color: widget.theme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Conditions to Pass',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (condition.logic != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: widget.theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Logic: ${condition.logic}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.primaryColor,
                ),
              ),
            ),
          if (baselineTotal > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: widget.theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Baseline total cigarettes: ${baselineTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.theme.primaryColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          ...rules
              .map<Widget>(
                (rule) => _buildPhaseRule(
                  rule,
                  fmCigarettesTotal: baselineTotal,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPhaseRule(
    PhaseRule rule, {
    int indent = 0,
    required double fmCigarettesTotal,
  }) {
    return Container(
      margin: EdgeInsets.only(left: indent * 12.0, bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rule.rules != null && rule.rules!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.alt_route, size: 12, color: widget.theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Logic: ${rule.logic ?? "AND"}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...rule.rules!
                .map<Widget>(
                  (nestedRule) => _buildPhaseRule(
                    nestedRule,
                    indent: indent + 1,
                    fmCigarettesTotal: fmCigarettesTotal,
                  ),
                )
                .toList(),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 12,
                  color: widget.theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatPhaseFieldName(rule.field),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatPhaseRuleCondition(
                          rule,
                          fmCigarettesTotal: fmCigarettesTotal,
                        ),
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
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

  String _formatPhaseFieldName(String? field) {
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

  String _formatPhaseRuleCondition(
    PhaseRule rule, {
    required double fmCigarettesTotal,
  }) {
    final operator = rule.operator ?? '';

    if (rule.formula != null) {
      final formula = rule.formula!;
      final base = (formula['base'] ?? '').toString();
      final percent = (formula['percent'] ?? 0) as num;
      final op = (formula['operator'] ?? '').toString();
      final percentLabel = (percent * 100).toStringAsFixed(
        percent * 100 % 1 == 0 ? 0 : 1,
      );

      if (base == 'fm_cigarettes_total') {
        if (fmCigarettesTotal > 0) {
          final computed = fmCigarettesTotal * percent;
          final computedRounded = computed.toStringAsFixed(1);
          return 'Must be $operator $computedRounded cigarettes\n($percentLabel% of your baseline: ${fmCigarettesTotal.toStringAsFixed(0)} cigarettes)';
        } else {
          return 'Must be $operator $percentLabel% of baseline total cigarettes';
        }
      }

      return 'Must be $operator $percentLabel% $op ${_formatFormulaBase(base)}';
    }

    final value = rule.value;
    if (value == null) {
      return 'Must be $operator value';
    }

    String displayValue = value.toString();
    if (rule.field == 'progress' && value is num) {
      displayValue = '${value.toString()}%';
    }

    return 'Must be $operator $displayValue';
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

  Widget _buildMissionsList(QuitDay day) {
    final missions = day.missions ?? [];
    if (missions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No missions for this day')),
      );
    }

    final isSelectedDayToday = _isToday(day.date);
    final isDayAvailableForCompletion = _isPastOrToday(day.date);
    final allMissionsCompleted = _areAllMissionsCompleted(missions);
    final showCongratulations = isSelectedDayToday && allMissionsCompleted;

    return Column(
      children: [
        if (showCongratulations)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.theme.primaryColor.withOpacity(0.12),
                  widget.theme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.theme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text('🎆', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('✨', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You have completed all missions for today!\nCome back tomorrow for new challenges.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ...missions.map((mission) {
          final missionId = mission.id ?? -1;
          final completed =
              mission.status == 'COMPLETED' ||
              widget.locallyCompletedMissionIds.contains(missionId);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green.withOpacity(0.05)
                  : widget.theme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: completed
                    ? Colors.green
                    : widget.theme.primaryColor.withOpacity(0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: completed ? Colors.green : widget.theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mission.name ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: completed ? Colors.green : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((mission.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      mission.description ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
                if (!completed &&
                    missionId != -1 &&
                    !widget.isReadOnly &&
                    !_isFailedStatus(widget.phase.status)) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isDayAvailableForCompletion && widget.phase.id != null
                          ? () => widget.onMissionCompleted(mission, widget.phase.id!)
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: isDayAvailableForCompletion
                            ? widget.theme.primaryColor
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isDayAvailableForCompletion
                            ? 'Complete Mission'
                            : 'Not Available Yet',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

