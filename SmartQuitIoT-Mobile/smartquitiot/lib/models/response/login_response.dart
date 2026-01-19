class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final bool firstLogin;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.firstLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      firstLogin: json['firstLogin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'firstLogin': firstLogin,
    };
  }
}