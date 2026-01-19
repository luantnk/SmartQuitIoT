import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/services/notification_service.dart';
import 'package:SmartQuitIoT/repositories/notification_repository.dart';
import 'package:SmartQuitIoT/models/achievement_notification.dart';
import 'package:SmartQuitIoT/models/notification_response.dart';
import 'package:SmartQuitIoT/providers/user_provider.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationService(dio: dio);
});

// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationRepository(service);
});

// Notification State
class NotificationState {
  final List<AchievementNotification> notifications;
  final List<AchievementNotification> readNotifications;
  final List<AchievementNotification> unreadNotifications;
  final bool isLoading;
  final bool isLoadingRead;
  final bool isLoadingUnread;
  final bool isLoadingMoreRead;
  final bool isLoadingMoreUnread;
  final String? error;
  final int unreadCount;

  // Pagination info for read notifications
  final int readCurrentPage;
  final int readTotalPages;
  final bool hasMoreRead;

  // Pagination info for unread notifications
  final int unreadCurrentPage;
  final int unreadTotalPages;
  final bool hasMoreUnread;

  NotificationState({
    this.notifications = const [],
    this.readNotifications = const [],
    this.unreadNotifications = const [],
    this.isLoading = false,
    this.isLoadingRead = false,
    this.isLoadingUnread = false,
    this.isLoadingMoreRead = false,
    this.isLoadingMoreUnread = false,
    this.error,
    this.unreadCount = 0,
    this.readCurrentPage = 0,
    this.readTotalPages = 0,
    this.hasMoreRead = false,
    this.unreadCurrentPage = 0,
    this.unreadTotalPages = 0,
    this.hasMoreUnread = false,
  });

  NotificationState copyWith({
    List<AchievementNotification>? notifications,
    List<AchievementNotification>? readNotifications,
    List<AchievementNotification>? unreadNotifications,
    bool? isLoading,
    bool? isLoadingRead,
    bool? isLoadingUnread,
    bool? isLoadingMoreRead,
    bool? isLoadingMoreUnread,
    String? error,
    int? unreadCount,
    int? readCurrentPage,
    int? readTotalPages,
    bool? hasMoreRead,
    int? unreadCurrentPage,
    int? unreadTotalPages,
    bool? hasMoreUnread,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      readNotifications: readNotifications ?? this.readNotifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingRead: isLoadingRead ?? this.isLoadingRead,
      isLoadingUnread: isLoadingUnread ?? this.isLoadingUnread,
      isLoadingMoreRead: isLoadingMoreRead ?? this.isLoadingMoreRead,
      isLoadingMoreUnread: isLoadingMoreUnread ?? this.isLoadingMoreUnread,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      readCurrentPage: readCurrentPage ?? this.readCurrentPage,
      readTotalPages: readTotalPages ?? this.readTotalPages,
      hasMoreRead: hasMoreRead ?? this.hasMoreRead,
      unreadCurrentPage: unreadCurrentPage ?? this.unreadCurrentPage,
      unreadTotalPages: unreadTotalPages ?? this.unreadTotalPages,
      hasMoreUnread: hasMoreUnread ?? this.hasMoreUnread,
    );
  }
}

