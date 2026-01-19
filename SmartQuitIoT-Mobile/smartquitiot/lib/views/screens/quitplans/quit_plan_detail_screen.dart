import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/quit_phase.dart';
import '../../../models/quit_plan_detail.dart';
import '../../../models/request/create_new_quit_plan_request.dart';
import '../../../models/request/update_form_metric_request.dart';
import '../../../models/response/form_metric_response.dart'
    as form_metric_response;
import '../../../providers/mission_refresh_provider.dart';
import '../../../providers/quit_plan_detail_provider.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../utils/phase_theme.dart';
import '../../../viewmodels/form_metric_view_model.dart';
import '../../widgets/mission_complete_dialog.dart';
import '../form_metric/_create_form_metric_dialog.dart';
import 'widgets/quit_plan_header.dart';
import 'widgets/quit_plan_insights.dart';
import 'widgets/phase_detail_view.dart';

class QuitPlanDetailScreen extends ConsumerStatefulWidget {
  final int quitPlanId;
  final bool isReadOnly;

  const QuitPlanDetailScreen({
    super.key,
    required this.quitPlanId,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<QuitPlanDetailScreen> createState() =>
      _QuitPlanDetailScreenState();
}

class _QuitPlanDetailScreenState extends ConsumerState<QuitPlanDetailScreen>
    with TickerProviderStateMixin {
  int selectedDayIndex = 0;
  final Set<int> locallyCompletedMissionIds = <int>{};
  int? _phaseActionInProgressId;
  String? _phaseActionInProgressType;
  late TabController _tabController;
  final List<TabController> _oldTabControllers = <TabController>[];
  bool _isDisposing = false;

  static const String _phaseActionKeepKey = 'keep';
  static const String _phaseActionRedoKey = 'redo';

  // Fixed 5 phases
  static const List<String> _fixedPhases = [
    'Preparation',
    'OnSet',
    'Peak Craving',
    'Subsiding',
    'Maintenance',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 5 tabs (fixed phases)
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(quitPlanDetailViewModelProvider.notifier)
          .loadQuitPlanDetail(widget.quitPlanId);
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

  void _showMissionCompleteDialog(QuitMissionItem mission, int phaseId) {
    // Don't show dialog in read-only mode
    if (widget.isReadOnly) return;

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
          ref
              .read(quitPlanDetailViewModelProvider.notifier)
              .loadQuitPlanDetail(widget.quitPlanId);
          ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
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

  void _setPhaseActionLoading(int? phaseId, String? actionKey) {
    if (!mounted) return;
    setState(() {
      _phaseActionInProgressId = phaseId;
      _phaseActionInProgressType = actionKey;
    });
  }

  bool _isPhaseActionLoading(int? phaseId, String actionKey) {
    return _phaseActionInProgressId == phaseId &&
        _phaseActionInProgressType == actionKey;
  }

  Widget _buildPhaseDetails(
    QuitPlanDetail plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final days = phase.details ?? [];

    // Tính toán tiến độ
    final totalMissions = phase.totalMissions ?? 0;
    final completedMissions = phase.completedMissions ?? 0;
    final phaseProgress = (totalMissions > 0)
        ? (completedMissions / totalMissions)
        : 0.0;
    final phasePercent = (phaseProgress * 100).toInt();

    final shouldShowKeptBanner =
        _isFailedStatus(phase.status) && (phase.keepPhase ?? false);
    final shouldShowRedoBadge = (phase.redo ?? false);

    // Lấy thông tin cho conditions
    final formMetric = plan
        .formMetricDTO; // Lưu ý: check model của bạn là formMetric hay formMetricDTO
    final smokeAvg = formMetric?.smokeAvgPerDay ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Phase Header Card
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
                      // Status Badge
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
                  const SizedBox(height: 10),
                  _buildPhaseInfoChips(phase, theme),
                  const SizedBox(height: 8),
                  // Progress Bar
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$phasePercent% completed',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. ✨ Redo Banner (CẬP NHẬT: Thêm vào đây)
          if (shouldShowRedoBadge) ...[
            const SizedBox(height: 12),
            _buildRedoPhaseBanner(),
          ],

          // 3. Kept Phase Banner
          if (shouldShowKeptBanner) ...[
            const SizedBox(height: 12),
            _buildKeptPhaseBanner(theme),
          ],

          // 4. Failed Actions
          if (_isFailedStatus(phase.status) &&
              !(phase.keepPhase ?? false) &&
              !(phase.redo ?? false)) ...[
            const SizedBox(height: 12),
            _buildFailedPhaseActionsInline(plan, phase, theme),
          ],

          // 5. Reason Text
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

          // ❌ 6. Stats Section -> ĐÃ BỊ XÓA THEO YÊU CẦU

          // 7. Conditions
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
                    smokeAvg, // Dùng biến lấy từ formMetricDTO ở trên
                    phase.durationDay ?? 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 8. Missions List (Sử dụng lại logic của bạn nhưng cần copy hàm _buildMissionsList từ Screen kia qua hoặc viết lại nhẹ)
          // Ở đây tôi giả định bạn sẽ dùng logic hiển thị list ngày như cũ.
          // Nếu bạn chưa copy hàm _buildMissionsList từ QuitPlanScreen qua đây, hãy copy nó qua.
          // Tạm thời tôi dùng logic hiển thị đơn giản cho Day List để code chạy được:
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
            // ... (Copy logic ListView Day selector từ QuitPlanScreen qua đây) ...
            SizedBox(
              height: 70,
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
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
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
                          Text(
                            _formatDate(day.date),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$completed/${missions.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
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
            // Hiển thị missions của ngày đang chọn
            if (selectedDayIndex < days.length)
              // Lưu ý: Bạn cần copy hàm _buildMissionsList từ file QuitPlanScreen.dart sang file này
              _buildMissionsList(days[selectedDayIndex], theme, phase),
          ],
        ],
      ),
    );
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
                if (!widget.isReadOnly &&
                    !completed &&
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

  bool _areAllMissionsCompleted(List<QuitMissionItem> missions) {
    if (missions.isEmpty) return false;
    return missions.every((mission) {
      final missionId = mission.id ?? -1;
      return mission.status == 'COMPLETED' ||
          locallyCompletedMissionIds.contains(missionId);
    });
  }

  bool get _hasPhaseActionInProgress =>
      _phaseActionInProgressId != null && _phaseActionInProgressType != null;

  Future<T> _withBlockingLoader<T>(
    Future<T> Function() task, {
    String message = 'Processing...',
  }) async {
    if (!mounted) {
      return await task();
    }

    bool overlayOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: _BlockingLoader(message: message),
      ),
    ).whenComplete(() {
      overlayOpen = false;
    });

    try {
      return await task();
    } finally {
      if (overlayOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _handleKeepPhaseAction(
    QuitPlanDetail plan,
    QuitPhaseDetail phase,
  ) async {
    final phaseId = phase.id;
    if (phaseId == null) {
      _showSnack('Missing phase information.', isError: true);
      return;
    }

    _setPhaseActionLoading(phaseId, _phaseActionKeepKey);

    try {
      await _withBlockingLoader(() async {
        await ref
            .read(quitPlanViewModelApiProvider.notifier)
            .keepPhase(quitPlanId: plan.id, phaseId: phaseId);
      });
      if (!mounted) return;

      _showSnack('Phase kept successfully.');
      await Future.delayed(const Duration(seconds: 2));

      ref
          .read(quitPlanDetailViewModelProvider.notifier)
          .loadQuitPlanDetail(widget.quitPlanId);
      ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    } catch (e) {
      _showSnack('Keep phase failed: ${_errorMessage(e)}', isError: true);
    } finally {
      _setPhaseActionLoading(null, null);
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

    if (selectedDate == null) {
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    _setPhaseActionLoading(phaseId, _phaseActionRedoKey);

    try {
      await _withBlockingLoader(() async {
        await ref
            .read(quitPlanViewModelApiProvider.notifier)
            .redoPhase(phaseId: phaseId, anchorStart: formattedDate);
      });
      if (!mounted) return;

      _showSnack('Phase restarted from $formattedDate.');
      ref
          .read(quitPlanDetailViewModelProvider.notifier)
          .loadQuitPlanDetail(widget.quitPlanId);
      ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    } catch (e) {
      _showSnack('Redo phase failed: ${_errorMessage(e)}', isError: true);
    } finally {
      _setPhaseActionLoading(null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quitPlanDetailViewModelProvider);

    // Listen for quit plan refresh trigger
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print(
          '🔄 [QuitPlanDetailScreen] Refresh triggered - reloading quit plan detail...',
        );
        ref
            .read(quitPlanDetailViewModelProvider.notifier)
            .loadQuitPlanDetail(widget.quitPlanId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quit Plan Details'),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: widget.isReadOnly
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref
                        .read(quitPlanDetailViewModelProvider.notifier)
                        .loadQuitPlanDetail(widget.quitPlanId);
                  },
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
                    .read(quitPlanDetailViewModelProvider.notifier)
                    .loadQuitPlanDetail(widget.quitPlanId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('No data found'));
          }

          final isCompleted = _isQuitPlanCompleted(data);
          final sortedPhases = data.phases != null && data.phases!.isNotEmpty
              ? _sortPhases(data.phases!)
              : <QuitPhaseDetail>[];

          final displayPhases = sortedPhases;

          assert(() {
            _mapPhasesToFixedPhases(sortedPhases);
            _hasRedoHistoryForPhaseName(sortedPhases, '');
            return true;
          }());

          _setTabControllerLength(displayPhases.length);

          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // Header content as sliver
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Header Section
                      QuitPlanHeader(plan: data),

                      // Congratulations Banner
                      if (isCompleted) _buildCongratulationsBanner(data),

                      // Insights Section
                      QuitPlanInsights(plan: data),

                      // Stats Section - will have square bottom when TabBar docks
                      _buildStats(
                        data,
                        phases: displayPhases,
                        dockedToTabBar: true,
                      ),
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
                final themeKey = phaseName.isNotEmpty ? phaseName : data.name;
                final theme = resolvePhaseTheme(themeKey);

                // return PhaseDetailView(
                //   plan: data,
                //   phase: phase,
                //   theme: theme,
                //   locallyCompletedMissionIds: locallyCompletedMissionIds,
                //   isReadOnly: widget.isReadOnly,
                //   onKeepPhase:
                //       _isFailedStatus(phase.status) &&
                //           !(phase.keepPhase ?? false) &&
                //           !widget.isReadOnly
                //       ? () => _handleKeepPhaseAction(data, phase)
                //       : null,
                //   onRedoPhase:
                //       _isFailedStatus(phase.status) &&
                //           !(phase.keepPhase ?? false) &&
                //           !widget.isReadOnly
                //       ? () => _handleRedoPhaseAction(phase)
                //       : null,
                //   onMissionCompleted: widget.isReadOnly
                //       ? (QuitMissionItem mission, int phaseId) {
                //           // No-op in read-only mode
                //         }
                //       : (QuitMissionItem mission, int phaseId) {
                //           _showMissionCompleteDialog(mission, phaseId);
                //         },
                //   keepLoading: _isPhaseActionLoading(
                //     phase.id,
                //     _phaseActionKeepKey,
                //   ),
                //   redoLoading: _isPhaseActionLoading(
                //     phase.id,
                //     _phaseActionRedoKey,
                //   ),
                //   hasPhaseActionInProgress: _hasPhaseActionInProgress,
                // );
                return _buildPhaseDetails(data, phase, theme);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  // Removed _buildHeader - replaced by QuitPlanHeader widget
  // Removed _buildPlanInsightsSection and all related methods - replaced by QuitPlanInsights widget

  Widget _buildStats(
    QuitPlanDetail data, {
    List<QuitPhaseDetail>? phases,
    bool dockedToTabBar = false,
  }) {
    final effectivePhases =
        phases ?? (data.phases ?? const <QuitPhaseDetail>[]);
    final totalMissions = effectivePhases.fold<int>(
      0,
      (sum, p) => sum + (p.totalMissions ?? 0),
    );
    final completedMissions = effectivePhases.fold<int>(
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
                '${effectivePhases.length}',
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

  // Removed _buildPhasesList - replaced by PhaseSelectorBar and PhaseDetailView widgets
  // Removed _buildPhaseDetails - replaced by PhaseDetailView widget
  // Removed _buildMissionsList - replaced by PhaseDetailView widget

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

  // Removed _areAllMissionsCompleted - moved to PhaseDetailView widget
  // Removed _buildMissionsList - replaced by PhaseDetailView widget

  Widget _buildFailedPhaseActionsInline(
    QuitPlanDetail plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final phaseId = phase.id;
    final keepLoading = _isPhaseActionLoading(phaseId, _phaseActionKeepKey);
    final redoLoading = _isPhaseActionLoading(phaseId, _phaseActionRedoKey);
    final actionsDisabled = _hasPhaseActionInProgress || phaseId == null;

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
              _buildActionCard(
                title: 'Keep Phase',
                description: 'Preserve all missions and continue',
                icon: Icons.layers_outlined,
                color: const Color(0xFF10B981),
                onTap: actionsDisabled
                    ? null
                    : () => _handleKeepPhaseAction(plan, phase),
                isLoading: keepLoading,
                theme: theme,
              ),
              _buildActionCard(
                title: 'Redo Phase',
                description: 'Restart with a fresh anchor date',
                icon: Icons.restart_alt,
                color: const Color(0xFF0EA5E9),
                onTap: actionsDisabled
                    ? null
                    : () => _handleRedoPhaseAction(phase),
                isLoading: redoLoading,
                theme: theme,
              ),
              _buildActionCard(
                title: 'New Plan',
                description: 'Start a brand new quit journey',
                icon: Icons.auto_awesome,
                color: const Color(0xFF8B5CF6),
                onTap: _hasPhaseActionInProgress
                    ? null
                    : () => _showCreateNewPlanDialog(theme),
                isLoading: false,
                theme: theme,
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
    required PhaseTheme theme,
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

  Widget _buildRedoPhaseBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
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
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have chosen to redo this phase.',
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
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectDate() async {
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
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (selectedDate == null) {
                _showSnack('Please select a start date', isError: true);
                return;
              }

              setDialogState(() {
                isProcessing = true;
              });

              try {
                final request = CreateNewQuitPlanRequest(
                  startDate: dateController.text,
                  useNRT: useNRT,
                  quitPlanName: nameController.text.trim(),
                );

                await _withBlockingLoader(() async {
                  await ref
                      .read(quitPlanViewModelProvider.notifier)
                      .createNewPlan(request);
                }, message: 'Creating quit plan...');

                if (!mounted) return;

                Navigator.of(context).pop();
                _showSnack('New quit plan created successfully! ');

                await _showCreateFormMetricDialog();

                ref
                    .read(quitPlanDetailViewModelProvider.notifier)
                    .loadQuitPlanDetail(widget.quitPlanId);
                ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
              } catch (e) {
                setDialogState(() {
                  isProcessing = false;
                });
                _showSnack(
                  'Failed to create new plan: ${_errorMessage(e)}',
                  isError: true,
                );
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
                              onPressed: isProcessing
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nameController,
                          enabled: !isProcessing,
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
                        TextFormField(
                          controller: dateController,
                          enabled: !isProcessing,
                          readOnly: true,
                          onTap: selectDate,
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
                                onChanged: isProcessing
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
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isProcessing
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
                                onPressed: isProcessing ? null : handleCreate,
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
                                child: isProcessing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
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
  }

  Future<void> _showCreateFormMetricDialog() async {
    if (!mounted) return;

    final formMetricData =
        await Navigator.push<form_metric_response.FormMetricDTO>(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateFormMetricDialog(),
            fullscreenDialog: true,
          ),
        );

    if (formMetricData != null && mounted) {
      try {
        final request = UpdateFormMetricRequest(
          smokeAvgPerDay: formMetricData.smokeAvgPerDay,
          numberOfYearsOfSmoking: formMetricData.numberOfYearsOfSmoking,
          cigarettesPerPackage: formMetricData.cigarettesPerPackage,
          minutesAfterWakingToSmoke: formMetricData.minutesAfterWakingToSmoke,
          smokingInForbiddenPlaces: formMetricData.smokingInForbiddenPlaces,
          cigaretteHateToGiveUp: formMetricData.cigaretteHateToGiveUp,
          morningSmokingFrequency: formMetricData.morningSmokingFrequency,
          smokeWhenSick: formMetricData.smokeWhenSick,
          moneyPerPackage: formMetricData.moneyPerPackage,
          estimatedMoneySavedOnPlan: formMetricData.estimatedMoneySavedOnPlan,
          amountOfNicotinePerCigarettes:
              formMetricData.amountOfNicotinePerCigarettes,
          estimatedNicotineIntakePerDay:
              formMetricData.estimatedNicotineIntakePerDay,
          interests: formMetricData.interests,
          triggered: formMetricData.triggered,
        );

        final response = await _withBlockingLoader(() async {
          return await ref
              .read(formMetricViewModelProvider.notifier)
              .updateFormMetric(request: request);
        }, message: 'Saving form metric...');

        if (response != null && mounted) {
          _showSnack('Form metric created successfully! ✅');
        } else {
          _showSnack('Failed to create form metric', isError: true);
        }
      } catch (e) {
        if (mounted) {
          _showSnack(
            'Failed to create form metric: ${_errorMessage(e)}',
            isError: true,
          );
        }
      }
    }
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
    int smokeAvgPerDay,
    int durationDay,
  ) {
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
        // if (baselineTotal > 0)
        //   Container(
        //     margin: const EdgeInsets.only(top: 6),
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        //     decoration: BoxDecoration(
        //       color: theme.primaryColor.withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Text(
        //       'Baseline total cigarettes: ${baselineTotal.toStringAsFixed(0)}',
        //       style: TextStyle(
        //         fontSize: 11,
        //         fontWeight: FontWeight.w600,
        //         color: theme.primaryColor,
        //       ),
        //     ),
        //   ),
        const SizedBox(height: 6),
        ...rules
            .map<Widget>(
              (rule) => _buildPhaseRule(
                rule,
                theme,
                fmCigarettesTotal: baselineTotal,
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
        return 'Must be $operator $percentLabel% of your baseline cigarettes';
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
  bool _isQuitPlanCompleted(QuitPlanDetail plan) {
    // Check if plan status is COMPLETED
    if (plan.status.toUpperCase() == 'COMPLETED') {
      return true;
    }

    // Check if all phases are completed, especially the last Maintenance phase
    final phases = plan.phases ?? [];
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
  Widget _buildCongratulationsBanner(QuitPlanDetail plan) {
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
            plan.name,
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

  Widget _buildFailedPhaseBanner(
    QuitPlanDetail plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final planName = plan.name.trim();
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
          if ((phase.reason ?? '').isEmpty) ...[
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

  /// Get smokeAvgPerDay from formMetricDTO or calculate from fmCigarettesTotal
  int _getSmokeAvgPerDay(
    int? formMetricSmokeAvgPerDay,
    double fmCigarettesTotal,
    int durationDay,
  ) {
    // Prefer formMetricDTO value if available
    if (formMetricSmokeAvgPerDay != null && formMetricSmokeAvgPerDay > 0) {
      return formMetricSmokeAvgPerDay;
    }
    // Otherwise calculate from fmCigarettesTotal / durationDay
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

  // Removed _buildTriggerChip - not used
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

class _BlockingLoader extends StatelessWidget {
  final String message;

  const _BlockingLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
