import '../core/errors/exception.dart';
import '../models/quit_plan_homepage.dart';
import '../services/quit_plan_homepage_service.dart';
import '../repositories/auth_repository.dart';

class QuitPlanHomepageRepository {
  final QuitPlanHomepageService _quitPlanHomepageService;
  final AuthRepository _authRepository;

  QuitPlanHomepageRepository({
    QuitPlanHomepageService? quitPlanHomepageService,
    AuthRepository? authRepository,
  }) : _quitPlanHomepageService =
           quitPlanHomepageService ?? QuitPlanHomepageService(),
       _authRepository = authRepository ?? AuthRepository();

  /// Get quit plan home page data
  Future<QuitPlanHomePage> getQuitPlanHomePage() async {
    try {
      // Use getValidAccessToken() to ensure we have a valid token (will refresh if expired)
      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw QuitPlanException('Access token not found. Please login again.');
      }

      // Call service to get response
      final QuitPlanHomePage quitPlan = await _quitPlanHomepageService
          .getQuitPlanHomePage(accessToken: accessToken);

      print(
        '✅ [QuitPlanHomepageRepository] Loaded quit plan: ${quitPlan.name}',
      );

      return quitPlan;
    } catch (e, st) {
      print('🔥 [QuitPlanHomepageRepository] Error getting quit plan: $e\n$st');
      if (e is QuitPlanException) rethrow;
      throw QuitPlanException('Failed to get quit plan: ${e.toString()}');
    }
  }
}
