import '../services/notification_service.dart';
import '../models/achievement_notification.dart';
import '../models/notification_response.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  /// Get all notifications with filters
  Future<NotificationResponse> getAllNotifications({
    required String accessToken,
    bool? isRead,
    String? type,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('📂 [NotificationRepository] Getting notifications...');
      print(
        '📂 [NotificationRepository] Filters - isRead: $isRead, type: $type, page: $page',
      );

      final response = await _notificationService.getAllNotifications(
        accessToken: accessToken,
        isRead: isRead,
        type: type,
        page: page,
        size: size,
      );

      print(
        '✅ [NotificationRepository] Got ${response.content.length} notifications',
      );
      return response;
    } catch (e) {
      print('❌ [NotificationRepository] Error getting notifications: $e');
      rethrow;
    }
  }

  /// Get all notifications from all 5 types
  /// Returns NotificationResponse with pagination info
  Future<NotificationResponse> getAllNotificationsAllTypes({
    required String accessToken,
    bool? isRead,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print(
        '📂 [NotificationRepository] Getting notifications from all types...',
      );

      final response = await _notificationService.getAllNotificationsAllTypes(
        accessToken: accessToken,
        isRead: isRead,
        page: page,
        size: size,
      );

      print(
        '✅ [NotificationRepository] Got ${response.content.length} total notifications',
      );
      print(
        '📄 [NotificationRepository] Page: ${response.page.number + 1}/${response.page.totalPages}',
      );
      return response;
    } catch (e) {
      print('❌ [NotificationRepository] Error getting all notifications: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead({required String accessToken}) async {
    try {
      print('📂 [NotificationRepository] Marking all as read...');

      final success = await _notificationService.markAllAsRead(
        accessToken: accessToken,
      );

      if (success) {
        print('✅ [NotificationRepository] All notifications marked as read');
      }
      return success;
    } catch (e) {
      print('❌ [NotificationRepository] Error marking all as read: $e');
      rethrow;
    }
  }

  /// Mark a single notification as read
  Future<bool> markAsRead({
    required String accessToken,
    required int notificationId,
  }) async {
    try {
      print(
        '📂 [NotificationRepository] Marking notification $notificationId as read...',
      );

      final success = await _notificationService.markAsRead(
        accessToken: accessToken,
        notificationId: notificationId,
      );

      if (success) {
        print(
          '✅ [NotificationRepository] Notification $notificationId marked as read',
        );
      }
      return success;
    } catch (e) {
      print(
        '❌ [NotificationRepository] Error marking notification as read: $e',
      );
      rethrow;
    }
  }

  /// Delete a single notification
  Future<bool> deleteNotification({
    required String accessToken,
    required int notificationId,
  }) async {
    try {
      print(
        '📂 [NotificationRepository] Deleting notification $notificationId...',
      );

      final success = await _notificationService.deleteNotification(
        accessToken: accessToken,
        notificationId: notificationId,
      );

      if (success) {
        print(
          '✅ [NotificationRepository] Notification $notificationId deleted',
        );
      }
      return success;
    } catch (e) {
      print('❌ [NotificationRepository] Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications({required String accessToken}) async {
    try {
      print('📂 [NotificationRepository] Deleting all notifications...');

      final success = await _notificationService.deleteAllNotifications(
        accessToken: accessToken,
      );

      if (success) {
        print('✅ [NotificationRepository] All notifications deleted');
      }
      return success;
    } catch (e) {
      print('❌ [NotificationRepository] Error deleting all notifications: $e');
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount({required String accessToken}) async {
    try {
      print('📂 [NotificationRepository] Getting unread count...');

      // Fetch only unread notifications with page 0 and size 1 to minimize data transfer
      final response = await getAllNotificationsAllTypes(
        accessToken: accessToken,
        isRead: false,
        page: 0,
        size: 100, // Get enough to show accurate count
      );

      final unreadCount = response.content.length;
      print('✅ [NotificationRepository] Unread count: $unreadCount');
      return unreadCount;
    } catch (e) {
      print('❌ [NotificationRepository] Error getting unread count: $e');
      return 0; // Return 0 on error instead of throwing
    }
  }
}
