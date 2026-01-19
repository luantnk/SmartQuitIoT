import 'package:SmartQuitIoT/viewmodels/quit_phase_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/phase.dart';
import '../models/quit_phase.dart';
import '../repositories/quit_plan_repository.dart';
import '../services/quit_plan_service.dart';
import '../viewmodels/quit_plan_view_model.dart';
import 'auth_provider.dart'; // Provider AuthRepository

final quitPlanServiceProvider = Provider<QuitPlanService>((ref) {
  final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';
  return QuitPlanService(baseUrl: apiBaseUrl);
});

// Repository Provider
final quitPlanRepositoryProvider = Provider<QuitPlanRepository>((ref) {
  final service = ref.watch(quitPlanServiceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return QuitPlanRepository(service: service, authRepository: authRepository);
});

// ViewModel Provider
// ViewModel Provider
final quitPlanViewModelProvider =
    StateNotifierProvider<QuitPlanViewModel, AsyncValue<Phase?>>((ref) {
      final repo = ref.watch(quitPlanRepositoryProvider);
      return QuitPlanViewModel(repo);
    });

final quitPlanViewModelApiProvider =
    StateNotifierProvider<QuitPhaseViewModel, AsyncValue<QuitPhase?>>((ref) {
      final repo = ref.watch(quitPlanRepositoryProvider);
      return QuitPhaseViewModel(repo);
    });
