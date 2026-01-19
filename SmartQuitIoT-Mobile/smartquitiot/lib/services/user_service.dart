import 'package:dio/dio.dart';
import 'package:SmartQuitIoT/models/user_model.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final Dio _dio;
  final TokenStorageService _tokenStorageService;
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  UserService({
    required Dio dio,
    required TokenStorageService tokenStorageService,
  })  : _dio = dio,
        _tokenStorageService = tokenStorageService;

  /// Get user profile information
  Future<UserModel> getUserProfile() async {
    try {
      final token = await _tokenStorageService.getAccessToken();
      if (token == null) throw Exception('No access token found');

      final response = await _dio.get(
        '$_baseUrl/members/p',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      try {
        final user = UserModel.fromJson(response.data);
        return user;
      } catch (jsonError, stackTrace) {
        print('❌ [UserService] JSON parse error: $jsonError');
        print(stackTrace);
        throw Exception('Failed to parse user profile data');
      }
    } on DioException catch (dioError) {
      print('❌ [UserService] Dio error: ${dioError.message}');
      if (dioError.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      }
      throw Exception('Failed to fetch user profile: ${dioError.message}');
    } catch (e) {
      print('❌ [UserService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UpdateUserProfileModel updateData) async {
    try {
      final token = await _tokenStorageService.getAccessToken();
      if (token == null) throw Exception('No access token found');

      final response = await _dio.put(
        '$_baseUrl/members',
        data: updateData.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      try {
        final user = UserModel.fromJson(response.data);
        return user;
      } catch (jsonError, stackTrace) {
        print('❌ [UserService] JSON parse error: $jsonError');
        print(stackTrace);
        throw Exception('Failed to parse updated user profile data');
      }
    } on DioException catch (dioError) {
      print('❌ [UserService] Dio error: ${dioError.message}');
      if (dioError.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      }
      if (dioError.response?.statusCode == 400) {
        throw Exception('Invalid data provided');
      }
      throw Exception('Failed to update user profile: ${dioError.message}');
    } catch (e) {
      print('❌ [UserService] Unexpected error: $e');
      rethrow;
    }
  }
}
