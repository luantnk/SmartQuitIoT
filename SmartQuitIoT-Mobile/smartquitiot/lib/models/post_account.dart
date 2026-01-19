class PostAccount {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;

  const PostAccount({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
  });

  factory PostAccount.fromJson(Map<String, dynamic> json) {
    return PostAccount(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}
