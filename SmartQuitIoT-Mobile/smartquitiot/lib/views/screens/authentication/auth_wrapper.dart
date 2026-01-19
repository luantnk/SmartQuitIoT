import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/state/auth_state.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';
import 'package:SmartQuitIoT/views/screens/common/main_navigation_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/onboarding_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated == false) {
        final isFirstLogin = next.isFirstLogin ?? false;

        if (isFirstLogin) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                (route) => false,
          );
        }
      }
    });

    final authState = ref.watch(authViewModelProvider);

    if (authState.isAuthenticated) {
      return const MainNavigationScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
