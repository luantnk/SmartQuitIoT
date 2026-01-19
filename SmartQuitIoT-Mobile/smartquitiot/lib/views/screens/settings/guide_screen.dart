import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Quit Smoking Guide',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    const Text(
                      'Your Journey to a Smoke-Free Life',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quitting smoking is one of the best decisions you can make for your health. This guide will help you understand the process and provide you with practical steps to succeed.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Image 1: Lighting a cigarette
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'lib/assets/images/download.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Why Quit Section
                    const Text(
                      'Why Quit Smoking?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D09E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                      'Improve your health and reduce the risk of heart disease, stroke, and cancer',
                    ),
                    _buildBulletPoint(
                      'Save money - the average smoker spends thousands of dollars per year',
                    ),
                    _buildBulletPoint(
                      'Protect your loved ones from secondhand smoke',
                    ),
                    _buildBulletPoint(
                      'Feel better physically - improved breathing, energy, and circulation',
                    ),
                    _buildBulletPoint(
                      'Look better - healthier skin, teeth, and reduced premature aging',
                    ),
                    const SizedBox(height: 30),

                    // Image 2: Cigarette butts
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'lib/assets/images/download (1).jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Steps to Quit Section
                    const Text(
                      'Steps to Successfully Quit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D09E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNumberedStep(
                      '1',
                      'Set a Quit Date',
                      'Choose a date within the next 2 weeks. This gives you time to prepare without losing motivation.',
                    ),
                    _buildNumberedStep(
                      '2',
                      'Identify Your Triggers',
                      'Recognize situations, emotions, or activities that make you want to smoke. Common triggers include stress, coffee, alcohol, or social situations.',
                    ),
                    _buildNumberedStep(
                      '3',
                      'Make a Plan',
                      'Decide how you will handle cravings. Consider nicotine replacement therapy, medications, or behavioral strategies.',
                    ),
                    _buildNumberedStep(
                      '4',
                      'Tell Family and Friends',
                      'Let your support network know about your quit date. Their encouragement can make a significant difference.',
                    ),
                    _buildNumberedStep(
                      '5',
                      'Remove Temptations',
                      'Get rid of all cigarettes, lighters, and ashtrays from your home, car, and workplace.',
                    ),
                    _buildNumberedStep(
                      '6',
                      'Stay Active',
                      'Physical activity can help reduce cravings and manage stress. Even a short walk can help.',
                    ),
                    _buildNumberedStep(
                      '7',
                      'Track Your Progress',
                      'Use this app to monitor your progress, celebrate milestones, and stay motivated.',
                    ),
                    const SizedBox(height: 20),

                    // Coping with Cravings
                    const Text(
                      'Coping with Cravings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D09E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cravings typically last 3-5 minutes. When you feel a craving:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint('Take deep breaths and count to 10'),
                    _buildBulletPoint('Drink a glass of water'),
                    _buildBulletPoint('Go for a walk or do some exercise'),
                    _buildBulletPoint('Call a friend or family member'),
                    _buildBulletPoint('Chew gum or eat a healthy snack'),
                    _buildBulletPoint('Remember why you decided to quit'),
                    const SizedBox(height: 20),

                    // Benefits Timeline
                    const Text(
                      'Health Benefits Timeline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D09E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimelineItem(
                      '20 minutes',
                      'Heart rate and blood pressure drop',
                    ),
                    _buildTimelineItem(
                      '12 hours',
                      'Carbon monoxide level in blood returns to normal',
                    ),
                    _buildTimelineItem(
                      '2 weeks',
                      'Circulation improves and lung function increases',
                    ),
                    _buildTimelineItem(
                      '1 month',
                      'Coughing and shortness of breath decrease',
                    ),
                    _buildTimelineItem(
                      '1 year',
                      'Risk of coronary heart disease is half that of a smoker',
                    ),
                    _buildTimelineItem(
                      '5 years',
                      'Risk of stroke is reduced to that of a non-smoker',
                    ),
                    _buildTimelineItem(
                      '10 years',
                      'Risk of lung cancer drops to about half that of a smoker',
                    ),
                    const SizedBox(height: 20),

                    // Final Message
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00D09E),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Remember',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D09E),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Quitting smoking is a journey, not a destination. Every day without a cigarette is a victory. If you slip up, don\'t give up - learn from it and continue your journey. You have the power to quit, and this app is here to support you every step of the way.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1F2937),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00D09E),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedStep(String number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D09E).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D09E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }
}
