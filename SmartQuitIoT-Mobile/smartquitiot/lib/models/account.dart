class Account {
  final int id;
  final String username;
  final String email;
  final String role;


  Account({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

