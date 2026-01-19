import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// ⚠️ LƯU Ý: Hãy chắc chắn đường dẫn này đúng với project của bạn
import '../../../models/response/form_metric_response.dart';

// Class format tiền tệ (giữ nguyên)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;
    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditFormMetricDialog extends StatefulWidget {
  final FormMetricDTO currentData;

  const EditFormMetricDialog({super.key, required this.currentData});

  @override
  State<EditFormMetricDialog> createState() => _EditFormMetricDialogState();
}

class _EditFormMetricDialogState extends State<EditFormMetricDialog> {
  // 1. Khai báo GlobalKey để quản lý Form state
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _smokeAvgController;
  late TextEditingController _yearsSmokingController;
  late TextEditingController _minutesAfterWakingController;
  late TextEditingController _cigarettesPerPackageController;
  late TextEditingController _moneyPerPackageController;
  late TextEditingController _nicotineAmountController;

  // Options lists
  final List<String> _availableInterests = [
    'All Interests',
    'Sports and Exercise',
    'Art and Creativity',
    'Cooking and Food',
    'Reading, Learning and Writing',
    'Music and Entertainment',
    'Nature and Outdoor Activities',
  ];

  final List<String> _availableTriggers = [
    'Morning', 'After Meal', 'Gaming', 'Party', 'Coffee',
    'Stress', 'Boredom', 'Driving', 'Sadness', 'Work',
  ];

  late List<String> _selectedInterests;
  late List<String> _selectedTriggers;
  late bool _smokingInForbiddenPlaces;
  late bool _cigaretteHateToGiveUp;
  late bool _morningSmokingFrequency;
  late bool _smokeWhenSick;

