import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class HealthConnectDemoScreen extends StatefulWidget {
  const HealthConnectDemoScreen({super.key});

  @override
  State<HealthConnectDemoScreen> createState() => _HealthConnectDemoScreenState();
}

class _HealthConnectDemoScreenState extends State<HealthConnectDemoScreen> {
  final Health _health = Health();
  final Map<HealthDataType, HealthDataPoint?> latestData = {};
  final List<HealthDataType> types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT,

    // HealthDataType.GENDER
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final permissions = types.map((e) => HealthDataAccess.READ).toList();
    bool? granted = await _health.requestAuthorization(types, permissions: permissions);
    if (granted != true) {
      openAppSettings();
    }
  }

  Future<void> _fetchHealthData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30)); // 30 ngày gần nhất
    final Map<HealthDataType, HealthDataPoint?> tmp = {};
    final uuid = const Uuid();

    for (var type in types) {
      final data = await _health.getHealthDataFromTypes(
        types: [type],
        startTime: start,
        endTime: now,
      );

      if (data.isNotEmpty) {
        if (type == HealthDataType.STEPS ||
            type == HealthDataType.DISTANCE_DELTA ||
            type == HealthDataType.TOTAL_CALORIES_BURNED) {
          // Cộng tất cả record trong 30 ngày
          double total = data.fold(
            0.0,
                (sum, p) => sum + (p.value as NumericHealthValue).numericValue,
          );

          tmp[type] = HealthDataPoint(
            uuid: uuid.v4(),
            value: NumericHealthValue(numericValue: total),
            type: type,
            unit: data.first.unit,
            dateFrom: start,
            dateTo: now,
            sourceDeviceId: "summary",
            sourceId: "summary",
            sourceName: "Health Summary",
            sourcePlatform: HealthPlatformType.googleHealthConnect,
          );
        } else {
          // Các loại khác lấy record mới nhất trong 30 ngày
          data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          tmp[type] = data.first;
        }
      } else {
        tmp[type] = null; // nếu không có dữ liệu
      }
    }

    setState(() {
      latestData
        ..clear()
        ..addAll(tmp);
    });
  }


  String _formatBloodPressure(HealthDataPoint? sys, HealthDataPoint? dia) {
    if (sys != null && dia != null) {
      final s = (sys.value as NumericHealthValue).numericValue.toInt();
      final d = (dia.value as NumericHealthValue).numericValue.toInt();
      return "$s/$d ${sys.unit}";
    }
    if (sys != null) {
      return "${(sys.value as NumericHealthValue).numericValue.toInt()} ${sys.unit}";
    }
    if (dia != null) {
      return "${(dia.value as NumericHealthValue).numericValue.toInt()} ${dia.unit}";
    }
    return "null";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Connect Demo")),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchHealthData,
              child: const Text("Tải dữ liệu 30 ngày gần nhất"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildTileOrNull(
                    title: "Nhịp tim",
                    point: latestData[HealthDataType.HEART_RATE],
                  ),
                  ListTile(
                    title: const Text("Huyết áp"),
                    subtitle: Text(_formatBloodPressure(
                      latestData[HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
                      latestData[HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
                    )),
                  ),
                  _buildTileOrNull(
                    title: "Tốc độ thở",
                    point: latestData[HealthDataType.RESPIRATORY_RATE],
                  ),
                  _buildTileOrNull(
                    title: "Đường huyết",
                    point: latestData[HealthDataType.BLOOD_GLUCOSE],
                  ),
                  _buildTileOrNull(
                    title: "Số bước",
                    point: latestData[HealthDataType.STEPS],
                  ),
                  _buildTileOrNull(
                    title: "Khoảng cách (m)",
                    point: latestData[HealthDataType.DISTANCE_DELTA],
                  ),
                  _buildTileOrNull(
                    title: "Năng lượng đã đốt (kcal)",
                    point: latestData[HealthDataType.TOTAL_CALORIES_BURNED],
                  ),
                  _buildTileOrNull(
                    title: "Chiều cao",
                    point: latestData[HealthDataType.HEIGHT],
                  ),
                  _buildTileOrNull(
                    title: "Cân nặng",
                    point: latestData[HealthDataType.WEIGHT],
                  ),
                  _buildTileOrNull(
                    title: "Đường huyết",
                    point: latestData[HealthDataType.BLOOD_GLUCOSE],
                  ),
                  // _buildTileOrNull(
                  //   title: "Ngày sinh",
                  //   point: latestData[HealthDataType.BIRTH_DATE],
                  // ),
                  // _buildTileOrNull(
                  //   title: "Giới tính",
                  //   point: latestData[HealthDataType.GENDER],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileOrNull({
    required String title,
    HealthDataPoint? point,
  }) {
    if (point != null) {
      final value = (point.value as NumericHealthValue).numericValue;
      final time = "${point.dateTo.hour}:${point.dateTo.minute}";
      return ListTile(
        title: Text(title),
        subtitle: Text("$value ${point.unit}"),
        trailing: Text(
          time,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12),
        ),
      );
    } else {
      return ListTile(
        title: Text(title),
        subtitle: const Text("null"),
      );
    }
  }
}