// Notification ViewModel
class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationViewModel(this._repository, this._ref)
    : super(NotificationState());

  /// Get all notifications from all types
  Future<void> getAllNotifications({
    bool? isRead,
    int page = 0,
    int size = 10,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('🔔 [NotificationViewModel] Loading all notifications...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await _repository.getAllNotificationsAllTypes(
        accessToken: token,
        isRead: isRead,
        page: page,
        size: size,
      );

      // Calculate unread count
      final unreadCount = response.content.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: response.content,
        isLoading: false,
        unreadCount: unreadCount,
      );

      print(
        '✅ [NotificationViewModel] Loaded ${response.content.length} notifications',
      );
      print('📊 [NotificationViewModel] Unread count: $unreadCount');
    } catch (e) {
      print('❌ [NotificationViewModel] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Get unread count only
  Future<void> getUnreadCount() async {
    try {
      print('🔔 [NotificationViewModel] Getting unread count...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final count = await _repository.getUnreadCount(accessToken: token);

      state = state.copyWith(unreadCount: count);
      print('📊 [NotificationViewModel] Unread count: $count');
    } catch (e) {
      print('❌ [NotificationViewModel] Error getting unread count: $e');
      // Don't update state with error, just log it
    }
  }

  /// Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      print('🔔 [NotificationViewModel] Marking all as read...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.markAllAsRead(accessToken: token);

      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );

        print('✅ [NotificationViewModel] All marked as read');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error marking all as read: $e');
      return false;
    }
  }

  /// Mark single notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      print(
        '🔔 [NotificationViewModel] Marking notification $notificationId as read...',
      );

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.markAsRead(
        accessToken: token,
        notificationId: notificationId,
      );

      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        // Recalculate unread count
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );

        print(
          '✅ [NotificationViewModel] Notification $notificationId marked as read',
        );
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      print(
        '🔔 [NotificationViewModel] Deleting notification $notificationId...',
      );

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.deleteNotification(
        accessToken: token,
        notificationId: notificationId,
      );

      if (success) {
        // Remove from local state
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        // Recalculate unread count
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );

        print('✅ [NotificationViewModel] Notification $notificationId deleted');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      print('🔔 [NotificationViewModel] Deleting all notifications...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.deleteAllNotifications(
        accessToken: token,
      );

      if (success) {
        state = state.copyWith(notifications: [], unreadCount: 0);

        print('✅ [NotificationViewModel] All notifications deleted');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error deleting all notifications: $e');
      return false;
    }
  }

  /// Get read notifications only
  Future<void> getReadNotifications({
    int page = 0,
    int size = 10,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        state = state.copyWith(isLoadingMoreRead: true, error: null);
      } else {
        state = state.copyWith(isLoadingRead: true, error: null);
      }
      print(
        '🔔 [NotificationViewModel] Loading read notifications (page: $page)...',
      );

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await _repository.getAllNotificationsAllTypes(
        accessToken: token,
        isRead: true,
        page: page,
        size: size,
      );

      final List<AchievementNotification> updatedNotifications;
      if (loadMore) {
        // Append new notifications to existing list
        updatedNotifications = [
          ...state.readNotifications,
          ...response.content,
        ];
      } else {
        // Replace with new notifications
        updatedNotifications = response.content;
      }

      final currentPage = response.page.number;
      final totalPages = response.page.totalPages;
      final hasMore = currentPage < totalPages - 1;

      state = state.copyWith(
        readNotifications: updatedNotifications,
        isLoadingRead: false,
        isLoadingMoreRead: false,
        readCurrentPage: currentPage,
        readTotalPages: totalPages,
        hasMoreRead: hasMore,
      );

      print(
        '✅ [NotificationViewModel] Loaded ${response.content.length} read notifications',
      );
      print(
        '📄 [NotificationViewModel] Page: ${currentPage + 1}/$totalPages, Has more: $hasMore',
      );
    } catch (e) {
      print('❌ [NotificationViewModel] Error loading read notifications: $e');
      state = state.copyWith(
        isLoadingRead: false,
        isLoadingMoreRead: false,
        error: e.toString(),
      );
    }
  }

  /// Get unread notifications only
  Future<void> getUnreadNotifications({
    int page = 0,
    int size = 10,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        state = state.copyWith(isLoadingMoreUnread: true, error: null);
      } else {
        state = state.copyWith(isLoadingUnread: true, error: null);
      }
      print(
        '🔔 [NotificationViewModel] Loading unread notifications (page: $page)...',
      );

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await _repository.getAllNotificationsAllTypes(
        accessToken: token,
        isRead: false,
        page: page,
        size: size,
      );

      final List<AchievementNotification> updatedNotifications;
      if (loadMore) {
        // Append new notifications to existing list
        updatedNotifications = [
          ...state.unreadNotifications,
          ...response.content,
        ];
      } else {
        // Replace with new notifications
        updatedNotifications = response.content;
      }

      final currentPage = response.page.number;
      final totalPages = response.page.totalPages;
      final hasMore = currentPage < totalPages - 1;

      state = state.copyWith(
        unreadNotifications: updatedNotifications,
        isLoadingUnread: false,
        isLoadingMoreUnread: false,
        unreadCount: updatedNotifications.length,
        unreadCurrentPage: currentPage,
        unreadTotalPages: totalPages,
        hasMoreUnread: hasMore,
      );

      print(
        '✅ [NotificationViewModel] Loaded ${response.content.length} unread notifications',
      );
      print(
        '📄 [NotificationViewModel] Page: ${currentPage + 1}/$totalPages, Has more: $hasMore',
      );
    } catch (e) {
      print('❌ [NotificationViewModel] Error loading unread notifications: $e');
      state = state.copyWith(
        isLoadingUnread: false,
        isLoadingMoreUnread: false,
        error: e.toString(),
      );
    }
  }

  /// Load more read notifications
  Future<void> loadMoreReadNotifications() async {
    if (!state.hasMoreRead || state.isLoadingMoreRead) {
      return;
    }
    final nextPage = state.readCurrentPage + 1;
    await getReadNotifications(page: nextPage, size: 10, loadMore: true);
  }

  /// Load more unread notifications
  Future<void> loadMoreUnreadNotifications() async {
    if (!state.hasMoreUnread || state.isLoadingMoreUnread) {
      return;
    }
    final nextPage = state.unreadCurrentPage + 1;
    await getUnreadNotifications(page: nextPage, size: 10, loadMore: true);
  }

  /// Refresh notifications
  Future<void> refresh() async {
    print('🔄 [NotificationViewModel] Refreshing notifications...');
    await getAllNotifications();
  }

  /// Refresh both read and unread tabs
  Future<void> refreshTabs() async {
    print('🔄 [NotificationViewModel] Refreshing both tabs...');
    await Future.wait([getReadNotifications(), getUnreadNotifications()]);
  }
}

// Notification ViewModel Provider
final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationViewModel(repository, ref);
    });

// Convenience providers for specific use cases

/// All notifications provider
final allNotificationsProvider = Provider<List<AchievementNotification>>((ref) {
  return ref.watch(notificationViewModelProvider).notifications;
});

/// Unread notifications provider
final unreadNotificationsProvider = Provider<List<AchievementNotification>>((
  ref,
) {
  final notifications = ref.watch(notificationViewModelProvider).notifications;
  return notifications.where((n) => !n.isRead).toList();
});

/// Unread count provider
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationViewModelProvider).unreadCount;
});

/// Loading state provider
final notificationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationViewModelProvider).isLoading;
});
