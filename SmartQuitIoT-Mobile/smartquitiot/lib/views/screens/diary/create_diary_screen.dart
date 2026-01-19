import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/providers/diary_refresh_provider.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/models/diary_create_result.dart';
import 'package:SmartQuitIoT/views/widgets/dialogs/smoked_again_dialog.dart';
import 'package:intl/intl.dart';
import 'package:health/health.dart';

class CreateDiaryScreen extends ConsumerStatefulWidget {
  const CreateDiaryScreen({super.key});

  @override
  ConsumerState<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends ConsumerState<CreateDiaryScreen> {
  DateTime selectedDate = DateTime.now();
  bool hasSmoked = false;
  int cigarettesSmoked = 0;
  double cravingLevel = 5.0;
  double moodLevel = 5.0;
  double confidenceLevel = 5.0;
  double anxietyLevel = 5.0;

  // Flag to track if we're waiting for diary creation result
  bool _isWaitingForResult = false;

  // Health instance
  final Health _health = Health();

  // Money formatter without VND symbol (dấu phẩy)
  final NumberFormat moneyFormatter = NumberFormat('#,###', 'en_US');

  // Triggers
  List<String> selectedTriggers = [];
  final List<String> availableTriggers = [
    "Morning",
    "After Meal",
    "Gaming",
    "Party",
    "Coffee",
    "Stress",
    "Boredom",
    "Driving",
    "Sadness",
    "Work",
  ];

  // NRT
  bool isUseNrt = false;
  double moneySpentOnNrt = 0.0;

  // IoT Data
  bool isConnectIoTDevice = false;
  int steps = 0;
  int heartRate = 0;
  int spo2 = 0;
  double sleepDuration = 0.0;
  double deepSleepDuration = 0.0;
  double remSleepDuration = 0.0;
  double lightSleepDuration = 0.0;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController moneyController = TextEditingController();

  // Health data controllers
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();
  final TextEditingController sleepDurationController = TextEditingController();
  final TextEditingController deepSleepController = TextEditingController();
  final TextEditingController remSleepController = TextEditingController();
  final TextEditingController lightSleepController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    moneyController.dispose();
    stepsController.dispose();
    heartRateController.dispose();
    spo2Controller.dispose();
    sleepDurationController.dispose();
    deepSleepController.dispose();
    remSleepController.dispose();
    lightSleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to diary record notifier state changes
    ref.listen<AsyncValue<DiaryCreateResult?>>(diaryRecordNotifierProvider, (
      previous,
      next,
    ) {
      // Only handle if we're waiting for a result and state changed from loading to data/error
      if (!_isWaitingForResult) return;

      final previousResult = previous?.valueOrNull;
      final nextResult = next.valueOrNull;

      // If we got a result and it's different from previous, handle it
      if (nextResult != null && nextResult != previousResult) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isWaitingForResult = false;
            });
            _handleDiaryResult(nextResult);
          }
        });
      } else if (next.hasError && (previous == null || !previous.hasError)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isWaitingForResult = false;
            });
            _handleDiaryError(next.error!);
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Entry Diary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Selector
              _buildDateSelector(),
              const SizedBox(height: 20),

              // Smoking Status
              _buildSmokingSection(),
              const SizedBox(height: 20),

              // Mood Sliders
              _buildMoodSection(),
              const SizedBox(height: 20),

              // Triggers
              _buildTriggersSection(),
              const SizedBox(height: 20),

              // NRT
              _buildNrtSection(),
              const SizedBox(height: 20),

              // IoT Data
              _buildIoTSection(),
              const SizedBox(height: 20),

              // Notes
              _buildNotesSection(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            'Today: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Icon(Icons.lock, color: Colors.grey[500], size: 20),
        ],
      ),
    );
  }

  Widget _buildSmokingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Did You Smoke Today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton('No', !hasSmoked, () {
                  setState(() {
                    hasSmoked = false;
                    cigarettesSmoked = 0;
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceButton('Yes', hasSmoked, () {
                  setState(() => hasSmoked = true);
                }),
              ),
            ],
          ),
          if (hasSmoked) ...[
            const SizedBox(height: 20),
            const Text(
              'How many cigarettes?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  cigarettesSmoked = int.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D09E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D09E) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSlider(
            'Cravings',
            cravingLevel,
            const Color(0xFFE91E63),
            (v) => setState(() => cravingLevel = v),
          ),
          const Divider(height: 32),
          _buildSlider(
            'Mood',
            moodLevel,
            const Color(0xFF2196F3),
            (v) => setState(() => moodLevel = v),
          ),
          const Divider(height: 32),
          _buildSlider(
            'Confidence',
            confidenceLevel,
            const Color(0xFF4CAF50),
            (v) => setState(() => confidenceLevel = v),
          ),
          const Divider(height: 32),
          _buildSlider(
            'Anxiety',
            anxietyLevel,
            const Color(0xFFFF9800),
            (v) => setState(() => anxietyLevel = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              '${value.round()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: color,
          inactiveColor: color.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTriggersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Triggers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTriggers.map((trigger) {
              final isSelected = selectedTriggers.contains(trigger);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedTriggers.remove(trigger);
                    } else {
                      selectedTriggers.add(trigger);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00D09E)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00D09E)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    trigger,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNrtSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Using NRT?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Switch(
                value: isUseNrt,
                activeThumbColor: const Color(0xFF00D09E),
                onChanged: (value) {
                  setState(() {
                    isUseNrt = value;
                    if (!value) {
                      moneySpentOnNrt = 0.0;
                      moneyController.clear();
                    }
                  });
                },
              ),
            ],
          ),
          if (isUseNrt) ...[
            const SizedBox(height: 12),
            const Text(
              'Money spent on NRT',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Loại bỏ ký tự không phải số
                final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (numericString.isEmpty) {
                  setState(() {
                    moneySpentOnNrt = 0.0;
                  });
                  return;
                }
                final parsed = int.tryParse(numericString) ?? 0;
                final formatted = moneyFormatter.format(parsed);

                // Chỉ update khi format khác với text hiện tại
                if (formatted != value) {
                  setState(() {
                    moneySpentOnNrt = parsed.toDouble();
                  });

                  // Tính toán cursor position
                  final cursorPosition = formatted.length;
                  moneyController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: cursorPosition),
                  );
                } else {
                  setState(() {
                    moneySpentOnNrt = parsed.toDouble();
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIoTSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Health Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _getDataFromIoT,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.bluetooth, color: Colors.white, size: 20),
              label: const Text(
                'Get Data From Your IoT Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Health data input fields
          _buildHealthDataFields(),
        ],
      ),
    );
  }

  Widget _buildHealthDataFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildHealthField(
                'Steps',
                stepsController,
                Icons.directions_walk,
                (value) => steps = int.tryParse(value) ?? 0,
                readOnly: true, // ✅ READ-ONLY: Chỉ fill khi connect IoT
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthField(
                'Heart Rate (bpm)',
                heartRateController,
                Icons.favorite,
                (value) => heartRate = int.tryParse(value) ?? 0,
                readOnly: true, // ✅ READ-ONLY: Chỉ fill khi connect IoT
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHealthField(
          'SpO2 (%)',
          spo2Controller,
          Icons.healing,
          (value) => spo2 = int.tryParse(value) ?? 0,
          readOnly: true, // ✅ READ-ONLY: Chỉ fill khi connect IoT
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthField(
                'Sleep Deep (h)',
                deepSleepController,
                Icons.nights_stay,
                (value) => deepSleepDuration = double.tryParse(value) ?? 0.0,
                readOnly: true, // ✅ READ-ONLY: Chỉ fill khi connect IoT
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthField(
                'Sleep REM (h)',
                remSleepController,
                Icons.dark_mode,
                (value) => remSleepDuration = double.tryParse(value) ?? 0.0,
                readOnly: true, // ✅ READ-ONLY: Chỉ fill khi connect IoT
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHealthField(
          'Sleep Light (h)',
          lightSleepController,
          Icons.light_mode,
          (value) => lightSleepDuration = double.tryParse(value) ?? 0.0,
          readOnly: true, // ✅ READ-ONLY: Chỉ fill khi connect IoT
        ),
        const SizedBox(height: 12),
        _buildHealthField(
          'Sleep Duration (h)',
          sleepDurationController,
          Icons.bedtime,
          (value) => sleepDuration = double.tryParse(value) ?? 0.0,
          readOnly: false, // ✅ USER CÓ THỂ NHẬP: Không khóa, cho phép user nhập
        ),
      ],
    );
  }

  Widget _buildHealthField(
    String label,
    TextEditingController controller,
    IconData icon,
    Function(String) onChanged, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00D09E)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            if (readOnly)
              Icon(Icons.lock_outline, size: 14, color: Colors.grey[500]),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          readOnly: readOnly,
          enabled: !readOnly,
          style: TextStyle(color: readOnly ? Colors.grey[600] : Colors.black),
          decoration: InputDecoration(
            hintText: '0',
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
          onChanged: readOnly ? null : onChanged,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'How are you feeling today?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Save Diary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _getDataFromIoT() async {
    try {
      // Request health permissions
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.BLOOD_OXYGEN, // SpO2
        HealthDataType.SLEEP_DEEP, // Deep Sleep
        HealthDataType.SLEEP_REM, // REM Sleep
        HealthDataType.SLEEP_LIGHT, // Light Sleep
      ];

      final permissions = types.map((e) => HealthDataAccess.READ).toList();
      bool? granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (granted != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Health permissions denied. Please enable in settings.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Fetch health data for today
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startOfDay,
        endTime: now,
      );

      // Process and update health data
      int fetchedSteps = 0;
      int fetchedHeartRate = 0;
      double deepSleepMinutes = 0;
      double remSleepMinutes = 0;
      double lightSleepMinutes = 0;
      double fetchedSpo2 = 0;
      int spo2Count = 0;

      for (var data in healthData) {
        double value = 0.0;
        if (data.value is NumericHealthValue) {
          value = (data.value as NumericHealthValue).numericValue.toDouble();
        }

        switch (data.type) {
          case HealthDataType.STEPS:
            fetchedSteps += value.toInt();
            break;

          case HealthDataType.HEART_RATE:
            // Lấy nhịp tim gần nhất
            if (fetchedHeartRate == 0 ||
                data.dateTo.isAfter(
                  DateTime.now().subtract(const Duration(hours: 1)),
                )) {
              fetchedHeartRate = value.toInt();
            }
            break;

          case HealthDataType.SLEEP_DEEP:
            deepSleepMinutes += data.dateTo
                .difference(data.dateFrom)
                .inMinutes
                .toDouble();
            break;
          case HealthDataType.SLEEP_REM:
            remSleepMinutes += data.dateTo
                .difference(data.dateFrom)
                .inMinutes
                .toDouble();
            break;
          case HealthDataType.SLEEP_LIGHT:
            lightSleepMinutes += data.dateTo
                .difference(data.dateFrom)
                .inMinutes
                .toDouble();
            break;

          case HealthDataType.BLOOD_OXYGEN:
            if (value > 0) {
              fetchedSpo2 += value;
              spo2Count++;
            }
            break;

          default:
            break;
        }
      }

      final deepSleepHours = deepSleepMinutes > 0
          ? deepSleepMinutes / 60.0
          : 0.0;
      final remSleepHours = remSleepMinutes > 0 ? remSleepMinutes / 60.0 : 0.0;
      final lightSleepHours = lightSleepMinutes > 0
          ? lightSleepMinutes / 60.0
          : 0.0;
      final calculatedSleepDuration =
          deepSleepHours + remSleepHours + lightSleepHours;

      // Cập nhật UI
      setState(() {
        steps = fetchedSteps;
        heartRate = fetchedHeartRate;
        spo2 = spo2Count > 0 ? (fetchedSpo2 / spo2Count).round() : 0;
        sleepDuration = calculatedSleepDuration;
        deepSleepDuration = deepSleepHours;
        remSleepDuration = remSleepHours;
        lightSleepDuration = lightSleepHours;
        isConnectIoTDevice = true;

        // Update text controllers
        stepsController.text = steps.toString();
        heartRateController.text = heartRate.toString();
        spo2Controller.text = spo2.toString();
        sleepDurationController.text = sleepDuration.toStringAsFixed(1);
        deepSleepController.text = deepSleepDuration.toStringAsFixed(1);
        remSleepController.text = remSleepDuration.toStringAsFixed(1);
        lightSleepController.text = lightSleepDuration.toStringAsFixed(1);
      });

      // Debug logging
      print('✅ [IoT] Steps: $steps');
      print('✅ [IoT] Heart Rate: $heartRate bpm');
      print('✅ [IoT] SpO2: $spo2%');
      print(
        '✅ [IoT] Sleep Duration (Deep Sleep): ${sleepDuration.toStringAsFixed(1)}h',
      );

      _showFlushBar(
        message: 'Health data synced successfully!',
        backgroundColor: const Color(0xFF00D09E),
        icon: Icons.check_circle,
      );
    } catch (e) {
      print('Error fetching health data: $e');
      _showFlushBar(
        message: 'Failed to sync health data: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        icon: Icons.error_outline,
      );
    }
  }

  void _showFlushBar({
    required String message,
    Color backgroundColor = const Color(0xFF00D09E),
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 3),
  }) {
    Flushbar(
      message: message,
      icon: Icon(icon, size: 28, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: backgroundColor,
      duration: duration,
      flushbarPosition: FlushbarPosition.TOP,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ).show(context);
  }

  void _saveDiary() async {
    final diaryNotifier = ref.read(diaryRecordNotifierProvider.notifier);

    final request = DiaryRecordRequest(
      date: selectedDate.toIso8601String().split('T')[0],
      haveSmoked: hasSmoked,
      cigarettesSmoked: cigarettesSmoked,
      triggers: selectedTriggers,
      isUseNrt: isUseNrt,
      moneySpentOnNrt: moneySpentOnNrt,
      cravingLevel: cravingLevel.round(),
      moodLevel: moodLevel.round(),
      confidenceLevel: confidenceLevel.round(),
      anxietyLevel: anxietyLevel.round(),
      note: notesController.text,
      isConnectIoTDevice: isConnectIoTDevice,
      steps: steps,
      heartRate: heartRate,
      spo2: spo2,
      sleepDuration: sleepDuration,
    );

    // Set flag to indicate we're waiting for result
    setState(() {
      _isWaitingForResult = true;
    });

    await diaryNotifier.createDiaryRecord(request);

    if (!mounted) return;

    // Fallback: check state immediately after await (in case listener didn't fire)
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final state = ref.read(diaryRecordNotifierProvider);
    final result = state.valueOrNull;

    // If we have a result and still waiting, process it
    if (_isWaitingForResult && result != null) {
      setState(() {
        _isWaitingForResult = false;
      });
      _handleDiaryResult(result);
    } else if (_isWaitingForResult && state.hasError) {
      setState(() {
        _isWaitingForResult = false;
      });
      _handleDiaryError(state.error!);
    }
  }

  void _handleDiaryResult(DiaryCreateResult result) {
    // Check if user smoked during quit plan (HTTP 209)
    if (result.isSmokedDuringQuitPlan) {
      print('⚠️ [CreateDiary] User smoked during quit plan, showing dialog...');

      // Trigger refreshes even for 209 response
      ref.read(metricsRefreshProvider.notifier).refreshMetrics();
      ref.read(diaryChartsRefreshProvider.notifier).refreshCharts();
      ref.read(diaryRefreshProvider.notifier).refreshDiaryHistory();

      if (!mounted) return;

      // Show the "Smoked Again" dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const SmokedAgainDialog(),
      ).then((_) {
        // After dialog is dismissed, navigate back if still on this screen
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return;
    }

    // Normal success case (200/201)
    if (result.isSuccess) {
      // Trigger metrics refresh after successful diary creation
      ref.read(metricsRefreshProvider.notifier).refreshMetrics();

      // Trigger diary charts refresh to update analytics
      ref.read(diaryChartsRefreshProvider.notifier).refreshCharts();

      // Trigger diary history refresh to update history list
      ref.read(diaryRefreshProvider.notifier).refreshDiaryHistory();
      print('✅ [CreateDiary] Triggered diary history refresh');

      if (!mounted) return;

      // Show success flushbar
      Flushbar(
        message: ' Diary saved successfully!',
        icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        onStatusChanged: (status) {
          // Navigate back after flushbar is dismissed
          if (status == FlushbarStatus.DISMISSED && mounted) {
            Navigator.of(context).pop();
          }
        },
      ).show(context);
    }
  }

  void _handleDiaryError(Object error) {
    if (!mounted) return;

    // Show error flushbar
    Flushbar(
      message: error.toString(),
      icon: const Icon(Icons.error_outline, size: 28, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: const Color(0xFFE53E3E),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ).show(context);
  }
}
