// lib/views/screens/appointments/appointments_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../models/appointment.dart';
import '../../../models/feedback_response.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// NOTE (VN): File này đã fix:
///  1) Navigator.pop(context, ...) thay cho `Navigator.pop(_, ...)` (undefined `_`)
///  2) Dialog buttons styled (Cancel = outlined pill, Confirm = filled green)
///  3) Avoid layout overflow: coachName/texts use Flexible/ellipsis; right column width reduced and responsive
///  4) After cancel -> call backend cancel endpoint then refresh list (no in-place mutation)
///
/// Comments in English except the NOTE above for you.

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Appointment> _appointments = [];
  bool _isSubmitting = false;
  int? _submittingRatingAppointmentId;

  // map lưu trạng thái đã rate trong session hoặc theo response từ server
  final Map<int, bool> _ratedMap = {};

  // Timer cho auto-refresh
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // colors
  static const Color primaryGreen = Color(0xFF00D09E);
  static const Color mintBg = Color(0xFFF1FFF3);
  static const Color cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    // Register observer để detect lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // Now 3 tabs: Pending (includes cancelled), In Progress, Completed
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
    // Bắt đầu auto-refresh mỗi 30 giây
    _startAutoRefresh();
  }

  @override
  void dispose() {
    // Cancel timer và remove observer
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Khi app resume (quay lại từ background), refresh data
    if (state == AppLifecycleState.resumed) {
      _refreshAppointmentsSilently();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh khi màn hình được rebuild (có thể do quay lại từ màn hình khác)
    // Nhưng chỉ refresh nếu đã load lần đầu và không đang loading
    if (!_loading && _appointments.isNotEmpty) {
      // Delay một chút để tránh refresh quá nhiều
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isRefreshing) {
          _refreshAppointmentsSilently();
        }
      });
    }
  }

  /// Bắt đầu auto-refresh định kỳ
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    // Refresh mỗi 30 giây để cập nhật trạng thái appointments
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && !_isRefreshing) {
        _refreshAppointmentsSilently();
      }
    });
  }

  /// Refresh appointments trong background (không show loading)
  Future<void> _refreshAppointmentsSilently() async {
    if (_isRefreshing) return; // Tránh refresh đồng thời

    setState(() {
      _isRefreshing = true;
    });

    try {
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        return;
      }

      final service = AppointmentService();
      final raw = await service.getMyAppointments(token);

      // Parse và update ratedMap
      final newRatedMap = <int, bool>{};
      for (var e in raw) {
        try {
          final Map<String, dynamic> m = Map<String, dynamic>.from(e);
          int? aid;
          if (m.containsKey('appointmentId')) {
            aid = m['appointmentId'] is int
                ? m['appointmentId'] as int
                : int.tryParse(m['appointmentId'].toString());
          } else if (m.containsKey('id')) {
            aid = m['id'] is int
                ? m['id'] as int
                : int.tryParse(m['id'].toString());
          }
          final ratingKeys = [
            'memberRating',
            'rating',
            'userRating',
            'member_rated',
            'hasRated',
            'rated',
          ];
          bool hasRating = false;
          for (var k in ratingKeys) {
            if (m.containsKey(k) && m[k] != null) {
              final v = m[k];
              if (v is bool && v == true) {
                hasRating = true;
                break;
              } else if (v is num && v > 0) {
                hasRating = true;
                break;
              } else if (v is String && v.isNotEmpty && v != '0') {
                hasRating = true;
                break;
              }
            }
          }
          if (aid != null) {
            newRatedMap[aid] = hasRating;
          }
        } catch (_) {}
      }

      final parsed = raw
          .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      for (var a in parsed) {
        if (a.hasRated != null) {
          newRatedMap[a.appointmentId] = a.hasRated!;
        }
      }

      // Chỉ update state nếu data thay đổi
      if (mounted) {
        final hasChanges =
            _appointments.length != parsed.length ||
            _appointments.any((old) {
              final newAppt = parsed.firstWhere(
                (newAppt) => newAppt.appointmentId == old.appointmentId,
                orElse: () => old,
              );
              return newAppt.runtimeStatus != old.runtimeStatus;
            });

        if (hasChanges) {
          setState(() {
            _appointments = parsed;
            _ratedMap.clear();
            _ratedMap.addAll(newRatedMap);
          });
        }
      }
    } catch (e) {
      debugPrint('[AutoRefresh] Failed to refresh appointments: $e');
      // Không show error cho auto-refresh, chỉ log
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _fetchAppointments({bool isRefresh = false}) async {
    if (!isRefresh) {
    setState(() {
      _loading = true;
      _error = null;
    });
    }

    try {
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('You are not logged in.');
      }

      final service = AppointmentService();
      final raw = await service.getMyAppointments(token);

      // parse raw: detect if backend returned a rating flag/value for each appointment
      _ratedMap.clear();
      for (var e in raw) {
        try {
          final Map<String, dynamic> m = Map<String, dynamic>.from(e);
          int? aid;
          if (m.containsKey('appointmentId')) {
            aid = m['appointmentId'] is int
                ? m['appointmentId'] as int
                : int.tryParse(m['appointmentId'].toString());
          } else if (m.containsKey('id')) {
            aid = m['id'] is int
                ? m['id'] as int
                : int.tryParse(m['id'].toString());
          }
          final ratingKeys = [
            'memberRating',
            'rating',
            'userRating',
            'member_rated',
            'hasRated',
            'rated',
          ];
          bool hasRating = false;
          for (var k in ratingKeys) {
            if (m.containsKey(k) && m[k] != null) {
              final v = m[k];
              if (v is bool && v == true) {
                hasRating = true;
                break;
              } else if (v is num && v > 0) {
                hasRating = true;
                break;
              } else if (v is String && v.isNotEmpty && v != '0') {
                hasRating = true;
                break;
              }
            }
          }
          if (aid != null) {
            _ratedMap[aid] = hasRating;
          }
        } catch (_) {}
      }

      final parsed = raw
          .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      for (var a in parsed) {
        if (a.hasRated != null) {
          _ratedMap[a.appointmentId] = a.hasRated!;
        }
      }
      setState(() {
        _appointments = parsed;
        _loading = false;
      });

      // debug
      debugPrint('[Appointments] fetched ${_appointments.length} items');
      for (var a in _appointments) {
        debugPrint(
          '[Appointments] id=${a.appointmentId} status=${a.runtimeStatus} date=${a.date} channel=${a.channelName} rated=${_ratedMap[a.appointmentId] ?? false}',
        );
      }
    } catch (e, st) {
      debugPrint('[ERROR] fetch appointments: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Appointment> _filterByStatus(String status) {
    final want = status.trim().toUpperCase();
    List<String> aliases;
    switch (want) {
      case 'PENDING':
        aliases = ['PENDING'];
        break;
      case 'IN_PROGRESS':
        aliases = ['IN_PROGRESS', 'INPROGRESS', 'IN PROGRESS'];
        break;
      case 'COMPLETED':
        aliases = ['COMPLETED'];
        break;
      case 'CANCELLED':
        aliases = ['CANCELLED', 'CANCELED']; // accept both spellings
        break;
      default:
        aliases = [want];
    }

    return _appointments.where((a) {
      final s = (a.runtimeStatus ?? '').trim().toUpperCase();
      return aliases.contains(s);
    }).toList();
  }

  // check if current instant is inside join window
  bool _isWithinJoinWindow(Appointment a) {
    try {
      final start = a.joinWindowStart;
      final end = a.joinWindowEnd;
      if (start == null || end == null) return false;

      // ensure comparing in UTC
      final startUtc = start.toUtc();
      final endUtc = end.toUtc();
      final nowUtc = DateTime.now().toUtc();

      final ok = !nowUtc.isBefore(startUtc) && !nowUtc.isAfter(endUtc);
      debugPrint(
        '[JoinWindow] appointment=${a.appointmentId} start=$startUtc end=$endUtc now=$nowUtc ok=$ok',
      );
      return ok;
    } catch (e, st) {
      debugPrint(
        '[JoinWindow] parse error for appointment ${a.appointmentId}: $e\n$st',
      );
      return false;
    }
  }

  Future<void> _onJoinPressed(Appointment a) async {
    debugPrint('[Join] pressed for appointment ${a.appointmentId}');
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      Flushbar(
        message: 'You are not logged in or token has expired',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final svc = AppointmentService();
      final resp = await svc.requestJoinToken(a.appointmentId, token);
      debugPrint('[JoinToken] resp = $resp');

      Navigator.pop(context); // remove loading

      context.pushNamed(
        'meeting',
        extra: {
        'channel': resp['channel'],
        'token': resp['token'],
        'uid': resp['uid'],
        'appointmentId': a.appointmentId,
        'expiresAt': resp['expiresAt'],
        },
      );
    } catch (e, st) {
      debugPrint('[Join] requestJoinToken failed: $e\n$st');
      Navigator.pop(context); // remove loading
      Flushbar(
        message: 'Cannot get token to join room: $e',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  // method riêng trong class _AppointmentsScreenState
  Future<Map<String, dynamic>?> _showRatingDialog() {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int selectedStars = 5;
        String comment = '';
        return StatefulBuilder(
          builder: (ctx2, setSt) {
          return DraggableScrollableSheet(
            initialChildSize: 0.46,
            minChildSize: 0.32,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, controller) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const Text(
                          'Rate your session',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 8),
                        const Text(
                          'Please share your feedback about the coaching session so the coach can improve.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      const SizedBox(height: 18),
                      Column(
                        children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final idx = i + 1;
                              final bool active = idx <= selectedStars;
                              return GestureDetector(
                                onTap: () => setSt(() => selectedStars = idx),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    transform: Matrix4.identity()
                                      ..scale(active ? 1.14 : 1.0),
                                    child: Icon(
                                      active
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: active ? 36 : 32,
                                      color: active
                                          ? Colors.amber
                                          : Colors.grey.shade400,
                                    ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          // label
                            Builder(
                              builder: (_) {
                                final labels = [
                                  'Terrible',
                                  'Bad',
                                  'Okay',
                                  'Good',
                                  'Excellent',
                                ];
                                return Text(
                                  labels[selectedStars - 1],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: 4,
                        onChanged: (v) => comment = v,
                        decoration: InputDecoration(
                          hintText: 'Write comment (optional)...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx2).pop(null),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black87),
                                ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () => Navigator.of(ctx2).pop({
                                  'stars': selectedStars,
                                  'comment': comment.trim(),
                                }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D09E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                elevation: 3,
                              ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
      },
    );
  }

  // Rate flow: open dialog, choose stars + optional comment, POST to backend and lock button
  Future<void> _onRatePressed(Appointment a) async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      Flushbar(
        message: 'You are not logged in.',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    final result = await _showRatingDialog();
    if (result == null) return; // user cancelled

    final int selectedStars = result['stars'] is int
        ? result['stars'] as int
        : int.tryParse(result['stars']?.toString() ?? '') ?? 5;
    final String comment = result['comment'] != null
        ? result['comment'].toString().trim()
        : '';

    // prevent double submit across taps
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _submittingRatingAppointmentId = a.appointmentId;
    });

    // show global loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final svc = AppointmentService();

      // ✅ THÊM DEBUG LOG
      print(
        '[AppointmentsScreen] _onRatePressed - appointmentId: ${a.appointmentId}',
      );
      print(
        '[AppointmentsScreen] _onRatePressed - selectedStars: $selectedStars',
      );
      print('[AppointmentsScreen] _onRatePressed - comment: "$comment"');
      print(
        '[AppointmentsScreen] _onRatePressed - comment length: ${comment.length}',
      );
      print(
        '[AppointmentsScreen] _onRatePressed - comment isEmpty: ${comment.isEmpty}',
      );

      await svc.rateAppointment(a.appointmentId, selectedStars, comment, token);

      // optimistic local update: mark rated immediately
      setState(() {
        _ratedMap[a.appointmentId] = true;
      });

      // refresh canonical state from server (optional), but preserve local rated flag
      await _fetchAppointments();
      setState(() {
        _ratedMap[a.appointmentId] =
            true; // re-apply in case server response didn't include it
      });

      Navigator.pop(context); // remove loading
      Flushbar(
        message: 'Thank you for your feedback!',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } catch (e, st) {
      try {
        Navigator.pop(context);
      } catch (_) {}
      debugPrint('[Rate] failed: $e\n$st');
      Flushbar(
        message: 'Cannot send feedback: ${e.toString()}',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } finally {
      setState(() {
        _isSubmitting = false;
        _submittingRatingAppointmentId = null;
      });
    }
  }

  // ----- View Feedback flow -----
  Future<void> _onViewFeedbackPressed(Appointment a) async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      Flushbar(
        message: 'You are not logged in.',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final svc = AppointmentService();
      final feedbackData = await svc.getFeedbackByAppointmentId(
        a.appointmentId,
        token,
      );
      final feedback = FeedbackResponse.fromJson(feedbackData);

      Navigator.pop(context); // Remove loading

      // Show feedback dialog
      _showFeedbackDialog(context, feedback, a);
    } catch (e, st) {
      try {
        Navigator.pop(context); // Remove loading
      } catch (_) {}
      debugPrint('[ViewFeedback] failed: $e\n$st');
      Flushbar(
        message: 'Cannot load feedback: ${e.toString()}',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  /// Hiển thị dialog với chi tiết feedback
  void _showFeedbackDialog(
    BuildContext context,
    FeedbackResponse feedback,
    Appointment appointment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.rate_review,
                            color: primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Feedback',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (feedback.date != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Submitted on ${DateFormat('EEE, dd MMM yyyy • HH:mm').format(feedback.date!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Rating stars
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final idx = i + 1;
                              final bool active = idx <= feedback.rating;
                              return Icon(
                                active
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 40,
                                color: active
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (_) {
                              final labels = [
                                'Terrible',
                                'Bad',
                                'Okay',
                                'Good',
                                'Excellent',
                              ];
                              return Text(
                                labels[feedback.rating - 1],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Comment (if exists)
                    if (feedback.content != null &&
                        feedback.content!.trim().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 18,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Comment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              feedback.content ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Appointment info
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 18,
                                color: primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Appointment Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFeedbackDetailRow(
                            Icons.person,
                            'Coach',
                            appointment.coachName,
                          ),
                          if (feedback.appointmentDate != null) ...[
                            const SizedBox(height: 8),
                            _buildFeedbackDetailRow(
                              Icons.calendar_today,
                              'Date',
                              DateFormat(
                                'EEE, dd MMM yyyy',
                              ).format(feedback.appointmentDate!),
                            ),
                          ],
                          if (feedback.startTime != null &&
                              feedback.endTime != null) ...[
                            const SizedBox(height: 8),
                            _buildFeedbackDetailRow(
                              Icons.access_time,
                              'Time',
                              '${feedback.startTime} - ${feedback.endTime}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedbackDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ----- Cancel flow (member) -----
  Future<void> _onCancelPressed(Appointment a) async {
    // Show confirm dialog with custom styles. Use context properly (no `_` variable).
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm Cancel'),
          content: const Text(
            'Are you sure you want to cancel this appointment? (If you cancel, your turn will NOT be refunded)',
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            // Cancel (outlined pill)
            SizedBox(
              height: 44,
              width: 120,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(color: Color(0xFF00D09E)),
                  foregroundColor: const Color(0xFF00D09E),
                ),
                child: const Text('No'),
              ),
            ),
            const SizedBox(width: 8),
            // Confirm (filled primary)
            SizedBox(
              height: 44,
              width: 120,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // call cancel API
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      Flushbar(
        message: 'You are not logged in.',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final svc = AppointmentService();
      // NOTE: AppointmentService must implement cancelAppointment(appointmentId, token)
      await svc.cancelAppointment(a.appointmentId, token);

      Navigator.pop(context); // remove loading

      Flushbar(
        message: 'Appointment cancelled successfully',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      // refresh list from server (safer than local mutation)
      await _fetchAppointments();
    } catch (e, st) {
      try {
        Navigator.pop(context);
      } catch (_) {}
      debugPrint('[Cancel] failed: $e\n$st');
      Flushbar(
        message: 'Cannot cancel appointment: $e',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Widget _buildList(List<Appointment> list) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchAppointments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            Center(child: Text('No appointments')),
            SizedBox(height: 60),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _fetchAppointments,
          child: SizedBox(
            height: constraints.maxHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = list[i];
                DateTime? dateParsed;
                try {
                  dateParsed = DateFormat('yyyy-MM-dd').parse(a.date);
                } catch (_) {}
                final dateLabel = dateParsed != null
                    ? DateFormat('EEE, dd MMM yyyy').format(dateParsed)
                    : a.date;
                final start = a.startTime.length >= 5
                    ? a.startTime.substring(0, 5)
                    : a.startTime;
                final end = a.endTime.length >= 5
                    ? a.endTime.substring(0, 5)
                    : a.endTime;
                final timeLabel = '$start • $end';

                final initials = _initialsFromName(a.coachName);

                final canJoin = _isWithinJoinWindow(a);

                final isCancelled = (a.runtimeStatus ?? '')
                    .toUpperCase()
                    .contains('CANCEL');

                // determine if this appointment is in Completed state
                final isCompleted =
                    (a.runtimeStatus ?? '').toUpperCase() == 'COMPLETED';

                // prefer server-provided flag if available, else fall back to client-side _ratedMap
                final hasRated = (a.hasRated != null)
                    ? a.hasRated!
                    : (_ratedMap[a.appointmentId] ?? false);
                final bool isSubmittingThis =
                    _isSubmitting &&
                    _submittingRatingAppointmentId == a.appointmentId;
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showAppointmentDetail(
                        context,
                        a,
                        dateLabel,
                        timeLabel,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // avatar + ghost on cancelled
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: isCancelled
                                  ? Colors.grey.shade200
                                  : mintBg,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: isCancelled
                                      ? Colors.grey.shade600
                                      : primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // content column: make it flexible to avoid overflow
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // coach name: allow ellipsis
                                  Text(
                                    a.coachName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCancelled
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          dateLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCancelled
                                                ? Colors.grey
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          timeLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCancelled
                                                ? Colors.grey
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          'Slot ${a.slotId}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCancelled
                                                ? Colors.grey.shade500
                                                : Colors.black45,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Appointment ID: ${a.appointmentId}',
                                    style: TextStyle(
                                      color: Colors.black26,
                                      fontSize: 12,
                                    ),
                                  ),
                                  // show cancelled detail if cancelled (small red text)
                                  if (isCancelled) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _cancelledLine(a),
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // right column: responsive controls
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 90,
                                maxWidth: 140,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 36,
                                    child: Center(
                                      child: _statusChip(a.runtimeStatus),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Completed => show Rate button (if not rated) OR "View Feedback" button
                                  if (isCompleted && !isCancelled) ...[
                      hasRated
                                        ? ElevatedButton.icon(
                                            onPressed: () =>
                                                _onViewFeedbackPressed(a),
                                            icon: const Icon(
                                              Icons.rate_review,
                                              size: 16,
                                            ),
                                            label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(90, 36),
                        ),
                      )
                          : isSubmittingThis
                      ? ElevatedButton(
                      onPressed: null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                          SizedBox(width: 8),
                          Text('Submitting'),
                        ],
                      ),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(90, 36),
                                              backgroundColor: primaryGreen,
                                            ),
                    )
                          : ElevatedButton(
                      onPressed: () => _onRatePressed(a),
                child: const Text('Rate'),
                style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                minimumSize: const Size(90, 36),
                ),
                                          ),
                ]
                                  // Join button only if not cancelled, status IN_PROGRESS and within window
                                  else if (!isCancelled &&
                                      a.runtimeStatus != null &&
                                      a.runtimeStatus!.toUpperCase().contains(
                                        'IN_PROGRESS',
                                      ) &&
                                      canJoin)
                                    ElevatedButton.icon(
                                      onPressed: () => _onJoinPressed(a),
                                      icon: const Icon(
                                        Icons.video_call,
                                        size: 16,
                                      ),
                                      label: const Text('Join'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        minimumSize: const Size(80, 36),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                      ),
                                    )
                                  // Pending: show Cancel button
                                  else if (!isCancelled &&
                                        a.runtimeStatus != null &&
                                      a.runtimeStatus!.toUpperCase().contains(
                                        'PENDING',
                                      ))
                                      SizedBox(
                                        width: 110,
                                        height: 36,
                                        child: ElevatedButton(
                                          onPressed: () => _onCancelPressed(a),
                                          child: const Text('Cancel'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade200,
                                            foregroundColor: Colors.red.shade900,
                                            minimumSize: const Size(80, 36),
                                            shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      IconButton(
                                        onPressed: () => _showAppointmentDetail(
                                          context,
                                          a,
                                          dateLabel,
                                          timeLabel,
                                        ),
                                        icon: Icon(
                                          Icons.chevron_right,
                                        color: isCancelled
                                            ? Colors.grey.shade400
                                            : Colors.grey,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _statusChip(String? status) {
    final s = (status ?? '').toUpperCase();
    Color color;
    String text;
    switch (s) {
      case 'PENDING':
        color = Colors.orange.shade700;
        text = 'Pending';
        break;
      case 'IN_PROGRESS':
      case 'INPROGRESS':
      case 'IN PROGRESS':
        color = Colors.blue.shade700;
        text = 'In progress';
        break;
      case 'COMPLETED':
        color = Colors.green.shade600;
        text = 'Completed';
        break;
      case 'CANCELLED':
      case 'CANCELED':
        color = Colors.red.shade600;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = s.isEmpty ? 'Unknown' : s;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    try {
      return DateFormat('HH:mm • dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      return dt.toString();
    }
  }

  String _prettyCancelledBy(String? cancelledBy) {
    if (cancelledBy == null) return 'Unknown';
    final s = cancelledBy.toUpperCase();
    if (s.contains('COACH')) return 'Coach';
    if (s.contains('MEMBER')) return 'Member';
    // fallback: return value
    return cancelledBy;
  }

  String _cancelledLine(Appointment a) {
    final who = _prettyCancelledBy(a.cancelledBy);
    final at = a.cancelledAt;
    final when = at != null
        ? DateFormat('HH:mm • dd MMM yyyy').format(at.toLocal())
        : '-';
    return 'Cancelled by $who • $when';
  }

  void _showAppointmentDetail(
      BuildContext context,
      Appointment a,
      String dateLabel,
      String timeLabel,
      ) {
    final isCancelled = (a.runtimeStatus ?? '').toUpperCase().contains(
      'CANCEL',
    );
    
    // Debug: log createdAt value
    debugPrint('[AppointmentDetail] appointmentId=${a.appointmentId}, createdAt=${a.createdAt}');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${a.appointmentId}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      tooltip: null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Info cards
                _buildDetailRow(
                  icon: Icons.person,
                  label: 'Coach',
                  value: a.coachName,
                  iconColor: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: dateLabel,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: timeLabel,
                  iconColor: Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.confirmation_number,
                  label: 'Slot',
                  value: '${a.slotId}',
                  iconColor: Colors.teal,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.add_circle_outline,
                  label: 'Booked at',
                  value: a.createdAt != null
                      ? DateFormat('EEE, dd MMM yyyy • HH:mm').format(a.createdAt!.toLocal())
                      : 'Not available',
                  iconColor: Colors.indigo,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _statusChip(a.runtimeStatus),
                        ],
                      ),
                    ),
                  ],
                ),
                if (a.joinWindowStart != null && a.joinWindowEnd != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.video_call,
                    label: 'Join Window',
                    value:
                        '${_fmtDt(a.joinWindowStart)} → ${_fmtDt(a.joinWindowEnd)}',
                    iconColor: Colors.green,
                  ),
                ],
                if (isCancelled) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cancellation Info',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.person_outline,
                          label: 'Cancelled by',
                          value: _prettyCancelledBy(a.cancelledBy),
                          iconColor: Colors.red,
                          compact: true,
                        ),
                        if (a.cancelledAt != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.schedule,
                            label: 'Cancelled at',
                            value: _fmtDt(a.cancelledAt),
                            iconColor: Colors.red,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool compact = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 6 : 8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: compact ? 16 : 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingOnly = _filterByStatus('PENDING');
    final cancelled = _filterByStatus('CANCELLED');
    final pendingTabList = [
      ...pendingOnly,
      ...cancelled,
    ]; // Pending tab = pending + cancelled
    final inprogress =
        _filterByStatus('IN_PROGRESS') + _filterByStatus('INPROGRESS');
    final completed = _filterByStatus('COMPLETED');

    return Scaffold(
      // prevent keyboard from resizing the body which can lead to layout errors
      resizeToAvoidBottomInset: false,
      backgroundColor: mintBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          elevation: 0,
          backgroundColor: primaryGreen,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, Color(0xFF00B88D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: null,
          ),
          centerTitle: true,
          title: const Text(
            'My Appointments',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: primaryGreen,
                  unselectedLabelColor: Colors.white.withOpacity(0.9),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(
                      child: Center(
                        child: Text('Pending (${pendingTabList.length})'),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: Text('In Progress (${inprogress.length})'),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: Text('Completed (${completed.length})'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pendingTabList),
          _buildList(inprogress),
          _buildList(completed),
        ],
      ),
    );
  }
}
