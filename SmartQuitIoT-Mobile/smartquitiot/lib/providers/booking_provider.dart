// lib/providers/booking_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/remaining_booking.dart';
import '../services/appointment_service.dart';

/// Provider cho AppointmentService (có thể override dễ dàng trong tests)
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

/// FutureProvider trả RemainingBooking để UI watch
final remainingBookingProvider = FutureProvider<RemainingBooking>((ref) async {
  final svc = ref.read(appointmentServiceProvider);
  return svc.getRemainingBookings();
});
