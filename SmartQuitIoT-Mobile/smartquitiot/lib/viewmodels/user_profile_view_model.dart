// viewmodels/user_profile_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
    );
  }
}

class UserProfileViewModel extends StateNotifier<UserProfileState> {
  final ApiService _apiService;

  UserProfileViewModel(this._apiService) : super(const UserProfileState());

  Future<void> loadUserProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final profile = await _apiService.getUserProfile(userId);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUserStatistics(String userId) async {
    try {
      final statistics = await _apiService.getUserStatistics(userId);
      state = state.copyWith(statistics: statistics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedProfile = await _apiService.updateUserProfile(profile);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}



// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final userProfileViewModelProvider = StateNotifierProvider<UserProfileViewModel, UserProfileState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserProfileViewModel(apiService);
});
