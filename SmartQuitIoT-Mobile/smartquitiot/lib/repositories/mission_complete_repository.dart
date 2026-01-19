import '../core/errors/exception.dart';
import '../models/mission_complete_request.dart';
import '../services/mission_complete_service.dart';
import '../repositories/auth_repository.dart';

class MissionCompleteRepository {
  final MissionCompleteService _missionCompleteService;
  final AuthRepository _authRepository;

  MissionCompleteRepository({
    MissionCompleteService? missionCompleteService, 
    AuthRepository? authRepository
  }) : _missionCompleteService = missionCompleteService ?? MissionCompleteService(),
       _authRepository = authRepository ?? AuthRepository();

  /// Complete a mission
  Future<bool> completeMission({
    required int phaseId,
    required int phaseDetailMissionId,
    List<String>? triggers,
  }) async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw MissionCompleteException('Access token not found. Please login again.');
      }

      final request = MissionCompleteRequest(
        phaseId: phaseId,
        phaseDetailMissionId: phaseDetailMissionId,
        triggered: triggers,
        notes: null, // Always null as per requirement
      );

      print('📡 [MissionCompleteRepository] Completing mission: phaseId=$phaseId, missionId=$phaseDetailMissionId');
      print('🎯 [MissionCompleteRepository] Triggers: $triggers');

      final success = await _missionCompleteService.completeMission(
        accessToken: accessToken,
        request: request,
      );

      if (success) {
        print('✅ [MissionCompleteRepository] Mission completed successfully');
      }

      return success;
    } catch (e, st) {
      print('🔥 [MissionCompleteRepository] Error completing mission: $e\n$st');
      if (e is MissionCompleteException) rethrow;
      throw MissionCompleteException('Failed to complete mission: ${e.toString()}');
    }
  }
}
