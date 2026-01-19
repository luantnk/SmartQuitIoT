import '../services/quit_plan_time_service.dart';

class QuitPlanTimeRepository {
  final QuitPlanTimeService _service;

  QuitPlanTimeRepository(this._service);

  Future<DateTime> getStartTime() async {
    try {
      return await _service.getStartTime();
    } catch (e) {
      print('❌ [QuitPlanTimeRepository] Error: $e');
      rethrow;
    }
  }
}
