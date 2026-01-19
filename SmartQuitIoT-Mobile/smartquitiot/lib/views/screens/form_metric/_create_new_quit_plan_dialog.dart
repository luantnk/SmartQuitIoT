import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../models/request/create_new_quit_plan_request.dart';
import '../../../views/widgets/common/full_screen_loader.dart';
import 'package:go_router/go_router.dart';

class CreateNewQuitPlanDialog extends ConsumerStatefulWidget {
  const CreateNewQuitPlanDialog({super.key});

  @override
  ConsumerState<CreateNewQuitPlanDialog> createState() =>
      _CreateNewQuitPlanDialogState();
}

class _CreateNewQuitPlanDialogState
    extends ConsumerState<CreateNewQuitPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quitPlanNameController;
  late TextEditingController _startDateController;
  bool _useNRT = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _quitPlanNameController = TextEditingController();
    _startDateController = TextEditingController();
  }

  @override
  void dispose() {
    _quitPlanNameController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Select Start Date',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00D09E),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  String? _validateQuitPlanName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter quit plan name';
    }
    if (value.trim().length < 3) {
      return 'Quit plan name must be at least 3 characters';
    }
    return null;
  }

  String? _validateStartDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select start date';
    }
    return null;
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      Flushbar(
        message: 'Please select a start date',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    final request = CreateNewQuitPlanRequest(
      startDate: _startDateController.text,
      useNRT: _useNRT,
      quitPlanName: _quitPlanNameController.text.trim(),
    );

    // Show full screen loader
    FullScreenLoader.show(context, message: 'Creating quit plan...');

    try {
      // Create new plan
      await ref.read(quitPlanViewModelProvider.notifier).createNewPlan(request);

      if (!mounted) return;

      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Hide full screen loader
      FullScreenLoader.hide(context);

      // Check state
      final state = ref.read(quitPlanViewModelProvider);

      if (state.hasError) {
        Flushbar(
          message: state.error.toString(),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      } else if (state.hasValue && state.value != null) {
        // Success - close create dialog
        Navigator.of(context).pop();

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => QuitPlanSuccessDialog(
              quitPlanName: _quitPlanNameController.text.trim(),
            ),
          );
        }
      } else {
        // Still loading or unknown state
        Flushbar(
          message: 'Failed to create quit plan',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      if (!mounted) return;
      // Hide full screen loader
      FullScreenLoader.hide(context);
      Flushbar(
        message: 'Failed to create quit plan: ${e.toString()}',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF00D09E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Create New Quit Plan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quit Plan Name
                TextFormField(
                  controller: _quitPlanNameController,
                  decoration: InputDecoration(
                    labelText: 'Quit Plan Name',
                    hintText: 'Enter quit plan name',
                    prefixIcon: const Icon(
                      Icons.label_outline,
                      color: Color(0xFF00D09E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00D09E),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: _validateQuitPlanName,
                ),
                const SizedBox(height: 20),

                // Start Date
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'Select start date',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF00D09E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00D09E),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: _validateStartDate,
                ),
                const SizedBox(height: 20),

                // Use NRT Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medical_services_outlined,
                        color: Color(0xFF00D09E),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use NRT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Nicotine Replacement Therapy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _useNRT,
                        onChanged: (value) {
                          setState(() {
                            _useNRT = value;
                          });
                        },
                        activeColor: const Color(0xFF00D09E),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuitPlanSuccessDialog extends StatelessWidget {
  final String quitPlanName;

  const QuitPlanSuccessDialog({super.key, required this.quitPlanName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D09E), Color(0xFF3FCF8E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D09E).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),

            // Success Text
            const Text(
              ' Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              'Your quit plan "$quitPlanName" has been created successfully!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Motivational message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D09E).withOpacity(0.1),
                    const Color(0xFF3FCF8E).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.rocket_launch,
                    color: Color(0xFF00D09E),
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re on your way to a smoke-free life!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to main screen
                  context.go('/main');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Go to Main',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
