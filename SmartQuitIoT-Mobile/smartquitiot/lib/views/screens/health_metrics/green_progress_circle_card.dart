import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
class GreenProgressCircleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // 0 → 1
  final String annualSave;
  final String monthlySave;

  const GreenProgressCircleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.annualSave,
    required this.monthlySave,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF00D09E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ========== Vòng tròn bên trái ========== (to hơn)
          CircularPercentIndicator(
            radius: 70.0,
            lineWidth: 10.0,
            percent: progress,
            center: Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white.withOpacity(0.15),
            progressColor: Colors.white,
            circularStrokeCap: CircularStrokeCap.round,
          ),

          const SizedBox(width: 20),

          // ========== Nội dung bên phải ========== (căn giữa)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // căn giữa ngang
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Annual & Monthly Save song song
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildMiniCard('Annual', annualSave)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniCard('Monthly', monthlySave)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 140, // to hơn nữa
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circle progress
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 9, // dày hơn
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          // % text
          Text(
            "${(progress * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18, // chữ to hơn
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMiniCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
