import 'package:logger/logger.dart';
import '../models/quit_plan_detail.dart';
import '../services/quit_plan_detail_service.dart';
import '../services/token_storage_service.dart';

class QuitPlanDetailRepository {
  final QuitPlanDetailService _service;
  final TokenStorageService _tokenStorage;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  QuitPlanDetailRepository({
    required QuitPlanDetailService service,
    required TokenStorageService tokenStorage,
  })  : _service = service,
        _tokenStorage = tokenStorage;

  /// Get quit plan detail by ID
  Future<QuitPlanDetail> getQuitPlanDetail(int quitPlanId) async {
    try {
      _logger.d('📋 [QuitPlanDetailRepository] Fetching quit plan detail for ID: $quitPlanId');

      // Get access token
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _logger.e('❌ [QuitPlanDetailRepository] Access token is null or empty');
        throw Exception('Access token not found. Please login again.');
      }

      _logger.d('🔑 [QuitPlanDetailRepository] Token retrieved successfully');

      // Call service
      final quitPlan = await _service.getQuitPlanDetail(
        quitPlanId: quitPlanId,
        accessToken: accessToken,
      );

      _logger.i('✅ [QuitPlanDetailRepository] Successfully fetched quit plan: ${quitPlan.name}');
      _logger.d('📊 [QuitPlanDetailRepository] Total phases: ${quitPlan.phases?.length ?? 0}');
      _logger.d('📊 [QuitPlanDetailRepository] Total missions: ${quitPlan.totalMissions}');
      _logger.d('📊 [QuitPlanDetailRepository] Completed missions: ${quitPlan.completedMissions}');

      return quitPlan;
    } catch (e) {
      _logger.e('❌ [QuitPlanDetailRepository] Error: $e');
      rethrow;
    }
  }
}
