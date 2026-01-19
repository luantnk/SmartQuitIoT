import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/errors/exception.dart';
import '../models/mission_complete_request.dart';
import '../models/response/error_response.dart';

class MissionCompleteService {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  final Dio _dio;
  static const Duration _timeout = Duration(seconds: 30);

  MissionCompleteService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.sendTimeout = _timeout;
  }

  /// Complete a mission via API
  Future<bool> completeMission({
    required String accessToken,
    required MissionCompleteRequest request,
  }) async {
    try {
      final url = '$_baseUrl/phase-detail-mission/complete';
      print('📡 [MissionCompleteService] POST: $url');
      print('📦 [MissionCompleteService] Request: ${request.toJson()}');

      final response = await _dio.post(
        url,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('✅ [MissionCompleteService] Status: ${response.statusCode}');
      print('📦 [MissionCompleteService] Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorResponse = ErrorResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        throw MissionCompleteException(
          'Server returned ${response.statusCode}: ${errorResponse.message}',
        );
      }
    } on DioException catch (e) {
      print('🚨 [DioException] ${e.message}');
      print('🧩 [StackTrace]: ${StackTrace.current}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw MissionCompleteException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw MissionCompleteException(
          'Network error. Please check your connection.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 401) {
          throw MissionCompleteException('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw MissionCompleteException('Access forbidden.');
        } else if (statusCode == 404) {
          throw MissionCompleteException('Mission not found.');
        } else if (statusCode! >= 500) {
          throw MissionCompleteException(
            'Server error. Please try again later.',
          );
        } else {
          throw MissionCompleteException(
            'Request failed with status: $statusCode',
          );
        }
      } else {
        throw MissionCompleteException('Network error: ${e.message}');
      }
    } catch (e) {
      print('🚨 [UnknownException] $e');
      print('🧩 [StackTrace]: ${StackTrace.current}');
      throw MissionCompleteException(
        'Failed to complete mission: ${e.toString()}',
      );
    }
  }
}
