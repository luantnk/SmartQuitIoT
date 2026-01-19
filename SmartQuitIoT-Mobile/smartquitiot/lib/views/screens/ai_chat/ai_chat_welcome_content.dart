import 'package:flutter/material.dart';

class AiChatWelcomeContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const AiChatWelcomeContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        _buildLogoSection(),
        const SizedBox(height: 40),
        _buildWelcomeText(),
        const SizedBox(height: 60),
        _buildStartButton(context),
        const Spacer(),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Image.asset(
      'lib/assets/logo/logo-2.png',
      width: 220,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D09E),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF00D09E).withOpacity(0.3),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
