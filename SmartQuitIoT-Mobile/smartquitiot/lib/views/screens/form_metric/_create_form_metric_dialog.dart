import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/response/form_metric_response.dart';
import '_edit_form_metric_dialog.dart'; // Import để dùng ThousandsSeparatorInputFormatter

class CreateFormMetricDialog extends StatefulWidget {
  const CreateFormMetricDialog({super.key});

  @override
  State<CreateFormMetricDialog> createState() => _CreateFormMetricDialogState();
}

class _CreateFormMetricDialogState extends State<CreateFormMetricDialog> {
  // Controllers
  late TextEditingController _smokeAvgController;
  late TextEditingController _yearsSmokingController;
  late TextEditingController _minutesAfterWakingController;
  late TextEditingController _cigarettesPerPackageController;
  late TextEditingController _moneyPerPackageController;
  late TextEditingController _nicotineAmountController;

  // Interests options
  final List<String> _availableInterests = [
    'All Interests',
    'Sports and Exercise',
    'Art and Creativity',
    'Cooking and Food',
    'Reading, Learning and Writing',
    'Music and Entertainment',
    'Nature and Outdoor Activities',
  ];

  // Triggers options
  final List<String> _availableTriggers = [
    'Morning',
    'After Meal',
    'Gaming',
    'Party',
    'Coffee',
    'Stress',
    'Boredom',
    'Driving',
    'Sadness',
    'Work',
  ];

  // Selected values
  late List<String> _selectedInterests;
  late List<String> _selectedTriggers;
  late bool _smokingInForbiddenPlaces;
  late bool _cigaretteHateToGiveUp;
  late bool _morningSmokingFrequency;
  late bool _smokeWhenSick;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty values
    _smokeAvgController = TextEditingController();
    _yearsSmokingController = TextEditingController();
    _minutesAfterWakingController = TextEditingController();
    _cigarettesPerPackageController = TextEditingController();
    _moneyPerPackageController = TextEditingController();
    _nicotineAmountController = TextEditingController();

