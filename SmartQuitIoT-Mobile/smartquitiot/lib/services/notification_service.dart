import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/notification_response.dart';
import '../models/achievement_notification.dart';

class NotificationService {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  final Dio _dio;
  static const Duration _timeout = Duration(seconds: 30);

  NotificationService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
    print('🔔 [NotificationService] Base URL: $_baseUrl');
  }

  /// Get all notifications with pagination and filters
  Future<NotificationResponse> getAllNotifications({
    required String accessToken,
    bool? isRead,
    String? type,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final url = '$_baseUrl/notifications/all';
      final request = NotificationRequest(
        isRead: isRead,
        type: type,
        page: page,
        size: size,
      );

      print('📡 [NotificationService] POST: $url');
      print('📦 [NotificationService] Request: ${request.toJson()}');
      print(
        '🔑 [NotificationService] Token: ${accessToken.substring(0, 20)}...',
      );

      final response = await _dio.post(
        url,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('✅ [NotificationService] Status: ${response.statusCode}');
      print('📦 [NotificationService] Response: ${response.data}');

      return NotificationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ [NotificationService] Error getting notifications: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead({required String accessToken}) async {
    try {
      final url = '$_baseUrl/notifications/read-all';
      print('📡 [NotificationService] PUT: $url');

      final response = await _dio.put(
        url,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print(
        '✅ [NotificationService] Mark all read - Status: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [NotificationService] Error marking all as read: $e');
      rethrow;
    }
  }

  /// Mark a single notification as read
  Future<bool> markAsRead({
    required String accessToken,
    required int notificationId,
  }) async {
    try {
      final url = '$_baseUrl/notifications/$notificationId/read';
      print('📡 [NotificationService] PUT: $url');

      final response = await _dio.put(
        url,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print(
        '✅ [NotificationService] Mark as read - Status: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [NotificationService] Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Delete a single notification (soft delete)
  Future<bool> deleteNotification({
    required String accessToken,
    required int notificationId,
  }) async {
    try {
      final url = '$_baseUrl/notifications/$notificationId';
      print('📡 [NotificationService] DELETE: $url');

      final response = await _dio.delete(
        url,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print('✅ [NotificationService] Delete - Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ [NotificationService] Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications({required String accessToken}) async {
    try {
      final url = '$_baseUrl/notifications/delete-all';
      print('📡 [NotificationService] DELETE: $url');

      final response = await _dio.delete(
        url,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print(
        '✅ [NotificationService] Delete all - Status: ${response.statusCode}',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ [NotificationService] Error deleting all notifications: $e');
      rethrow;
    }
  }

  /// Get all notifications across all types (single request without type filter)
  /// Returns NotificationResponse with pagination info
  Future<NotificationResponse> getAllNotificationsAllTypes({
    required String accessToken,
    bool? isRead,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print(
        '🔔 [NotificationService] Fetching notifications from all types (no type filter)...',
      );

      // Call getAllNotifications without type parameter to get all notifications
      // Don't pass type parameter at all so it won't be in request body
      final response = await getAllNotifications(
        accessToken: accessToken,
        isRead: isRead,
        // type is not passed, so it will be null and won't appear in request body
        page: page,
        size: size,
      );

      // Sort by createdAt descending (newest first)
      final allNotifications = List<AchievementNotification>.from(
        response.content,
      );
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print(
        '✅ [NotificationService] Total notifications from all types: ${allNotifications.length}, Page: ${response.page.number}/${response.page.totalPages - 1}',
      );

      // Return response with sorted content but keep original pagination info
      return NotificationResponse(
        content: allNotifications,
        page: response.page,
      );
    } catch (e) {
      print(
        '❌ [NotificationService] Error getting notifications from all types: $e',
      );
      rethrow;
    }
  }
}
