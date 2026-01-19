// lib/views/screens/appointments/coach_detail_screen.dart
// Màn chi tiết coach + flow đặt lịch
// - Sau khi đặt thành công: chỉ show confirmation dialog và refresh lại slot list
// - Không còn chuyển thẳng tới màn đánh giá (rating) từ flow đặt lịch
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:SmartQuitIoT/views/screens/appointments/coach_list_items.dart';
import 'package:SmartQuitIoT/views/screens/appointments/info_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/time_slot_grid.dart';
import '../../../../models/slot_available.dart';
import '../../../../models/coach_detail.dart';
import '../../../providers/coach_detail_provider.dart';
import '../../../providers/booking_provider.dart';
import 'custom_button.dart';
import 'info_row.dart';
import '../../../models/request/appointment_request.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';

class CoachDetailScreen extends ConsumerStatefulWidget {
  final Coach coach;

  const CoachDetailScreen({super.key, required this.coach});

  @override
  ConsumerState<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends ConsumerState<CoachDetailScreen> {
  String? selectedSlot;
  DateTime selectedDateTime = DateTime.now();
  String selectedDate = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());
  List<SlotAvailable> availableSlots = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[DEBUG] initState: loading coach detail for today');
      _loadCoachDetail();
    });
  }

  Future<void> _loadCoachDetail({String? dateIso}) async {
    debugPrint('[DEBUG] _loadCoachDetail called with dateIso=$dateIso');
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final viewModel = ref.read(coachDetailViewModelProvider.notifier);
      final formattedDate =
          dateIso ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      debugPrint('[DEBUG] formattedDate used = $formattedDate');

      int? coachId;
      try {
        coachId = int.tryParse(widget.coach.id.toString());
      } catch (_) {}

      if (coachId == null) {
        throw Exception('Invalid coach id: ${widget.coach.id}');
      }

      await viewModel.loadCoachDetail(coachId, formattedDate);
      final state = ref.read(coachDetailViewModelProvider);
      final slots = state.slots ?? [];

      debugPrint(
        '[DEBUG] _loadCoachDetail: received slots count=${slots.length}',
      );

      setState(() {
        availableSlots = slots;
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('[ERROR] _loadCoachDetail exception: $e\n$st');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openDatePickerBottomSheet(BuildContext context) async {
    debugPrint('[DEBUG] _openDatePickerBottomSheet called');
    try {
      DateTime today = DateTime.now();
      final firstDate = DateTime(today.year, today.month, today.day);
      final lastDate = firstDate.add(const Duration(days: 60));

      DateTime tempSelected = selectedDateTime.isBefore(firstDate)
          ? firstDate
          : selectedDateTime;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx2, setModalState) {
              return SafeArea(
                child: Padding(
                  padding:
                      MediaQuery.of(ctx2).viewInsets +
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      CalendarDatePicker(
                        initialDate: tempSelected,
                        firstDate: firstDate,
                        lastDate: lastDate,
                        onDateChanged: (d) {
                          setModalState(() => tempSelected = d);
                          debugPrint(
                            '[DEBUG] bottom sheet tempSelected updated = $d',
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx2).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final chosen = DateTime(
                                  tempSelected.year,
                                  tempSelected.month,
                                  tempSelected.day,
                                );
                                final nowDate = DateTime.now();
                                final todayOnly = DateTime(
                                  nowDate.year,
                                  nowDate.month,
                                  nowDate.day,
                                );

                                if (chosen.isBefore(todayOnly)) {
                                  Flushbar(
                                    message:
                                        'Please select a date from today onwards.',
                                    icon: const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    backgroundColor: const Color(0xFF00D09E),
                                    duration: const Duration(seconds: 3),
                                    margin: const EdgeInsets.all(8),
                                    borderRadius: BorderRadius.circular(8),
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context);
                                  return;
                                }

                                setState(() {
                                  selectedDateTime = tempSelected;
                                  selectedDate = DateFormat(
                                    'EEEE, MMM dd, yyyy',
                                  ).format(selectedDateTime);
                                  selectedSlot = null;
                                });

                                final iso = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(selectedDateTime);
                                debugPrint(
                                  '[DEBUG] Confirm pressed: selectedDateTime=$selectedDateTime iso=$iso',
                                );

                                Navigator.of(ctx2).pop();
                                _loadCoachDetail(dateIso: iso);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D09E),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e, st) {
      debugPrint('[ERROR] Exception in _openDatePickerBottomSheet: $e\n$st');

      final today = DateTime.now();
      final firstDate = DateTime(today.year, today.month, today.day);
      final lastDate = firstDate.add(const Duration(days: 60));

      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTime.isBefore(firstDate)
            ? firstDate
            : selectedDateTime,
        firstDate: firstDate,
        lastDate: lastDate,
      );

      if (picked != null) {
        setState(() {
          selectedDateTime = picked;
          selectedDate = DateFormat(
            'EEEE, MMM dd, yyyy',
          ).format(selectedDateTime);
          selectedSlot = null;
        });

        final iso = DateFormat('yyyy-MM-dd').format(selectedDateTime);
        debugPrint('[DEBUG] fallback (catch) picked date iso=$iso');
        _loadCoachDetail(dateIso: iso);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachDetailViewModelProvider);
    final CoachDetail? detail = state.coach;
    final fabHeroTag = 'coach_date_fab_${widget.coach.id}';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(detail),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(detail),
                  const SizedBox(height: 16),
                  _buildInfoCard(detail),
                  const SizedBox(height: 24),
                  _buildTimeSlotsSection(context),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Confirm Booking',
                    onPressed: selectedSlot == null ? null : _handleBooking,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: fabHeroTag,
        onPressed: () {
          debugPrint('[DEBUG] FAB pressed to open date picker');
          _openDatePickerBottomSheet(context);
        },
        backgroundColor: const Color(0xFF00D09E),
        child: const Icon(Icons.date_range),
      ),
    );
  }

  Widget _buildAppBar(CoachDetail? detail) {
    final title = detail?.fullName ?? widget.coach.name ?? 'Coach';
    final avatarUrl = detail?.avatarUrl ?? (widget.coach.imageUrl ?? '');

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF00D09E),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00D09E), Color(0xFF00B88D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 56, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(CoachDetail? detail) {
    final patientsLabel = '—';
    final ratingValue = detail?.ratingAvg ?? widget.coach.rating ?? 0.0;
    final ratingLabel = ratingValue.toStringAsFixed(1);
    final yearsExp =
        (detail?.experienceYears?.toString() ??
                widget.coach.experience?.split(' ').first ??
                '0')
            .toString();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.people_outline,
            patientsLabel,
            'Patients',
            const Color(0xFF00D09E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.star_rounded,
            ratingLabel,
            'Rating',
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.workspace_premium_rounded,
            yearsExp,
            'Years Exp.',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildInfoCard(CoachDetail? detail) {
    final languagesFallback = 'English, Vietnamese';
    final specialty = (detail?.specializations?.isNotEmpty == true)
        ? detail!.specializations!
        : (widget.coach.specialty ?? 'Health Coach');
    final experience = detail != null
        ? '${detail.experienceYears} years'
        : (widget.coach.experience ?? '');
    final bio = detail?.bio ?? (widget.coach.bio ?? '');

    return InfoCard(
      title: 'About Coach',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            icon: Icons.work_outline,
            text: specialty,
            iconColor: const Color(0xFF00D09E),
          ),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.school_outlined,
            text: experience,
            iconColor: const Color(0xFF00D09E),
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.language_rounded,
            text: languagesFallback,
            iconColor: const Color(0xFF00D09E),
          ),
          const Divider(height: 32),
          Text(
            bio,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF00D09E),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            debugPrint('[DEBUG] InkWell tapped to open date picker');
            _openDatePickerBottomSheet(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00D09E), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF00D09E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedDate,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (errorMessage != null)
          Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          )
        else if (availableSlots.isEmpty)
          const Center(child: Text('No available slots for this day'))
        else
          TimeSlotGrid(
            timeSlots: availableSlots
                .map(
                  (slot) =>
                      TimeSlot(time: slot.startTime ?? '', available: true),
                )
                .toList(),
            selectedSlot: selectedSlot,
            onSlotSelected: (slot) => setState(() => selectedSlot = slot),
          ),
      ],
    );
  }

  void _handleBooking() async {
    if (selectedSlot == null) return;

    final matches = availableSlots
        .where((s) => s.startTime == selectedSlot)
        .toList();
    final SlotAvailable? chosenSlot = matches.isNotEmpty ? matches.first : null;

    if (chosenSlot == null) {
      Flushbar(
        message: 'Selected slot not found. Please try again.',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    final slotId = chosenSlot.slotId;

    final state = ref.read(coachDetailViewModelProvider);
    final coachDetail = state.coach;
    final coachId = coachDetail?.id ?? int.tryParse(widget.coach.id.toString());

    if (coachId == null) {
      Flushbar(
        message: 'Invalid coach ID',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    final isoDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
    final req = AppointmentRequest(
      coachId: coachId,
      slotId: slotId,
      date: isoDate,
    );

    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();

    if (token == null || token.isEmpty) {
      Flushbar(
        message: 'You are not logged in. Please log in to book an appointment.',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = AppointmentService();
      final resp = await service.bookAppointment(req.toJson(), token);

      try {
        Navigator.of(context).pop(); // dismiss loading
      } catch (_) {}

      final data = resp['data'] as Map<String, dynamic>?;

      setState(() {
        availableSlots.removeWhere((s) => s.slotId == slotId);
        selectedSlot = null;
      });

      // Refresh remaining booking quota
      ref.refresh(remainingBookingProvider);

      // Hiện dialog xác nhận — **không chuyển tới màn rating**
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00D09E),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data != null
                    ? 'Your consultation with ${data['coachName'] ?? (coachDetail?.fullName ?? widget.coach.name)} has been scheduled for ${data['startTime'] ?? selectedSlot} on ${data['date'] ?? isoDate}.'
                    : 'Booking success for $isoDate.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // đóng dialog và refresh slot list (để reflect trạng thái mới)
                  Navigator.pop(context);
                  _loadCoachDetail(dateIso: isoDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, st) {
      try {
        Navigator.of(context).pop(); // dismiss loading on error
      } catch (_) {}
      debugPrint('[ERROR] booking failed: $e\n$st');
      final errMsg = e is Exception
          ? e.toString().replaceAll('Exception: ', '')
          : 'Booking failed';
      ScaffoldMessenger.of(context);
      Flushbar(
        message: errMsg,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }
}