  @override
  void initState() {
    super.initState();

    // Init controllers with existing data
    _smokeAvgController = TextEditingController(text: widget.currentData.smokeAvgPerDay.toString());
    _yearsSmokingController = TextEditingController(text: widget.currentData.numberOfYearsOfSmoking.toString());
    _minutesAfterWakingController = TextEditingController(text: widget.currentData.minutesAfterWakingToSmoke.toString());
    _cigarettesPerPackageController = TextEditingController(text: widget.currentData.cigarettesPerPackage.toString());

    final formattedMoney = NumberFormat('#,###', 'vi_VN').format(widget.currentData.moneyPerPackage);
    _moneyPerPackageController = TextEditingController(text: formattedMoney);

    _nicotineAmountController = TextEditingController(text: widget.currentData.amountOfNicotinePerCigarettes.toString());

    // Clean and init lists
    _selectedInterests = List.from(widget.currentData.interests.where((e) => e.isNotEmpty));
    _selectedTriggers = List.from(widget.currentData.triggered.where((e) => e.isNotEmpty));

    _smokingInForbiddenPlaces = widget.currentData.smokingInForbiddenPlaces;
    _cigaretteHateToGiveUp = widget.currentData.cigaretteHateToGiveUp;
    _morningSmokingFrequency = widget.currentData.morningSmokingFrequency;
    _smokeWhenSick = widget.currentData.smokeWhenSick;
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

  // --- VALIDATOR LOGIC (Tiếng Anh) ---
  String? _validateNumber(String? value, {bool allowZero = false, bool isMoney = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required'; // Lỗi bắt buộc nhập
    }

    // Nếu là tiền, bỏ dấu phẩy đi để check
    String checkValue = isMoney ? value.replaceAll(RegExp(r'[^0-9]'), '') : value;

    final number = double.tryParse(checkValue);
    if (number == null) {
      return 'Invalid number format'; // Lỗi format
    }

    if (!allowZero && number <= 0) {
      return 'Value must be greater than 0'; // Lỗi phải lớn hơn 0
    }

    if (allowZero && number < 0) {
      return 'Value cannot be negative'; // Lỗi không được âm
    }

    return null; // Không có lỗi
  }

  void _handleSave() {
    // 1. Kích hoạt Validate toàn bộ Form
    // Nếu có lỗi, UI tự động đỏ lên và hàm này dừng lại, không chạy tiếp.
    if (!_formKey.currentState!.validate()) {
      // Optional: Scroll to top or show a small toast saying "Check errors"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in red before saving.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 2. Validate Chips (Interests/Triggers) - Phần này không dùng TextFormField nên vẫn check thủ công
    if (_selectedInterests.isEmpty) {
      _showError('Please select at least one interest');
      return;
    }
    if (_selectedTriggers.isEmpty) {
      _showError('Please select at least one trigger');
      return;
    }

    // Parse money (remove non-digits)
    final moneyText = _moneyPerPackageController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Tạo object mới
    final updatedData = FormMetricDTO(
      id: widget.currentData.id,
      smokeAvgPerDay: int.parse(_smokeAvgController.text),
      numberOfYearsOfSmoking: int.parse(_yearsSmokingController.text),
      minutesAfterWakingToSmoke: int.parse(_minutesAfterWakingController.text),
      cigarettesPerPackage: int.parse(_cigarettesPerPackageController.text),
      moneyPerPackage: double.parse(moneyText),
      amountOfNicotinePerCigarettes: double.parse(_nicotineAmountController.text),

      smokingInForbiddenPlaces: _smokingInForbiddenPlaces,
      cigaretteHateToGiveUp: _cigaretteHateToGiveUp,
      morningSmokingFrequency: _morningSmokingFrequency,
      smokeWhenSick: _smokeWhenSick,

      estimatedMoneySavedOnPlan: widget.currentData.estimatedMoneySavedOnPlan,
      estimatedNicotineIntakePerDay: widget.currentData.estimatedNicotineIntakePerDay,
      interests: _selectedInterests,
      triggered: _selectedTriggers,
    );

    Navigator.pop(context, updatedData);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Form Metric', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00D09E),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Wrap toàn bộ Column trong Form
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Smoking Habits', Icons.smoking_rooms),
              const SizedBox(height: 16),

              // Sử dụng hàm build mới: _buildTextFormField
              _buildTextFormField(
                label: 'Average Cigarettes Per Day',
                controller: _smokeAvgController,
                icon: Icons.smoking_rooms,
                validator: (val) => _validateNumber(val, allowZero: false),
                isInteger: true,
              ),
              const SizedBox(height: 12),

              _buildTextFormField(
                label: 'Years of Smoking',
                controller: _yearsSmokingController,
                icon: Icons.calendar_today,
                validator: (val) => _validateNumber(val, allowZero: false),
                isInteger: true,
              ),
              const SizedBox(height: 12),

              _buildTextFormField(
                label: 'Minutes After Waking',
                controller: _minutesAfterWakingController,
                icon: Icons.access_time,
                validator: (val) => _validateNumber(val, allowZero: true), // Cho phép 0 phút
                isInteger: true,
              ),
              const SizedBox(height: 12),

              _buildTextFormField(
                label: 'Cigarettes Per Package',
                controller: _cigarettesPerPackageController,
                icon: Icons.inventory_2,
                validator: (val) => _validateNumber(val, allowZero: false),
                isInteger: true,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Financial Information', Icons.money),
              const SizedBox(height: 16),

              _buildTextFormField(
                label: 'Money Per Package',
                controller: _moneyPerPackageController,
                icon: Icons.money,
                validator: (val) => _validateNumber(val, allowZero: false, isMoney: true),
                isMoney: true,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Nicotine Information', Icons.water_drop),
              const SizedBox(height: 16),

              _buildTextFormField(
                label: 'Nicotine Per Cigarette (mg)',
                controller: _nicotineAmountController,
                icon: Icons.water_drop,
                validator: (val) => _validateNumber(val, allowZero: false),
                isInteger: false, // Cho phép số lẻ (0.5mg)
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Smoking Behaviors', Icons.psychology),
              const SizedBox(height: 16),
              _buildSwitchTile('Smoking in Forbidden Places', _smokingInForbiddenPlaces, (v) => setState(() => _smokingInForbiddenPlaces = v), Icons.location_off),
              _buildRadioSelection('Cigarette Hate to Give Up', _cigaretteHateToGiveUp, Icons.favorite),
              _buildSwitchTile('Morning Smoking Frequency', _morningSmokingFrequency, (v) => setState(() => _morningSmokingFrequency = v), Icons.wb_sunny),
              _buildSwitchTile('Smoke When Sick', _smokeWhenSick, (v) => setState(() => _smokeWhenSick = v), Icons.medical_services),

              const SizedBox(height: 24),
              _buildSectionTitle('Your Interests', Icons.interests),
              const SizedBox(height: 12),
              _buildInterestsSection(),

              const SizedBox(height: 24),
              _buildSectionTitle('Smoking Triggers', Icons.warning_amber),
              const SizedBox(height: 12),
              _buildMultiSelectSection(_availableTriggers, _selectedTriggers, const Color(0xFFFF6B6B)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ĐÃ NÂNG CẤP ---

  // Thay TextField bằng TextFormField để hỗ trợ validator
  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    bool isInteger = false,
    bool isMoney = false,
  }) {
    return Container(
      // Container này tạo bóng (Shadow) cho ô nhập
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        // Dòng này quan trọng: Kiểm tra lỗi ngay khi user gõ phím
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
        inputFormatters: [
          if (isMoney)
            ThousandsSeparatorInputFormatter()
          else
            FilteringTextInputFormatter.allow(RegExp(isInteger ? r'[0-9]' : r'[0-9.]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF00D09E)),
          // Style khi bình thường
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Trong suốt vì đã có shadow container
          ),
          // Style khi focus (đang nhập)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D09E), width: 2),
          ),
          // Style khi CÓ LỖI (Màu đỏ)
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          // Style cho dòng chữ báo lỗi
          errorStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF00D09E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF00D09E), size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        secondary: Icon(icon, color: const Color(0xFF00D09E)),
        value: value, onChanged: onChanged, activeColor: const Color(0xFF00D09E),
      ),
    );
  }

  Widget _buildRadioSelection(String title, bool currentValue, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon, color: const Color(0xFF00D09E)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87))),
            ]),
          ),
          const Divider(height: 1),
          RadioListTile<bool>(
            title: const Text('The first in the morning', style: TextStyle(fontSize: 14)),
            value: true, groupValue: currentValue, activeColor: const Color(0xFF00D09E),
            onChanged: (val) => setState(() => _cigaretteHateToGiveUp = val!),
          ),
          RadioListTile<bool>(
            title: const Text('Any other', style: TextStyle(fontSize: 14)),
            value: false, groupValue: currentValue, activeColor: Colors.orange,
            onChanged: (val) => setState(() => _cigaretteHateToGiveUp = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    final isAllInterestsSelected = _selectedInterests.contains("All Interests");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: _availableInterests.map((option) {
          final isAllInterests = option == "All Interests";
          final isSelected = isAllInterestsSelected ? true : _selectedInterests.contains(option);
          final isDisabled = isAllInterestsSelected && !isAllInterests;
          return FilterChip(
            label: Text(option),
            selected: isSelected,
            onSelected: isDisabled ? null : (val) {
              setState(() {
                if (isAllInterests) {
                  if (val) { _selectedInterests.clear(); _selectedInterests.add(option); }
                  else { _selectedInterests.remove(option); }
                } else {
                  if (val) { _selectedInterests.add(option); }
                  else { _selectedInterests.remove(option); }
                }
              });
            },
            backgroundColor: Colors.white, selectedColor: const Color(0xFF00B386),
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
            checkmarkColor: Colors.white,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiSelectSection(List<String> options, List<String> selected, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return FilterChip(
            label: Text(option), selected: isSelected,
            onSelected: (val) => setState(() => val ? selected.add(option) : selected.remove(option)),
            backgroundColor: Colors.grey.shade100, selectedColor: color.withOpacity(0.2), checkmarkColor: color,
            labelStyle: TextStyle(color: isSelected ? color : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          );
        }).toList(),
      ),
    );
  }
}