import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/errors/exception.dart';
import '../models/quit_plan_homepage.dart';
import '../models/response/error_response.dart';

class QuitPlanHomepageService {
  static final String _baseUrl = 
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';
  
  final Dio _dio;
  static const Duration _timeout = Duration(seconds: 30);

  QuitPlanHomepageService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
  }

  /// Get quit plan home page data from API
  Future<QuitPlanHomePage> getQuitPlanHomePage({
    required String accessToken,
  }) async {
    try {
      final url = '$_baseUrl/phase/home-page';
      print('📡 [QuitPlanHomepageService] GET: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('✅ [QuitPlanHomepageService] Status: ${response.statusCode}');
      print('📦 [QuitPlanHomepageService] Data: ${response.data}');

      if (response.statusCode == 200) {
        return QuitPlanHomePage.fromJson(response.data as Map<String, dynamic>);
      } else {
        final errorResponse = ErrorResponse.fromJson(response.data as Map<String, dynamic>);
        throw QuitPlanException(
          'Server returned ${response.statusCode}: ${errorResponse.message}',
        );
      }
    } on DioException catch (e) {
      print('🚨 [DioException] ${e.message}');
      print('🧩 [StackTrace]: ${StackTrace.current}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw QuitPlanException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw QuitPlanException('Network error. Please check your connection.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        print('❌ [Response Status]: $statusCode');
        print('📦 [Response Data]: ${e.response!.data}');
        print('📋 [Response Headers]: ${e.response!.headers}');
        
        if (statusCode == 401) {
          throw QuitPlanException('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw QuitPlanException('Access forbidden.');
        } else if (statusCode == 404) {
          throw QuitPlanException('Quit plan not found.');
        } else if (statusCode == 400) {
          // Log chi tiết lỗi 400
          print('⚠️ [400 Bad Request] Response body: ${e.response!.data}');
          throw QuitPlanException('Bad request (400): ${e.response!.data}');
        } else if (statusCode! >= 500) {
          throw QuitPlanException('Server error. Please try again later.');
        } else {
          throw QuitPlanException('Request failed with status: $statusCode');
        }
      } else {
        throw QuitPlanException('Network error: ${e.message}');
      }
    } catch (e) {
      print('🚨 [UnknownException] $e');
      print('🧩 [StackTrace]: ${StackTrace.current}');
      throw QuitPlanException('Failed to load quit plan: ${e.toString()}');
    }
  }
}
