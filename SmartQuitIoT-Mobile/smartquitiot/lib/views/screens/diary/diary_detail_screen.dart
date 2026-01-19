
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Import thư viện biểu đồ
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/providers/diary_refresh_provider.dart';
import 'edit_diary_dialog.dart';

class DiaryDetailScreen extends ConsumerWidget {
  final int diaryId;

  const DiaryDetailScreen({super.key, required this.diaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the provider family with diaryId parameter
    final diaryDetail = ref.watch(diaryDetailProvider(diaryId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Diary Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          diaryDetail.when(
            data: (diary) => IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => EditDiaryDialog(diaryRecord: diary),
                );
                // Refresh detail and history if edit was successful
                if (result == true) {
                  ref.invalidate(diaryDetailProvider(diaryId));
                  ref.invalidate(diaryHistoryProvider);
                  ref.read(diaryRefreshProvider.notifier).refreshDiaryHistory();
                }
              },
              tooltip: 'Edit Diary',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: diaryDetail.when(
        data: (diary) => _buildDiaryDetail(diary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load diary details',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryDetail(DiaryRecord diary) {
    final moneyFormatter = NumberFormat('#,###', 'en_US'); // Use en_US to ensure comma separator

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Header
            _buildDateHeader(diary.date),
            const SizedBox(height: 20),

            // Smoking Status
            _buildSmokingSection(diary),
            const SizedBox(height: 20),

            // Mood Levels
            _buildMoodSection(diary),
            const SizedBox(height: 20),

            // Triggers
            if (diary.triggers.isNotEmpty) ...[
              _buildTriggersSection(diary.triggers),
              const SizedBox(height: 20),
            ],

            // NRT Section - Always show to display money spent
            _buildNrtSection(diary, moneyFormatter),
            const SizedBox(height: 20),

            // Health Data (Raw)
            if (diary.isConnectIoTDevice) ...[
              _buildHealthSection(diary),
              const SizedBox(height: 20),
            ],

            // Notes
            if (diary.note.isNotEmpty) ...[
              _buildNotesSection(diary.note),
              const SizedBox(height: 20),
            ],

            // Statistics (Raw)
            _buildStatisticsSection(diary),

            // ===> NEW DASHBOARD SECTION <===
            const SizedBox(height: 30),
            const Divider(thickness: 1, height: 40),
            _buildDashboardSection(diary),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- EXISTING WIDGETS ---

  Widget _buildDateHeader(String date) {
    final parsedDate = DateTime.parse(date);
    final dayOfMonth = DateFormat('d').format(parsedDate);
    final monthYear = DateFormat('MMMM yyyy').format(parsedDate);
    final dayOfWeek = DateFormat('EEEE').format(parsedDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D09E), Color(0xFF00B88A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                dayOfMonth,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthYear,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayOfWeek,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF00D09E),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSmokingSection(DiaryRecord diary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Icon(
                diary.haveSmoked ? Icons.smoking_rooms : Icons.smoke_free,
                color: diary.haveSmoked ? Colors.red : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Smoking Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                diary.haveSmoked ? 'Smoked' : 'Smoke-free',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: diary.haveSmoked ? Colors.red : Colors.green,
                ),
              ),
              if (diary.haveSmoked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    '${diary.cigarettesSmoked} cigarettes',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection(DiaryRecord diary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.mood, color: Color(0xFF00D09E), size: 24),
              SizedBox(width: 12),
              Text(
                'Mood & Feelings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMoodItem(
            'Cravings',
            diary.cravingLevel,
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 16),
          _buildMoodItem('Mood', diary.moodLevel, const Color(0xFF2196F3)),
          const SizedBox(height: 16),
          _buildMoodItem(
            'Confidence',
            diary.confidenceLevel,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _buildMoodItem(
            'Anxiety',
            diary.anxietyLevel,
            const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodItem(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 10.0,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$value/10',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTriggersSection(List<String> triggers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Color(0xFFFF9800), size: 24),
              SizedBox(width: 12),
              Text(
                'Triggers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: triggers.map((trigger) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00D09E)),
                ),
                child: Text(
                  trigger,
                  style: const TextStyle(
                    color: Color(0xFF00D09E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNrtSection(DiaryRecord diary, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.medical_services, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 12),
              Text(
                'NRT Usage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Money spent:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  '${formatter.format(diary.moneySpentOnNrt)} VND',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection(DiaryRecord diary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.health_and_safety, color: Color(0xFF2196F3), size: 24),
              SizedBox(width: 12),
              Text(
                'Health Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Row 1
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  'Steps',
                  '${diary.steps}',
                  Icons.directions_walk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthItem(
                  'Heart Rate',
                  '${diary.heartRate} bpm',
                  Icons.favorite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  'SpO2',
                  '${diary.spo2}%',
                  Icons.healing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthItem(
                  'Sleep',
                  '${diary.sleepDuration}h',
                  Icons.bedtime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00D09E), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String note) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.note_alt, color: Color(0xFF9C27B0), size: 24),
              SizedBox(width: 12),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(DiaryRecord diary) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF673AB7), size: 24),
              SizedBox(width: 12),
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Nicotine Intake',
                  '${formatter.format(diary.estimatedNicotineIntake)} mg',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Reduction',
                  '${diary.reductionPercentage.toStringAsFixed(1)}%',
                  diary.reductionPercentage >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- NEW DASHBOARD WIDGETS ---

  Widget _buildDashboardSection(DiaryRecord diary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.dashboard_customize, color: Color(0xFF00D09E), size: 28),
            SizedBox(width: 12),
            Text(
              'Metrics Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Chart 1: Phân tích tâm lý (Bar Chart)
        _buildPsychologyChart(diary),
        
        const SizedBox(height: 20),
        
        // Chart 2: Hiệu suất sức khỏe (Giả lập Goal Progress)
        // _buildHealthEfficiencyCards(diary),
      ],
    );
  }

  Widget _buildPsychologyChart(DiaryRecord diary) {
    return Container(
      height: 300,
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
        children: [
          const Text(
            "Psychological Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 30), // Thêm khoảng trống
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label;
                      switch (group.x) {
                        case 0: label = 'Craving'; break;
                        case 1: label = 'Mood'; break;
                        case 2: label = 'Confid.'; break;
                        case 3: label = 'Anxiety'; break;
                        default: label = '';
                      }
                      return BarTooltipItem(
                        '$label\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: (rod.toY).toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFF00D09E),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Craving'; break;
                          case 1: text = 'Mood'; break;
                          case 2: text = 'Confid.'; break;
                          case 3: text = 'Anxiety'; break;
                          default: text = '';
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFFA0AEC0),
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, diary.cravingLevel.toDouble(), const Color(0xFFE91E63)),
                  _makeBarGroup(1, diary.moodLevel.toDouble(), const Color(0xFF2196F3)),
                  _makeBarGroup(2, diary.confidenceLevel.toDouble(), const Color(0xFF4CAF50)),
                  _makeBarGroup(3, diary.anxietyLevel.toDouble(), const Color(0xFFFF9800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  // Widget _buildHealthEfficiencyCards(DiaryRecord diary) {
  //   // Giả định mục tiêu (Có thể sửa lại theo logic app của bạn)
  //   const int stepGoal = 10000;
  //   const double sleepGoal = 8.0; 
    
  //   double stepProgress = (diary.steps / stepGoal).clamp(0.0, 1.0);
  //   double sleepProgress = (diary.sleepDuration / sleepGoal).clamp(0.0, 1.0);

  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _buildCircularMetric(
  //           "Daily Steps",
  //           "${(stepProgress * 100).toInt()}%",
  //           stepProgress,
  //           const Color(0xFF00D09E),
  //           Icons.directions_walk,
  //           "${diary.steps} / $stepGoal",
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: _buildCircularMetric(
  //           "Sleep Goal",
  //           "${(sleepProgress * 100).toInt()}%",
  //           sleepProgress,
  //           const Color(0xFF6C63FF),
  //           Icons.bedtime,
  //           "${diary.sleepDuration}h / ${sleepGoal}h",
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCircularMetric(String title, String percentage, double value, Color color, IconData icon, String subtitle) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF2D3748),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             SizedBox(
  //               width: 80,
  //               height: 80,
  //               child: CircularProgressIndicator(
  //                 value: value,
  //                 strokeWidth: 8,
  //                 backgroundColor: color.withOpacity(0.1),
  //                 valueColor: AlwaysStoppedAnimation<Color>(color),
  //                 strokeCap: StrokeCap.round,
  //               ),
  //             ),
  //             Icon(icon, color: color, size: 32),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           percentage,
  //           style: TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             color: color,
  //           ),
  //         ),
  //         Text(
  //           subtitle,
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}