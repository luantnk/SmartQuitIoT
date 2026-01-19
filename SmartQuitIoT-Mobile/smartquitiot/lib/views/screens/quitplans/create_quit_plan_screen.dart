import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/request/create_new_quit_plan_request.dart';
import '../../../providers/quit_plan_provider.dart';

class CreateQuitPlanScreen extends ConsumerStatefulWidget {
  const CreateQuitPlanScreen({super.key});

  @override
  ConsumerState<CreateQuitPlanScreen> createState() =>
      _CreateQuitPlanScreenState();
}

class _CreateQuitPlanScreenState extends ConsumerState<CreateQuitPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _planNameController;
  late final TextEditingController _startDateController;
  DateTime? _selectedDate;
  bool _useNRT = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController();
    _startDateController = TextEditingController();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 1, 12, 31),
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

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showMessage({
    required String message,
    required Color color,
    IconData icon = Icons.info_outline,
  }) {
    Flushbar(
      message: message,
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showMessage(
        message: 'Please choose a start date',
        color: Colors.red,
        icon: Icons.error_outline,
      );
      return;
    }

    final request = CreateNewQuitPlanRequest(
      startDate: _startDateController.text,
      useNRT: _useNRT,
      quitPlanName: _planNameController.text.trim(),
    );

    setState(() => _isSubmitting = true);

    try {
      await ref.read(quitPlanViewModelProvider.notifier).createNewPlan(request);
      final state = ref.read(quitPlanViewModelProvider);

      if (state.hasError) {
        _showMessage(
          message: state.error.toString(),
          color: Colors.red,
          icon: Icons.error_outline,
        );
        return;
      }

      if (state.hasValue && state.value != null) {
        ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
        if (!mounted) return;
        _showMessage(
          message: 'Quit plan created successfully! ',
          color: const Color(0xFF00D09E),
          icon: Icons.check_circle_outline,
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          context.go('/main');
        }
        return;
      }

      _showMessage(
        message: 'Unable to create quit plan. Please try again.',
        color: Colors.red,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isSubmitting,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF00D09E),
              elevation: 0,
              foregroundColor: Colors.white,
              title: const Text(
                'Create Quit Plan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            backgroundColor: const Color(0xFFF1FFF3),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.flag_circle,
                              color: Color(0xFF00D09E),
                              size: 32,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Set a future start date, pick whether to use NRT, and name your personalized plan.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _planNameController,
                        decoration: InputDecoration(
                          labelText: 'Quit Plan Name',
                          hintText: 'Ex: Smoke-Free Week',
                          prefixIcon: const Icon(
                            Icons.label_outline,
                            color: Color(0xFF00D09E),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter quit plan name';
                          }
                          if (value.trim().length < 3) {
                            return 'Quit plan name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: _pickStartDate,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          hintText: 'Select start date',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF00D09E),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select start date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Use NRT',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('Nicotine Replacement Therapy'),
                          value: _useNRT,
                          onChanged: (value) => setState(() => _useNRT = value),
                          activeColor: const Color(0xFF00D09E),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D09E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Create Quit Plan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isSubmitting) const _FullScreenLoadingBarrier(),
        ],
      ),
    );
  }
}

class _FullScreenLoadingBarrier extends StatelessWidget {
  const _FullScreenLoadingBarrier();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.4),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Create Quit Plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
