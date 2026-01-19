import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/utils/notification_helper.dart';
import 'package:SmartQuitIoT/views/screens/authentication/otp_screen.dart';
import 'package:SmartQuitIoT/views/widgets/inputs/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _emailController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _updateButtonState() {
    if (mounted) {
      setState(() {
        _isButtonEnabled = _formKey.currentState?.validate() ?? false;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_isEmailValid(value)) return 'Invalid email format';
    return null;
  }

  Future<void> _sendResetLink() async {
    if (_isButtonEnabled && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        final success = await ref
            .read(authViewModelProvider.notifier)
            .forgotPassword(_emailController.text);

        if (mounted) {
          if (success) {
            NotificationHelper.showTopNotification(
              context,
              title: "Success",
              message: "An OTP has been sent to your email. Please check.",
            );
            await Future.delayed(const Duration(milliseconds: 1500));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(email: _emailController.text),
              ),
            );
          } else {
            final error = ref.read(authViewModelProvider).error;
            NotificationHelper.showTopNotification(
              context,
              title: "Error",
              message: error ?? "An unknown error occurred.",
              isError: true,
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // child: Text(
                  //   'Forgot Password',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Enter your email to reset your password',
                          hint: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isButtonEnabled && !_isLoading)
                        ? _sendResetLink
                        : null,
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
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'), // ✅ Dùng GoRouter
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF00D09E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
