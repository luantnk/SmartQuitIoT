// viewmodels/chatbot_view_model.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:SmartQuitIoT/models/chat_message.dart';
import 'package:SmartQuitIoT/models/state/chatbot_state.dart';
import 'package:SmartQuitIoT/services/chatbot_service.dart';
import 'package:SmartQuitIoT/repositories/chatbot_repository.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';

class ChatbotViewModel extends StateNotifier<ChatbotState> {
  final TokenStorageService _tokenStorage;
  ChatbotRepository? _repository;
  StreamSubscription<ChatMessage>? _messageSubscription;

  ChatbotViewModel(this._tokenStorage) : super(ChatbotState());

  /// Initialize chatbot (load history + connect WebSocket)
  Future<void> initialize() async {
    try {
      debugPrint('🚀 [ChatbotViewModel] Initializing chatbot...');
      state = state.copyWith(isLoading: true, clearError: true);

      // Get token and parse memberId
      final token = await _tokenStorage.getAccessToken();
      int? memberId;
      
      if (token != null) {
        try {
          final decoded = JwtDecoder.decode(token);
          memberId = decoded['memberId'] != null 
              ? int.tryParse(decoded['memberId'].toString()) 
              : null;
          debugPrint('✅ [ChatbotViewModel] Member ID: $memberId');
        } catch (e) {
          debugPrint('❌ [ChatbotViewModel] Error parsing token: $e');
        }
      }

      // Create service and repository
      final dio = Dio();
      final service = ChatbotService(dio, token, memberId);
      _repository = ChatbotRepository(service);

      // Load chat history
      final messages = await _repository!.loadChatHistory();
      debugPrint('✅ [ChatbotViewModel] Loaded ${messages.length} messages');

      state = state.copyWith(messages: messages);

      // Connect WebSocket
      await _repository!.connectWebSocket();
      debugPrint('✅ [ChatbotViewModel] WebSocket connected');

      // Listen to real-time messages
      _messageSubscription = _repository!.messageStream.listen(
        (message) {
          debugPrint('📨 [ChatbotViewModel] Received real-time message');
          _addMessage(message);
        },
        onError: (error) {
          debugPrint('❌ [ChatbotViewModel] Stream error: $error');
        },
      );

      state = state.copyWith(
        isLoading: false,
        isConnected: true,
      );
      debugPrint('✅ [ChatbotViewModel] Initialization complete');
    } catch (e) {
      debugPrint('❌ [ChatbotViewModel] Initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize chatbot: $e',
      );
    }
  }

  /// Send message to chatbot
  Future<void> sendMessage(String text, List<ChatMessageMedia>? media) async {
    if (text.trim().isEmpty) return;
    if (_repository == null) {
      debugPrint('⚠️ [ChatbotViewModel] Repository not initialized');
      state = state.copyWith(errorMessage: 'Chatbot not initialized');
      return;
    }

    try {
      debugPrint('📤 [ChatbotViewModel] Sending message...');
      state = state.copyWith(isSending: true, clearError: true);

      // Add user message to UI immediately
      final userMessage = ChatMessage(
        messageType: 'USER',
        text: text.trim(),
        media: media,
        timestamp: DateTime.now(),
      );
      _addMessage(userMessage);

      // Add loading indicator for AI response
      final loadingMessage = ChatMessage(
        messageType: 'ASSISTANT',
        text: '',
        timestamp: DateTime.now(),
        isLoading: true,
      );
      _addMessage(loadingMessage);

      // Send to backend via WebSocket
      await _repository!.sendMessage(text.trim(), media);
      debugPrint('✅ [ChatbotViewModel] Message sent');

      state = state.copyWith(isSending: false);
      
      // Safety timeout: Remove loading message after 30 seconds if no response
      Future.delayed(const Duration(seconds: 30), () {
        debugPrint('⏰ [ChatbotViewModel] Loading timeout - removing loading messages');
        final currentMessages = state.messages.where((m) => !m.isLoading).toList();
        if (currentMessages.length != state.messages.length) {
          state = state.copyWith(messages: currentMessages);
        }
      });
    } catch (e) {
      debugPrint('❌ [ChatbotViewModel] Send error: $e');
      
      // Remove loading message on error
      final filteredMessages = state.messages
          .where((m) => !m.isLoading)
          .toList();
      
      state = state.copyWith(
        isSending: false,
        messages: filteredMessages,
        errorMessage: 'Failed to send message: $e',
      );
    }
  }

