import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/utils/notification_helper.dart';

import '../../../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String resetToken;
  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateButtonState);
    _confirmController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateButtonState);
    _confirmController.removeListener(_updateButtonState);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;
    final isPasswordValid = _validatePassword(password) == null;
    final isConfirmPasswordValid = _validateConfirmPassword(confirmPassword) == null;
    final shouldBeEnabled = isPasswordValid && isConfirmPasswordValid;
    if (mounted && _isButtonEnabled != shouldBeEnabled) {
      setState(() {
        _isButtonEnabled = shouldBeEnabled;
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password.';
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!regex.hasMatch(value)) return 'Must be 8+ chars with uppercase, lowercase, number, & special char.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authViewModelProvider.notifier)
          .resetPassword(widget.resetToken, _passwordController.text);

      if (mounted) {
        if (success) {
          NotificationHelper.showTopNotification(
            context,
            title: "Success",
            message: "Your password has been reset successfully. Please log in again.",
          );
          await Future.delayed(const Duration(milliseconds: 2000));
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          final error = ref.read(authViewModelProvider).error;
          NotificationHelper.showTopNotification(
            context,
            title: "Error",
            message: error ?? "Failed to reset password. Please try again.",
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        floatingLabelStyle: const TextStyle(color: Color(0xFF00D09E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D09E), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
          color: Colors.grey,
        ),
      ),
    );
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
                  child: Text('Set New Password', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                        const Text(
                          'Create a new, strong password for your account.',
                          style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildPasswordField(
                          label: 'New Password',
                          controller: _passwordController,
                          obscure: _obscurePassword,
                          toggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          label: 'Confirm Password',
                          controller: _confirmController,
                          obscure: _obscureConfirm,
                          toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: _validateConfirmPassword,
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
                    onPressed: _isButtonEnabled && !_isLoading ? _resetPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}