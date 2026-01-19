import 'package:logger/logger.dart';
import '../models/response/form_metric_response.dart';
import '../models/request/update_form_metric_request.dart';
import '../models/response/update_form_metric_response.dart';
import '../services/form_metric_service.dart';

class FormMetricRepository {
  final FormMetricService _formMetricService;
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

  FormMetricRepository(this._formMetricService) {
    _logger.i('📊 [FormMetricRepository] Initialized');
  }

  /// Get form metric data
  Future<FormMetricResponse> getFormMetric({
    required String accessToken,
  }) async {
    try {
      _logger.d('📊 [FormMetricRepository] Fetching form metric...');
      
      final response = await _formMetricService.getFormMetric(
        accessToken: accessToken,
      );

      _logger.i('✅ [FormMetricRepository] Successfully fetched form metric');
      _logger.d('📊 [FormMetricRepository] FTND Score: ${response.ftndScore}');
      _logger.d('📊 [FormMetricRepository] Smoke Avg/Day: ${response.formMetricDTO.smokeAvgPerDay}');
      
      return response;
    } catch (e, stackTrace) {
      _logger.e('❌ [FormMetricRepository] Failed to fetch form metric: $e');
      _logger.e('🧩 [FormMetricRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update form metric data
  Future<UpdateFormMetricResponse> updateFormMetric({
    required String accessToken,
    required UpdateFormMetricRequest request,
  }) async {
    try {
      _logger.d('📊 [FormMetricRepository] Updating form metric...');
      _logger.d('📊 [FormMetricRepository] Smoke Avg/Day: ${request.smokeAvgPerDay}');
      _logger.d('📊 [FormMetricRepository] Years Smoking: ${request.numberOfYearsOfSmoking}');
      
      final response = await _formMetricService.updateFormMetric(
        accessToken: accessToken,
        request: request,
      );

      _logger.i('✅ [FormMetricRepository] Successfully updated form metric');
      _logger.w('⚠️ [FormMetricRepository] Alert flag: ${response.alert}');
      _logger.i('📊 [FormMetricRepository] New FTND Score: ${response.ftndScore}');
      
      if (response.alert) {
        _logger.w('🚨 [FormMetricRepository] ALERT: FTND-affecting fields were changed!');
        _logger.w('🚨 [FormMetricRepository] User should consider creating new quit plan');
      }
      
      return response;
    } catch (e, stackTrace) {
      _logger.e('❌ [FormMetricRepository] Failed to update form metric: $e');
      _logger.e('🧩 [FormMetricRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
