import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
// Import AuthRepository (thay vì TokenStorageService trực tiếp)
import '../repositories/auth_repository.dart';

class MembershipApiService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final AuthRepository _authRepository = AuthRepository();

  final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  late final String _baseUrl = '$_apiBaseUrl/membership-packages';

  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final accessToken = await _authRepository.getValidAccessToken();

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    } else if (requireAuth) {
      throw Exception('No access token found — user not logged in');
    }

    return headers;
  }

  Future<http.Response> getMembershipPackages() async {
    final uri = Uri.parse(_baseUrl);
    try {
      // Thêm token vào header (nếu có)
      final headers = await _getHeaders(requireAuth: false);

      final response = await http.get(uri, headers: headers);
      return response;
    } catch (e) {
      _logger.e('Network error fetching packages', error: e);
      rethrow;
    }
  }

  Future<http.Response> getPlansForPackage(int packageId) async {
    final uri = Uri.parse('$_baseUrl/plans/$packageId');
    try {
      final headers = await _getHeaders(requireAuth: false);
      final response = await http.get(uri, headers: headers);
      return response;
    } catch (e) {
      _logger.e('Network error fetching plans for package $packageId', error: e);
      rethrow;
    }
  }

  Future<http.Response> createPaymentLink({
    required int packageId,
    required int duration,
  }) async {
    final uri = Uri.parse('$_baseUrl/create-payment-link');
    try {
      final headers = await _getHeaders(requireAuth: true);
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'membershipPackageId': packageId,
          'duration': duration,
        }),
      );
      return response;
    } catch (e) {
      _logger.e('❌ Network error creating payment link', error: e);
      rethrow;
    }
  }

  Future<http.Response> processPayment(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/process');
    try {
      _logger.i('🌐 [MembershipService] Calling processPayment API...\n🔗 URL: $uri\n📦 Body: $body');
      final headers = await _getHeaders(requireAuth: true);
      final tokenDebug = headers['Authorization'] ?? 'No Token';
      _logger.d('🔑 [MembershipService] Auth Header: ${tokenDebug.substring(0, tokenDebug.length > 20 ? 20 : tokenDebug.length)}...');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('⏰ [MembershipService] Request timeout after 30 seconds');
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      _logger.i('📊 [MembershipService] Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      _logger.e('❌ [MembershipService] Network error processing payment', error: e);
      rethrow;
    }
  }

  Future<http.Response> getCurrentSubscription() async {
    final uri = Uri.parse('$_apiBaseUrl/membership-subscriptions/current');

    try {
      _logger.i('📡 [MembershipService] Fetching current subscription...\n🌐 URL: $uri');
      final headers = await _getHeaders(requireAuth: true);
      final response = await http.get(
        uri,
        headers: headers,
      );
      _logger.i('📊 [MembershipService] Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        _logger.d('✅ [MembershipService] Successfully fetched current subscription');
      } else {
        _logger.w('❌ [MembershipService] Failed: ${response.body}');
      }
      return response;
    } catch (e) {
      _logger.e('❌ [MembershipService] Network error fetching current subscription', error: e);
      rethrow;
    }
  }
}