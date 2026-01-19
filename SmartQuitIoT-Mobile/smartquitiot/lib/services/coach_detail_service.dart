// lib/services/coach_detail_service.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'token_storage_service.dart'; // relative path tuỳ project của em

class CoachDetailService {
  final Dio _dio;
  final TokenStorageService _tokenStorage = TokenStorageService();

  CoachDetailService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_BASE_URL'] ?? '',
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
          // don't set global Authorization here (we get token per-request)
        ),
      ) {
    // Add logging interceptor (safe; it will print headers & bodies - be careful with tokens in prod)
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  String _replacePlaceholder(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  Future<Map<String, dynamic>> fetchCoachDetail(String tokenFromCaller, int coachId) async {
    // NOTE: keep this signature for compatibility (still accept token param)
    // but we'll prefer token from storage if available (so caller doesn't have to pass it)
    try {
      String? token = tokenFromCaller;
      // prefer token from storage if exists (helps consistency)
      final stored = await _tokenStorage.getAccessToken();
      if (stored != null && stored.isNotEmpty) {
        token = stored;
      }

      if (token == null || token.isEmpty) {
        throw Exception('Missing access token');
      }

      // Use baseUrl + path to avoid double-building
      final path = '/coaches/$coachId';
      debugPrint('[DEBUG] fetchCoachDetail path=$path');

      final response = await _dio.get(
        path,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('[DEBUG] fetchCoachDetail status=${response.statusCode} dataType=${response.data.runtimeType}');

      if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }

      if (response.data is Map && response.data.containsKey('data')) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return Map<String, dynamic>.from(response.data);
    } on DioError catch (e) {
      debugPrint('[ERROR] fetchCoachDetail DioError: ${e.message} statusCode=${e.response?.statusCode} body=${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      if (e.type == DioErrorType.connectionTimeout || e.type == DioErrorType.receiveTimeout) {
        throw Exception('Request timeout when fetching coach detail.');
      }
      rethrow;
    } catch (e, st) {
      debugPrint('[ERROR] fetchCoachDetail unexpected: $e\n$st');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchAvailableSlots(String tokenFromCaller, int coachId, String date) async {
    try {
      String? token = tokenFromCaller;
      final stored = await _tokenStorage.getAccessToken();
      if (stored != null && stored.isNotEmpty) {
        token = stored;
      }

      if (token == null || token.isEmpty) {
        throw Exception('Missing access token');
      }

      final path = '/coaches/$coachId/slots/available';
      final query = {'date': date};

      debugPrint('[DEBUG] fetchAvailableSlots path=$path query=$query');

      final response = await _dio.get(
        path,
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      ).timeout(const Duration(seconds: 12));

      debugPrint('[DEBUG] fetchAvailableSlots status=${response.statusCode} dataType=${response.data.runtimeType}');

      if (response.statusCode == 401) {
        debugPrint('[ERROR] fetchAvailableSlots -> 401 Unauthorized: body=${response.data}');
        throw Exception('Unauthorized');
      }

      if (response.data is Map && response.data.containsKey('data')) {
        return List<dynamic>.from(response.data['data']);
      }
      if (response.data is List) {
        return List<dynamic>.from(response.data);
      }

      throw Exception("Unexpected response format: ${response.data}");
    } on TimeoutException {
      debugPrint('[ERROR] fetchAvailableSlots TimeoutException for coachId=$coachId date=$date');
      throw Exception('Request timed out. Kiểm tra backend hoặc mạng.');
    } on DioError catch (e) {
      debugPrint('[ERROR] fetchAvailableSlots DioError: ${e.message} status=${e.response?.statusCode} body=${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      if (e.type == DioErrorType.connectionTimeout || e.type == DioErrorType.receiveTimeout) {
        throw Exception('Request timeout. Không thể kết nối tới server.');
      }
      rethrow;
    } catch (e, st) {
      debugPrint('[ERROR] fetchAvailableSlots unexpected: $e\n$st');
      rethrow;
    }
  }
}
