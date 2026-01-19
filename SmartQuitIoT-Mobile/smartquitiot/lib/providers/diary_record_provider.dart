import 'package:SmartQuitIoT/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/models/diary_history.dart';
import 'package:SmartQuitIoT/models/diary_charts.dart';
import 'package:SmartQuitIoT/models/diary_create_result.dart';
import 'package:SmartQuitIoT/repositories/diary_record_repository.dart';
import 'package:SmartQuitIoT/services/diary_service.dart';
import 'package:SmartQuitIoT/core/errors/failures.dart';
import 'package:SmartQuitIoT/models/state/diary_today_state.dart';
import 'package:SmartQuitIoT/viewmodels/diary_today_view_model.dart';
import 'package:SmartQuitIoT/providers/diary_refresh_provider.dart';

// Service provider
final diaryServiceProvider = Provider<DiaryService>((ref) {
  return DiaryService(ref.read(authRepositoryProvider));
});

// Repository provider
final diaryRecordRepositoryProvider = Provider<DiaryRecordRepository>((ref) {
  return DiaryRecordRepository(
    ref.read(authRepositoryProvider),
    ref.read(diaryServiceProvider),
  );
});

final diaryTodayViewModelProvider =
    StateNotifierProvider<DiaryTodayViewModel, DiaryTodayState>((ref) {
      final repository = ref.watch(diaryRecordRepositoryProvider);
      return DiaryTodayViewModel(repository);
    });

// Data providers
final diaryHistoryProvider = FutureProvider<List<DiaryHistory>>((ref) async {
  final repository = ref.read(diaryRecordRepositoryProvider);
  return await repository.getDiaryHistory();
});

final diaryChartsProvider = FutureProvider<DiaryCharts>((ref) async {
  // Listen for refresh trigger
  ref.watch(diaryChartsRefreshProvider);

  print('📊 [DiaryChartsProvider] Fetching diary charts data...');
  final repository = ref.read(diaryRecordRepositoryProvider);
  return await repository.getDiaryCharts();
});

final allDiaryRecordsProvider = FutureProvider<List<DiaryRecord>>((ref) async {
  final repository = ref.read(diaryRecordRepositoryProvider);
  return await repository.getAllDiaryRecords();
});

final todayDiaryRecordProvider = FutureProvider<DiaryRecord?>((ref) async {
  final repository = ref.read(diaryRecordRepositoryProvider);

  try {
    // Get all diary records and filter for today
    final allRecords = await repository.getAllDiaryRecords();
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Find today's record
    for (final record in allRecords) {
      if (record.date == todayString) {
        return record;
      }
    }

    return null; // No record for today
  } catch (e) {
    print('❌ Error getting today diary record: $e');
    return null;
  }
});

final diaryRecordNotifierProvider =
    StateNotifierProvider<DiaryRecordNotifier, AsyncValue<DiaryCreateResult?>>((
      ref,
    ) {
      print('🏗️ Creating DiaryRecordNotifier instance...');
      final repository = ref.watch(diaryRecordRepositoryProvider);
      return DiaryRecordNotifier(repository, ref);
    });

class DiaryRecordNotifier
    extends StateNotifier<AsyncValue<DiaryCreateResult?>> {
  final DiaryRecordRepository _repository;
  final Ref _ref;

  DiaryRecordNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null)) {
    print('✅ DiaryRecordNotifier initialized with repository');
  }

  Future<void> createDiaryRecord(DiaryRecordRequest request) async {
    print('📝 [DiaryRecordNotifier] Starting createDiaryRecord...');
    state = const AsyncValue.loading();
    try {
      final result = await _repository.createDiaryRecord(request);
      print(
        '✅ [DiaryRecordNotifier] Diary created with status code: ${result.statusCode}',
      );
      state = AsyncValue.data(result);
      _ref.read(diaryTodayViewModelProvider.notifier).refreshTodayStatus();
    } on ServerFailure catch (e) {
      print('❌ [DiaryRecordNotifier] ServerFailure: ${e.message}');
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      print('❌ [DiaryRecordNotifier] Error: $e');
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> updateDiaryRecord(
    int id,
    DiaryRecordUpdateRequest request,
  ) async {
    print('📝 [DiaryRecordNotifier] Starting updateDiaryRecord for ID: $id...');
    state = const AsyncValue.loading();
    try {
      final updatedRecord = await _repository.updateDiaryRecord(id, request);
      print('✅ [DiaryRecordNotifier] Diary updated successfully');
      
      // Create a result object similar to create for consistency
      final result = DiaryCreateResult(
        diaryRecord: updatedRecord,
        statusCode: 200,
        message: 'Diary record updated successfully',
      );
      
      state = AsyncValue.data(result);
      
      // Invalidate providers to refresh data
      _ref.invalidate(diaryDetailProvider(id));
      _ref.invalidate(diaryHistoryProvider);
      _ref.invalidate(diaryChartsProvider);
      _ref.read(diaryChartsRefreshProvider.notifier).refreshCharts();
      _ref.read(diaryRefreshProvider.notifier).refreshDiaryHistory();
    } on ServerFailure catch (e) {
      print('❌ [DiaryRecordNotifier] ServerFailure: ${e.message}');
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      print('❌ [DiaryRecordNotifier] Error: $e');
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

// Provider để check xem hôm nay đã có diary record chưa
final hasTodayDiaryRecordProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(diaryRecordRepositoryProvider);
  return await repository.hasDiaryRecordToday();
});

// Provider for diary detail by ID (using family to cache per ID)
final diaryDetailProvider = FutureProvider.family<DiaryRecord, int>((
  ref,
  diaryId,
) async {
  print('📖 [DiaryDetailProvider] Loading diary detail for ID: $diaryId');
  final repository = ref.watch(diaryRecordRepositoryProvider);
  return await repository.getDiaryRecordById(diaryId);
});

// Refresh Provider for diary charts (auto-refresh after creating diary)
final diaryChartsRefreshProvider =
    StateNotifierProvider<DiaryChartsRefreshNotifier, int>((ref) {
      return DiaryChartsRefreshNotifier();
    });

class DiaryChartsRefreshNotifier extends StateNotifier<int> {
  DiaryChartsRefreshNotifier() : super(0);

  void refreshCharts() {
    print('🔄 [DiaryChartsRefreshNotifier] Triggering charts refresh...');
    state++;
  }
}
