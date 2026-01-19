import 'package:riverpod/riverpod.dart';

import '../models/payment_link_data.dart';
import '../models/state/membership_state.dart';
import '../models/membership_subscription.dart';
import '../repositories/membership_repository.dart';

class MembershipViewModel extends StateNotifier<MembershipState> {
  final MembershipRepository _repository;

  MembershipViewModel({MembershipRepository? repository})
    : _repository = repository ?? MembershipRepository(),
      super(const MembershipState());

  Future<void> fetchMembershipPackages() async {
    state = state.copyWith(state: ViewState.loading);
    try {
      final packages = await _repository.fetchMembershipPackages();
      state = state.copyWith(state: ViewState.success, packages: packages);
    } catch (e) {
      state = state.copyWith(
        state: ViewState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<PaymentLinkData?> createPaymentLink({
    required int packageId,
    required int duration,
  }) async {
    try {
      final paymentData = await _repository.createPaymentLink(
        packageId: packageId,
        duration: duration,
      );
      return paymentData;
    } catch (e) {
      print('Error in ViewModel creating payment link: $e');
      return null;
    }
  }

  Future<MembershipSubscription?> createFreeTrialSubscription({
    required int packageId,
    required int duration,
  }) async {
    try {
      final subscription = await _repository.createFreeTrialSubscription(
        packageId: packageId,
        duration: duration,
      );
      return subscription;
    } catch (e) {
      print('Error in ViewModel creating free trial: $e');
      return null;
    }
  }

  // viewmodels/membership_viewmodel.dart
  Future<void> processPaymentResult(Map<String, dynamic> body) async {
    state = state.copyWith(state: ViewState.loading);
    try {
      final result = await _repository.processPaymentResult(body);
      state = state.copyWith(
        state: ViewState.success,
        activeSubscription: result,
      );
    } catch (e) {
      print('Error processing payment result: $e');
      state = state.copyWith(
        state: ViewState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset membership state to initial state (used on logout)
  void reset() {
    state = const MembershipState();
  }
}
