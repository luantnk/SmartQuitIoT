// services/api_service.dart
import 'dart:async';
import 'dart:math';
import '../models/user_profile.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  // Fake API call to get user profile
  Future<UserProfile> getUserProfile(String userId) async {
    await _simulateDelay();

    // Simulate random success/failure
    if (Random().nextBool()) {
      throw Exception('Failed to load user profile');
    }

    // Return fake data
    return UserProfile(
      id: userId,
      name: 'John Doe',
      email: 'john.doe@example.com',
      avatarUrl: 'https://via.placeholder.com/150',
      smokeFreeDays: Random().nextInt(365) + 1,
      cigarettesAvoided: Random().nextInt(1000) + 100,
      moneySaved: (Random().nextDouble() * 1000) + 100,
    );
  }

  // Fake API call to update user profile
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    await _simulateDelay();

    // Simulate random success/failure
    if (Random().nextBool()) {
      throw Exception('Failed to update user profile');
    }

    // Return updated profile
    return profile;
  }

  // Fake API call to get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    await _simulateDelay();

    return {
      'totalDays': Random().nextInt(365) + 1,
      'cigarettesAvoided': Random().nextInt(1000) + 100,
      'moneySaved': (Random().nextDouble() * 1000) + 100,
      'healthScore': Random().nextInt(100) + 1,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}
