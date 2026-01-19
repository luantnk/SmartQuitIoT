import 'package:SmartQuitIoT/services/membership_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class PaymentCancelScreen extends ConsumerStatefulWidget {
  final String? code;
  final String? id;
  final String? status;
  final String? cancel;
  final String? orderCode;

  const PaymentCancelScreen({
    super.key,
    this.code,
    this.id,
    this.status,
    this.cancel,
    this.orderCode,
  });

  @override
  ConsumerState<PaymentCancelScreen> createState() => _PaymentCancelScreenState();
}

class _PaymentCancelScreenState extends ConsumerState<PaymentCancelScreen> {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final MembershipApiService _membershipApiService = MembershipApiService();
  
  bool _isProcessing = true; // Biến check xem đang gọi API hay chưa

  @override
  void initState() {
    super.initState();
    // Gọi API báo hủy ngay khi màn hình hiện lên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _processCancellation();
      }
    });
  }

  Future<void> _processCancellation() async {
    try {
      _logger.w('⚠️ [PaymentCancel] User cancelled payment. Reporting to backend...');

      // 1. Lấy data từ params (ưu tiên widget params, fallback sang arguments)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      final pCode = widget.code ?? args?['code']?.toString();
      final pId = widget.id ?? args?['id']?.toString();
      final pStatus = widget.status ?? args?['status']?.toString();
      // Vì đây là màn hình Cancel, ta có thể force cancel = true luôn cho chắc chắn
      final bool isCancelled = true; 
      final pOrderCode = int.tryParse(widget.orderCode ?? args?['orderCode']?.toString() ?? '0');

      // 2. Tạo body gửi về backend
      final Map<String, dynamic> cancelData = {
        'code': pCode,
        'id': pId,
        'cancel': isCancelled,
        'status': pStatus ?? 'CANCELLED',
        'orderCode': pOrderCode,
      };

      _logger.d('📤 [PaymentCancel] Payload: $cancelData');
      // 3. Gọi API
      await _membershipApiService.processPayment(cancelData);
      _logger.i('✅ [PaymentCancel] Cancellation recorded successfully on backend.');

    } catch (e) {
      // Nếu lỗi mạng khi báo hủy, vẫn cho user tiếp tục nhưng log lại lỗi
      _logger.e('❌ [PaymentCancel] Failed to record cancellation to backend', error: e);
    } finally {
      // Dù API thành công hay thất bại, cũng tắt loading để user bấm nút về nhà
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy data để hiển thị (chỉ mang tính minh họa)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final displayOrderCode = widget.orderCode ?? args?['orderCode'] ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ICON ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.redAccent)
                    : const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 80),
              ),
              const SizedBox(height: 30),

              // --- TEXT STATUS ---
              Text(
                _isProcessing ? 'Cancelling Transaction...' : 'Payment Cancelled',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                _isProcessing
                    ? 'Please wait while we update the order status.'
                    : 'Your transaction has been cancelled.\nNo charges were made.',
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              
              if (!_isProcessing) ...[
                const SizedBox(height: 8),
                Text(
                  'Order Code: $displayOrderCode',
                  style: const TextStyle(fontSize: 14, color: Colors.black38, fontStyle: FontStyle.italic),
                ),
              ],

              const SizedBox(height: 50),

              // --- BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null // Disable nút khi đang gọi API
                      : () {
                          _logger.i('🏠 [PaymentCancel] User returning to Home');
                          context.go('/main');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: Colors.redAccent.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}