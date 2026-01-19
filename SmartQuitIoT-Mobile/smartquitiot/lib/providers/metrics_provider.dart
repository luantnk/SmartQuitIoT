import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/home_metrics.dart';
import 'package:SmartQuitIoT/models/health_recovery.dart';
import 'package:SmartQuitIoT/models/home_health_recovery.dart';
import 'package:SmartQuitIoT/repositories/metrics_repository.dart';
import 'package:SmartQuitIoT/services/metrics_service.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';

final metricsAuthTokenProvider = Provider<String?>((ref) {
  return ref.watch(authViewModelProvider.select((s) => s.accessToken));
});

// Service Provider
final metricsServiceProvider = Provider<MetricsService>((ref) {
  return MetricsService(ref.read(authRepositoryProvider));
});

// Repository Provider
final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository(
    ref.read(authRepositoryProvider),
    ref.read(metricsServiceProvider),
  );
});

// Home Metrics Provider
final homeMetricsProvider = FutureProvider.autoDispose<HomeMetrics>((
  ref,
) async {
  ref.watch(metricsAuthTokenProvider);

  final repository = ref.read(metricsRepositoryProvider);
  return await repository.getHomeMetrics();
});

// Health Recoveries Provider
final healthRecoveriesProvider =
    FutureProvider.autoDispose<HealthRecoveryResponse>((ref) async {
      ref.watch(metricsAuthTokenProvider);

      // Listen for refresh trigger
      ref.watch(metricsRefreshProvider);

      final repository = ref.read(metricsRepositoryProvider);
      return await repository.getHealthRecoveries();
    });

// Home Health Recovery Provider
final homeHealthRecoveryProvider =
    FutureProvider.autoDispose<HomeHealthRecovery>((ref) async {
      ref.watch(metricsAuthTokenProvider);

      // Listen for refresh trigger
      ref.watch(metricsRefreshProvider);

      final repository = ref.read(metricsRepositoryProvider);
      return await repository.getHomeHealthRecovery();
    });

// Refresh Provider for metrics (similar to diary refresh)
final metricsRefreshProvider =
    StateNotifierProvider<MetricsRefreshNotifier, int>((ref) {
      return MetricsRefreshNotifier();
    });

class MetricsRefreshNotifier extends StateNotifier<int> {
  MetricsRefreshNotifier() : super(0);

  void refreshMetrics() {
    state++;
  }
}
