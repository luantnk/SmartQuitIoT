// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';
// import '../models/achievement_notification.dart';

// class NotificationStorageService {
//   static const String _notificationsKey = 'cached_notifications';
//   static const int _maxNotifications = 100; // Limit stored notifications

//   /// Save notifications to local storage
//   Future<void> saveNotifications(
//     List<AchievementNotification> notifications,
//   ) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Limit to max notifications (keep newest)
//       final limitedNotifications = notifications
//           .take(_maxNotifications)
//           .toList();

//       // Convert to JSON
//       final jsonList = limitedNotifications.map((n) => n.toJson()).toList();
//       final jsonString = jsonEncode(jsonList);

//       // Save to SharedPreferences
//       await prefs.setString(_notificationsKey, jsonString);

//       debugPrint(
//         '💾 [NotificationStorage] Saved ${limitedNotifications.length} notifications to storage',
//       );
//     } catch (e, stackTrace) {
//       debugPrint('❌ [NotificationStorage] Error saving notifications: $e');
//       debugPrint('Stack trace: $stackTrace');
//     }
//   }

//   /// Load notifications from local storage
//   Future<List<AchievementNotification>> loadNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = prefs.getString(_notificationsKey);

//       if (jsonString == null || jsonString.isEmpty) {
//         debugPrint('📭 [NotificationStorage] No cached notifications found');
//         return [];
//       }

//       // Parse JSON
//       final jsonList = jsonDecode(jsonString) as List<dynamic>;
//       final notifications = jsonList
//           .map(
//             (json) =>
//                 AchievementNotification.fromJson(json as Map<String, dynamic>),
//           )
//           .toList();

//       debugPrint(
//         '📬 [NotificationStorage] Loaded ${notifications.length} notifications from storage',
//       );
//       return notifications;
//     } catch (e, stackTrace) {
//       debugPrint('❌ [NotificationStorage] Error loading notifications: $e');
//       debugPrint('Stack trace: $stackTrace');
//       return [];
//     }
//   }

//   /// Add a single notification to storage
//   Future<void> addNotification(AchievementNotification notification) async {
//     try {
//       // Load existing notifications
//       final notifications = await loadNotifications();

//       // Add new notification at the beginning
//       notifications.insert(0, notification);

//       // Save updated list
//       await saveNotifications(notifications);

//       debugPrint(
//         '➕ [NotificationStorage] Added notification: ${notification.title}',
//       );
//     } catch (e) {
//       debugPrint('❌ [NotificationStorage] Error adding notification: $e');
//     }
//   }

//   /// Mark notification as read
//   Future<void> markAsRead(int notificationId) async {
//     try {
//       final notifications = await loadNotifications();

//       // Find and update notification
//       final updatedNotifications = notifications.map((n) {
//         if (n.id == notificationId) {
//           return n.copyWith(isRead: true);
//         }
//         return n;
//       }).toList();

//       // Save updated list
//       await saveNotifications(updatedNotifications);

//       debugPrint(
//         '✅ [NotificationStorage] Marked notification $notificationId as read',
//       );
//     } catch (e) {
//       debugPrint('❌ [NotificationStorage] Error marking as read: $e');
//     }
//   }

//   /// Clear all notifications
//   Future<void> clearAll() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_notificationsKey);

//       debugPrint('🗑️ [NotificationStorage] Cleared all notifications');
//     } catch (e) {
//       debugPrint('❌ [NotificationStorage] Error clearing notifications: $e');
//     }
//   }

//   /// Get unread count
//   Future<int> getUnreadCount() async {
//     try {
//       final notifications = await loadNotifications();
//       final unreadCount = notifications.where((n) => !n.isRead).length;

//       debugPrint('🔢 [NotificationStorage] Unread count: $unreadCount');
//       return unreadCount;
//     } catch (e) {
//       debugPrint('❌ [NotificationStorage] Error getting unread count: $e');
//       return 0;
//     }
//   }
// }