  /// Add message to chat list
  void _addMessage(ChatMessage message) {
    debugPrint('📥 [ChatbotViewModel] Adding message: type=${message.messageType}, isLoading=${message.isLoading}, id=${message.id}, text=${message.text.length > 50 ? message.text.substring(0, 50) : message.text}...');
    
    final currentMessages = List<ChatMessage>.from(state.messages);
    
    // Check for duplicates first
    bool isDuplicate = false;
    
    // If message has an ID, check by ID first (most reliable)
    if (message.id != null && message.id!.isNotEmpty) {
      isDuplicate = currentMessages.any((m) => m.id == message.id && m.id!.isNotEmpty);
      if (isDuplicate) {
        debugPrint('⚠️ [ChatbotViewModel] Duplicate message detected by ID: ${message.id}');
      }
    }
    
    // If not duplicate by ID, check by content (text + messageType)
    // This handles cases where messages don't have IDs or have duplicate IDs
    if (!isDuplicate) {
      isDuplicate = currentMessages.any((m) {
        // Must match message type
        if (m.messageType != message.messageType) return false;
        
        // Must match text content (exact match for now)
        if (m.text.trim() != message.text.trim()) return false;
        
        // If both have IDs and they're different, not a duplicate
        if (m.id != null && message.id != null && 
            m.id!.isNotEmpty && message.id!.isNotEmpty && 
            m.id != message.id) {
          return false;
        }
        
        // If both have timestamps, check if they're very close (within 2 seconds)
        // This prevents false positives from messages sent at different times
        if (m.timestamp != null && message.timestamp != null) {
          final timeDiff = (m.timestamp!.difference(message.timestamp!).inSeconds).abs();
          // If timestamps are more than 2 seconds apart, likely different messages
          if (timeDiff > 2) {
            return false;
          }
        }
        
        // Consider it a duplicate if text and type match
        return true;
      });
      
      if (isDuplicate) {
        debugPrint('⚠️ [ChatbotViewModel] Duplicate message detected by content: ${message.text.length > 30 ? message.text.substring(0, 30) : message.text}...');
      }
    }
    
    // Skip if duplicate (unless it's a loading message being replaced)
    if (isDuplicate && !message.isLoading) {
      debugPrint('⏭️ [ChatbotViewModel] Skipping duplicate message');
      return;
    }
    
    // Count loading messages before
    final loadingCountBefore = currentMessages.where((m) => m.isLoading).length;
    debugPrint('🔍 [ChatbotViewModel] Loading messages before: $loadingCountBefore');
    
    // Remove ALL loading messages if this is a real AI response
    if (message.isAssistant && !message.isLoading) {
      debugPrint('✅ [ChatbotViewModel] Removing all loading messages...');
      currentMessages.removeWhere((m) => m.isLoading);
      
      final loadingCountAfter = currentMessages.where((m) => m.isLoading).length;
      debugPrint('🔍 [ChatbotViewModel] Loading messages after: $loadingCountAfter');
    }
    
    // If this is a duplicate loading message, replace the existing one instead of adding
    if (isDuplicate && message.isLoading) {
      // Replace existing loading message
      final index = currentMessages.indexWhere((m) => 
        m.isLoading && 
        m.messageType == message.messageType &&
        (m.id == message.id || (m.id == null && message.id == null))
      );
      if (index != -1) {
        currentMessages[index] = message;
        debugPrint('🔄 [ChatbotViewModel] Replaced loading message at index $index');
      } else {
        currentMessages.add(message);
      }
    } else {
      currentMessages.add(message);
    }
    
    state = state.copyWith(messages: currentMessages);
    
    debugPrint('📊 [ChatbotViewModel] Total messages now: ${currentMessages.length}');
  }

  /// Reload chat history
  Future<void> reloadHistory() async {
    if (_repository == null) {
      await initialize();
      return;
    }
    
    try {
      debugPrint('🔄 [ChatbotViewModel] Reloading chat history...');
      state = state.copyWith(isLoading: true, clearError: true);

      final messages = await _repository!.loadChatHistory();
      state = state.copyWith(messages: messages, isLoading: false);
      
      debugPrint('✅ [ChatbotViewModel] History reloaded');
    } catch (e) {
      debugPrint('❌ [ChatbotViewModel] Reload error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reload history: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    debugPrint('🗑️ [ChatbotViewModel] Disposing...');
    _messageSubscription?.cancel();
    _repository?.disconnectWebSocket();
    _repository?.dispose();
    super.dispose();
  }
}