    // Initialize selections
    _selectedInterests = [];
    _selectedTriggers = [];
    _smokingInForbiddenPlaces = false;
    _cigaretteHateToGiveUp = false;
    _morningSmokingFrequency = false;
    _smokeWhenSick = false;
  }

  @override
  void dispose() {
    _smokeAvgController.dispose();
    _yearsSmokingController.dispose();
    _minutesAfterWakingController.dispose();
    _cigarettesPerPackageController.dispose();
    _moneyPerPackageController.dispose();
    _nicotineAmountController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    // Validate all required fields
    if (_smokeAvgController.text.trim().isEmpty) {
      _showError('Please enter average cigarettes per day');
      return false;
    }
    if (_yearsSmokingController.text.trim().isEmpty) {
      _showError('Please enter years of smoking');
      return false;
    }
    if (_minutesAfterWakingController.text.trim().isEmpty) {
      _showError('Please enter minutes after waking');
      return false;
    }
    if (_cigarettesPerPackageController.text.trim().isEmpty) {
      _showError('Please enter cigarettes per package');
      return false;
    }
    if (_moneyPerPackageController.text.trim().isEmpty) {
      _showError('Please enter money per package');
      return false;
    }
    if (_nicotineAmountController.text.trim().isEmpty) {
      _showError('Please enter nicotine amount');
      return false;
    }
    if (_selectedInterests.isEmpty) {
      _showError('Please select at least one interest');
      return false;
    }
    if (_selectedTriggers.isEmpty) {
      _showError('Please select at least one trigger');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleContinue() {
    // Validate first
    if (!_validateFields()) {
      return;
    }

    // Parse money - strip any non-digit characters before parsing
    final moneyText = _moneyPerPackageController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final formMetricData = FormMetricDTO(
      id: 0,
      smokeAvgPerDay: int.tryParse(_smokeAvgController.text) ?? 0,
      numberOfYearsOfSmoking: int.tryParse(_yearsSmokingController.text) ?? 0,
      minutesAfterWakingToSmoke:
          int.tryParse(_minutesAfterWakingController.text) ?? 0,
      cigarettesPerPackage:
          int.tryParse(_cigarettesPerPackageController.text) ?? 0,
      moneyPerPackage: double.tryParse(moneyText) ?? 0,
      amountOfNicotinePerCigarettes:
          double.tryParse(_nicotineAmountController.text) ?? 0,
      smokingInForbiddenPlaces: _smokingInForbiddenPlaces,
      cigaretteHateToGiveUp: _cigaretteHateToGiveUp,
      morningSmokingFrequency: _morningSmokingFrequency,
      smokeWhenSick: _smokeWhenSick,
      estimatedMoneySavedOnPlan: 0,
      estimatedNicotineIntakePerDay: 0,
      interests: _selectedInterests,
      triggered: _selectedTriggers,
    );

    Navigator.pop(context, formMetricData);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Create Form Metric',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF00D09E),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            TextButton.icon(
              onPressed: _handleContinue,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Required message banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC107),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFFF9800),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Required Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please fill in all fields to continue. This information is required to create your quit plan.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Smoking Habits Section
              _buildSectionTitle('Smoking Habits', Icons.smoking_rooms),
              const SizedBox(height: 16),
              _buildTextField(
                'Average Cigarettes Per Day',
                _smokeAvgController,
                Icons.smoking_rooms,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Years of Smoking',
                _yearsSmokingController,
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Minutes After Waking',
                _minutesAfterWakingController,
                Icons.access_time,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Cigarettes Per Package',
                _cigarettesPerPackageController,
                Icons.inventory_2,
              ),

              const SizedBox(height: 24),

              // Financial Section
              _buildSectionTitle('Financial Information', Icons.money),
              const SizedBox(height: 16),
              _buildMoneyTextField(
                'Money Per Package',
                _moneyPerPackageController,
                Icons.money,
              ),

              const SizedBox(height: 24),

              // Nicotine Section
              _buildSectionTitle('Nicotine Information', Icons.water_drop),
              const SizedBox(height: 16),
              _buildTextField(
                'Nicotine Per Cigarette (mg)',
                _nicotineAmountController,
                Icons.water_drop,
              ),

              const SizedBox(height: 24),

              // Smoking Behaviors
              _buildSectionTitle('Smoking Behaviors', Icons.psychology),
              const SizedBox(height: 16),
              _buildSwitchTile(
                'Smoking in Forbidden Places',
                _smokingInForbiddenPlaces,
                (value) => setState(() => _smokingInForbiddenPlaces = value),
                Icons.location_off,
              ),
              _buildRadioSelection(
                'Cigarette Hate to Give Up',
                _cigaretteHateToGiveUp,
                Icons.favorite,
              ),
              _buildSwitchTile(
                'Morning Smoking Frequency',
                _morningSmokingFrequency,
                (value) => setState(() => _morningSmokingFrequency = value),
                Icons.wb_sunny,
              ),
              _buildSwitchTile(
                'Smoke When Sick',
                _smokeWhenSick,
                (value) => setState(() => _smokeWhenSick = value),
                Icons.medical_services,
              ),

              const SizedBox(height: 24),

              // Interests Selection
              _buildSectionTitle('Your Interests', Icons.interests),
              const SizedBox(height: 12),
              _buildMultiSelectSection(
                _availableInterests,
                _selectedInterests,
                const Color(0xFF00B386),
              ),

              const SizedBox(height: 24),

              // Triggers Selection
              _buildSectionTitle('Smoking Triggers', Icons.warning_amber),
              const SizedBox(height: 12),
              _buildMultiSelectSection(
                _availableTriggers,
                _selectedTriggers,
                const Color(0xFFFF6B6B),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00D09E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00D09E), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF00D09E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandsSeparatorInputFormatter()],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF00D09E)),
          hintText: 'e.g., 20,000',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        secondary: Icon(icon, color: const Color(0xFF00D09E)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00D09E),
      ),
    );
  }

  Widget _buildRadioSelection(String title, bool currentValue, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00D09E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Radio Options
          RadioListTile<bool>(
            title: const Row(
              children: [
                Icon(Icons.wb_sunny, size: 20, color: Color(0xFF00D09E)),
                SizedBox(width: 8),
                Text(
                  'The first in the morning',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            value: true,
            groupValue: currentValue,
            activeColor: const Color(0xFF00D09E),
            onChanged: (value) {
              setState(() {
                _cigaretteHateToGiveUp = value!;
              });
            },
          ),
          RadioListTile<bool>(
            title: const Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Any other',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            value: false,
            groupValue: currentValue,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _cigaretteHateToGiveUp = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectSection(
    List<String> options,
    List<String> selected,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return FilterChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (value) {
              setState(() {
                if (value) {
                  selected.add(option);
                } else {
                  selected.remove(option);
                }
              });
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: color.withOpacity(0.2),
            checkmarkColor: color,
            labelStyle: TextStyle(
              color: isSelected ? color : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          );
        }).toList(),
      ),
    );
  }
}
