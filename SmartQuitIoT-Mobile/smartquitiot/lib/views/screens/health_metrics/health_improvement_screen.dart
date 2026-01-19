import 'package:flutter/material.dart';
import 'improvement_card.dart';

class HealthImprovementScreen extends StatelessWidget {
  const HealthImprovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // nền trắng chính
      body: Column(
        children: [
          // Header xanh phủ toàn bộ trên cùng
          Container(
            width: double.infinity,
            color: const Color(0xFF00D09E),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    const Text(
                      'Health Improvements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24), // cân bằng icon back
                  ],
                ),
              ),
            ),
          ),

          // Content trắng full height
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    ImprovementCard(
                      score: 100,
                      title: 'Heart Rate',
                      description: 'Your heart rate try to have heart rate from 60-100bpm',
                      isGood: true,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 100,
                      title: 'Oxygen Level',
                      description: 'Your oxygen levels should remain between 95% and 100%',
                      isGood: true,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 100,
                      title: 'Carbon monoxide',
                      description: 'Your carbon monoxide levels should be 0 or at safe concentration',
                      isGood: true,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 100,
                      title: 'Nicotine expelled from body',
                      description: 'All nicotine should have been expelled from your body',
                      isGood: true,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 100,
                      title: 'Taste and Smell',
                      description: 'Your ability to taste and smell should be much improved',
                      isGood: true,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 80,
                      title: 'Breathing',
                      description: 'It is those your lung capacity should have returned to normal',
                      isGood: false,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 65,
                      title: 'Energy level',
                      description: 'Your heart rate in a decline because low resistance to normal',
                      isGood: false,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 100,
                      title: 'Heart Rate',
                      description: 'It is likely your energy should have returned to normal',
                      isGood: true,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 17,
                      title: 'Addiction',
                      description: 'It is about the blood nicotine in your entire and brain should be zero',
                      isGood: false,
                    ),
                    SizedBox(height: 12),
                    ImprovementCard(
                      score: 2,
                      title: 'Circulation',
                      description: 'Your heart rate should have returned to normal',
                      isGood: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
