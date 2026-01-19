import '../quit_plan_homepage.dart';

class QuitPlanHomepageState {
  final QuitPlanHomePage? quitPlan;
  final bool isLoading;
  final String? error;

  const QuitPlanHomepageState({
    this.quitPlan,
    this.isLoading = false,
    this.error,
  });

  QuitPlanHomepageState copyWith({
    QuitPlanHomePage? quitPlan,
    bool? isLoading,
    String? error,
  }) {
    return QuitPlanHomepageState(
      quitPlan: quitPlan ?? this.quitPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasQuitPlan => quitPlan != null;
  bool get hasError => error != null;
}
