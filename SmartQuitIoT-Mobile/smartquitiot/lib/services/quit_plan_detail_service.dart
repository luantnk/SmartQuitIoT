import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/quit_plan_detail.dart';

class QuitPlanDetailService {
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

  QuitPlanDetailService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
    _logger.i('📋 [QuitPlanDetailService] Initialized with base URL: $_baseUrl');
  }

  /// Get specific quit plan detail by ID
  Future<QuitPlanDetail> getQuitPlanDetail({
    required int quitPlanId,
    required String accessToken,
  }) async {
    try {
      final url = '$_baseUrl/quit-plan/specific/$quitPlanId';
      
      _logger.d('📡 [QuitPlanDetailService] GET: $url');
      _logger.d('🔑 [QuitPlanDetailService] Token: ${accessToken.substring(0, 20)}...');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      _logger.i('✅ [QuitPlanDetailService] Response Status: ${response.statusCode}');
      _logger.d('📦 [QuitPlanDetailService] Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final quitPlan = QuitPlanDetail.fromJson(response.data);
        _logger.i('✅ [QuitPlanDetailService] Successfully parsed quit plan: ${quitPlan.name}');
        return quitPlan;
      } else {
        _logger.e('❌ [QuitPlanDetailService] Unexpected response: ${response.statusCode}');
        throw Exception('Unexpected response status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('❌ [QuitPlanDetailService] DioException: ${e.message}');
      _logger.e('📊 [QuitPlanDetailService] Status Code: ${e.response?.statusCode}');
      _logger.e('📦 [QuitPlanDetailService] Response Data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Please try again.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Quit plan not found.');
      } else {
        throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to fetch quit plan');
      }
    } catch (e) {
      _logger.e('❌ [QuitPlanDetailService] Unexpected error: $e');
      throw Exception('Failed to fetch quit plan: $e');
    }
  }
}
