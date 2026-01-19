import 'package:flutter/material.dart';
import 'mission_card.dart';
import 'mission_header_card.dart';
import 'mission_progress_card.dart';


class SuggestedMissionScreen extends StatelessWidget {
  const SuggestedMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MissionHeaderCard(
                title: 'Daily Missions',
                subtitle: 'Complete missions to earn points',
              ),
              const SizedBox(height: 16),
              const MissionProgressCard(
                completed: 3,
                total: 5,
                points: 250,
              ),
              const SizedBox(height: 24),
              MissionCard(
                title: 'Walk 5,000 steps',
                description: 'Track your daily steps and stay fit',
                icon: Icons.directions_walk,
                color: Colors.blue,
                isCompleted: false,
                progress: 0.6,
                points: 50,
                difficulty: 'Easy',
                onTap: () {
                  // handle tap
                },
              ),
              const SizedBox(height: 16),
              MissionCard(
                title: 'Drink 2L of water',
                description: 'Keep your body hydrated',
                icon: Icons.water_drop,
                color: Colors.purple,
                isCompleted: true,
                progress: 1.0,
                points: 30,
                difficulty: 'Easy',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
