import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/user_model.dart';
import 'package:SmartQuitIoT/services/user_service.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// User Service Provider
final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return UserService(dio: dio, tokenStorageService: tokenStorage);
});

// User Profile Provider
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  try {
    final userService = ref.watch(userServiceProvider);
    return await userService.getUserProfile();
  } catch (e) {
    print('❌ [UserProfileProvider] Error: $e');
    return null;
  }
});
