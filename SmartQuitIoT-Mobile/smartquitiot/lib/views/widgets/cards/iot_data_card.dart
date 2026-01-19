import 'package:flutter/material.dart';

class IoTDataCard extends StatelessWidget {
  final int steps;
  final int heartRate;
  final int spo2;
  final int activityMinutes;
  final int respiratoryRate;
  final double sleepDuration;
  final int sleepQuality;
  final VoidCallback onGetDataFromIoT;

  const IoTDataCard({
    super.key,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.activityMinutes,
    required this.respiratoryRate,
    required this.sleepDuration,
    required this.sleepQuality,
    required this.onGetDataFromIoT,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.devices_outlined,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'IoT Device Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onGetDataFromIoT,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Get Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  'Steps',
                  steps.toString(),
                  Icons.directions_walk,
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  'Heart Rate',
                  '$heartRate bpm',
                  Icons.favorite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDataItem('SpO2', '$spo2%', Icons.air)),
              Expanded(
                child: _buildDataItem(
                  'Activity',
                  '${activityMinutes}m',
                  Icons.timer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  'Respiratory',
                  '$respiratoryRate/min',
                  Icons.airline_seat_recline_normal,
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  'Sleep',
                  '${sleepDuration.toStringAsFixed(1)}h',
                  Icons.bedtime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  'Sleep Quality',
                  '$sleepQuality/10',
                  Icons.star,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9C27B0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF9C27B0), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
