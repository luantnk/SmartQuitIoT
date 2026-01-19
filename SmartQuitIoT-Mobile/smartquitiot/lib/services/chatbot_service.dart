// services/chatbot_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:SmartQuitIoT/models/chat_message.dart';

class ChatbotService {
  final Dio _dio;
  final String? _token;
  final int? _memberId;

  StompClient? _stompClient;
  StreamController<ChatMessage>? _messageController;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  ChatbotService(this._dio, this._token, this._memberId) {
    _messageController = StreamController<ChatMessage>.broadcast();
  }

  bool get isConnected => _isConnected;
  Stream<ChatMessage> get messageStream => _messageController!.stream;

  /// Load chat history
  Future<List<ChatMessage>> loadChatHistory() async {
    if (_memberId == null) {
      throw Exception('Member ID is required');
    }

    debugPrint(
      '📖 [ChatbotService] Loading chat history for member $_memberId',
    );

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      final url = '$baseUrl/chatbot/$_memberId';

      debugPrint('🌐 [ChatbotService] URL: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: _token != null ? {'Authorization': 'Bearer $_token'} : {},
        ),
      );

      debugPrint('📊 [ChatbotService] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('✅ [ChatbotService] Loaded ${data.length} messages');

        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [ChatbotService] Error loading chat history: $e');
      debugPrint('🧩 [ChatbotService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Connect to WebSocket
  Future<void> connectWebSocket() async {
    if (_memberId == null) {
      debugPrint('⚠️ [ChatbotService] Cannot connect: Member ID is null');
      return;
    }

    if (_isConnected) {
      debugPrint('🟢 [ChatbotService] WebSocket already connected');
      return;
    }

    // Get base URL - keep /api if present, backend might need /api/ws
    var baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

    final wsUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final fullWsUrl = '$wsUrl/ws';

    debugPrint('🔌 [ChatbotService] Connecting to WebSocket: $fullWsUrl');
    debugPrint('📡 [ChatbotService] Subscribing to: /topic/chatbot/$_memberId');

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: fullWsUrl,
          onConnect: (StompFrame frame) {
            _isConnected = true;
            _reconnectTimer?.cancel();
            debugPrint('✅ [ChatbotService] WebSocket connected!');

            // Subscribe to chatbot topic
            final subscribeDestination = '/topic/chatbot/$_memberId';
            debugPrint(
              '🔔 [ChatbotService] Subscribing to: $subscribeDestination',
            );

            _stompClient!.subscribe(
              destination: subscribeDestination,
              callback: (StompFrame frame) {
                debugPrint(
                  '📬 [ChatbotService] Frame received! Body is null: ${frame.body == null}',
                );
                if (frame.body != null) {
                  try {
                    debugPrint(
                      '📨 [ChatbotService] Received message: ${frame.body}',
                    );
                    final json = jsonDecode(frame.body!);
                    final message = ChatMessage.fromJson(json);
                    _messageController?.add(message);
                    debugPrint('✅ [ChatbotService] Message added to stream');
                  } catch (e) {
                    debugPrint('❌ [ChatbotService] Error parsing message: $e');
                    debugPrint(
                      '🧩 [ChatbotService] Stack: ${StackTrace.current}',
                    );
                  }
                } else {
                  debugPrint(
                    '⚠️ [ChatbotService] Received frame with null body',
                  );
                }
              },
            );
          },
          onWebSocketError: (dynamic error) {
            debugPrint('❌ [ChatbotService] WebSocket error: $error');
            _isConnected = false;
            _scheduleReconnect();
          },
          onStompError: (StompFrame frame) {
            debugPrint('❌ [ChatbotService] STOMP error: ${frame.body}');
            _isConnected = false;
          },
          onDisconnect: (StompFrame frame) {
            debugPrint('🔴 [ChatbotService] WebSocket disconnected');
            _isConnected = false;
            _scheduleReconnect();
          },
          stompConnectHeaders: _token != null
              ? {'Authorization': 'Bearer $_token'}
              : {},
          webSocketConnectHeaders: _token != null
              ? {'Authorization': 'Bearer $_token'}
              : {},
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          reconnectDelay: const Duration(seconds: 5),
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      debugPrint('❌ [ChatbotService] Error connecting to WebSocket: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  /// Send message via WebSocket
  void sendMessage(String text, List<ChatMessageMedia>? media) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('❌ [ChatbotService] Cannot send - WebSocket not connected');
      debugPrint('   _stompClient is null: ${_stompClient == null}');
      debugPrint('   _isConnected: $_isConnected');
      throw Exception('WebSocket not connected');
    }

    debugPrint('📤 [ChatbotService] Sending message to /app/chatbot');
    debugPrint('👤 [ChatbotService] Member ID: $_memberId');
    debugPrint('📝 [ChatbotService] Text: $text');
    debugPrint('🖼️ [ChatbotService] Media count: ${media?.length ?? 0}');

    final payload = {
      'memberId': _memberId,
      'message':
          text, // ← Changed from 'text' to 'message' to match backend DTO
      if (media != null && media.isNotEmpty)
        'media': media.map((m) => m.toJson()).toList(),
    };

    debugPrint('📦 [ChatbotService] Full payload: ${jsonEncode(payload)}');

    _stompClient!.send(destination: '/app/chatbot', body: jsonEncode(payload));

    debugPrint('✅ [ChatbotService] Message sent successfully to backend');
    debugPrint(
      '⏳ [ChatbotService] Waiting for response on /topic/chatbot/$_memberId...',
    );
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      debugPrint('🔄 [ChatbotService] Attempting to reconnect WebSocket...');
      connectWebSocket();
    });
  }

  /// Disconnect WebSocket
  Future<void> disconnectWebSocket() async {
    debugPrint('🔌 [ChatbotService] Disconnecting WebSocket...');
    _reconnectTimer?.cancel();
    _stompClient?.deactivate();
    _isConnected = false;
  }

  /// Dispose resources
  void dispose() {
    disconnectWebSocket();
    _messageController?.close();
    _messageController = null;
  }
}
