// services/app_token_manager.dart
import 'package:flutter/material.dart';

class AppTokenManager with WidgetsBindingObserver {
  AppTokenManager._privateConstructor();

  static final AppTokenManager instance = AppTokenManager._privateConstructor();

  /// Gọi khi app start
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    // ❌ REMOVED: Do NOT clear tokens on app start!
    // Users should stay logged in between app sessions
    // await _clearTokensOnStart();
    debugPrint('[AppTokenManager] Initialized - tokens preserved');
  }

  /// ❌ DISABLED: Do NOT clear tokens on app start
  /// Tokens should only be cleared on explicit logout
  // Future<void> _clearTokensOnStart() async {
  //   await _tokenService.clearTokens();
  //   debugPrint('[AppTokenManager] Tokens cleared on app start.');
  // }

  /// Lifecycle observer
  ///
  /// IMPORTANT: Tokens are preserved when app goes to background.
  /// This allows users to:
  /// - Switch to another app and come back without needing to login again
  /// - Keep their session active when app is in background
  ///
  /// Tokens are ONLY cleared when:
  /// - User explicitly logs out
  /// - App is completely terminated (killed by OS) - tokens are still preserved
  ///   and will be checked on next app start via SplashScreen
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ❌ DISABLED: Do NOT clear tokens on lifecycle changes!
    // This causes users to be logged out when app goes to background
    // Tokens should only be cleared on explicit logout

    // Log lifecycle changes for debugging
    debugPrint('[AppTokenManager] App lifecycle changed to: $state');
    debugPrint('[AppTokenManager] Tokens preserved - user stays logged in');

    // if (state == AppLifecycleState.inactive ||
    //     state == AppLifecycleState.detached) {
    //   _tokenService.clearTokens();
    //   debugPrint(
    //     '[AppTokenManager] Tokens cleared due to app lifecycle: $state',
    //   );
    // }
  }

  /// Dispose observer nếu cần
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
