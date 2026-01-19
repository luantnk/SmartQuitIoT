import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:SmartQuitIoT/models/achievement_notification.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Function(String?)? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notification tapped: ${response.payload}');
        onNotificationTap?.call(response.payload);
      },
    );

    _initialized = true;
    debugPrint('✅ Local notifications initialized');
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  Future<void> showAchievementNotification(AchievementNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'achievement_channel',
      'Achievements',
      channelDescription: 'Notifications for unlocked achievements',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF00D09E),
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      notification.id,
      notification.title,
      notification.content,
      notificationDetails,
      payload: notification.deepLink,
    );

    debugPrint('🔔 Showed notification: ${notification.title}');
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
