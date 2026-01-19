class RegisterRequest {
  final String username;
  final String password;
  final String confirmPassword;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String dob;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
    };
  }
}