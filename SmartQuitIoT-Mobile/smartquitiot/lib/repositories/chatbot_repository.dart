// repositories/chatbot_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:SmartQuitIoT/models/chat_message.dart';
import 'package:SmartQuitIoT/services/chatbot_service.dart';

class ChatbotRepository {
  final ChatbotService _chatbotService;

  ChatbotRepository(this._chatbotService);

  /// Load chat history from API
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      debugPrint('📖 [ChatbotRepository] Loading chat history...');
      final messages = await _chatbotService.loadChatHistory();
      debugPrint('✅ [ChatbotRepository] Loaded ${messages.length} messages');
      return messages;
    } catch (e) {
      debugPrint('❌ [ChatbotRepository] Error loading chat history: $e');
      rethrow;
    }
  }

  /// Connect to WebSocket
  Future<void> connectWebSocket() async {
    try {
      debugPrint('🔌 [ChatbotRepository] Connecting WebSocket...');
      await _chatbotService.connectWebSocket();
      debugPrint('✅ [ChatbotRepository] WebSocket connected');
    } catch (e) {
      debugPrint('❌ [ChatbotRepository] Error connecting WebSocket: $e');
      rethrow;
    }
  }

  /// Send message to chatbot
  Future<void> sendMessage(String text, List<ChatMessageMedia>? media) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      debugPrint('📤 [ChatbotRepository] Sending message...');
      debugPrint('📝 [ChatbotRepository] Text: $text');
      debugPrint('🖼️ [ChatbotRepository] Media: ${media?.length ?? 0} items');

      _chatbotService.sendMessage(text, media);
      debugPrint('✅ [ChatbotRepository] Message sent successfully');
    } catch (e) {
      debugPrint('❌ [ChatbotRepository] Error sending message: $e');
      rethrow;
    }
  }

  /// Get real-time message stream
  Stream<ChatMessage> get messageStream => _chatbotService.messageStream;

  /// Check if WebSocket is connected
  bool get isConnected => _chatbotService.isConnected;

  /// Disconnect WebSocket
  Future<void> disconnectWebSocket() async {
    try {
      debugPrint('🔌 [ChatbotRepository] Disconnecting WebSocket...');
      await _chatbotService.disconnectWebSocket();
      debugPrint('✅ [ChatbotRepository] WebSocket disconnected');
    } catch (e) {
      debugPrint('❌ [ChatbotRepository] Error disconnecting: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _chatbotService.dispose();
  }
}
