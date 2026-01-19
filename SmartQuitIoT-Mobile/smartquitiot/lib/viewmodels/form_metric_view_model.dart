import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/state/form_metric_state.dart';
import '../models/request/update_form_metric_request.dart';
import '../models/response/form_metric_response.dart';
import '../models/response/update_form_metric_response.dart';
import '../repositories/form_metric_repository.dart';
import '../services/form_metric_service.dart';
import '../services/token_storage_service.dart';
import 'package:dio/dio.dart';

// Providers
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final formMetricServiceProvider = Provider<FormMetricService>((ref) {
  final dio = ref.watch(dioProvider);
  return FormMetricService(dio: dio);
});

final formMetricRepositoryProvider = Provider<FormMetricRepository>((ref) {
  final formMetricService = ref.watch(formMetricServiceProvider);
  return FormMetricRepository(formMetricService);
});

final formMetricViewModelProvider =
    StateNotifierProvider<FormMetricViewModel, FormMetricState>((ref) {
  final repository = ref.watch(formMetricRepositoryProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return FormMetricViewModel(repository, tokenStorage);
});

// FormMetric ViewModel
class FormMetricViewModel extends StateNotifier<FormMetricState> {
  final FormMetricRepository _repository;
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

  FormMetricViewModel(this._repository, this._tokenStorage)
      : super(FormMetricState()) {
    _logger.i('📊 [FormMetricViewModel] Initialized');
  }

  /// Load form metric data
  Future<void> loadFormMetric() async {
    try {
      _logger.d('📊 [FormMetricViewModel] Loading form metric...');
      state = state.copyWith(isLoading: true, error: null);

      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        _logger.w('⚠️ [FormMetricViewModel] No access token found');
        state = state.copyWith(
          isLoading: false,
          error: 'Please login to view form metrics',
        );
        return;
      }

      final formMetric = await _repository.getFormMetric(
        accessToken: token,
      );

      _logger.i('✅ [FormMetricViewModel] Form metric loaded successfully');
      _logger.d('📊 [FormMetricViewModel] FTND Score: ${formMetric.ftndScore}');
      
      state = state.copyWith(
        isLoading: false,
        formMetric: formMetric,
        error: null,
      );
    } catch (e, stackTrace) {
      _logger.e('❌ [FormMetricViewModel] Failed to load form metric: $e');
      _logger.e('🧩 [FormMetricViewModel] Stack trace: $stackTrace');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh form metric data
  Future<void> refresh() async {
    _logger.d('🔄 [FormMetricViewModel] Refreshing form metric...');
    await loadFormMetric();
  }

  /// Update form metric data
  Future<UpdateFormMetricResponse?> updateFormMetric({
    required UpdateFormMetricRequest request,
  }) async {
    try {
      _logger.d('📊 [FormMetricViewModel] Updating form metric...');
      state = state.copyWith(isLoading: true, error: null);

      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        _logger.w('⚠️ [FormMetricViewModel] No access token found');
        state = state.copyWith(
          isLoading: false,
          error: 'Please login to update form metrics',
        );
        return null;
      }

      final response = await _repository.updateFormMetric(
        accessToken: token,
        request: request,
      );

      _logger.i('✅ [FormMetricViewModel] Form metric updated successfully');
      _logger.w('⚠️ [FormMetricViewModel] Alert flag: ${response.alert}');
      _logger.i('📊 [FormMetricViewModel] New FTND Score: ${response.ftndScore}');
      
      // Update state với data mới
      state = state.copyWith(
        isLoading: false,
        formMetric: FormMetricResponse(
          formMetricDTO: response.formMetricDTO,
          ftndScore: response.ftndScore,
        ),
        error: null,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.e('❌ [FormMetricViewModel] Failed to update form metric: $e');
      _logger.e('🧩 [FormMetricViewModel] Stack trace: $stackTrace');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      return null;
    }
  }
}
