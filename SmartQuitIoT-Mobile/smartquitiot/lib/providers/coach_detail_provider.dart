import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/coach_detail_repository.dart';
import '../viewmodels/coach_detail_viewmodel.dart';

// Repository provider
final coachDetailRepositoryProvider = Provider<CoachDetailRepository>(
        (ref) => CoachDetailRepository(),
);

// ViewModel provider
final coachDetailViewModelProvider =
StateNotifierProvider<CoachDetailViewModel, CoachDetailState>(
        (ref) => CoachDetailViewModel(ref.read(coachDetailRepositoryProvider)),
);
