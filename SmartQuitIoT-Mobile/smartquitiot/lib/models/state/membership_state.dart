import '../membership_package.dart';
import '../membership_subscription.dart';


enum ViewState { idle, loading, success, error }

class MembershipState {
  final ViewState state;
  final List<MembershipPackage> packages;
  final String errorMessage;
  final MembershipSubscription? activeSubscription;

  const MembershipState({
    this.state = ViewState.idle,
    this.packages = const [],
    this.errorMessage = '',
    this.activeSubscription,
  });

  MembershipState copyWith({
    ViewState? state,
    List<MembershipPackage>? packages,
    String? errorMessage, MembershipSubscription? activeSubscription,
  }) {
    return MembershipState(
      state: state ?? this.state,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
      activeSubscription: activeSubscription ?? this.activeSubscription,
    );
  }
}
