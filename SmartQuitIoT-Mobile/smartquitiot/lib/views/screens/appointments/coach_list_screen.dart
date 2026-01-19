// lib/views/screens/appointments/coach_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:another_flushbar/flushbar.dart';
import 'coach_detail_screen.dart';
import 'coach_list_items.dart';
import '../../../providers/coach_provider.dart';
import '../../../models/coach.dart' as api_models;
import '../../../models/remaining_booking.dart';
import '../../../providers/booking_provider.dart';

/// Màn chọn coach + hiển thị quota lượt booking còn lại.
/// - Pill nhỏ, subtle, chạm vào mở bottom sheet chi tiết.
/// - Các helper widget nhỏ tách ra thành StatelessWidget (có thể dùng const).
class CoachListScreen extends ConsumerStatefulWidget {
  const CoachListScreen({super.key});

  @override
  ConsumerState<CoachListScreen> createState() => _CoachListScreenState();
}

class _CoachListScreenState extends ConsumerState<CoachListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coachState = ref.watch(coachListStateProvider);
    final viewModel = ref.read(coachListStateProvider.notifier);

    // watch remaining booking provider
    final remainingAsync = ref.watch(remainingBookingProvider);

    // play subtle animation once data available
    remainingAsync.whenData((_) {
      Timer(const Duration(milliseconds: 50), () {
        if (mounted) _animCtrl.forward();
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFDFF7E2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00D09E),
        centerTitle: true,
        title: const Text(
          'Choose a Coach',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              viewModel.refresh();
              ref.refresh(remainingBookingProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // subtle pill area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: remainingAsync.when(
                data: (remaining) => RemainingPill(
                  remaining: remaining,
                  onTap: () => _showRemainingDetail(context, remaining),
                ),
                loading: () => const RemainingPillLoading(),
                error: (err, st) => RemainingPillError(
                  message: err.toString(),
                  onRetry: () => ref.refresh(remainingBookingProvider),
                ),
              ),
            ),
          ),

          // list of coaches
          Expanded(
            child: coachState.when(
              data: (coaches) {
                if (coaches.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.refresh();
                    ref.refresh(remainingBookingProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: coaches.length,
                    itemBuilder: (context, index) {
                      final coach = coaches[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CoachListItem(
                          coach: _convertApiCoachToLocalCoach(coach),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoachDetailScreen(
                                  coach: _convertApiCoachToLocalCoach(coach),
                                ),
                              ),
                            );
                            // Refresh quota khi quay lại từ detail screen
                            ref.refresh(remainingBookingProvider);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                ),
              ),
              error: (error, stack) =>
                  _buildErrorState(error.toString(), viewModel),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom sheet hiển thị chi tiết quota
  void _showRemainingDetail(BuildContext context, RemainingBooking r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // small drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Booking quota',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // big remaining number but still subtle
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${r.remaining}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.used} used • ${r.allowed} allowed',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        if (r.periodStart != null && r.periodEnd != null) ...[
                          Text(
                            'Period',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(r.periodStart!)} → ${_formatDate(r.periodEnd!)}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (r.note != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            r.note!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        // TODO: navigate to subscription/manage screen nếu cần
                      },
                      child: const Text(
                        'Manage subscription',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Empty / error / convert helpers ------------------------------------------------

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person_search, size: 80, color: Color(0xFF00D09E)),
          SizedBox(height: 16),
          Text(
            'No Coaches Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are currently no coaches available for booking.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorState(String error, dynamic viewModel) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  Coach _convertApiCoachToLocalCoach(api_models.Coach apiCoach) {
    print('[CoachListScreen] Converting coach id=${apiCoach.id}');
    print(
      '[CoachListScreen] apiCoach.specializations = ${apiCoach.specializations}',
    );
    print(
      '[CoachListScreen] apiCoach.specializations is null? ${apiCoach.specializations == null}',
    );

    return Coach(
      id: apiCoach.id.toString(),
      name: apiCoach.fullName,
      specialty:
          apiCoach.specializations ??
          'Health Coach', // Use specializations if available, fallback to default
      rating: apiCoach.ratingAvg,
      reviews: 0,
      experience: 'Professional Coach',
      imageUrl: apiCoach.avatarUrl,
      bio:
          'Professional coach with expertise in helping people achieve their health goals.',
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

// ------------------------- Helper widgets (const-friendly) -------------------------

/// Pill nhỏ hiển thị số lượt còn lại (subtle)
class RemainingPill extends StatelessWidget {
  final RemainingBooking remaining;
  final VoidCallback? onTap;

  const RemainingPill({super.key, required this.remaining, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${remaining.remaining}',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bookings left',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${remaining.used} used • ${remaining.allowed} allowed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading state for pill
class RemainingPillLoading extends StatelessWidget {
  const RemainingPillLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.10)),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Loading booking quota...',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state for pill (with retry)
class RemainingPillError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const RemainingPillError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 32, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load booking info',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00D09E)),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
