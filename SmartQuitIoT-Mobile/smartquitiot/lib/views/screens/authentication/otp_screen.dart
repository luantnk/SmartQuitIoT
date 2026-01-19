import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/utils/notification_helper.dart';
import 'package:SmartQuitIoT/views/screens/authentication/reset_password_screen.dart';

import '../../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_checkOtpLength);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_checkOtpLength);
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkOtpLength() {
    final otp = _controllers.map((c) => c.text).join();
    if (mounted) {
      setState(() {
        _isButtonEnabled = otp.length == 6;
      });
    }
  }

  // --- HÀM ĐÃ ĐƯỢC CẬP NHẬT ---
  Future<void> _verifyOtp() async {
    if (!_isButtonEnabled || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final otp = _controllers.map((e) => e.text).join();
      final resetToken = await ref
          .read(authViewModelProvider.notifier)
          .verifyOtp(widget.email, otp);

      if (mounted) {
        if (resetToken != null) {
          // 1. HIỂN THỊ THÔNG BÁO THÀNH CÔNG
          NotificationHelper.showTopNotification(
            context,
            title: "Success",
            message: "OTP verified successfully. Please set your new password.",
          );

          // 2. CHỜ MỘT CHÚT ĐỂ NGƯỜI DÙNG ĐỌC THÔNG BÁO
          await Future.delayed(const Duration(milliseconds: 1500));

          // 3. ĐIỀU HƯỚNG SANG MÀN HÌNH TIẾP THEO
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResetPasswordScreen(resetToken: resetToken)),
          );
        } else {
          // Logic xử lý lỗi giữ nguyên
          final error = ref.read(authViewModelProvider).error;
          NotificationHelper.showTopNotification(
            context,
            title: "Verification Failed",
            message: error ?? "An unknown error occurred.",
            isError: true,
          );
        }
      }
    } finally {
      if (mounted) {
        // Tắt loading sau khi hoàn tất (dù thành công hay thất bại)
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildOtpField(int index) {
    // Phần này giữ nguyên, không thay đổi
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D09E), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Phần UI build giữ nguyên, không thay đổi
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(color: Color(0xFF00D09E)),
                child: const Center(
                  child: Text(
                    'OTP Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                          children: [
                            const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _buildOtpField(index)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isButtonEnabled && !_isLoading) ? _verifyOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text(
                      'Verify',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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