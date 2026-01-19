import 'package:SmartQuitIoT/models/user_model.dart';
import 'package:SmartQuitIoT/services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository({required UserService userService})
    : _userService = userService;

  /// Get user profile with error handling
  Future<UserModel> getUserProfile() async {
    try {
      print('📦 [UserRepository] Getting user profile...');
      final userProfile = await _userService.getUserProfile();
      print('✅ [UserRepository] User profile retrieved successfully');
      return userProfile;
    } catch (e) {
      print('❌ [UserRepository] Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile with validation
  Future<UserModel> updateUserProfile({
    required String firstName,
    required String lastName,
    required String dob,
    required String avatarUrl,
  }) async {
    try {
      print('📦 [UserRepository] Updating user profile...');

      // Basic validation
      if (firstName.trim().isEmpty) {
        throw Exception('First name cannot be empty');
      }
      if (lastName.trim().isEmpty) {
        throw Exception('Last name cannot be empty');
      }
      if (dob.trim().isEmpty) {
        throw Exception('Date of birth cannot be empty');
      }

      final updateData = UpdateUserProfileModel(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        dob: dob.trim(),
        avatarUrl: avatarUrl.trim(),
      );

      final updatedProfile = await _userService.updateUserProfile(updateData);
      print('✅ [UserRepository] User profile updated successfully');
      return updatedProfile;
    } catch (e) {
      print('❌ [UserRepository] Error updating user profile: $e');
      rethrow;
    }
  }

  /// Validate date format (optional helper)
  bool isValidDateFormat(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format date for display (optional helper)
  String formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  /// Format date for API (optional helper)
  String formatDateForAPI(String dateString) {
    try {
      // If input is in DD/MM/YYYY format, convert to YYYY-MM-DD
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      }
      return dateString; // Return original if not in expected format
    } catch (e) {
      return dateString;
    }
  }
}
