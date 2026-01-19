import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int counter;
  final bool isLoading;

  const HomeState({this.counter = 0, this.isLoading = false});

  HomeState copyWith({int? counter, bool? isLoading}) {
    return HomeState(
      counter: counter ?? this.counter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState());

  void increment() {
    state = state.copyWith(counter: state.counter + 1);
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel();
});
