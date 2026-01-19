import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/phase.dart';
import '../models/request/create_new_quit_plan_request.dart';
import '../models/request/create_quit_plan_request.dart';
import '../repositories/auth_repository.dart';

class QuitPlanService {
  QuitPlanService({
    Dio? dio,
    Logger? logger,
    String? baseUrl,
    AuthRepository? authRepository,
  }) : _dio = dio ?? Dio(),
       _logger = logger ?? Logger(),
       _authRepository = authRepository ?? AuthRepository(),
       _baseUrl = baseUrl ?? dotenv.env['API_BASE_URL'] ?? '' {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 75),
      sendTimeout: const Duration(seconds: 30),
    );

    _logger.i('[QuitPlanService] Initialized with baseUrl: $_baseUrl');
  }

  final Dio _dio;
  final Logger _logger;
  final AuthRepository _authRepository;
  final String _baseUrl;

  /// Lấy access token từ AuthRepository
  Future<String> _getAccessToken() async {
    final token = await _authRepository.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No valid access token available. Please login again.');
    }
    return token;
  }

  /// Create options với auto token
  Future<Options> _options() async {
    final accessToken = await _getAccessToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<Phase> createQuitPlan({required CreateQuitPlanRequest request}) async {
    try {
      _logger.i(
        '[QuitPlanService] POST $_baseUrl/quit-plan/create-in-first-login',
      );
      final response = await _dio.post(
        '/quit-plan/create-in-first-login',
        data: request.toJson(),
        options: await _options(),
      );

      _logger.d('[QuitPlanService] Response: ${response.statusCode}');
      return Phase.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logError('createQuitPlan', e);
      throw Exception(_mapError(e));
    }
  }

  Future<Phase> createNewQuitPlan({
    required CreateNewQuitPlanRequest request,
  }) async {
    try {
      _logger.i('[QuitPlanService] POST $_baseUrl/quit-plan/create-new');

      // Create a temporary Dio instance with 1 minute timeout for this request
      final tempDio = Dio(_dio.options);
      tempDio.options.receiveTimeout = const Duration(seconds: 60);

      final options = await _options();
      final response = await tempDio.post(
        '/quit-plan/create-new',
        data: request.toJson(),
        options: options,
      );

      _logger.d('[QuitPlanService] Response: ${response.statusCode}');
      return Phase.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logError('createNewQuitPlan', e);
      throw Exception(_mapError(e));
    }
  }

  Future<Map<String, dynamic>> getQuitPlan() async {
    try {
      _logger.i('[QuitPlanService] GET $_baseUrl');
      final response = await _dio.get('/quit-plan', options: await _options());

      _logger.d('[QuitPlanService] Response: ${response.statusCode}');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      _logError('getQuitPlan', e);
      throw Exception(_mapError(e));
    }
  }

  Future<void> keepPhase({
    required int quitPlanId,
    required int phaseId,
  }) async {
    try {
      _logger.i('[QuitPlanService] POST $_baseUrl/keep-plan');
      await _dio.post(
        '/quit-plan/keep-plan',
        data: {'quitPlanId': quitPlanId, 'phaseId': phaseId},
        options: await _options(),
      );
    } on DioException catch (e) {
      _logError('keepPhase', e);
      throw Exception(_mapError(e));
    }
  }

  Future<void> redoPhase({
    required int phaseId,
    required String anchorStart,
  }) async {
    try {
      _logger.i('[QuitPlanService] POST $_baseUrl/redo-phase');
      await _dio.post(
        '/phase/redo',
        data: {'phaseId': phaseId, 'anchorStart': anchorStart},
        options: await _options(),
      );
    } on DioException catch (e) {
      _logError('redoPhase', e);
      throw Exception(_mapError(e));
    }
  }

  void _logError(String action, DioException e) {
    _logger.e('[QuitPlanService] $action failed', error: e);
  }

  String _mapError(DioException e) {
    if (e.response != null) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      return 'Request failed ($status): $message';
    }
    return e.message ?? 'Unknown error';
  }
}
