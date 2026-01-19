import 'dart:async';
import 'package:SmartQuitIoT/services/membership_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart'; // Import Logger
import '../../../providers/membership_provider.dart';
import '../../../models/membership_subscription.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String? code;
  final String? id;
  final String? status;
  final String? cancel;
  final String? orderCode;
  
  // Các field hiển thị UI (optional)
  final String? packageName;
  final String? amount;
  final String? startDate;
  final String? endDate;

  const PaymentSuccessScreen({
    super.key,
    this.code,
    this.id,
    this.status,
    this.cancel,
    this.orderCode,
    this.packageName,
    this.amount,
    this.startDate,
    this.endDate,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  // Khởi tạo Logger và Service
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final MembershipApiService _membershipApiService = MembershipApiService();

  MembershipSubscription? _subscription;
  bool _isProcessingApi = true; // Biến này kiểm soát việc loading xoay xoay
  bool _isNavigating = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    // Đảm bảo context sẵn sàng trước khi gọi API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _processPaymentAndFetchData();
      }
    });
  }

  /// Hàm xử lý chính: Gọi Process Payment -> Fetch Subscription -> Mở khóa UI
  Future<void> _processPaymentAndFetchData() async {
    try {
      _logger.i('🔄 [PaymentSuccess] Starting payment processing sequence...');
      
      final Map<String, dynamic> paymentData = {
        'code': widget.code,
        'id': widget.id,
        'cancel': widget.cancel == 'true',
        'status': widget.status,
        'orderCode': int.tryParse(widget.orderCode ?? '0'),
      };

      // 2. Gọi API processPayment để Backend xác thực và lưu DB
      _logger.i('🌐 [PaymentSuccess] Calling Backend to finalize payment...');
      await _membershipApiService.processPayment(paymentData);

      _logger.d('✅ [PaymentSuccess] Payment finalized by backend. Fetching new subscription status...');

      // 3. Delay nhẹ (optional) để UX mượt hơn, tránh flash màn hình quá nhanh
      await Future.delayed(const Duration(seconds: 1));

      // 4. Fetch lại subscription mới nhất để cập nhật Provider
      await ref.read(currentSubscriptionProvider.notifier).fetchCurrentSubscription();

      // Lấy dữ liệu từ provider để hiển thị
      final subscriptionAsync = ref.read(currentSubscriptionProvider);
      final subscription = subscriptionAsync.value;

      _logger.i('✅ [PaymentSuccess] Membership fetched successfully: ${subscription?.membershipPackage?.name}');

      if (mounted) {
        setState(() {
          _subscription = subscription;
          _isProcessingApi = false; // Tắt loading -> Nút Back to Home sẽ sáng lên
        });
      }

    } catch (e, stackTrace) {
      _logger.e('❌ [PaymentSuccess] Error processing payment flow', error: e, stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          // Lưu lỗi để hiển thị UI
          _apiError = 'Could not verify payment. Please check your internet or contact support.';
          _isProcessingApi = false; // Tắt loading để hiện lỗi
        });
      }
    }
  }

  Future<void> _handleNavigateHome() async {
    if (_isNavigating || !mounted) return;

    // Chỉ cho phép navigate khi đã xử lý xong (_isProcessingApi = false)
    // Code nút bấm ở dưới đã handle việc disable, nhưng check lại cho chắc
    if (_isProcessingApi) {
      _logger.w('⚠️ User tried to navigate while processing');
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    // Refresh nhẹ một lần nữa trước khi về home để chắc chắn data đồng bộ
    try {
      await ref.read(currentSubscriptionProvider.notifier).fetchCurrentSubscription().timeout(const Duration(seconds: 3));
    } catch (e) {
      _logger.w('⚠️ Pre-navigation refresh skipped/failed: $e');
    }

    if (!mounted) return;

    try {
      _logger.i('🏠 Navigating back to Home');
      context.go('/main');
    } catch (e) {
      _logger.e('❌ Navigation error', error: e);
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy data từ arguments (fallback nếu widget params null)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final displayCode = widget.code ?? args?['code']?.toString() ?? '';
    final displayId = widget.id ?? args?['id']?.toString() ?? '';
    final displayStatus = widget.status ?? args?['status']?.toString() ?? '';
    final displayOrderCode = widget.orderCode ?? args?['orderCode']?.toString() ?? '';

    // Ưu tiên data từ subscription thực tế, fallback sang params
    final displayPackageName = _subscription?.membershipPackage?.name ?? widget.packageName ?? 'Premium Membership';
    
    // Xử lý hiển thị tiền
    String formattedAmount = '';
    final rawAmount = _subscription?.totalAmount?.toString() ?? widget.amount ?? args?['amount']?.toString() ?? '';
    if (rawAmount.isNotEmpty) {
      try {
        final amountInt = double.tryParse(rawAmount) ?? 0;
        formattedAmount = NumberFormat('#,###', 'vi_VN').format(amountInt);
      } catch (e) {
        formattedAmount = rawAmount;
      }
    }

    // Xử lý hiển thị ngày
    String formattedStartDate = _formatDate(_subscription?.startDate?.toString() ?? widget.startDate);
    String formattedEndDate = _formatDate(_subscription?.endDate?.toString() ?? widget.endDate);

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- ICON / LOADING INDICATOR ---
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _isProcessingApi
                        ? const Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                            ),
                          )
                        : Icon(
                            _apiError != null ? Icons.warning_rounded : Icons.check_rounded,
                            color: _apiError != null ? Colors.orange : const Color(0xFF4CAF50),
                            size: 60,
                          ),
                  ),
                  const SizedBox(height: 40),

                  // --- STATUS TEXT ---
                  Text(
                    _isProcessingApi
                        ? 'Finalizing Payment...' // Đang xử lý
                        : _apiError != null
                            ? 'Verification Issue'
                            : 'Payment Successful!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isProcessingApi
                        ? 'Please wait while we secure your membership...' // Thông báo chờ
                        : _apiError != null
                            ? 'Payment received but verification failed. Please check app status later.'
                            : 'Your premium membership has been activated successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  // --- ERROR BOX (IF ANY) ---
                  if (_apiError != null && !_isProcessingApi) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Text(
                        '$_apiError\nError: ${_apiError?.split(':').last ?? 'Unknown'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // --- DETAILS CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          icon: Icons.check_circle,
                          title: 'Status',
                          value: _isProcessingApi 
                              ? 'Verifying...' 
                              : (displayStatus.isEmpty ? 'Success' : displayStatus.toUpperCase()),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(icon: Icons.receipt_long, title: 'Order Code', value: displayOrderCode),
                        if (displayCode.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(icon: Icons.qr_code, title: 'Ref Code', value: displayCode),
                        ],
                        if (formattedAmount.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(icon: Icons.attach_money, title: 'Amount', value: '$formattedAmount VND'),
                        ],
                        const Divider(height: 32),
                        _buildDetailRow(icon: Icons.workspace_premium, title: 'Package', value: displayPackageName),
                        if (formattedStartDate.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(icon: Icons.calendar_today, title: 'Start', value: formattedStartDate),
                        ],
                        if (formattedEndDate.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(icon: Icons.event_available, title: 'End', value: formattedEndDate),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- ACTION BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // DISABLE nút này nếu đang loading
                      onPressed: (_isProcessingApi || _isNavigating)
                          ? null 
                          : _handleNavigateHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        // Màu khi bị disable
                        disabledBackgroundColor: Colors.white.withOpacity(0.5),
                        disabledForegroundColor: Colors.black38,
                      ),
                      child: (_isProcessingApi || _isNavigating)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                                ),
                                SizedBox(width: 12),
                                Text('Finalizing...'), // Text khi đang load
                              ],
                            )
                          : const Text(
                              'Back to Home',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper format date
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildDetailRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00D09E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00D09E), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}