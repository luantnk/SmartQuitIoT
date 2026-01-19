import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../../../models/quit_phase.dart';
import '../../../models/request/create_new_quit_plan_request.dart';
import '../../../utils/phase_theme.dart';
import '../../widgets/mission_complete_dialog.dart';
import '../../widgets/common/full_screen_loader.dart';
import '../diary/diary_screen.dart';
import 'quit_plan_history_screen.dart';

class QuitPlanScreen extends ConsumerStatefulWidget {
  const QuitPlanScreen({super.key});

  @override
  ConsumerState<QuitPlanScreen> createState() => _QuitPlanScreenState();
}

class _QuitPlanScreenState extends ConsumerState<QuitPlanScreen>
    with TickerProviderStateMixin {
  int selectedDayIndex = 0;
  final Set<int> locallyCompletedMissionIds = <int>{};
  final Set<int> _notifiedNewPhases =
      <int>{}; // Track new phases that already showed notification
  List<QuitPhaseDetail>?
  _previousPhases; // Track previous phases to detect new ones
  late TabController _tabController;
  final List<TabController> _oldTabControllers = <TabController>[];
  bool _isDisposing = false;

  // Fixed 5 phases
  static const List<String> _fixedPhases = [
    'Preparation',
    'OnSet',
    'Peak Craving',
    'Subsiding',
    'Maintenance',
  ];

  void _showMissionCompleteDialog(QuitMissionItem mission, int phaseId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MissionCompleteDialog(
        phaseId: phaseId,
        phaseDetailMissionId: mission.id ?? 0,
        missionCode: mission.code ?? '',
        missionName: mission.name ?? '',
        missionDescription: mission.description ?? '',
        onCompleted: () {
          // Refresh the quit plan data after mission completion
          ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
          // Also add to local completed set for immediate UI update
          setState(() {
            locallyCompletedMissionIds.add(mission.id ?? 0);
          });
        },
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00D09E),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _handleKeepPhaseAction(
    QuitPhase plan,
    QuitPhaseDetail phase,
  ) async {
    final planId = plan.id;
    final phaseId = phase.id;
    if (planId == null || phaseId == null) {
      _showSnack('Missing phase information.', isError: true);
      return;
    }

    if (!mounted) return;
    FullScreenLoader.show(context, message: 'Keeping phase...');

    try {
      await ref
          .read(quitPlanViewModelApiProvider.notifier)
          .keepPhase(quitPlanId: planId, phaseId: phaseId);

      if (!mounted) return;
      FullScreenLoader.hide(context);

      _showSnack('Phase kept successfully.');

      // Reload quit plan data
      await ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    } catch (e) {
      if (!mounted) return;
      FullScreenLoader.hide(context);
      _showSnack('Keep phase failed: ${_errorMessage(e)}', isError: true);
    }
  }

  Future<void> _handleRedoPhaseAction(QuitPhaseDetail phase) async {
    final phaseId = phase.id;
    if (phaseId == null) {
      _showSnack('Missing phase information.', isError: true);
      return;
    }

    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Choose restart date',
    );

    if (selectedDate == null) {
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    if (!mounted) return;
    FullScreenLoader.show(context, message: 'Restarting phase...');

    try {
      await ref
          .read(quitPlanViewModelApiProvider.notifier)
          .redoPhase(phaseId: phaseId, anchorStart: formattedDate);

      if (!mounted) return;
      FullScreenLoader.hide(context);

      _showSnack('Phase restarted from $formattedDate.');

      // Reload quit plan data
      await ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    } catch (e) {
      if (!mounted) return;
      FullScreenLoader.hide(context);
      _showSnack('Redo phase failed: ${_errorMessage(e)}', isError: true);
    }
  }

  /// Check if there's a new phase created after a failed phase (redo scenario)
  bool _hasNewPhaseAfterFailed(
    QuitPhaseDetail failedPhase,
    List<QuitPhaseDetail> allPhases,
  ) {
    if (!_isFailedStatus(failedPhase.status)) return false;

    final failedPhaseName = failedPhase.name ?? '';
    final failedPhaseId = failedPhase.id;
    if (failedPhaseName.isEmpty || failedPhaseId == null) return false;

    // Find if there's a phase with the same name but different status (CREATED or IN_PROGRESS)
    // and created after the failed phase
    for (final phase in allPhases) {
      if (phase.id == failedPhaseId) continue; // Skip the failed phase itself
      if (phase.name != failedPhaseName) continue; // Must be same phase name

      // Check if it's a new phase (CREATED or IN_PROGRESS) that was created after the failed phase
      final isNewPhase =
          phase.status == 'CREATED' || phase.status == 'IN_PROGRESS';
      if (isNewPhase) {
        // Check if startDate is after failed phase's endDate (or created after)
        try {
          if (failedPhase.endDate != null && phase.startDate != null) {
            final failedEndDate = DateTime.parse(failedPhase.endDate!);
            final newStartDate = DateTime.parse(phase.startDate!);
            if (newStartDate.isAfter(failedEndDate) ||
                newStartDate.isAtSameMomentAs(failedEndDate)) {
              return true;
            }
          }
          // If dates are not available, check by createdAt
          if (failedPhase.createdAt != null && phase.createdAt != null) {
            final failedCreatedAt = DateTime.parse(failedPhase.createdAt!);
            final newCreatedAt = DateTime.parse(phase.createdAt!);
            if (newCreatedAt.isAfter(failedCreatedAt)) {
              return true;
            }
          }
        } catch (e) {
          // If date parsing fails, assume it's a new phase if status matches
          if (isNewPhase) return true;
        }
      }
    }
    return false;
  }

  /// Detect new phases and show notification
  void _detectAndNotifyNewPhases(List<QuitPhaseDetail> currentPhases) {
    if (_previousPhases == null) {
      _previousPhases = List.from(currentPhases);
      return;
    }

    // Find new phases that weren't in previous list
    final previousPhaseIds = _previousPhases!.map((p) => p.id).toSet();
    final newPhases = currentPhases.where((phase) {
      final phaseId = phase.id;
      if (phaseId == null) return false;
      if (previousPhaseIds.contains(phaseId)) return false;
      if (_notifiedNewPhases.contains(phaseId)) return false;
      // Only notify for CREATED or IN_PROGRESS phases
      return phase.status == 'CREATED' || phase.status == 'IN_PROGRESS';
    }).toList();

    // Check for phases that were redo (same name as failed phase)
    for (final phase in currentPhases) {
      if (_isFailedStatus(phase.status)) {
        if (_hasNewPhaseAfterFailed(phase, currentPhases)) {
          // Find the new phase
          final newPhase = currentPhases.firstWhere(
            (p) =>
                p.name == phase.name &&
                p.id != phase.id &&
                (p.status == 'CREATED' || p.status == 'IN_PROGRESS'),
            orElse: () => phase,
          );
          if (newPhase.id != null &&
              newPhase.id != phase.id &&
              !_notifiedNewPhases.contains(newPhase.id)) {
            _notifiedNewPhases.add(newPhase.id!);
          }
        }
      }
    }

    // Notify about completely new phases
    // for (final newPhase in newPhases) {
    //   final phaseId = newPhase.id;
    //   if (phaseId != null && !_notifiedNewPhases.contains(phaseId)) {
    //     _notifiedNewPhases.add(phaseId);
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (mounted) {
    //         _showSnack(
    //           '✨ New phase "${newPhase.name ?? 'Phase'}" has been created!',
    //         );
    //       }
    //     });
    //   }
    // }

    _previousPhases = List.from(currentPhases);
  }

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 5 tabs (fixed phases)
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    });
  }

  void _setTabControllerLength(int desiredLength) {
    final nextLength = desiredLength < 1 ? 1 : desiredLength;
    if (_tabController.length == nextLength) return;

    final oldController = _tabController;
    final safeIndex = oldController.index.clamp(0, nextLength - 1);
    _tabController = TabController(
      length: nextLength,
      vsync: this,
      initialIndex: safeIndex,
    );
    _oldTabControllers.add(oldController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposing) return;
      if (_oldTabControllers.remove(oldController)) {
        oldController.dispose();
      }
    });
  }

  @override
  void dispose() {
    _isDisposing = true;
    for (final c in _oldTabControllers) {
      c.dispose();
    }
    _oldTabControllers.clear();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quitPlanViewModelApiProvider);

    // Listen for quit plan refresh trigger
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print('🔄 [QuitPlanScreen] Refresh triggered - reloading quit plan...');
        ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
      }
    });

    // Detect new phases after redo and show notification
    state.when(
      data: (data) {
        if (data != null && data.phases != null) {
          _detectAndNotifyNewPhases(data.phases!);
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quit Plan'),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
            },
            tooltip: 'Refresh Quit Plan',
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuitPlanHistoryScreen(),
                ),
              );
            },
            tooltip: 'Quit Plan History',
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(quitPlanViewModelApiProvider.notifier)
                    .loadQuitPlan(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          // Check if quit plan is inactive - treat as if no quit plan exists
          // TODO: Temporarily allow viewing even when isActive is false
          if (data == null ||
              // data.active == false ||  // Temporarily disabled
              (data.phases?.isEmpty ?? true)) {
            return const Center(child: Text('No quit plan found'));
          }

          final phases = data.phases!;
          // Sort phases: redo phases appear right after their failed phase
          final sortedPhases = _sortPhases(phases);
          final planInsights = _buildPlanInsightsSection(data);

          assert(() {
            _mapPhasesToFixedPhases(sortedPhases);
            _hasRedoHistoryForPhaseName(sortedPhases, '');
            return true;
          }());

          final displayPhases = sortedPhases;
          final isCompleted = _isQuitPlanCompleted(data, displayPhases);

          _setTabControllerLength(displayPhases.length);

          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // Header content as sliver
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildHeader(data),
                      if (isCompleted) _buildCongratulationsBanner(data),
                      if (planInsights != null) planInsights,
                      // Header Card (Phase/Missions/Progress) - will have square bottom when TabBar docks
                      _buildStats(displayPhases, dockedToTabBar: true),
                    ],
                  ),
                ),

                // Sticky TabBar that docks below Header Card
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: const Color(0xFF00D09E),
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: const Color(0xFF00D09E),
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: displayPhases.map((phase) {
                          final phaseName = (phase.name ?? '').trim();
                          final themeKey = phaseName.isNotEmpty
                              ? phaseName
                              : 'Quit Plan';
                          final theme = resolvePhaseTheme(themeKey);

                          return Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  theme.icon,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  phaseName.isNotEmpty ? phaseName : 'Phase',
                                ),
                                if (phase.status != null) ...[
                                  const SizedBox(width: 6),
                                  if (phase.redo ?? false) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Redo',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isFailedStatus(phase.status)
                                          ? Colors.redAccent.withOpacity(0.15)
                                          : theme.primaryColor.withOpacity(
                                              0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatStatus(phase.status),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: _isFailedStatus(phase.status)
                                            ? Colors.redAccent
                                            : theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: displayPhases.map((phase) {
                final phaseName = (phase.name ?? '').trim();
                final themeKey = phaseName.isNotEmpty
                    ? phaseName
                    : (data.name ?? 'Quit Plan');
                final theme = resolvePhaseTheme(themeKey);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildPhaseDetails(data, phase, theme),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DiaryScreen()),
          );
        },
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white, // ✅ thêm dòng này
        icon: const Icon(Icons.book), // icon giờ sẽ tự trắng
        label: const Text('Diary'),
      ),
    );
  }

  Widget _buildHeader(QuitPhase data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smoke_free,
                  color: Color(0xFF00D09E),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name ?? 'Quit Plan',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'FTND Score: ${data.ftndScore ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (data.useNRT == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NRT',
                    style: TextStyle(
                      color: Color(0xFF00D09E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(data.startDate)} → ${_formatDate(data.endDate)}',

                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    List<QuitPhaseDetail> phases, {
    bool dockedToTabBar = false,
  }) {
    final totalMissions = phases.fold<int>(
      0,
      (sum, p) => sum + (p.totalMissions ?? 0),
    );
    final completedMissions = phases.fold<int>(
      0,
      (sum, p) => sum + (p.completedMissions ?? 0),
    );
    final progress = totalMissions > 0
        ? completedMissions / totalMissions
        : 0.0;

    return Container(
      margin: dockedToTabBar
          ? const EdgeInsets.only(left: 16, right: 16, top: 16)
          : const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: dockedToTabBar
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              )
            : BorderRadius.circular(16),
        boxShadow: dockedToTabBar
            ? [] // Remove shadow when docked, TabBar will have shadow
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Phases',
                '${phases.length}',
                Icons.flag,
                const Color(0xFF3B82F6),
              ),
              _buildStatItem(
                'Missions',
                '$completedMissions/$totalMissions',
                Icons.task_alt,
                const Color(0xFF10B981),
              ),
              _buildStatItem(
                'Progress',
                '${(progress * 100).toInt()}%',
                Icons.trending_up,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00D09E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildPlanInsightsSection(QuitPhase plan) {
    final formMetric = plan.formMetric;
    final currentMetric = plan.currentMetric;
    final hasLifestyleInfo =
        (formMetric?.interests.isNotEmpty ?? false) ||
        (formMetric?.triggered.isNotEmpty ?? false);

    if (formMetric == null && currentMetric == null && !hasLifestyleInfo) {
      return null;
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

  Widget _buildBaselineMetricsCard(QuitPlanFormMetric metrics) {
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
            value: metrics.smokeAvgPerDay?.toString() ?? 'N/A',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.calendar_month,
            label: 'Years of smoking',
            value: metrics.numberOfYearsOfSmoking?.toString() ?? 'N/A',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.timer,
            label: 'Minutes to first cigarette',
            value: metrics.minutesAfterWakingToSmoke != null
                ? '${metrics.minutesAfterWakingToSmoke} mins'
                : 'N/A',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.inventory_2_outlined,
            label: 'Cigarettes per pack',
            value: metrics.cigarettesPerPackage?.toString() ?? 'N/A',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.science,
            label: 'Nicotine per cig',
            value: metrics.amountOfNicotinePerCigarettes != null
                ? '${metrics.amountOfNicotinePerCigarettes!.toStringAsFixed(2)} mg'
                : 'N/A',
            iconColor: const Color(0xFF2563EB),
          ),
          _buildMetricLine(
            icon: Icons.bolt,
            label: 'Estimated nicotine per day',
            value: metrics.estimatedNicotineIntakePerDay != null
                ? '${metrics.estimatedNicotineIntakePerDay!.toStringAsFixed(2)} mg'
                : 'N/A',
            iconColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitAndFinanceCard(QuitPlanFormMetric metrics) {
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

  Widget _buildLifestyleChipsCard(QuitPlanFormMetric metrics) {
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

  Widget _buildCurrentMetricCard(QuitPlanCurrentMetric metrics) {
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
          if (metrics.avgCigarettesPerDay != null)
            _buildMetricLine(
              icon: Icons.smoke_free,
              label: 'Avg cigarettes per day (current)',
              value: metrics.avgCigarettesPerDay!.toStringAsFixed(1),
              iconColor: const Color(0xFF0EA5E9),
            ),
          const SizedBox(height: 12),
          if (metrics.avgCravingLevel != null)
            _buildMetricProgressRow(
              label: 'Craving level',
              value: metrics.avgCravingLevel!,
              color: Colors.redAccent,
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
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF00D09E),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
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
      border: Border.all(color: const Color(0xFFE2E8F0)),
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

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Removed _buildPhasesList - replaced with TabBar interface

  Widget _buildPhaseDetails(
    QuitPhase plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final days = phase.details ?? [];
    final snapshot = phase.snapshotMetric;
    final avgCraving = phase.avgCravingLevel ?? snapshot?.avgCravingLevel;
    final avgCigarettes = phase.avgCigarettes ?? snapshot?.avgCigarettesPerDay;
    final avgMood = phase.avgMood ?? snapshot?.avgMood;
    final avgAnxiety = phase.avgAnxiety ?? snapshot?.avgAnxiety;
    final avgConfidence =
        phase.avgConfidentLevel ?? snapshot?.avgConfidentLevel;
    final snapshotProgress = snapshot?.progress;
    final hasStatSection = [
      avgCraving,
      avgCigarettes,
      avgMood,
      avgAnxiety,
      avgConfidence,
      phase.fmCigarettesTotal,
      snapshotProgress,
    ].any((value) => value != null);

    final shouldShowStats = hasStatSection && phase.status == 'COMPLETED';

    // Calculate progress
    final totalMissions = phase.totalMissions ?? 0;
    final completedMissions = phase.completedMissions ?? 0;
    final phaseProgress = (totalMissions > 0)
        ? (completedMissions / totalMissions)
        : 0.0;
    final phasePercent = (phaseProgress * 100).toInt();
    final shouldShowKeptBanner =
        _isFailedStatus(phase.status) && (phase.keepPhase ?? false);
    final shouldShowRedoBadge = (phase.redo ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phase Header Card
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.primaryColor.withOpacity(0.18),
              width: 1,
            ),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        theme.icon,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.name ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(phase.startDate)} → ${_formatDate(phase.endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (shouldShowRedoBadge) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Redo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isFailedStatus(phase.status)
                                  ? Colors.redAccent.withOpacity(0.15)
                                  : theme.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatStatus(phase.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isFailedStatus(phase.status)
                                    ? Colors.redAccent
                                    : theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildPhaseInfoChips(phase, theme),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: phaseProgress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$phasePercent% completed',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (shouldShowRedoBadge) ...[
          const SizedBox(height: 12),
          _buildRedoPhaseBanner(),
        ],

        // Kept Phase Banner
        if (shouldShowKeptBanner) ...[
          const SizedBox(height: 12),
          _buildKeptPhaseBanner(theme),
        ],

        // Failed Phase Actions
        if (_isFailedStatus(phase.status) &&
            !(phase.keepPhase ?? false) &&
            !(phase.redo ?? false)) ...[
          const SizedBox(height: 12),
          _buildFailedPhaseActions(plan, phase, theme),
        ],

        // Phase Details Content
        const SizedBox(height: 12),
        if ((phase.reason ?? '').isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.primaryColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phase.reason ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (shouldShowStats) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Phase Statistics',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (avgCraving != null)
                      Expanded(
                        child: _buildSmallStat(
                          label: 'Avg Craving',
                          value: avgCraving.toStringAsFixed(1),
                          color: Colors.red,
                        ),
                      ),
                    if (avgCigarettes != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallStat(
                          label: 'Avg Cigs',
                          value: avgCigarettes.toStringAsFixed(1),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
                if (snapshotProgress != null) ...[
                  const SizedBox(height: 6),
                  _buildSmallStat(
                    label: 'Phase Progress',
                    value: '${snapshotProgress.toStringAsFixed(0)}%',
                    color: theme.primaryColor,
                  ),
                ],
                if (avgMood != null ||
                    avgAnxiety != null ||
                    avgConfidence != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (avgMood != null)
                        Expanded(
                          child: _buildSmallStat(
                            label: 'Mood',
                            value: avgMood.toStringAsFixed(1),
                            color: const Color(0xFF0EA5E9),
                          ),
                        ),
                      if (avgAnxiety != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSmallStat(
                            label: 'Anxiety',
                            value: avgAnxiety.toStringAsFixed(1),
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                      if (avgConfidence != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSmallStat(
                            label: 'Confidence',
                            value: avgConfidence.toStringAsFixed(1),
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (phase.fmCigarettesTotal != null) ...[
                  const SizedBox(height: 6),
                  _buildSmallStat(
                    label: 'Total Cigarettes',
                    value: phase.fmCigarettesTotal!.toStringAsFixed(0),
                    color: Colors.deepOrange,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (phase.condition != null &&
            (phase.condition!.rules?.isNotEmpty ?? false)) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Conditions to Pass',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPhaseConditions(
                  phase.condition!,
                  theme,
                  phase.fmCigarettesTotal ?? 0,
                  phase.durationDay ?? 0,
                  // Try to get smokeAvgPerDay from formMetricDTO if available
                  _calculateSmokeAvgPerDay(
                    phase.fmCigarettesTotal ?? 0,
                    phase.durationDay ?? 0,
                  ),
                  currentAvgMood: (avgMood != null && avgMood > 0)
                      ? avgMood
                      : plan.currentMetric?.avgMood,
                  currentAvgCigarettesPerDay:
                      (avgCigarettes != null && avgCigarettes > 0)
                      ? avgCigarettes
                      : plan.currentMetric?.avgCigarettesPerDay,
                  currentProgress: snapshotProgress ?? (phaseProgress * 100),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
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
          const Text(
            'Days:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70, // tăng chút để vừa chữ day + date
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, dayIdx) {
                final day = days[dayIdx];
                final isSelected = selectedDayIndex == dayIdx;
                final missions = day.missions ?? [];
                final completed = missions
                    .where(
                      (m) =>
                          m.status == 'COMPLETED' ||
                          locallyCompletedMissionIds.contains(m.id),
                    )
                    .length;

                return GestureDetector(
                  onTap: () => setState(() => selectedDayIndex = dayIdx),
                  child: Container(
                    width: 80, // tăng chút rộng để ngày không bị ép
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
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
                            color: isSelected ? Colors.white : Colors.grey[700],
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
                                : theme.primaryColor,
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
          if (selectedDayIndex < days.length)
            _buildMissionsList(days[selectedDayIndex], theme, phase),
        ],
      ],
    );
  }

  /// Check if a given date is today
  bool _isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
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
    } catch (e) {
      return false;
    }
  }

  /// Check if all missions for a day are completed
  bool _areAllMissionsCompleted(List<QuitMissionItem> missions) {
    if (missions.isEmpty) return false;
    return missions.every((mission) {
      final missionId = mission.id ?? -1;
      return mission.status == 'COMPLETED' ||
          locallyCompletedMissionIds.contains(missionId);
    });
  }

  Widget _buildMissionsList(
    QuitDay day,
    PhaseTheme theme,
    QuitPhaseDetail phase,
  ) {
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
    final isRedoPhase = phase.redo == true;

    // ✅ Logic mới: Kiểm tra xem Phase đã hoàn thành chưa
    final isPhaseCompleted = phase.status == 'COMPLETED';

    return Column(
      children: [
        if (showCongratulations)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.12),
                  theme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
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
                    color: theme.primaryColor,
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
              locallyCompletedMissionIds.contains(missionId);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green.withOpacity(0.05)
                  : theme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: completed
                    ? Colors.green
                    : theme.primaryColor.withOpacity(0.4),
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
                      color: completed ? Colors.green : theme.primaryColor,
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

                // ✅ Đã cập nhật điều kiện ở đây:
                // Thêm: && !isPhaseCompleted
                if (!completed &&
                    missionId != -1 &&
                    !isRedoPhase &&
                    !isPhaseCompleted) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isDayAvailableForCompletion && phase.id != null
                          ? () => _showMissionCompleteDialog(mission, phase.id!)
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: isDayAvailableForCompletion
                            ? theme.primaryColor
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

  Widget _buildPhaseConditions(
    PhaseCondition condition,
    PhaseTheme theme,
    double fmCigarettesTotal,
    int durationDay,
    int smokeAvgPerDay, {
    double? currentAvgMood,
    double? currentAvgCigarettesPerDay,
    double? currentProgress,
  }) {
    final rules = condition.rules ?? [];

    // Calculate baseline total: use fmCigarettesTotal if available, otherwise calculate from smokeAvgPerDay * durationDay
    double baselineTotal = fmCigarettesTotal;
    if (baselineTotal <= 0 && smokeAvgPerDay >= 0 && durationDay >= 0) {
      baselineTotal = (smokeAvgPerDay * durationDay).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (condition.logic != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Logic: ${condition.logic}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
        if (baselineTotal > 0)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Baseline: ${baselineTotal.toStringAsFixed(0)} cigarettes',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
        const SizedBox(height: 6),
        ...rules
            .map<Widget>(
              (rule) => _buildPhaseRule(
                rule,
                theme,
                fmCigarettesTotal: baselineTotal,
                smokeAvgPerDay: smokeAvgPerDay,
                durationDay: durationDay,
                currentAvgMood: currentAvgMood,
                currentAvgCigarettesPerDay: currentAvgCigarettesPerDay,
                currentProgress: currentProgress,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildPhaseRule(
    PhaseRule rule,
    PhaseTheme theme, {
    int indent = 0,
    required double fmCigarettesTotal,
    required int smokeAvgPerDay,
    required int durationDay,
    double? currentAvgMood,
    double? currentAvgCigarettesPerDay,
    double? currentProgress,
  }) {
    final currentValue = _getCurrentValueForPhaseRuleField(
      rule.field,
      currentAvgMood: currentAvgMood,
      currentAvgCigarettesPerDay: currentAvgCigarettesPerDay,
      currentProgress: currentProgress,
    );

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
                Icon(Icons.alt_route, size: 12, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Logic: ${rule.logic ?? "AND"}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...rule.rules!
                .map<Widget>(
                  (nestedRule) => _buildPhaseRule(
                    nestedRule,
                    theme,
                    indent: indent + 1,
                    fmCigarettesTotal: fmCigarettesTotal,
                    smokeAvgPerDay: smokeAvgPerDay,
                    durationDay: durationDay,
                    currentAvgMood: currentAvgMood,
                    currentAvgCigarettesPerDay: currentAvgCigarettesPerDay,
                    currentProgress: currentProgress,
                  ),
                )
                .toList(),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 12,
                  color: theme.primaryColor,
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
                          smokeAvgPerDay: smokeAvgPerDay,
                          durationDay: durationDay,
                          currentValue: currentValue,
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

  double? _getCurrentValueForPhaseRuleField(
    String? field, {
    double? currentAvgMood,
    double? currentAvgCigarettesPerDay,
    double? currentProgress,
  }) {
    final normalized = (field ?? '').toLowerCase();
    if (normalized == 'progress') return currentProgress;

    if (normalized.contains('mood')) return currentAvgMood;
    if (normalized.contains('cigarettes')) return currentAvgCigarettesPerDay;

    return null;
  }

  String _formatCurrentRuleValue(String? field, double value) {
    final normalized = (field ?? '').toLowerCase();

    if (normalized == 'progress') {
      return 'Current: ${value.toStringAsFixed(1)}%';
    }
    if (normalized.contains('mood')) {
      return 'Current: ${value.toStringAsFixed(1)}/10';
    }
    if (normalized.contains('cigarettes')) {
      return 'Current: ${value.toStringAsFixed(1)} cig/day';
    }

    return 'Current: ${value.toStringAsFixed(1)}';
  }

  Widget _buildPhaseInfoChips(QuitPhaseDetail phase, PhaseTheme theme) {
    final chips = <Widget>[];

    if (phase.createdAt != null && phase.createdAt!.isNotEmpty) {
      chips.add(
        _buildInfoChip(
          icon: Icons.event,
          label: 'Created',
          value: _formatDateTime(phase.createdAt),
          theme: theme,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 10, runSpacing: 10, children: chips);
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required PhaseTheme theme,
    Color? valueColor,
  }) {
    final effectiveColor = valueColor ?? theme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: effectiveColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFailedPhaseActions(
    QuitPhase plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Phase Failed - Choose an action',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFailedActionButton(
            title: 'Keep Phase',
            description: 'Preserve all missions and continue',
            icon: Icons.layers_outlined,
            color: const Color(0xFF10B981),
            onTap: () => _handleKeepPhaseAction(plan, phase),
          ),
          const SizedBox(height: 8),
          _buildFailedActionButton(
            title: 'Redo Phase',
            description: 'Restart this phase with a fresh date',
            icon: Icons.restart_alt,
            color: const Color(0xFF0EA5E9),
            onTap: () => _handleRedoPhaseAction(phase),
          ),
          const SizedBox(height: 8),
          _buildFailedActionButton(
            title: 'Create New Quit Plan',
            description: 'Start a brand new quit journey',
            icon: Icons.auto_awesome,
            color: const Color(0xFF8B5CF6),
            onTap: () => _handleCreateNewPlan(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedActionButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateNewPlan(PhaseTheme theme) async {
    await _showCreateNewPlanDialog(theme);
  }

  Widget _buildKeptPhaseBanner(PhaseTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.done_all, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

  Widget _buildRedoPhaseBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08), // Màu nền vàng nhạt
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.4)), // Viền vàng
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.refresh_rounded, color: Colors.amber[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phase Redone',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber[900], // Màu chữ đậm
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have chosen to redo this phase.', // Nội dung bạn yêu cầu
                  style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateNewPlanDialog(PhaseTheme theme) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    bool useNRT = false;
    DateTime? selectedDate;
    bool isCreating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectDate() async {
              if (isCreating) return; // Prevent date selection when creating

              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(now.year, now.month, now.day),
                lastDate: now.add(const Duration(days: 365)),
                helpText: 'Select Start Date',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00D09E),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                setDialogState(() {
                  selectedDate = pickedDate;
                  dateController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(pickedDate);
                });
              }
            }

            Future<void> handleCreate() async {
              if (isCreating) return; // Prevent multiple submissions

              if (!formKey.currentState!.validate()) {
                return;
              }

              if (selectedDate == null) {
                _showSnack('Please select a start date', isError: true);
                return;
              }

              // Set creating state to true
              setDialogState(() {
                isCreating = true;
              });

              try {
                final request = CreateNewQuitPlanRequest(
                  startDate: dateController.text,
                  useNRT: useNRT,
                  quitPlanName: nameController.text.trim(),
                );

                await ref
                    .read(quitPlanViewModelProvider.notifier)
                    .createNewPlan(request);

                // Check if widget is still mounted
                if (!mounted) return;

                // Close dialog after successful creation
                Navigator.of(dialogContext).pop();

                // Wait a bit for dialog to close
                await Future.delayed(const Duration(milliseconds: 200));

                // Refresh quit plan data
                if (mounted) {
                  await ref
                      .read(quitPlanViewModelApiProvider.notifier)
                      .loadQuitPlan();
                  if (mounted) {
                    _showSnack('New quit plan created successfully! ');
                  }
                }
              } catch (e) {
                // Reset creating state on error
                setDialogState(() {
                  isCreating = false;
                });

                if (mounted) {
                  _showSnack(
                    'Failed to create new plan: ${_errorMessage(e)}',
                    isError: true,
                  );
                }
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Create New Quit Plan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: isCreating
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Plan Name Field
                        TextFormField(
                          controller: nameController,
                          enabled: !isCreating,
                          decoration: InputDecoration(
                            labelText: 'Quit Plan Name',
                            hintText: 'Enter quit plan name',
                            prefixIcon: Icon(
                              Icons.label_outline,
                              color: theme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quit plan name';
                            }
                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Start Date Field
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          enabled: !isCreating,
                          onTap: isCreating ? null : selectDate,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            hintText: 'Select start date',
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: theme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select start date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Use NRT Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Use NRT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Nicotine Replacement Therapy',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: useNRT,
                                onChanged: isCreating
                                    ? null
                                    : (value) {
                                        setDialogState(() {
                                          useNRT = value;
                                        });
                                      },
                                activeColor: theme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isCreating
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isCreating ? null : handleCreate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isCreating
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Create',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    dateController.dispose();
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
    required int smokeAvgPerDay,
    required int durationDay,
    double? currentValue,
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
        // For avg cigarettes rules, showing a per-day target is clearer than total cigarettes.
        final hasBaselinePerDay = smokeAvgPerDay > 0;
        final hasDuration = durationDay > 0;

        if (hasBaselinePerDay) {
          final baselinePerDay = smokeAvgPerDay.toDouble();
          final targetPerDay = baselinePerDay * percent;
          final targetPerDayRounded = targetPerDay.toStringAsFixed(1);
          final baselinePerDayRounded = baselinePerDay.toStringAsFixed(0);

          var result =
              'Target: $operator $targetPerDayRounded cig/day\n($percentLabel% of your baseline: $baselinePerDayRounded cig/day)';

          if (hasDuration) {
            final targetTotal = targetPerDay * durationDay;
            result =
                '$result\nOver $durationDay days: $operator ${targetTotal.toStringAsFixed(1)} cigarettes';
          } else if (fmCigarettesTotal > 0) {
            // Fallback: if we only know baseline total, still show it.
            final computed = fmCigarettesTotal * percent;
            result =
                '$result\nBaseline total: ${fmCigarettesTotal.toStringAsFixed(0)} cigarettes → Target: ${computed.toStringAsFixed(1)} cigarettes';
          }

          if (currentValue != null) {
            result =
                '$result\n${_formatCurrentRuleValue(rule.field, currentValue)}';
          }
          return result;
        }

        // If we don't have baseline per-day, fall back to total baseline.
        if (fmCigarettesTotal > 0) {
          final computed = fmCigarettesTotal * percent;
          final computedRounded = computed.toStringAsFixed(1);
          var result =
              'Target: $operator $computedRounded cigarettes\n($percentLabel% of your baseline total: ${fmCigarettesTotal.toStringAsFixed(0)} cigarettes)';
          if (hasDuration) {
            final perDay = computed / durationDay;
            result =
                '$result\nApprox per day: $operator ${perDay.toStringAsFixed(1)} cig/day';
          }
          if (currentValue != null) {
            result =
                '$result\n${_formatCurrentRuleValue(rule.field, currentValue)}';
          }
          return result;
        }

        var result = 'Target: $operator $percentLabel% of baseline cigarettes';
        if (currentValue != null) {
          result =
              '$result\n${_formatCurrentRuleValue(rule.field, currentValue)}';
        }
        return result;
      }

      var result =
          'Must be $operator $percentLabel% $op ${_formatFormulaBase(base)}';
      if (currentValue != null) {
        result =
            '$result\n${_formatCurrentRuleValue(rule.field, currentValue)}';
      }
      return result;
    }

    final value = rule.value;
    if (value == null) {
      return 'Must be $operator value';
    }

    String displayValue = value.toString();
    if (rule.field == 'progress' && value is num) {
      displayValue = '${value.toString()}%';
    }

    var result = 'Must be $operator $displayValue';
    if (currentValue != null) {
      result = '$result\n${_formatCurrentRuleValue(rule.field, currentValue)}';
    }
    return result;
  }

  String _formatBoolLabel(bool? value) {
    return value == true ? 'Yes' : 'No';
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return 'N/A';
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    final normalized = status.replaceAll('_', ' ').toLowerCase();
    return normalized
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  bool _hasRedoHistoryForPhaseName(
    List<QuitPhaseDetail> phases,
    String phaseName,
  ) {
    final normalizedTarget = phaseName.trim().toLowerCase();
    if (normalizedTarget.isEmpty) return false;
    return phases.any((p) {
      final normalizedName = (p.name ?? '').trim().toLowerCase();
      final matches =
          normalizedName == normalizedTarget ||
          normalizedName.contains(normalizedTarget) ||
          normalizedTarget.contains(normalizedName);
      return matches && (p.redo ?? false);
    });
  }

  int _phaseRecencyCompare(QuitPhaseDetail a, QuitPhaseDetail b) {
    final aStart = _tryParseDateTime(a.startDate);
    final bStart = _tryParseDateTime(b.startDate);
    if (aStart != null || bStart != null) {
      if (aStart == null) return -1;
      if (bStart == null) return 1;
      final cmp = aStart.compareTo(bStart);
      if (cmp != 0) return cmp;
    }

    final aCreated = _tryParseDateTime(a.createdAt);
    final bCreated = _tryParseDateTime(b.createdAt);
    if (aCreated != null || bCreated != null) {
      if (aCreated == null) return -1;
      if (bCreated == null) return 1;
      final cmp = aCreated.compareTo(bCreated);
      if (cmp != 0) return cmp;
    }

    final aId = a.id ?? -1;
    final bId = b.id ?? -1;
    return aId.compareTo(bId);
  }

  bool _isNewerPhase(QuitPhaseDetail candidate, QuitPhaseDetail? existing) {
    if (existing == null) return true;
    final cmp = _phaseRecencyCompare(candidate, existing);
    if (cmp > 0) return true;
    if (cmp < 0) return false;

    final candidateRedo = candidate.redo ?? false;
    final existingRedo = existing.redo ?? false;
    if (existingRedo && !candidateRedo) return true;
    return false;
  }

  /// Maps fixed phase names to actual phase data from API
  /// Returns a map where keys are fixed phase names and values are QuitPhaseDetail or null
  Map<String, QuitPhaseDetail?> _mapPhasesToFixedPhases(
    List<QuitPhaseDetail> sortedPhases,
  ) {
    final Map<String, QuitPhaseDetail?> phaseMap = {};

    // Initialize all fixed phases as null
    for (final fixedPhase in _fixedPhases) {
      phaseMap[fixedPhase] = null;
    }

    // Map actual phases to fixed phases by matching phase names
    for (final phase in sortedPhases) {
      final phaseName = (phase.name ?? '').trim();
      if (phaseName.isEmpty) continue;

      String? matchedKey;
      if (phaseMap.containsKey(phaseName)) {
        matchedKey = phaseName;
      } else {
        final normalizedPhaseName = phaseName.toLowerCase();
        for (final fixedPhase in _fixedPhases) {
          if (normalizedPhaseName == fixedPhase.toLowerCase()) {
            matchedKey = fixedPhase;
            break;
          }
        }
        matchedKey ??= () {
          for (final fixedPhase in _fixedPhases) {
            final normalizedFixed = fixedPhase.toLowerCase();
            if (normalizedPhaseName.contains(normalizedFixed) ||
                normalizedFixed.contains(normalizedPhaseName)) {
              return fixedPhase;
            }
          }
          return null;
        }();
      }

      if (matchedKey == null) continue;
      if (_isNewerPhase(phase, phaseMap[matchedKey])) {
        phaseMap[matchedKey] = phase;
      }
    }

    return phaseMap;
  }

  bool _isFailedStatus(String? status) =>
      status != null && status.toUpperCase() == 'FAILED';

  /// Check if quit plan is completed
  bool _isQuitPlanCompleted(QuitPhase plan, List<QuitPhaseDetail> phases) {
    // Check if plan status is COMPLETED
    if (plan.status != null && plan.status!.toUpperCase() == 'COMPLETED') {
      return true;
    }

    // Check if all phases are completed, especially the last Maintenance phase
    if (phases.isEmpty) return false;

    // Check if the last phase is Maintenance and completed
    final lastPhase = phases.last;
    final isLastPhaseMaintenance = (lastPhase.name ?? '')
        .toLowerCase()
        .contains('maintenance');
    final isLastPhaseCompleted =
        lastPhase.status != null &&
        lastPhase.status!.toUpperCase() == 'COMPLETED';

    if (isLastPhaseMaintenance && isLastPhaseCompleted) {
      return true;
    }

    // Also check if all phases are completed
    final allPhasesCompleted = phases.every(
      (phase) =>
          phase.status != null && phase.status!.toUpperCase() == 'COMPLETED',
    );

    return allPhasesCompleted;
  }

  /// Build congratulations banner when quit plan is completed
  Widget _buildCongratulationsBanner(QuitPhase plan) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00B894)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.4),
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
              Text('', style: TextStyle(fontSize: 32)),
              SizedBox(width: 8),
              Text('🎆', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('✨', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have successfully completed your quit plan!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.name ?? 'Quit Plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'You are now smoke-free! Keep up the amazing work! 💪',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return dateTime;
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  /// Calculate smokeAvgPerDay from fmCigarettesTotal and durationDay
  int _calculateSmokeAvgPerDay(double fmCigarettesTotal, int durationDay) {
    if (durationDay > 0 && fmCigarettesTotal > 0) {
      return (fmCigarettesTotal / durationDay).round();
    }
    return 0;
  }

  /// Sort phases so that redo phases appear right after their failed phase
  /// Primary sort: by startDate
  /// Secondary: if phase failed has a redo phase, place redo phase immediately after
  List<QuitPhaseDetail> _sortPhases(List<QuitPhaseDetail> phases) {
    if (phases.isEmpty) return phases;

    // Create a copy to avoid modifying original list
    final sorted = List<QuitPhaseDetail>.from(phases);

    sorted.sort((a, b) {
      final aDate = _tryParseDateTime(a.startDate);
      final bDate = _tryParseDateTime(b.startDate);

      if (aDate != null || bDate != null) {
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        final cmp = aDate.compareTo(bDate);
        if (cmp != 0) return cmp;
      }

      final aId = a.id ?? -1;
      final bId = b.id ?? -1;
      return aId.compareTo(bId);
    });

    return sorted;
  }
}

// Delegate for sticky TabBar that docks below Header Card
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 56.0; // Minimum height of TabBar (with padding)

  @override
  double get maxExtent => 56.0; // Maximum height of TabBar (with padding)

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
