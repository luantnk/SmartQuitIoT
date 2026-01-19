import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../repositories/auth_repository.dart';
import 'dart:convert';

class AchievementService {
  final Dio _dio = Dio();
  final AuthRepository _authRepository;
  late final String baseUrl;

  AchievementService(this._authRepository) {
    baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

    // Setup Dio interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authRepository.getAccessToken();
          print('🔑 Achievement API Token: ${token?.substring(0, 20)}...');
          print('📡 Achievement Request to: ${options.uri}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Achievement Response: ${response.statusCode}');
          print('📦 Achievement Response Data: ${jsonEncode(response.data)}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Achievement Error: ${error.message}');
          print('❌ Achievement Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
  }

  /// Get all user achievements
  Future<Response> getAllMyAchievements() async {
    return await _dio.get('/achievement/all-my-achievements');
  }

  /// Get home achievements (random 4 achievements for home screen)
  Future<Response> getHomeAchievements() async {
    print('🏠 [AchievementService] Fetching home achievements...');
    return await _dio.get('/achievement/my-achievements-at-home');
  }

  /// Get top leaderboards with achievements
  Future<Response> getTopLeaderBoards() async {
    print('🏆 [AchievementService] Fetching top leaderboards...');
    return await _dio.get('/achievement/top-leader-boards');
  }
}
