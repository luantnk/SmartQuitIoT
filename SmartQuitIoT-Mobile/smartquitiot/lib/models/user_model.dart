class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final String gender;
  final String dob;
  final int age;
  final AccountModel account;
  final bool usedFreeTrial;
  final String? morningReminderTime;
  final String? quietStart;
  final String? quietEnd;
  final String? timeZone;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.gender,
    required this.dob,
    required this.age,
    required this.account,
    required this.usedFreeTrial,
    this.morningReminderTime,
    this.quietStart,
    this.quietEnd,
    this.timeZone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      account: AccountModel.fromJson(json['account'] ?? {}),
      usedFreeTrial: json['usedFreeTrial'] ?? false,
      morningReminderTime: json['morningReminderTime'],
      quietStart: json['quietStart'],
      quietEnd: json['quietEnd'],
      timeZone: json['timeZone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'dob': dob,
      'age': age,
      'account': account.toJson(),
      'usedFreeTrial': usedFreeTrial,
      'morningReminderTime': morningReminderTime,
      'quietStart': quietStart,
      'quietEnd': quietEnd,
      'timeZone': timeZone,
    };
  }

  // Helper method to get full name
  String get fullName => '$firstName $lastName';

  // Helper method to get display name for profile
  String get displayName => fullName.isNotEmpty ? fullName : 'User';
}

class AccountModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String accountType;
  final String createdAt;
  final bool active;
  final bool firstLogin;
  final bool banned;

  AccountModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.accountType,
    required this.createdAt,
    required this.active,
    required this.firstLogin,
    required this.banned,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accountType: json['accountType'] ?? '',
      createdAt: json['createdAt'] ?? '',
      active: json['active'] ?? false,
      firstLogin: json['firstLogin'] ?? false,
      banned: json['banned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'accountType': accountType,
      'createdAt': createdAt,
      'active': active,
      'firstLogin': firstLogin,
      'banned': banned,
    };
  }
}

// Model for updating user profile
class UpdateUserProfileModel {
  final String firstName;
  final String lastName;
  final String dob;
  final String avatarUrl;

  UpdateUserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'avatarUrl': avatarUrl,
    };
  }
}
