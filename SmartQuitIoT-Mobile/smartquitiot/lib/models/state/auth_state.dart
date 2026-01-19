class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? accessToken;
  final String? refreshToken;
  final bool? isFirstLogin;
  final String? username;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.accessToken,
    this.refreshToken,
    this.isFirstLogin,
    this.username,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? accessToken,
    String? refreshToken,
    bool? isFirstLogin,
    String? username,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      username: username ?? this.username,
    );
  }

  AuthState clearAuth() {
    return const AuthState();
  }
}