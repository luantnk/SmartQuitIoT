import 'package:logger/logger.dart';
import '../models/quit_plan_history.dart';
import '../services/quit_plan_history_service.dart';
import '../services/token_storage_service.dart';

class QuitPlanHistoryRepository {
  final QuitPlanHistoryService _service;
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

  QuitPlanHistoryRepository({
    required QuitPlanHistoryService service,
    required TokenStorageService tokenStorage,
  })  : _service = service,
        _tokenStorage = tokenStorage;

  /// Get all quit plan history
  Future<List<QuitPlanHistory>> getAllQuitPlans() async {
    try {
      _logger.d('📜 [QuitPlanHistoryRepository] Fetching all quit plans...');

      // Get access token
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _logger.e('❌ [QuitPlanHistoryRepository] Access token is null or empty');
        throw Exception('Access token not found. Please login again.');
      }

      _logger.d('🔑 [QuitPlanHistoryRepository] Token retrieved successfully');

      // Call service
      final quitPlans = await _service.getAllQuitPlans(accessToken: accessToken);

      _logger.i('✅ [QuitPlanHistoryRepository] Successfully fetched ${quitPlans.length} quit plans');

      // Sort by createdAt (newest first)
      quitPlans.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt);
          final dateB = DateTime.parse(b.createdAt);
          return dateB.compareTo(dateA); // Descending order
        } catch (e) {
          _logger.w('⚠️ [QuitPlanHistoryRepository] Error parsing dates: $e');
          return 0;
        }
      });

      _logger.d('📊 [QuitPlanHistoryRepository] Quit plans sorted by date');

      return quitPlans;
    } catch (e) {
      _logger.e('❌ [QuitPlanHistoryRepository] Error: $e');
      rethrow;
    }
  }

  /// Get active quit plan
  Future<QuitPlanHistory?> getActiveQuitPlan() async {
    try {
      _logger.d('📜 [QuitPlanHistoryRepository] Fetching active quit plan...');

      final quitPlans = await getAllQuitPlans();
      final activeQuitPlan = quitPlans.firstWhere(
        (plan) => plan.active,
        orElse: () => quitPlans.first, // Fallback to first if no active
      );

      _logger.i('✅ [QuitPlanHistoryRepository] Active quit plan found: ${activeQuitPlan.name}');
      return activeQuitPlan;
    } catch (e) {
      _logger.e('❌ [QuitPlanHistoryRepository] Error getting active quit plan: $e');
      return null;
    }
  }

  /// Get quit plans by status
  Future<List<QuitPlanHistory>> getQuitPlansByStatus(String status) async {
    try {
      _logger.d('📜 [QuitPlanHistoryRepository] Fetching quit plans with status: $status');

      final quitPlans = await getAllQuitPlans();
      final filteredPlans = quitPlans.where((plan) => plan.status == status).toList();

      _logger.i('✅ [QuitPlanHistoryRepository] Found ${filteredPlans.length} quit plans with status: $status');
      return filteredPlans;
    } catch (e) {
      _logger.e('❌ [QuitPlanHistoryRepository] Error filtering by status: $e');
      rethrow;
    }
  }
}
