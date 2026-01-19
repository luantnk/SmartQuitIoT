import 'package:flutter/material.dart';
import 'detalied_chart_painter.dart';
import 'health_chart.dart';

class DiaryMetricsScreen extends StatelessWidget {
  const DiaryMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // nền trắng chính
      body: Column(
        children: [
          // Header xanh phủ toàn bộ trên cùng (bao cả status bar)
          Container(
            width: double.infinity,
            color: const Color(0xFF00D09E),
            child: SafeArea(
              bottom: false, // chỉ padding trên, không ảnh hưởng content dưới
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
                      'Diary Metrics',
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
              color: Colors.white, // content trắng hoàn toàn
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    HealthChart(
                      title: 'Cravings',
                      onTap: () => _showMetricDetail(context, 'Cravings'),
                    ),
                    const SizedBox(height: 16),
                    HealthChart(
                      title: 'Mood',
                      onTap: () => _showMetricDetail(context, 'Mood'),
                    ),
                    const SizedBox(height: 16),
                    HealthChart(
                      title: 'Anxiety',
                      onTap: () => _showMetricDetail(context, 'Anxiety'),
                    ),
                    const SizedBox(height: 16),
                    HealthChart(
                      title: 'Confidence',
                      onTap: () => _showMetricDetail(context, 'Confidence'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMetricDetail(BuildContext context, String metricName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                // Title
                Text(
                  metricName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Nội dung scrollable
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
                          child: CustomPaint(
                            painter: DetailedChartPainter(),
                            size: Size.infinite,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Thống kê chi tiết',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildStatItem('Trung bình tuần này', '7.2/10'),
                        _buildStatItem('Cao nhất', '9.1/10'),
                        _buildStatItem('Thấp nhất', '4.8/10'),
                        _buildStatItem('Xu hướng', '+12% so với tuần trước'),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }
}
