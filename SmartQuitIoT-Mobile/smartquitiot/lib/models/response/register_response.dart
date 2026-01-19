import '../account.dart';

class RegisterResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final Account account;

  RegisterResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.account,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      account: Account.fromJson(json['account'] ?? {}),
    );
  }
}
