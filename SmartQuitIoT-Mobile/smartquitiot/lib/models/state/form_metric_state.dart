import '../response/form_metric_response.dart';

class FormMetricState {
  final bool isLoading;
  final FormMetricResponse? formMetric;
  final String? error;

  FormMetricState({
    this.isLoading = false,
    this.formMetric,
    this.error,
  });

  FormMetricState copyWith({
    bool? isLoading,
    FormMetricResponse? formMetric,
    String? error,
  }) {
    return FormMetricState(
      isLoading: isLoading ?? this.isLoading,
      formMetric: formMetric ?? this.formMetric,
      error: error,
    );
  }
}
