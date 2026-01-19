import '../today_mission.dart';

class TodayMissionState {
  final List<TodayMissionDetail> missions;
  final bool isLoading;
  final String? error;
  final bool allMissionsCompleted;

  const TodayMissionState({
    this.missions = const [],
    this.isLoading = false,
    this.error,
    this.allMissionsCompleted = false,
  });

  TodayMissionState copyWith({
    List<TodayMissionDetail>? missions,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? allMissionsCompleted,
  }) {
    return TodayMissionState(
      missions: missions ?? this.missions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      allMissionsCompleted: allMissionsCompleted ?? this.allMissionsCompleted,
    );
  }

  bool get hasMissions => missions.isNotEmpty;
  bool get hasError => error != null;
}
