import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/reminder_settings_repository.dart';
import '../services/reminder_settings_service.dart';
import '../repositories/auth_repository.dart';

// Providers
final reminderSettingsServiceProvider = Provider<ReminderSettingsService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ReminderSettingsService(authRepository: authRepository);
});

final reminderSettingsRepositoryProvider = Provider<ReminderSettingsRepository>((ref) {
  final reminderSettingsService = ref.watch(reminderSettingsServiceProvider);
  return ReminderSettingsRepository(reminderSettingsService: reminderSettingsService);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Reminder Settings State
class ReminderSettingsState {
  final bool isUpdating;
  final String? error;

  ReminderSettingsState({
    this.isUpdating = false,
    this.error,
  });

  ReminderSettingsState copyWith({
    bool? isUpdating,
    String? error,
  }) {
    return ReminderSettingsState(
      isUpdating: isUpdating ?? this.isUpdating,
      error: error ?? this.error,
    );
  }
}

// Reminder Settings ViewModel
class ReminderSettingsViewModel extends StateNotifier<ReminderSettingsState> {
  final ReminderSettingsRepository _reminderSettingsRepository;

  ReminderSettingsViewModel({
    required ReminderSettingsRepository reminderSettingsRepository,
  })  : _reminderSettingsRepository = reminderSettingsRepository,
        super(ReminderSettingsState());

  /// Update reminder settings
  Future<void> updateReminderSettings({
    required String morningReminderTime,
    required String quietStart,
    required String quietEnd,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      print('🔄 [ReminderSettingsViewModel] Updating reminder settings...');
      await _reminderSettingsRepository.updateReminderSettings(
        morningReminderTime: morningReminderTime,
        quietStart: quietStart,
        quietEnd: quietEnd,
      );

      state = state.copyWith(isUpdating: false, error: null);
      print('✅ [ReminderSettingsViewModel] Reminder settings updated successfully');
    } catch (e) {
      print('❌ [ReminderSettingsViewModel] Error updating reminder settings: $e');
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Reminder Settings ViewModel Provider
final reminderSettingsViewModelProvider =
    StateNotifierProvider<ReminderSettingsViewModel, ReminderSettingsState>((ref) {
  final reminderSettingsRepository = ref.watch(reminderSettingsRepositoryProvider);
  return ReminderSettingsViewModel(reminderSettingsRepository: reminderSettingsRepository);
});

