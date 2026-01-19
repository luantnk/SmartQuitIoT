import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../repositories/auth_repository.dart';

class ReminderSettingsService {
  final Dio _dio;
  final Logger _logger;
  final AuthRepository _authRepository;
  final String _baseUrl;

  ReminderSettingsService({
    Dio? dio,
    Logger? logger,
    AuthRepository? authRepository,
    String? baseUrl,
  })  : _dio = dio ?? Dio(),
        _logger = logger ?? Logger(),
        _authRepository = authRepository ?? AuthRepository(),
        _baseUrl = baseUrl ?? (dotenv.env['API_BASE_URL'] ?? '') {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );

    _logger.i('[ReminderSettingsService] Initialized with baseUrl: $_baseUrl');
  }

  /// Get access token from AuthRepository
  Future<String> _getAccessToken() async {
    final token = await _authRepository.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No valid access token available. Please login again.');
    }
    return token;
  }

  /// Create options with auto token
  Future<Options> _options() async {
    final accessToken = await _getAccessToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Update reminder settings
  Future<Map<String, dynamic>> updateReminderSettings({
    required String morningReminderTime,
    required String quietStart,
    required String quietEnd,
  }) async {
    try {
      _logger.i('[ReminderSettingsService] Updating reminder settings...');
      _logger.d('[ReminderSettingsService] morningReminderTime: $morningReminderTime');
      _logger.d('[ReminderSettingsService] quietStart: $quietStart');
      _logger.d('[ReminderSettingsService] quietEnd: $quietEnd');

      final requestData = {
        'morningReminderTime': morningReminderTime,
        'quietStart': quietStart,
        'quietEnd': quietEnd,
      };

      _logger.d('[ReminderSettingsService] Request data: $requestData');

      final response = await _dio.put(
        '$_baseUrl/members/settings/reminder',
        data: requestData,
        options: await _options(),
      );

      _logger.i('[ReminderSettingsService] Response Status: ${response.statusCode}');
      _logger.d('[ReminderSettingsService] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('[ReminderSettingsService] Reminder settings updated successfully');
        return response.data as Map<String, dynamic>;
      } else {
        _logger.e('[ReminderSettingsService] Unexpected response: ${response.statusCode}');
        throw Exception('Failed to update reminder settings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('[ReminderSettingsService] DioException: ${e.message}');
      _logger.e('[ReminderSettingsService] Status Code: ${e.response?.statusCode}');
      _logger.e('[ReminderSettingsService] Response Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Invalid data provided';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update reminder settings: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('[ReminderSettingsService] Unexpected error: $e');
      _logger.e('[ReminderSettingsService] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

