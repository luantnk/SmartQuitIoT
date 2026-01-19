import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/models/badge.dart' as mymodels;
import 'package:SmartQuitIoT/views/widgets/cards/badge_card.dart';
import 'package:SmartQuitIoT/views/screens/badges/badge_detail_screen.dart';

class BadgesScreen extends StatelessWidget {
  // Get the list of badges from model
  final List<mymodels.Badge> badges = mymodels.BadgeData.getBadges();

  BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Quit Smoking Journey', // 👈 translated
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00D09E), // 👈 hardcoded color
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 màu của mũi tên back
        ),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00D09E),
                  Color(0xFF00D09E), // 👈 green color
                ],
              ),
            ),
            child: Column(
              children: [
                // 👇 Replace Icon with PNG image Achievement
                Image.asset(
                  'lib/assets/images/Achievement.png', // local path in assets folder
                  height: 110,
                  width: 110,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Achievements', // 👈 translated
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${badges.where((b) => b.isUnlocked).length}/${badges.length} badges unlocked', // 👈 translated
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Badges grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final mymodels.Badge badge = badges[index]; // 👈 typed
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BadgeDetailScreen(
                            badge: badge,
                          ), // 👈 pass Badge model
                        ),
                      );
                    },
                    child: BadgeCard(badge: badge), // 👈 pass Badge model
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
