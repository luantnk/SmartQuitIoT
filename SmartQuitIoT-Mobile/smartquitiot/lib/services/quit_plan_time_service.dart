import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../repositories/auth_repository.dart';

class QuitPlanTimeService {
  final Dio _dio = Dio();
  final AuthRepository _authRepository;
  late final String baseUrl;

  QuitPlanTimeService(this._authRepository) {
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    baseUrl = '$apiBaseUrl/quit-plan/time';

    // Setup Dio interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authRepository.getAccessToken();
          print('🔑 QuitPlanTime API Token: ${token?.substring(0, 20)}...');
          print('📡 QuitPlanTime Request to: ${options.uri}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ QuitPlanTime Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ QuitPlanTime Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<DateTime> getStartTime() async {
    try {
      // Check if token is available before making request
      final token = await _authRepository.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No access token available. Please login again.');
      }

      final response = await _dio.get(baseUrl);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response formats
        if (data is! Map<String, dynamic>) {
          throw Exception(
            'Invalid response format: expected Map but got ${data.runtimeType}',
          );
        }

        final startTimeStr = data['startTime'];
        if (startTimeStr == null) {
          throw Exception('startTime field is missing in response');
        }

        if (startTimeStr is! String) {
          throw Exception(
            'startTime must be a String, but got ${startTimeStr.runtimeType}',
          );
        }

        try {
          return DateTime.parse(startTimeStr);
        } catch (e) {
          throw Exception('Failed to parse startTime "$startTimeStr": $e');
        }
      } else {
        throw Exception(
          'Failed to get start time: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      String errorMessage = 'Failed to load timer';
      if (e.response != null) {
        errorMessage = 'Failed to load timer: HTTP ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'No quit plan found.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. Please try again.';
      }
      print('❌ [QuitPlanTimeService] DioError: $errorMessage - ${e.message}');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ [QuitPlanTimeService] Error getting start time: $e');
      rethrow;
    }
  }
}
