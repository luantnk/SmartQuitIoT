// providers/chatbot_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:SmartQuitIoT/viewmodels/chatbot_view_model.dart';
import 'package:SmartQuitIoT/models/state/chatbot_state.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';

// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// Member ID Provider - Parse from JWT token
final memberIdProvider = FutureProvider<int?>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final token = await tokenStorage.getAccessToken();
  
  if (token == null) return null;
  
  try {
    final decoded = JwtDecoder.decode(token);
    final memberId = decoded['memberId'];
    return memberId != null ? int.tryParse(memberId.toString()) : null;
  } catch (e) {
    print('❌ [MemberId] Error parsing token: $e');
    return null;
  }
});

// Chatbot ViewModel Provider
// Note: Service will be created with proper token/memberId during initialization
final chatbotViewModelProvider = 
    StateNotifierProvider<ChatbotViewModel, ChatbotState>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ChatbotViewModel(tokenStorage);
});
