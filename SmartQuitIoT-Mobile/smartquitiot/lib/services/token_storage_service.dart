// services/token_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Save both tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _logger.i('💾 [TokenStorage] Saving tokens to SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
    ]);
    _logger.i('✅ [TokenStorage] Tokens saved successfully');

    // Verify immediately
    final saved = prefs.getString(_accessTokenKey);
    _logger.d(
      '🔍 [TokenStorage] Verification - Token exists: ${saved != null}',
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    _logger.d(
      '📖 [TokenStorage] Reading access token: ${token != null ? "Found (${token.substring(0, 20)}...)" : "NULL"}',
    );
    return token;
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Clear all tokens and user data
  Future<void> clearTokens() async {
    _logger.w('🗑️ [TokenStorage] CLEARING ALL TOKENS!');
    _logger.d('📍 [TokenStorage] Call stack: ${StackTrace.current}');
    final prefs = await SharedPreferences.getInstance();

    // Remove all tokens and user data
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_userDataKey),
    ]);

    // Verify removal immediately
    final accessTokenAfter = prefs.getString(_accessTokenKey);
    final refreshTokenAfter = prefs.getString(_refreshTokenKey);
    final userDataAfter = prefs.getString(_userDataKey);

    if (accessTokenAfter == null &&
        refreshTokenAfter == null &&
        userDataAfter == null) {
      _logger.i('✅ [TokenStorage] Tokens cleared and verified');
    } else {
      _logger.w('⚠️ [TokenStorage] WARNING: Some tokens may still exist!');
      _logger.w(
        '   Access token: ${accessTokenAfter != null ? "EXISTS" : "NULL"}',
      );
      _logger.w(
        '   Refresh token: ${refreshTokenAfter != null ? "EXISTS" : "NULL"}',
      );
      _logger.w('   User data: ${userDataAfter != null ? "EXISTS" : "NULL"}');
      // Force remove again
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_userDataKey),
      ]);
      _logger.i('✅ [TokenStorage] Force cleared again');
    }
  }

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clear user data only
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }
}
