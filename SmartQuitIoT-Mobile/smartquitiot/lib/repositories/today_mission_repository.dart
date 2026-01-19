import '../core/errors/exception.dart';
import '../models/today_mission.dart';
import '../services/today_mission_service.dart';
import '../repositories/auth_repository.dart';

class TodayMissionRepository {
  final TodayMissionService _todayMissionService;
  final AuthRepository _authRepository;

  TodayMissionRepository({
    TodayMissionService? todayMissionService, 
    AuthRepository? authRepository
  }) : _todayMissionService = todayMissionService ?? TodayMissionService(),
       _authRepository = authRepository ?? AuthRepository();

  /// Get today's missions, filtering out completed ones
  Future<List<TodayMissionDetail>> getTodayMissions() async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw TodayMissionException('Access token not found. Please login again.');
      }

      // Call service to get response
      final TodayMissionResponse response = await _todayMissionService.getTodayMissions(
        accessToken: accessToken,
      );

      // Filter only INCOMPLETED missions
      final incompletedMissions = response.phaseDetailMissionResponseDTOS
          .where((mission) => mission.isIncompleted)
          .toList();

      print('✅ [TodayMissionRepository] Loaded ${incompletedMissions.length} incompleted missions out of ${response.phaseDetailMissionResponseDTOS.length} total');

      return incompletedMissions;
    } catch (e, st) {
      print('🔥 [TodayMissionRepository] Error getting today missions: $e\n$st');
      if (e is TodayMissionException) rethrow;
      throw TodayMissionException('Failed to get today missions: ${e.toString()}');
    }
  }

  /// Get all today's missions (both completed and incompleted)
  Future<TodayMissionResponse> getAllTodayMissions() async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw TodayMissionException('Access token not found. Please login again.');
      }

      final TodayMissionResponse response = await _todayMissionService.getTodayMissions(
        accessToken: accessToken,
      );

      print('✅ [TodayMissionRepository] Loaded ${response.phaseDetailMissionResponseDTOS.length} total missions');

      return response;
    } catch (e, st) {
      print('🔥 [TodayMissionRepository] Error getting all today missions: $e\n$st');
      if (e is TodayMissionException) rethrow;
      throw TodayMissionException('Failed to get all today missions: ${e.toString()}');
    }
  }

  /// Check if all missions are completed
  Future<bool> areAllMissionsCompleted() async {
    try {
      final response = await getAllTodayMissions();
      final allCompleted = response.phaseDetailMissionResponseDTOS
          .every((mission) => mission.isCompleted);
      
      print('✅ [TodayMissionRepository] All missions completed: $allCompleted');
      return allCompleted;
    } catch (e) {
      print('🔥 [TodayMissionRepository] Error checking mission completion: $e');
      return false;
    }
  }
}
