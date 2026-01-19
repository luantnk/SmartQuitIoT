import 'package:dio/dio.dart';
import 'package:SmartQuitIoT/models/achievement.dart';
import 'package:SmartQuitIoT/core/errors/failures.dart';
import '../services/achievement_service.dart';

class AchievementRepository {
  final AchievementService _achievementService;

  AchievementRepository(this._achievementService);

  /// Get all user achievements
  Future<List<Achievement>> getAllMyAchievements() async {
    try {
      final response = await _achievementService.getAllMyAchievements();

      if (response.statusCode == 200) {
        print('🔍 Parsing achievements from response...');
        
        if (response.data is List) {
          final achievements = (response.data as List)
              .map((json) => Achievement.fromJson(json))
              .toList();
          
          print('✅ Successfully parsed ${achievements.length} achievements');
          print('   - Unlocked: ${achievements.where((a) => a.unlocked).length}');
          print('   - Locked: ${achievements.where((a) => !a.unlocked).length}');
          
          return achievements;
        } else {
          throw ServerFailure('Response data is not a List');
        }
      } else {
        throw ServerFailure(
          'Failed to fetch achievements: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get home achievements (random 4 for home screen)
  Future<List<Achievement>> getHomeAchievements() async {
    try {
      print('🏠 [AchievementRepository] Fetching home achievements...');
      final response = await _achievementService.getHomeAchievements();

      if (response.statusCode == 200) {
        print('🔍 [AchievementRepository] Parsing home achievements...');
        
        if (response.data is List) {
          final achievements = (response.data as List)
              .map((json) => Achievement.fromJson(json))
              .toList();
          
          print('✅ [AchievementRepository] Parsed ${achievements.length} home achievements');
          print('   - Unlocked: ${achievements.where((a) => a.unlocked).length}');
          print('   - Locked: ${achievements.where((a) => !a.unlocked).length}');
          
          return achievements;
        } else {
          throw ServerFailure('Response data is not a List');
        }
      } else {
        throw ServerFailure(
          'Failed to fetch home achievements: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (e.response?.statusCode == 404) {
          return 'No achievements found.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Server returned error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Network error occurred.';
    }
  }
}
