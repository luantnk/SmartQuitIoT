import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:SmartQuitIoT/views/screens/common/loading_screen.dart';

class QRPaymentScreen extends StatelessWidget {
  final String selectedPlan;
  final String paymentMethod;

  const QRPaymentScreen({
    super.key,
    required this.selectedPlan,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final planPrice = selectedPlan == 'annual' ? '900,000 VND' : '99,000 VND';
    final paymentTitle = _getPaymentTitle(paymentMethod);

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Stack(
              alignment: Alignment.center,
              children: [
                // Icon back bên trái
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 24, top: 8, bottom: 8),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Tiêu đề chính giữa
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$paymentTitle Payment',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===== QR CODE SECTION =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR Code Container
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: SvgPicture.asset(
                          'lib/assets/qrcode.svg', // đảm bảo file svg có trong assets
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Price
                    Text(
                      planPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Instruction
                    Text(
                      'Open your $paymentTitle app and scan this QR code to pay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Payment Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handlePayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black, // chữ đen
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'I have completed the payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== HOME INDICATOR =====
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentTitle(String method) {
    switch (method) {
      case 'momo':
        return 'MoMo';
      case 'banking':
        return 'Banking';
      case 'zalopay':
        return 'ZaloPay';
      default:
        return 'Payment';
    }
  }

  void _handlePayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          selectedPlan: selectedPlan,
          paymentMethod: paymentMethod,
        ),
      ),
    );
  }
}
