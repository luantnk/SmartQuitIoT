import 'package:SmartQuitIoT/views/screens/leaderboard/progress_card.dart';
import 'package:flutter/material.dart';

class CommunityProgressSection extends StatelessWidget {
  const CommunityProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 👈 nền trắng
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // 👈 nhỏ gọn hơn
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Community Progress',
            style: TextStyle(
              fontSize: 16, // 👈 chữ nhỏ lại
              fontWeight: FontWeight.bold,
              color: Colors.black, // 👈 chữ đen
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              ProgressCard(
                animationPath: 'lib/assets/animations/people.json',
                title: 'Total Participants',
                value: '1,245',
                borderColor: Colors.purpleAccent,           // xanh dương
                valueColor: Colors.purpleAccent,            // chữ xanh
              ),
              ProgressCard(
                animationPath: 'lib/assets/animations/fire.json',
                title: 'Average Streak',
                value: '37 Days',
                borderColor: Colors.orangeAccent,   // cam
                valueColor: Colors.orangeAccent,    // chữ cam
              ),
              ProgressCard(
                animationPath: 'lib/assets/animations/savings.json',
                title: 'Total Savings',
                value: '5.2M VND',
                borderColor: Colors.greenAccent,   // tím
                valueColor: Colors.greenAccent,    // chữ tím
              ),
            ],
          )
        ],
      ),
    );
  }
}
