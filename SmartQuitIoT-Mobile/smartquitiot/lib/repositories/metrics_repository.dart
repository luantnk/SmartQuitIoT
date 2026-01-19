import 'package:dio/dio.dart';
import 'package:SmartQuitIoT/models/home_metrics.dart';
import 'package:SmartQuitIoT/models/health_recovery.dart';
import 'package:SmartQuitIoT/models/home_health_recovery.dart';
import 'package:SmartQuitIoT/core/errors/failures.dart';
import '../services/metrics_service.dart';
import '../repositories/auth_repository.dart';

class MetricsRepository {
  final MetricsService _metricsService;
  final AuthRepository _authRepository;

  MetricsRepository(this._authRepository, this._metricsService);

  /// Get home screen metrics
  Future<HomeMetrics> getHomeMetrics() async {
    try {
      final response = await _metricsService.getHomeMetrics();

      if (response.statusCode == 200) {
        return HomeMetrics.fromJson(response.data);
      } else {
        throw ServerFailure(
          'Failed to fetch home metrics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get health recovery data
  Future<HealthRecoveryResponse> getHealthRecoveries() async {
    try {
      final response = await _metricsService.getHealthRecoveries();

      if (response.statusCode == 200) {
        print('🔍 Parsing HealthRecoveryResponse from data...');
        try {
          final healthRecoveryResponse = HealthRecoveryResponse.fromJson(response.data);
          print('✅ Successfully parsed HealthRecoveryResponse');
          print('   - Health Recoveries count: ${healthRecoveryResponse.healthRecoveries.length}');
          print('   - Metrics streaks: ${healthRecoveryResponse.metrics.streaks}');
          return healthRecoveryResponse;
        } catch (parseError) {
          print('❌ JSON Parsing Error: $parseError');
          print('❌ Response data type: ${response.data.runtimeType}');
          print('❌ Response keys: ${response.data is Map ? (response.data as Map).keys : "Not a Map"}');
          throw ServerFailure('Failed to parse health recoveries: $parseError');
        }
      } else {
        throw ServerFailure(
          'Failed to fetch health recoveries: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  /// Get home screen health recovery data
  Future<HomeHealthRecovery> getHomeHealthRecovery() async {
    try {
      final response = await _metricsService.getHomeHealthRecovery();

      if (response.statusCode == 200) {
        print('🔍 Parsing HomeHealthRecovery from data...');
        print('📦 Response data: ${response.data}');
        return HomeHealthRecovery.fromJson(response.data);
      } else {
        throw ServerFailure(
          'Failed to fetch home health recovery: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (e.response?.statusCode == 404) {
          return 'No data found.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Server returned error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Network error occurred.';
    }
  }
}
