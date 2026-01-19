import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/providers/diary_refresh_provider.dart';
import 'package:SmartQuitIoT/models/diary_history.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'diary_detail_screen.dart';

class DiaryHistoryScreen extends ConsumerStatefulWidget {
  const DiaryHistoryScreen({super.key});

  @override
  ConsumerState<DiaryHistoryScreen> createState() => _DiaryHistoryScreenState();
}

class _DiaryHistoryScreenState extends ConsumerState<DiaryHistoryScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Listen for diary refresh trigger to auto-refresh history
    ref.listen(diaryRefreshProvider, (previous, next) {
      if (previous != next) {
        print('🔄 [DiaryHistory] Refresh triggered, invalidating provider...');
        ref.invalidate(diaryHistoryProvider);
      }
    });

    final diaryHistoryAsync = ref.watch(diaryHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Diary History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement analytics
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // History List
          Expanded(
            child: diaryHistoryAsync.when(
              data: (historyList) {
                if (historyList.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredList = _filterHistoryList(historyList);
                return _buildHistoryList(filteredList);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D09E)),
              ),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const Text(
            'Filter:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'Smoke-free',
                  'Smoked',
                  'This Week',
                  'This Month',
                ].map((filter) => _buildFilterChip(filter)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => selectedFilter = filter);
        },
        selectedColor: const Color(0xFF00D09E).withOpacity(0.2),
        checkmarkColor: const Color(0xFF00D09E),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF00D09E) : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'You haven\'t logged any diary entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your daily progress to track your journey',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/create-diary');
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Log Now',
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

  Widget _buildErrorState(Object error) {
    // Extract meaningful error message
    String errorMessage = 'Something went wrong';
    if (error.toString().contains('ServerFailure')) {
      errorMessage =
          'Unable to connect to server. Please check your internet connection.';
    } else if (error.toString().contains('No data found')) {
      errorMessage = 'No diary entries found. Start logging your journey!';
    } else {
      errorMessage = error.toString();
    }

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
              Icons.history_outlined,
              size: 48,
              color: Color(0xFF00D09E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Diary History Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(diaryHistoryProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Retry',
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

  Widget _buildHistoryList(List<DiaryHistory> historyList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final diary = historyList[index];
        return _buildHistoryCard(diary);
      },
    );
  }

  Widget _buildHistoryCard(DiaryHistory diary) {
    final date = DateTime.parse(diary.date);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final dayOfWeek = DateFormat('EEEE').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to detail view (view-only mode)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryDetailScreen(diaryId: diary.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Date Section
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: diary.haveSmoked
                          ? [Colors.red[400]!, Colors.red[600]!]
                          : [const Color(0xFF00D09E), const Color(0xFF00B88A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dayOfWeek,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            diary.haveSmoked
                                ? Icons.smoking_rooms
                                : Icons.smoke_free,
                            color: diary.haveSmoked ? Colors.red : Colors.green,
                            size: 20,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 8),

                      // Status and Stats
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: diary.haveSmoked
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: diary.haveSmoked
                                    ? Colors.red[200]!
                                    : Colors.green[200]!,
                              ),
                            ),
                            child: Text(
                              diary.haveSmoked ? 'Smoked' : 'Smoke-free',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: diary.haveSmoked
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          if (diary.reductionPercentage != 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: diary.reductionPercentage >= 0
                                    ? Colors.blue[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: diary.reductionPercentage >= 0
                                      ? Colors.blue[200]!
                                      : Colors.orange[200]!,
                                ),
                              ),
                              child: Text(
                                '${diary.reductionPercentage >= 0 ? '+' : ''}${diary.reductionPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: diary.reductionPercentage >= 0
                                      ? Colors.blue[700]
                                      : Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DiaryHistory> _filterHistoryList(List<DiaryHistory> historyList) {
    final now = DateTime.now();

    switch (selectedFilter) {
      case 'Smoke-free':
        return historyList.where((diary) => !diary.haveSmoked).toList();
      case 'Smoked':
        return historyList.where((diary) => diary.haveSmoked).toList();
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return historyList.where((diary) {
          final diaryDate = DateTime.parse(diary.date);
          return diaryDate.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        return historyList.where((diary) {
          final diaryDate = DateTime.parse(diary.date);
          return diaryDate.isAfter(
            monthStart.subtract(const Duration(days: 1)),
          );
        }).toList();
      default:
        return historyList;
    }
  }
}
