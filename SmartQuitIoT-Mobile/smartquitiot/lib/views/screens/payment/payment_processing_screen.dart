import 'package:SmartQuitIoT/models/request/payment_process_request.dart';
import 'package:SmartQuitIoT/repositories/membership_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String? code;
  final String? id;
  final String? status;
  final String? cancel;
  final String? orderCode;

  const PaymentProcessingScreen({
    super.key,
    this.code,
    this.id,
    this.status,
    this.cancel,
    this.orderCode,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final MembershipRepository _repository = MembershipRepository();
  bool _isProcessing = true;
  String _statusMessage = 'Processing your payment...';

  @override
  void initState() {
    super.initState();
    // Set initial message based on cancel status
    final isCancelled = widget.cancel?.toLowerCase() == 'true';
    if (isCancelled) {
      _statusMessage = 'Processing cancellation...';
    }
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      print('📝 [PaymentProcessing] Starting payment processing...');
      print('📦 [PaymentProcessing] Params:');
      print('   - code: ${widget.code}');
      print('   - id: ${widget.id}');
      print('   - status: ${widget.status}');
      print('   - cancel: ${widget.cancel}');
      print('   - orderCode: ${widget.orderCode}');

      // Check if payment was cancelled BEFORE calling API
      final isCancelled = widget.cancel?.toLowerCase() == 'true';
      final isPaid = widget.status?.toUpperCase() == 'PAID';

      if (isCancelled || !isPaid) {
        // Payment cancelled or failed - skip API call and go directly to cancel screen
        print('❌ [PaymentProcessing] Payment cancelled or failed, skipping API call');
        
        // Still call API to update backend status (for cancelled payments)
        final request = PaymentProcessRequest.fromQueryParams({
          'id': widget.id,
          'orderCode': widget.orderCode,
          'cancel': widget.cancel,
          'status': widget.status,
        });

        try {
          print('🌐 [PaymentProcessing] Calling API to update cancel status...');
          await _repository.processPaymentResult(request.toJson());
          print('✅ [PaymentProcessing] Cancel status updated in backend');
        } catch (e) {
          print('⚠️ [PaymentProcessing] Failed to update cancel status (expected): $e');
          // Expected to fail for cancelled payments - backend doesn't create subscription
        }

        if (!mounted) return;

        // Navigate to cancel screen
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay for UX
        if (!mounted) return;
        
        context.go('/payment/cancel', extra: {
          'code': widget.code,
          'id': widget.id,
          'status': widget.status,
          'cancel': widget.cancel,
          'orderCode': widget.orderCode,
        });
        return;
      }

      // Payment successful - process normally
      final request = PaymentProcessRequest.fromQueryParams({
        'id': widget.id,
        'orderCode': widget.orderCode,
        'cancel': widget.cancel,
        'status': widget.status,
      });

      print('🌐 [PaymentProcessing] Calling API with:');
      print('   ${request.toJson()}');

      // Call API to process payment
      final subscription = await _repository.processPaymentResult(
        request.toJson(),
      );

      print('✅ [PaymentProcessing] Payment processed successfully');
      print('📊 [PaymentProcessing] Subscription: ${subscription?.id}');

      if (!mounted) return;

      // Navigate to success screen
      print(' [PaymentProcessing] Payment successful, navigating to success screen');
      context.go('/payment/success', extra: {
        'code': widget.code,
        'id': widget.id,
        'status': widget.status,
        'cancel': widget.cancel,
        'orderCode': widget.orderCode,
        'packageName': subscription?.membershipPackage?.name ?? 'Premium',
        'amount': subscription?.totalAmount?.toString() ?? '0',
        'startDate': subscription?.startDate?.toString() ?? '',
        'endDate': subscription?.endDate?.toString() ?? '',
      });
    } catch (e, stackTrace) {
      print('❌ [PaymentProcessing] Error processing payment: $e');
      print('🧩 [PaymentProcessing] Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Failed to process payment: ${e.toString()}';
      });

      // Show error and allow retry
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.go('/premium');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Redirecting to membership screen...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
