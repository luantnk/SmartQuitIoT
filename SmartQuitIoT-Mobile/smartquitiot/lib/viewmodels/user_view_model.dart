import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/user_model.dart';
import 'package:SmartQuitIoT/repositories/user_repository.dart';
import 'package:SmartQuitIoT/services/user_service.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';
import 'package:dio/dio.dart';

// Providers
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorageService = ref.watch(tokenStorageServiceProvider);
  return UserService(dio: dio, tokenStorageService: tokenStorageService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userService = ref.watch(userServiceProvider);
  return UserRepository(userService: userService);
});

// User state
class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  UserState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

// User ViewModel
class UserViewModel extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserViewModel({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UserState());

  /// Load user profile
  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔄 [UserViewModel] Loading user profile...');
      final user = await _userRepository.getUserProfile();
      state = state.copyWith(user: user, isLoading: false, error: null);
      print('✅ [UserViewModel] User profile loaded successfully');
    } catch (e) {
      print('❌ [UserViewModel] Error loading user profile: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String dob,
    required String avatarUrl,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      print('🔄 [UserViewModel] Updating user profile...');
      final updatedUser = await _userRepository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        avatarUrl: avatarUrl,
      );

      state = state.copyWith(user: updatedUser, isUpdating: false, error: null);
      print('✅ [UserViewModel] User profile updated successfully');
    } catch (e) {
      print('❌ [UserViewModel] Error updating user profile: $e');
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }
}

// User ViewModel Provider
final userViewModelProvider = StateNotifierProvider<UserViewModel, UserState>((
  ref,
) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserViewModel(userRepository: userRepository);
});

// Convenience providers for specific data
final userProvider = Provider<UserModel?>((ref) {
  return ref.watch(userViewModelProvider).user;
});

final userLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userViewModelProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userViewModelProvider).error;
});

final userUpdatingProvider = Provider<bool>((ref) {
  return ref.watch(userViewModelProvider).isUpdating;
});
