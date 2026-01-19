import 'package:SmartQuitIoT/views/screens/health_metrics/diary_metric_screen.dart';
import 'package:SmartQuitIoT/views/screens/health_metrics/health_improvement_screen.dart';
import 'package:flutter/material.dart';
import 'green_progress_circle_card.dart';
import 'connect_button.dart';
import 'health_chart.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  bool isConnected = false;
  bool isConnecting = false;
  double progress = 0.75;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _connectDevice() {
    setState(() {
      isConnected = !isConnected;
    });
  }

  void _navigateToChart(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryMetricsScreen(),
      ),
    );
  }

  Widget _buildHealthImprovementButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HealthImprovementScreen(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00D09E),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Health Improvement',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        bottom: false, // bỏ padding bottom của SafeArea để tránh xanh lộ ra
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Arrow back với navigate
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () {
                      Navigator.pop(context); // quay về màn trước, giữ nguyên bottom nav bar
                    },
                  ),

                  const Spacer(),
                  const Text(
                    'Health Metrics',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const SizedBox(width: 22),
                ],
              ),
            ),

            // Content trắng
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GreenProgressCircleCard(
                        title: 'Saving Progress',
                        subtitle: 'Your progress this year',
                        progress: progress,
                        annualSave: '\$1200',
                        monthlySave: '\$100',
                      ),
                      const SizedBox(height: 20),
                      ConnectButton(
                        isConnected: isConnected,
                        isConnecting: isConnecting,
                        animationController: _animationController,
                        onPressed: _connectDevice,
                      ),
                      const SizedBox(height: 20),
                      if (isConnected) ...[
                        HealthChart(
                          title: 'Sleep Hours',
                          onTap: () => _navigateToChart(context, 'Sleep'),
                        ),
                        const SizedBox(height: 16),
                        HealthChart(
                          title: 'Heart Rate',
                          onTap: () => _navigateToChart(context, 'Heart Rate'),
                        ),
                        const SizedBox(height: 16),
                        HealthChart(
                          title: 'Steps',
                          onTap: () => _navigateToChart(context, 'Steps'),
                        ),
                        const SizedBox(height: 16),
                        HealthChart(
                          title: 'Confidence',
                          onTap: () => _navigateToChart(context, 'Confidence'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildHealthImprovementButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
