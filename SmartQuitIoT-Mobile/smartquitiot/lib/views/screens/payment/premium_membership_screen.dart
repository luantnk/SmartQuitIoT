import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Đã thêm import GoRouter
import 'package:intl/intl.dart';
import '../../../models/state/membership_state.dart';
import '../../../providers/membership_provider.dart';
import 'plan_selection_screen.dart';
import 'payment_success_screen.dart';

class PremiumMembershipScreen extends ConsumerStatefulWidget {
  const PremiumMembershipScreen({super.key});

  @override
  ConsumerState<PremiumMembershipScreen> createState() =>
      _PremiumMembershipScreenState();
}

class _PremiumMembershipScreenState
    extends ConsumerState<PremiumMembershipScreen> {
  String _formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  bool _isProcessingFreeTrial = false;

  Future<void> _handleFreeTrialClick() async {
    if (_isProcessingFreeTrial) return;

    setState(() {
      _isProcessingFreeTrial = true;
    });

    try {
      final subscription = await ref
          .read(membershipViewModelProvider.notifier)
          .createFreeTrialSubscription(packageId: 1, duration: 7);

      if (mounted && subscription != null) {
        // Refresh subscription
        await ref
            .read(currentSubscriptionProvider.notifier)
            .fetchCurrentSubscription();

        // Navigate to success screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                status: 'SUCCESS',
                packageName:
                    subscription.membershipPackage?.name ?? 'Free Trial',
                amount: subscription.totalAmount?.toString() ?? '0',
                startDate: subscription.startDate?.toIso8601String(),
                endDate: subscription.endDate?.toIso8601String(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating free trial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingFreeTrial = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(membershipViewModelProvider);
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(membershipViewModelProvider.notifier)
                .fetchMembershipPackages();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header (Đã sửa thêm nút Back)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Nút Back
                    Positioned(
                      left: 0,
                      child: InkWell(
                        onTap: () {
                          // Logic quay lại dùng GoRouter
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Tiêu đề chính
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Premium Membership',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24, // Giảm nhẹ size để vừa vặn hơn
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register membership for more features.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Membership Illustration
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20), // Giảm padding 1 chút cho cân đối
                child: Center(
                  child: Image.asset(
                    'lib/assets/images/membership.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Plans section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Builder(
                  builder: (_) {
                    if (state == ViewState.loading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    } else if (state == ViewState.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            viewModel.errorMessage,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else if (state == ViewState.success &&
                        viewModel.packages.isNotEmpty) {
                      return Column(
                        children: viewModel.packages.map((pkg) {
                          final isFree = pkg.price == 0;
                          final isPremium = pkg.type.toUpperCase() == 'PREMIUM';

                          // Enhanced box decoration for each card type
                          final BoxDecoration boxDecoration = isPremium
                              ? BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFF4E4BC),
                                      Color(0xFFC9A961),
                                      Color(0xFFF7E8C4),
                                      Color(0xFFB8941F),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFD4AF37,
                                      ).withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                )
                              : isFree
                              ? BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.green.shade50,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.green.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                )
                              : BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.grey.shade50],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                );

                          final mainTextColor = isPremium
                              ? Colors.white
                              : isFree
                              ? Colors.green.shade800
                              : Colors.grey.shade900;

                          final subTextColor = isPremium
                              ? Colors.white.withOpacity(0.9)
                              : isFree
                              ? Colors.green.shade700
                              : Colors.grey.shade600;

                          final dividerColor = isPremium
                              ? Colors.white.withOpacity(0.4)
                              : Colors.grey.shade300;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: boxDecoration,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: isFree
                                        ? (_isProcessingFreeTrial
                                            ? null
                                            : _handleFreeTrialClick)
                                        : () => _navigateToPlanSelection(
                                            context,
                                            pkg.id,
                                            pkg.name,
                                          ),
                                    child: Stack(
                                      children: [
                                        if (isPremium) _buildGlossySheen(),
                                        if (isFree && _isProcessingFreeTrial)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Color(0xFF00D09E),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          pkg.name,
                                                          style: TextStyle(
                                                            color:
                                                                mainTextColor,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            shadows: isPremium
                                                                ? [
                                                                    const Shadow(
                                                                      color: Colors
                                                                          .black26,
                                                                      blurRadius:
                                                                          4,
                                                                      offset:
                                                                          Offset(
                                                                            1,
                                                                            1,
                                                                          ),
                                                                    ),
                                                                  ]
                                                                : [],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          pkg.description,
                                                          style: TextStyle(
                                                            color: subTextColor,
                                                            fontSize: 16,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  if (!isFree) ...[
                                                    Text(
                                                      _formatCurrency(
                                                        pkg.price,
                                                      ),
                                                      style: TextStyle(
                                                        color: mainTextColor,
                                                        fontSize: 28,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        height: 1.0,
                                                        shadows: isPremium
                                                            ? [
                                                                const Shadow(
                                                                  color: Colors
                                                                      .black26,
                                                                  blurRadius: 4,
                                                                  offset:
                                                                      Offset(
                                                                        1,
                                                                        1,
                                                                      ),
                                                                ),
                                                              ]
                                                            : [],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 4,
                                                      ),
                                                      child: Text(
                                                        '/ ${pkg.durationUnit.toLowerCase()}',
                                                        style: TextStyle(
                                                          color: subTextColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green
                                                            .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                          12,
                                                        ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .green
                                                              .shade300,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.stars_rounded,
                                                            color: Colors
                                                                .green
                                                                .shade700,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            'Free trial for ${pkg.duration} days',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .green
                                                                  .shade800,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16.0,
                                                ),
                                                child: Divider(
                                                  height: 1,
                                                  color: dividerColor,
                                                ),
                                              ),
                                              _buildFeatureList(
                                                pkg.features,
                                                isPremium: isPremium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    } else {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No membership packages available.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Terms
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Text(
                  'By placing this order, you agree to the Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renewal is turned off at least 24-hours before the end of the current period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),

              // Home Indicator
              Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features, {required bool isPremium}) {
    final featureColor = isPremium ? Colors.white : const Color(0xFF4A4A4A);
    final iconColor = isPremium ? Colors.white : const Color(0xFF00D09E);
    final textShadow = isPremium
        ? [
            const Shadow(
              color: Colors.black38,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ]
        : <Shadow>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: iconColor,
                size: 20,
                shadows: textShadow,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    color: featureColor,
                    fontSize: 15,
                    height: 1.4,
                    shadows: textShadow,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGlossySheen() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Transform.translate(
          offset: const Offset(-80, -120),
          child: Transform.rotate(
            angle: -pi / 6,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPlanSelection(
    BuildContext context,
    int packageId,
    String packageName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PlanSelectionScreen(packageId: packageId, packageName: packageName),
      ),
    );
  }
}