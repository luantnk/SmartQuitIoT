import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/quit_plan_history.dart';

class QuitPlanHistoryService {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  static const Duration _timeout = Duration(seconds: 30);

  QuitPlanHistoryService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
    _logger.i('📜 [QuitPlanHistoryService] Initialized with base URL: $_baseUrl');
  }

  /// Get all quit plan history
  Future<List<QuitPlanHistory>> getAllQuitPlans({
    required String accessToken,
  }) async {
    try {
      final url = '$_baseUrl/quit-plan/all-quit-plan';
      
      _logger.d('📡 [QuitPlanHistoryService] GET: $url');
      _logger.d('🔑 [QuitPlanHistoryService] Token: ${accessToken.substring(0, 20)}...');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      _logger.i('✅ [QuitPlanHistoryService] Response Status: ${response.statusCode}');
      _logger.d('📦 [QuitPlanHistoryService] Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final quitPlans = data
            .map((json) => QuitPlanHistory.fromJson(json as Map<String, dynamic>))
            .toList();
        
        _logger.i('✅ [QuitPlanHistoryService] Successfully parsed ${quitPlans.length} quit plans');
        return quitPlans;
      } else {
        _logger.e('❌ [QuitPlanHistoryService] Unexpected response: ${response.statusCode}');
        throw Exception('Unexpected response status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('❌ [QuitPlanHistoryService] DioException: ${e.message}');
      _logger.e('📊 [QuitPlanHistoryService] Status Code: ${e.response?.statusCode}');
      _logger.e('📦 [QuitPlanHistoryService] Response Data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Please try again.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint not found.');
      } else {
        throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to fetch quit plans');
      }
    } catch (e) {
      _logger.e('❌ [QuitPlanHistoryService] Unexpected error: $e');
      throw Exception('Failed to fetch quit plans: $e');
    }
  }
}
