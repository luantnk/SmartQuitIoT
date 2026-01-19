import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification Refresh Provider
/// 
/// This provider is used to trigger notification refresh across the app.
/// When a notification is received via WebSocket or when user performs actions
/// that should update notifications, this provider is triggered.
/// 
/// Usage:
/// - Trigger refresh: ref.read(notificationRefreshProvider.notifier).refreshNotifications()
/// - Listen for changes: ref.listen(notificationRefreshProvider, (previous, next) { ... })
final notificationRefreshProvider = 
    StateNotifierProvider<NotificationRefreshNotifier, int>((ref) {
  return NotificationRefreshNotifier();
});

class NotificationRefreshNotifier extends StateNotifier<int> {
  NotificationRefreshNotifier() : super(0);

  /// Trigger notification refresh
  void refreshNotifications() {
    print('🔄 [NotificationRefresh] Triggering notification refresh...');
    state = state + 1; // Increment counter to trigger listeners
  }

  /// Trigger unread count refresh only (lighter weight)
  void refreshUnreadCount() {
    print('🔄 [NotificationRefresh] Triggering unread count refresh...');
    state = state + 1;
  }
}
