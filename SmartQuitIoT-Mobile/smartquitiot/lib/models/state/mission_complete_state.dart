class MissionCompleteState {
  final bool isLoading;
  final String? error;
  final bool isCompleted;
  final List<String> selectedTriggers;

  const MissionCompleteState({
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
    this.selectedTriggers = const [],
  });

  MissionCompleteState copyWith({
    bool? isLoading,
    String? error,
    bool? isCompleted,
    List<String>? selectedTriggers,
  }) {
    return MissionCompleteState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
      selectedTriggers: selectedTriggers ?? this.selectedTriggers,
    );
  }

  bool get hasError => error != null;
}
