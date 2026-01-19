import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/quit_plan_history.dart';
import '../../../providers/quit_plan_history_provider.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../../../providers/auth_provider.dart';
import 'quit_plan_detail_screen.dart';

class QuitPlanHistoryScreen extends ConsumerStatefulWidget {
  const QuitPlanHistoryScreen({super.key});

  @override
  ConsumerState<QuitPlanHistoryScreen> createState() =>
      _QuitPlanHistoryScreenState();
}

class _QuitPlanHistoryScreenState extends ConsumerState<QuitPlanHistoryScreen> {
  String _selectedFilter = 'ALL'; // ALL, IN_PROGRESS, COMPLETED, CANCELED

  @override
  Widget build(BuildContext context) {
    final quitPlansAsync = ref.watch(quitPlanHistoryViewModelProvider);

    // Listen for authentication state changes (login/logout/user switch)
    ref.listen(authViewModelProvider, (previous, next) {
      if (previous != null) {
        final wasAuthenticated = previous.isAuthenticated;
        final isAuthenticated = next.isAuthenticated;
        final previousUsername = previous.username;
        final currentUsername = next.username;

        // Case 1: User logged in (from not authenticated to authenticated)
        if (!wasAuthenticated && isAuthenticated) {
          print(
            '🔄 [QuitPlanHistoryScreen] User logged in - refreshing quit plan history...',
          );
          ref.read(quitPlanHistoryViewModelProvider.notifier).refresh();
        }
        // Case 2: User logged out (from authenticated to not authenticated)
        else if (wasAuthenticated && !isAuthenticated) {
          print(
            '🔒 [QuitPlanHistoryScreen] User logged out - clearing quit plan history...',
          );
          // Clear data immediately to prevent showing old user's data
          ref.read(quitPlanHistoryViewModelProvider.notifier).clear();
        }
        // Case 3: User switched (username changed while authenticated)
        else if (isAuthenticated &&
            previousUsername != null &&
            currentUsername != null &&
            previousUsername != currentUsername) {
          print(
            '🔄 [QuitPlanHistoryScreen] User switched from $previousUsername to $currentUsername - clearing and refreshing quit plan history...',
          );
          // Clear old data first, then load new user's data
          ref.read(quitPlanHistoryViewModelProvider.notifier).clear();
          Future.microtask(() {
            ref.read(quitPlanHistoryViewModelProvider.notifier).refresh();
          });
        }
      }
    });

    // Listen for quit plan refresh trigger
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print(
          '🔄 [QuitPlanHistoryScreen] Refresh triggered - reloading quit plan history...',
        );
        ref.read(quitPlanHistoryViewModelProvider.notifier).refresh();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quit Plan History'),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(quitPlanHistoryViewModelProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: quitPlansAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D09E)),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(quitPlanHistoryViewModelProvider.notifier)
                            .refresh();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (quitPlans) {
                if (quitPlans.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter quit plans
                final filteredPlans = _filterQuitPlans(quitPlans);

                if (filteredPlans.isEmpty) {
                  return _buildNoResultsState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(quitPlanHistoryViewModelProvider.notifier)
                        .refresh();
                  },
                  color: const Color(0xFF00D09E),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: filteredPlans.length,
                    itemBuilder: (context, index) {
                      return _buildQuitPlanCard(filteredPlans[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('ALL', 'All', Icons.list),
            const SizedBox(width: 10),
            _buildFilterChip('IN_PROGRESS', 'In Progress', Icons.play_circle),
            const SizedBox(width: 10),
            _buildFilterChip('COMPLETED', 'Completed', Icons.check_circle),
            const SizedBox(width: 10),
            _buildFilterChip('CANCELED', 'Canceled', Icons.cancel),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D09E) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D09E) : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D09E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF00D09E),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<QuitPlanHistory> _filterQuitPlans(List<QuitPlanHistory> quitPlans) {
    if (_selectedFilter == 'ALL') {
      return quitPlans;
    }
    return quitPlans.where((plan) => plan.status == _selectedFilter).toList();
  }

  Widget _buildQuitPlanCard(QuitPlanHistory quitPlan) {
    final statusColor = Color(quitPlan.statusColor);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuitPlanDetailScreen(
                  quitPlanId: quitPlan.id,
                  isReadOnly: true,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status icon circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor, statusColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(quitPlan.status),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quitPlan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatusBadge(
                                quitPlan.statusDisplayText,
                                statusColor,
                              ),
                              if (quitPlan.active) _buildActiveBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.0),
                        statusColor.withOpacity(0.2),
                        statusColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Information rows
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Start',
                  _formatDate(quitPlan.startDate),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.event_outlined,
                  'End',
                  _formatDate(quitPlan.endDate),
                ),
                const SizedBox(height: 16),
                // Bottom row with FTND Score and NRT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.assessment_outlined,
                        'FTND Score',
                        '${quitPlan.ftndScore}',
                        isCompact: true,
                      ),
                    ),
                    if (quitPlan.useNRT) _buildNRTBadge(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00B87C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Active',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNRTBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00B87C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services, size: 14, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'NRT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isCompact = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        if (!isCompact) ...[
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 13 : 13,
            color: Colors.grey[800],
            fontWeight: isCompact ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Quit Plans Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your quit plan history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filter',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'IN_PROGRESS':
        return Icons.play_circle;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
