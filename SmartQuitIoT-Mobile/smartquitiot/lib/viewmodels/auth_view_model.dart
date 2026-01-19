import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import '../models/state/auth_state.dart';
import '../repositories/auth_repository.dart';
import '../services/token_storage_service.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
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

  AuthViewModel(this._authRepository) : super(const AuthState());

  String? _decodeUsername(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['username'];
    } catch (e) {
      return null;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String confirmPassword,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.register(
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        email: email,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dob: dob,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _authRepository.loginWithGoogle();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isFirstLogin: response.firstLogin,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final accessToken = await _authRepository.getAccessToken();
        final username = _decodeUsername(accessToken);
        state = state.copyWith(
          isAuthenticated: true,
          accessToken: accessToken,
          refreshToken: await _authRepository.getRefreshToken(),
          username: username,
        );
        return true;
      }
      state = state.clearAuth();
      return false;
    } catch (e) {
      await _authRepository.clearAuthData();
      state = state.clearAuth();
      return false;
    }
  }

  Future<bool> resetPassword(String resetToken, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.resetPassword(resetToken, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginResponse = await _authRepository.login(
        usernameOrEmail,
        password,
      );
      final username = _decodeUsername(loginResponse.accessToken);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        isFirstLogin: loginResponse.firstLogin,
        username: username,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resetToken = await _authRepository.verifyOtp(email, otp);
      state = state.copyWith(isLoading: false);
      return resetToken;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> logout() async {
    _logger.i('🚪 [AuthViewModel] Starting logout...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // AuthRepository.logout() already handles clearing tokens
      // No need to clear again here, but we do it as a safety measure
      await _authRepository.logout();

      // Clear state immediately
      state = state.clearAuth();
      _logger.i('✅ [AuthViewModel] Logout completed successfully');
    } catch (e) {
      // Even if logout fails, clear state and tokens
      _logger.w('⚠️ [AuthViewModel] Logout error (non-critical): $e');
      final tokenStorage = TokenStorageService();
      await tokenStorage.clearTokens();
      state = state.clearAuth();
      _logger.i('✅ [AuthViewModel] State and tokens cleared despite error');
    }
  }

  /// Helper method to verify tokens are cleared after logout
  Future<bool> verifyTokensCleared() async {
    final tokenStorage = TokenStorageService();
    final accessToken = await tokenStorage.getAccessToken();
    final refreshToken = await tokenStorage.getRefreshToken();
    final isCleared = accessToken == null && refreshToken == null;
    if (!isCleared) {
      _logger.w('⚠️ [AuthViewModel] WARNING: Tokens still exist after logout!');
      _logger.w('   Access token: ${accessToken != null ? "EXISTS" : "NULL"}');
      _logger.w(
        '   Refresh token: ${refreshToken != null ? "EXISTS" : "NULL"}',
      );
    }
    return isCleared;
  }

  /// Clear authentication data when app restarts
  /// This ensures app always starts from login screen when restarted
  Future<void> clearAuthOnRestart() async {
    _logger.i('🔄 [AuthViewModel] Clearing auth data on app restart...');
    try {
      await _authRepository.clearAuthData();
      state = state.clearAuth();
      _logger.i('✅ [AuthViewModel] Auth data cleared on restart');
    } catch (e) {
      _logger.w('⚠️ [AuthViewModel] Error clearing auth on restart: $e');
      // Force clear even if there's an error
      final tokenStorage = TokenStorageService();
      await tokenStorage.clearTokens();
      state = state.clearAuth();
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  bool? get isFirstLogin => state.isFirstLogin;
  String? get username => state.username;
}
