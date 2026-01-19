import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:SmartQuitIoT/models/achievement_notification.dart';
import 'package:SmartQuitIoT/repositories/auth_repository.dart';

class WebSocketService {
  final AuthRepository _authRepository;
  StompClient? _stompClient;
  StreamController<AchievementNotification>? _notificationController;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int? _currentAccountId;

  WebSocketService(this._authRepository) {
    _notificationController =
        StreamController<AchievementNotification>.broadcast();
  }

  bool get isConnected => _isConnected;
  Stream<AchievementNotification> get notificationStream =>
      _notificationController!.stream;

  Future<void> connect(int accountId) async {
    if (_isConnected && _currentAccountId == accountId) {
      debugPrint('🟢 WebSocket already connected for account $accountId');
      return;
    }

    _currentAccountId = accountId;
    // Get base URL - keep /api if present, backend might need /api/ws
    var baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

    final wsUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final fullWsUrl = '$wsUrl/ws';

    debugPrint('🔌 Connecting to WebSocket: $fullWsUrl');
    debugPrint('📡 Subscribing to topic: /topic/notifications/$accountId');

    try {
      final token = await _authRepository.getAccessToken();

      _stompClient = StompClient(
        config: StompConfig(
          url: fullWsUrl,
          onConnect: (StompFrame frame) {
            _isConnected = true;
            _reconnectTimer?.cancel();
            debugPrint('✅ WebSocket connected successfully!');

            // Subscribe to user's notification channel
            _stompClient!.subscribe(
              destination: '/topic/notifications/$accountId',
              callback: (StompFrame frame) {
                if (frame.body != null) {
                  try {
                    debugPrint('📨 Received notification: ${frame.body}');
                    final json = jsonDecode(frame.body!);
                    final notification = AchievementNotification.fromJson(json);
                    _notificationController?.add(notification);
                  } catch (e) {
                    debugPrint('❌ Error parsing notification: $e');
                  }
                }
              },
            );
          },
          onWebSocketError: (dynamic error) {
            debugPrint('❌ WebSocket error: $error');
            _isConnected = false;
            _scheduleReconnect(accountId);
          },
          onStompError: (StompFrame frame) {
            debugPrint('❌ STOMP error: ${frame.body}');
            _isConnected = false;
          },
          onDisconnect: (StompFrame frame) {
            debugPrint('🔴 WebSocket disconnected');
            _isConnected = false;
            _scheduleReconnect(accountId);
          },
          beforeConnect: () async {
            debugPrint('🔄 Before connect callback');
          },
          stompConnectHeaders: token != null
              ? {'Authorization': 'Bearer $token'}
              : {},
          webSocketConnectHeaders: token != null
              ? {'Authorization': 'Bearer $token'}
              : {},
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          reconnectDelay: const Duration(seconds: 5),
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      debugPrint('❌ Error connecting to WebSocket: $e');
      _isConnected = false;
      _scheduleReconnect(accountId);
    }
  }

  void _scheduleReconnect(int accountId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      debugPrint('🔄 Attempting to reconnect WebSocket...');
      connect(accountId);
    });
  }

  Future<void> disconnect() async {
    debugPrint('🔌 Disconnecting WebSocket...');
    _reconnectTimer?.cancel();
    _stompClient?.deactivate();
    _isConnected = false;
    _currentAccountId = null;
  }

  void dispose() {
    disconnect();
    _notificationController?.close();
    _notificationController = null;
  }
}
