class DiaryTodayState {
  final bool isLoading;
  final bool isRefreshing;
  final bool? hasRecordToday;
  final String? error;
  final DateTime? lastUpdated;

  const DiaryTodayState({
    required this.isLoading,
    required this.isRefreshing,
    this.hasRecordToday,
    this.error,
    this.lastUpdated,
  });

  factory DiaryTodayState.initial() {
    return const DiaryTodayState(
      isLoading: false,
      isRefreshing: false,
      hasRecordToday: null,
      error: null,
      lastUpdated: null,
    );
  }

  DiaryTodayState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? hasRecordToday,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return DiaryTodayState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasRecordToday: hasRecordToday ?? this.hasRecordToday,
      error: clearError ? null : error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
