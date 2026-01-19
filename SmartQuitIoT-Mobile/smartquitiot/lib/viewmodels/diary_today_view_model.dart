import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/state/diary_today_state.dart';
import 'package:SmartQuitIoT/repositories/diary_record_repository.dart';

class DiaryTodayViewModel extends StateNotifier<DiaryTodayState> {
  final DiaryRecordRepository _repository;

  DiaryTodayViewModel(this._repository) : super(DiaryTodayState.initial()) {
    _initialize();
  }

  void _initialize() {
    Future.microtask(checkTodayStatus);
  }

  Future<void> checkTodayStatus() async {
    state = state.copyWith(
      isLoading: true,
      isRefreshing: false,
      clearError: true,
    );
    await _fetchStatus();
  }

  Future<void> refreshTodayStatus() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, clearError: true);
    await _fetchStatus(showLoading: false);
  }

  Future<void> _fetchStatus({bool showLoading = true}) async {
    try {
      final hasRecord = await _repository.hasDiaryRecordToday();
      state = state.copyWith(
        isLoading: showLoading ? false : state.isLoading,
        isRefreshing: false,
        hasRecordToday: hasRecord,
        clearError: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }
}
