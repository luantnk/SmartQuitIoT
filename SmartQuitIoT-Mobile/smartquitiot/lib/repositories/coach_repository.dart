import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/errors/exception.dart';
import '../models/coach.dart';
import '../services/token_storage_service.dart';

class CoachRepository {
  final http.Client _client;
  final TokenStorageService _tokenService = TokenStorageService();
  final String _baseUrl =
      '${dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080'}/coaches';

  CoachRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Helper: build authorized headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Lấy danh sách coaches
  /// Nếu force=true sẽ thêm query param timestamp để tránh cache/proxy trả dữ liệu cũ
  Future<CoachListResponse> getCoaches({bool force = false}) async {
    try {
      final headers = await _getHeaders();
      String url = _baseUrl;
      if (force) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        url = '$_baseUrl?_t=$ts';
      }

      // Debug: in url + headers
      // ignore: avoid_print
      print('[CoachRepository] GET $url');
      // ignore: avoid_print
      print('[CoachRepository] headers: $headers');

      final response = await _client.get(Uri.parse(url), headers: headers);

      // Debug: in status + body
      // ignore: avoid_print
      print('[CoachRepository] status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Try to normalize to shape expected by CoachListResponse.fromJson
        if (jsonData is List) {
          // server returned plain list -> wrap into expected envelope
          final wrapped = {'success': true, 'data': jsonData};
          return CoachListResponse.fromJson(wrapped);
        } else if (jsonData is Map<String, dynamic>) {
          return CoachListResponse.fromJson(jsonData);
        } else {
          throw const CoachException('Invalid response structure from server');
        }
      } else if (response.statusCode == 401) {
        throw const CoachException(
          'Unauthorized: Invalid or expired token',
          401,
        );
      } else {
        throw CoachException(
          'Failed to load coaches: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const CoachException('Network error: Unable to connect to server');
    } on FormatException {
      throw const CoachException('Invalid response format from server');
    } catch (e) {
      throw CoachException('Unexpected error: $e');
    }
  }

  /// Lấy thông tin chi tiết của 1 coach (không đổi)
  Future<Coach> getCoachById(int id) async {
    try {
      final headers = await _getHeaders();

      final response = await _client.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Coach.fromJson(jsonData['data']);
        } else {
          throw CoachException('Coach not found');
        }
      } else if (response.statusCode == 401) {
        throw const CoachException(
          'Unauthorized: Invalid or expired token',
          401,
        );
      } else {
        throw CoachException(
          'Failed to load coach: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const CoachException('Network error: Unable to connect to server');
    } on FormatException {
      throw const CoachException('Invalid response format from server');
    } catch (e) {
      throw CoachException('Unexpected error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
