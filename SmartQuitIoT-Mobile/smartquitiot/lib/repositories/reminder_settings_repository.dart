import '../services/reminder_settings_service.dart';

class ReminderSettingsRepository {
  final ReminderSettingsService _reminderSettingsService;

  ReminderSettingsRepository({
    required ReminderSettingsService reminderSettingsService,
  }) : _reminderSettingsService = reminderSettingsService;

  /// Update reminder settings with validation
  Future<Map<String, dynamic>> updateReminderSettings({
    required String morningReminderTime,
    required String quietStart,
    required String quietEnd,
  }) async {
    try {
      print('📦 [ReminderSettingsRepository] Updating reminder settings...');

      // Basic validation
      if (morningReminderTime.trim().isEmpty) {
        throw Exception('Morning reminder time cannot be empty');
      }
      if (quietStart.trim().isEmpty) {
        throw Exception('Quiet start time cannot be empty');
      }
      if (quietEnd.trim().isEmpty) {
        throw Exception('Quiet end time cannot be empty');
      }

      // Validate time format (HH:mm)
      if (!_isValidTimeFormat(morningReminderTime)) {
        throw Exception('Invalid morning reminder time format. Expected HH:mm');
      }
      if (!_isValidTimeFormat(quietStart)) {
        throw Exception('Invalid quiet start time format. Expected HH:mm');
      }
      if (!_isValidTimeFormat(quietEnd)) {
        throw Exception('Invalid quiet end time format. Expected HH:mm');
      }

      final result = await _reminderSettingsService.updateReminderSettings(
        morningReminderTime: morningReminderTime.trim(),
        quietStart: quietStart.trim(),
        quietEnd: quietEnd.trim(),
      );

      print('✅ [ReminderSettingsRepository] Reminder settings updated successfully');
      return result;
    } catch (e) {
      print('❌ [ReminderSettingsRepository] Error updating reminder settings: $e');
      rethrow;
    }
  }

  /// Validate time format (HH:mm)
  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }
}

