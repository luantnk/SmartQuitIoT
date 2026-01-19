import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../repositories/auth_repository.dart';
import 'dart:convert';

class MetricsService {
  final Dio _dio = Dio();
  final AuthRepository _authRepository;
  late final String baseUrl;

  MetricsService(this._authRepository) {
    baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

    // Setup Dio interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authRepository.getAccessToken();
          print('🔑 Metrics API Token: $token');
          print('📡 Metrics Request to: ${options.uri}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Metrics Response: ${response.statusCode}');
          print('📦 Metrics Response Data: ${jsonEncode(response.data)}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Metrics Error: ${error.message}');
          print('❌ Metrics Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
  }

  /// Get home screen metrics
  Future<Response> getHomeMetrics() async {
    return await _dio.get('/metrics/home-screen');
  }

  /// Get detailed health recovery metrics
  Future<Response> getHealthRecoveries() async {
    return await _dio.get('/metrics/health-data');
  }

  /// Get home screen health recovery data
  Future<Response> getHomeHealthRecovery() async {
    return await _dio.get('/metrics/home-screen-health-recovery');
  }
}
