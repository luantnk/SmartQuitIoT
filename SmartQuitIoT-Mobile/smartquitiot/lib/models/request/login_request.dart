class LoginRequest {
  final String usernameOrEmail;
  final String password;

  LoginRequest({
    required this.usernameOrEmail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      usernameOrEmail: json['usernameOrEmail'] ?? '',
      password: json['password'] ?? '',
    );
  }
}