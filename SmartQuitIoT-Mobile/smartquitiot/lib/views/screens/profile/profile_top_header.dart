import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------- Header (Back + Notification) ----------------
class ProfileTopHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ProfileTopHeader({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBackTap ?? () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
