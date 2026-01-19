// models/state/chatbot_state.dart
import 'package:SmartQuitIoT/models/chat_message.dart';

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isConnected;
  final bool isSending;
  final String? errorMessage;

  ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.isSending = false,
    this.errorMessage,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isConnected,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
