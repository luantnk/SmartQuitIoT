import 'package:flutter/material.dart';
import 'qr_payment_screen.dart';

class PaymentOptionsScreen extends StatelessWidget {
  final String selectedPlan;

  const PaymentOptionsScreen({super.key, required this.selectedPlan});

  @override
  Widget build(BuildContext context) {
    final planPrice = selectedPlan == 'annual' ? '900,000 VND' : '99,000 VND';
    final planText = selectedPlan == 'annual' ? 'Annual Plan' : 'Monthly Plan';

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Payment Options',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$planText - $planPrice',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24), // cân cho icon back
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Payment Methods
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // MoMo
                    _buildPaymentOption(
                      context,
                      title: 'MoMo',
                      subtitle: 'Pay with MoMo e-wallet',
                      icon: Icons.smartphone,
                      iconColor: const Color(0xFFE91E63),
                      paymentMethod: 'momo',
                    ),
                    const SizedBox(height: 16),

                    // Internet Banking
                    _buildPaymentOption(
                      context,
                      title: 'Internet Banking',
                      subtitle: 'Pay with bank transfer',
                      icon: Icons.credit_card,
                      iconColor: const Color(0xFF2196F3),
                      paymentMethod: 'banking',
                    ),
                    const SizedBox(height: 16),

                    // ZaloPay
                    _buildPaymentOption(
                      context,
                      title: 'ZaloPay',
                      subtitle: 'Pay with ZaloPay e-wallet',
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF1976D2),
                      paymentMethod: 'zalopay',
                    ),

                    const Spacer(),

                    // Home Indicator
                    Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String paymentMethod,
  }) {
    return GestureDetector(
      onTap: () => _navigateToQRPayment(context, paymentMethod),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF333333).withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQRPayment(BuildContext context, String paymentMethod) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRPaymentScreen(
          selectedPlan: selectedPlan,
          paymentMethod: paymentMethod,
        ),
      ),
    );
  }
}
