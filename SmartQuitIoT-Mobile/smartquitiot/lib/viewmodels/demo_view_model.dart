// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user_profile.dart';
// import '../repositories/user_repository.dart';

// /// State class for Demo screen
// class DemoState {
//   final UserProfile? userProfile;
//   final Map<String, dynamic>? userStatistics;
//   final List<UserProfile>? multipleUsers;
//   final bool isLoading;
//   final String? errorMessage;
//   final String lastAction;

//   const DemoState({
//     this.userProfile,
//     this.userStatistics,
//     this.multipleUsers,
//     this.isLoading = false,
//     this.errorMessage,
//     this.lastAction = 'None',
//   });

//   DemoState copyWith({
//     UserProfile? userProfile,
//     Map<String, dynamic>? userStatistics,
//     List<UserProfile>? multipleUsers,
//     bool? isLoading,
//     String? errorMessage,
//     String? lastAction,
//   }) {
//     return DemoState(
//       userProfile: userProfile ?? this.userProfile,
//       userStatistics: userStatistics ?? this.userStatistics,
//       multipleUsers: multipleUsers ?? this.multipleUsers,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//       lastAction: lastAction ?? this.lastAction,
//     );
//   }
// }

// /// Demo ViewModel using Repository pattern
// class DemoViewModel extends StateNotifier<DemoState> {
//   final UserRepository _userRepository;

//   DemoViewModel({UserRepository? userRepository})
//     : _userRepository = userRepository ?? UserRepository(),
//       super(const DemoState());

//   /// Load single user profile
//   Future<void> loadUserProfile(String userId) async {
//     state = state.copyWith(
//       isLoading: true,
//       errorMessage: null,
//       lastAction: 'Loading user profile...',
//     );

//     try {
//       final userProfile = await _userRepository.getUserProfile(userId);
//       state = state.copyWith(
//         userProfile: userProfile,
//         isLoading: false,
//         lastAction: 'User profile loaded successfully',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: e.toString(),
//         lastAction: 'Failed to load user profile',
//       );
//     }
//   }

//   /// Load user statistics
//   Future<void> loadUserStatistics(String userId) async {
//     state = state.copyWith(
//       isLoading: true,
//       errorMessage: null,
//       lastAction: 'Loading user statistics...',
//     );

//     try {
//       final statistics = await _userRepository.getUserStatistics(userId);
//       state = state.copyWith(
//         userStatistics: statistics,
//         isLoading: false,
//         lastAction: 'User statistics loaded successfully',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: e.toString(),
//         lastAction: 'Failed to load user statistics',
//       );
//     }
//   }

//   /// Update user profile
//   Future<void> updateUserProfile(UserProfile profile) async {
//     state = state.copyWith(
//       isLoading: true,
//       errorMessage: null,
//       lastAction: 'Updating user profile...',
//     );

//     try {
//       final updatedProfile = await _userRepository.updateUserProfile(profile);
//       state = state.copyWith(
//         userProfile: updatedProfile,
//         isLoading: false,
//         lastAction: 'User profile updated successfully',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: e.toString(),
//         lastAction: 'Failed to update user profile',
//       );
//     }
//   }

//   /// Load multiple users
//   Future<void> loadMultipleUsers(List<String> userIds) async {
//     state = state.copyWith(
//       isLoading: true,
//       errorMessage: null,
//       lastAction: 'Loading multiple users...',
//     );

//     try {
//       final users = await _userRepository.getMultipleUserProfiles(userIds);
//       state = state.copyWith(
//         multipleUsers: users,
//         isLoading: false,
//         lastAction: 'Multiple users loaded successfully',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: e.toString(),
//         lastAction: 'Failed to load multiple users',
//       );
//     }
//   }

//   /// Clear error message
//   void clearError() {
//     state = state.copyWith(errorMessage: null);
//   }

//   /// Reset state
//   void reset() {
//     state = const DemoState();
//   }
// }

// /// Riverpod providers
// final userRepositoryProvider = Provider<UserRepository>((ref) {
//   return UserRepository();
// });

// final demoViewModelProvider = StateNotifierProvider<DemoViewModel, DemoState>((
//   ref,
// ) {
//   final userRepository = ref.watch(userRepositoryProvider);
//   return DemoViewModel(userRepository: userRepository);
// });
