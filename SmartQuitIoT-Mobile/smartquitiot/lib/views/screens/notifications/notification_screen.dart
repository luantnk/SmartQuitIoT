import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_item.dart';
import 'package:SmartQuitIoT/providers/notification_provider.dart';
import 'package:SmartQuitIoT/providers/notification_refresh_provider.dart';
import 'package:SmartQuitIoT/models/achievement_notification.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMarkingAllAsRead = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load both tabs on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).getUnreadNotifications();
      ref.read(notificationViewModelProvider.notifier).getReadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTapNotification(AchievementNotification notification) async {
    // Mark as read when tapping with visual feedback
    if (!notification.isRead) {
      await ref
          .read(notificationViewModelProvider.notifier)
          .markAsRead(notification.id);

      // Refresh both tabs to sync UI with API state
      if (mounted) {
        await ref.read(notificationViewModelProvider.notifier).refreshTabs();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Marked as read'),
              ],
            ),
            backgroundColor: const Color(0xFF00D09E),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    // Show modern dialog with notification details
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getNotificationColor(
                          notification.type,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getNotificationColor(notification.type),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Content
                Text(
                  notification.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                // Time
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      _formatNotificationTime(notification.createdAt),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ACHIEVEMENT':
        return Icons.emoji_events;
      case 'MISSION':
        return Icons.check_circle;
      case 'PHASE':
        return Icons.timeline;
      case 'QUIT_PLAN':
        return Icons.calendar_today;
      case 'SYSTEM':
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'ACHIEVEMENT':
        return Colors.amber;
      case 'MISSION':
        return Colors.green;
      case 'PHASE':
        return Colors.blue;
      case 'QUIT_PLAN':
        return Colors.orange;
      case 'SYSTEM':
        return Colors.purple;
      default:
        return const Color(0xFF00D09E);
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final datePart = DateFormat('EEE, dd MMM yyyy').format(localDateTime);
    final timePart = DateFormat('HH:mm').format(localDateTime);
    return '$datePart • $timePart';
  }

  @override
  Widget build(BuildContext context) {
    // Listen for refresh trigger
    ref.listen(notificationRefreshProvider, (previous, next) {
      if (previous != next) {
        print('🔄 [NotificationScreen] Refresh triggered, reloading...');
        ref.read(notificationViewModelProvider.notifier).refreshTabs();
      }
    });

    final notificationState = ref.watch(notificationViewModelProvider);
    final readNotifications = notificationState.readNotifications;
    final unreadNotifications = notificationState.unreadNotifications;
    final isLoadingRead = notificationState.isLoadingRead;
    final isLoadingUnread = notificationState.isLoadingUnread;
    final isLoadingMoreRead = notificationState.isLoadingMoreRead;
    final isLoadingMoreUnread = notificationState.isLoadingMoreUnread;
    final unreadCount = notificationState.unreadCount;
    final hasMoreRead = notificationState.hasMoreRead;
    final hasMoreUnread = notificationState.hasMoreUnread;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00D09E), Color(0xFF00B887)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Unread'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Read'),
                  if (readNotifications.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${readNotifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (unreadNotifications.isNotEmpty ||
              readNotifications.isNotEmpty) ...[
            _isMarkingAllAsRead
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.done_all,
                          color: Colors.white,
                          size: 24,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () async {
                      if (_isMarkingAllAsRead) return;

                      setState(() => _isMarkingAllAsRead = true);

                      await ref
                          .read(notificationViewModelProvider.notifier)
                          .markAllAsRead();

                      // Refresh both tabs to sync UI with API state
                      if (mounted) {
                        await ref
                            .read(notificationViewModelProvider.notifier)
                            .refreshTabs();

                        setState(() => _isMarkingAllAsRead = false);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'All notifications marked as read',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF00D09E),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    tooltip: 'Mark all as read',
                  ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Clear All',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Unread Tab
          _buildNotificationTab(
            notifications: unreadNotifications,
            isLoading: isLoadingUnread,
            isLoadingMore: isLoadingMoreUnread,
            hasMore: hasMoreUnread,
            emptyMessage: 'No unread notifications',
            emptySubtitle: 'You\'re all caught up! ',
            onRefresh: () async {
              await ref
                  .read(notificationViewModelProvider.notifier)
                  .getUnreadNotifications();
            },
            onLoadMore: () async {
              await ref
                  .read(notificationViewModelProvider.notifier)
                  .loadMoreUnreadNotifications();
            },
            forceHideBadge: false, // Show badge in Unread tab
          ),
          // Read Tab
          _buildNotificationTab(
            notifications: readNotifications,
            isLoading: isLoadingRead,
            isLoadingMore: isLoadingMoreRead,
            hasMore: hasMoreRead,
            emptyMessage: 'No read notifications',
            emptySubtitle: 'Read notifications will appear here',
            onRefresh: () async {
              await ref
                  .read(notificationViewModelProvider.notifier)
                  .getReadNotifications();
            },
            onLoadMore: () async {
              await ref
                  .read(notificationViewModelProvider.notifier)
                  .loadMoreReadNotifications();
            },
            forceHideBadge: true, // HIDE badge in Read tab
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTab({
    required List<AchievementNotification> notifications,
    required bool isLoading,
    required bool isLoadingMore,
    required bool hasMore,
    required String emptyMessage,
    required String emptySubtitle,
    required Future<void> Function() onRefresh,
    required Future<void> Function() onLoadMore,
    bool forceHideBadge = false,
  }) {
    if (isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return _buildEmptyState(message: emptyMessage, subtitle: emptySubtitle);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount:
            notifications.length +
            (hasMore ? 1 : 0), // Add 1 for load more button
        itemBuilder: (context, index) {
          // Show load more button at the end
          if (index == notifications.length) {
            return _buildLoadMoreButton(
              isLoading: isLoadingMore,
              onTap: onLoadMore,
            );
          }

          return _buildNotificationItem(
            notifications[index],
            forceHideBadge: forceHideBadge,
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton({
    required bool isLoading,
    required Future<void> Function() onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      child: Center(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                ),
              )
            : ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.expand_more, size: 20),
                label: const Text(
                  'Load More',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00D09E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFF00D09E),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
              ),
      ),
    );
  }

  Widget _buildNotificationItem(
    AchievementNotification notification, {
    bool forceHideBadge = false,
  }) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        await ref
            .read(notificationViewModelProvider.notifier)
            .deleteNotification(notification.id);

        // Refresh both tabs
        if (mounted) {
          await ref.read(notificationViewModelProvider.notifier).refreshTabs();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Notification deleted successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF00D09E),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: NotificationItem(
        icon: _getNotificationIcon(notification.type),
        iconColor: _getNotificationColor(notification.type),
        title: notification.title,
        subtitle: notification.content,
        metadata: _formatNotificationTime(notification.createdAt),
        isUnread: !notification.isRead,
        forceHideBadge: forceHideBadge,
        onTap: () => _onTapNotification(notification),
        onDelete: () => _showDeleteConfirmDialog(notification),
      ),
    );
  }

  Widget _buildEmptyState({required String message, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF00D09E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(AchievementNotification notification) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Notification?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete this notification?',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Close dialog first
                        Navigator.pop(context);

                        // Delete notification
                        await ref
                            .read(notificationViewModelProvider.notifier)
                            .deleteNotification(notification.id);

                        // Refresh both tabs
                        if (mounted) {
                          await ref
                              .read(notificationViewModelProvider.notifier)
                              .refreshTabs();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Notification deleted successfully',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF00D09E),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Clear All Notifications?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete all notifications? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(notificationViewModelProvider.notifier)
                            .deleteAllNotifications();

                        // Refresh both tabs to show empty state
                        if (context.mounted) {
                          await ref
                              .read(notificationViewModelProvider.notifier)
                              .refreshTabs();

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'All notifications deleted',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
