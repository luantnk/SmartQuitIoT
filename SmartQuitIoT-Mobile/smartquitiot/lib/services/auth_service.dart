import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/errors/exception.dart';
import '../models/response/error_response.dart';
import '../models/request/login_request.dart';
import '../models/response/login_response.dart';
import '../models/request/register_request.dart';
import '../models/response/register_response.dart';

class AuthService {
  static final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  static final String _baseUrl = '$_apiBaseUrl/auth';
  static final String _accountsBaseUrl = '$_apiBaseUrl/accounts';
  static const Duration _timeout = Duration(seconds: 30);

  /// Register a new user
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_accountsBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw AuthException(errorResponse.message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Login with username and password
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/member'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw AuthException(errorResponse.message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw AuthException(errorResponse.message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Token refresh failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/password/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw AuthException(ErrorResponse.fromJson(errorData).message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to request OTP: ${e.toString()}');
    }
  }

  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      )
          .timeout(const Duration(seconds: 30));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData['resetToken'] as String;
      } else {
        throw AuthException(ErrorResponse.fromJson(responseData).message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } on FormatException {
      throw AuthException('Invalid response format from server.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to verify OTP: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'resetToken': resetToken,
          'newPassword': newPassword,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw AuthException(ErrorResponse.fromJson(errorData).message);
      }
    } on http.ClientException {
      throw AuthException('Network error. Please check your connection.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final url = Uri.parse('$_baseUrl/google');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          responseBody['message'] ?? 'Failed to login with Google',
        );
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<void> logout(String accessToken) async {
    try {
      await http
          .post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      )
          .timeout(_timeout);
    } catch (e) {
      // Logout errors are usually not critical
    }
  }
}
