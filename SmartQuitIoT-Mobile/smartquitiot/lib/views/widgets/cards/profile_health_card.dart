import 'package:flutter/material.dart';

class ProfileHealthCard extends StatelessWidget {
  const ProfileHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset('lib/assets/user.png', width: 40, height: 40),
          const SizedBox(height: 10),
          _iconLabelValue('lib/assets/heart.png', '98 bpm'),
          const SizedBox(height: 6),
          _iconLabelValue('lib/assets/sleep.png', '1 Hour'),
          const SizedBox(height: 6),
          _iconLabelValue('lib/assets/shoe.png', '2,500 Steps'),
        ],
      ),
    );
  }

  Widget _iconLabelValue(String icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon, width: 18, height: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D09E),
          ),
        ),
      ],
    );
  }
}
