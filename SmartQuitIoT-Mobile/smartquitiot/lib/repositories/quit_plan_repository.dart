import '../models/request/create_new_quit_plan_request.dart';
import '../models/request/create_quit_plan_request.dart';
import '../models/phase.dart';
import '../services/quit_plan_service.dart';
import 'auth_repository.dart';

class QuitPlanRepository {
  final QuitPlanService service;
  final AuthRepository authRepository;

  QuitPlanRepository({required this.service, required this.authRepository});

  Future<Phase> createPlan(CreateQuitPlanRequest request) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('Access token not found. Please login again.');
      }

      return await service.createQuitPlan(request: request);
    } catch (e) {
      throw Exception('Failed to create quit plan: ${e.toString()}');
    }
  }

  Future<Phase> createNewPlan(CreateNewQuitPlanRequest request) async {
    try {
      final token = await authRepository.getAccessToken();
      if (token == null) {
        throw Exception('Access token not found. Please login again.');
      }

      return await service.createNewQuitPlan(request: request);
    } catch (e) {
      throw Exception('Failed to create new quit plan: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getQuitPlan() async {
    return await service.getQuitPlan();
  }

  Future<void> keepPhase({
    required int quitPlanId,
    required int phaseId,
  }) async {
    await service.keepPhase(quitPlanId: quitPlanId, phaseId: phaseId);
  }

  Future<void> redoPhase({
    required int phaseId,
    required String anchorStart,
  }) async {
    await service.redoPhase(phaseId: phaseId, anchorStart: anchorStart);
  }
}
