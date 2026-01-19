import 'package:SmartQuitIoT/views/screens/authentication/enhanced_auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/notification_helper.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/headers/auth_header.dart';
import '../../widgets/inputs/custom_text_field.dart';
import 'custom_date_picker.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  String? _selectedGender;
  final List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];

  bool _isFormValid = false;

  // --- 1. Xóa initState và các listener không cần thiết ---
  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 14),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final String formattedDate = DateFormat(
        'dd / MM / yyyy',
      ).format(pickedDate);
      setState(() {
        _dobController.text = formattedDate;
      });
      // Validate lại form sau khi chọn ngày
      _formKey.currentState?.validate();
    }
  }

  void _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateUi = DateFormat('dd / MM / yyyy').parse(_dobController.text);
    final formattedDobApi = DateFormat('yyyy-MM-dd').format(dateUi);

    final success = await ref
        .read(authViewModelProvider.notifier)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _selectedGender!,
          dob: formattedDobApi,
        );

    if (mounted) {
      if (success) {
        NotificationHelper.showTopNotification(
          context,
          title: "Registration Successful",
          message: "Please log in to begin using our services.",
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/login'); // ✅ dùng GoRouter thay Navigator
        }
      } else {
        final error = ref.read(authViewModelProvider).error;
        if (error != null) {
          NotificationHelper.showTopNotification(
            context,
            title: "Login Failed",
            message: error,
            isError: true,
          );
          ref.read(authViewModelProvider.notifier).clearError();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    const greenBorderColor = Color(0xFF00D09E);
    final borderRadius = BorderRadius.circular(12.0);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: greenBorderColor),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1FFF3),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProfessionalAuthHeader(title: 'Sign Up New Account'),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // --- 2. Thêm onChanged trực tiếp vào Form ---
                      onChanged: () {
                        setState(() {
                          _isFormValid =
                              _formKey.currentState?.validate() ?? false;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Username',
                            hint: 'Your username',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 5) {
                                return 'Username must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hint: 'John',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              if (value.length < 2) {
                                return 'First Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hint: 'Doe',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              if (value.length < 2) {
                                return 'Last Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'example@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomDatePickerField(
                            controller: _dobController,
                            label: 'Date Of Birth',
                            hint: 'DD / MM / YYYY',
                            onTap: _selectDate,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your date of birth';
                              }

                              DateTime? birthDate;
                              try {
                                birthDate = DateFormat(
                                  'dd / MM / yyyy',
                                ).parse(value);
                              } catch (e) {
                                return 'Invalid date format';
                              }

                              if (_calculateAge(birthDate) < 14) {
                                return 'Member must be at least 14 years old';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Gender',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                decoration: InputDecoration(
                                  hintText: 'Select your gender',
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: borderRadius,
                                    borderSide: const BorderSide(
                                      color: greenBorderColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: borderRadius,
                                    borderSide: const BorderSide(
                                      color: greenBorderColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: borderRadius,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: borderRadius,
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: borderRadius,
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                items: _genderOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                  // Không cần gọi _validateForm() ở đây nữa vì Form.onChanged đã xử lý
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select your gender';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            obscure: _obscure1,
                            onToggle: () =>
                                setState(() => _obscure1 = !_obscure1),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 5) {
                                return 'Password must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmController,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            obscure: _obscure2,
                            onToggle: () =>
                                setState(() => _obscure2 = !_obscure2),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          authState.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : PrimaryButton(
                                  text: 'Sign Up',
                                  // 3. Vô hiệu hóa nút bấm nếu form không hợp lệ
                                  onPressed: _isFormValid
                                      ? _handleSignUp
                                      : null,
                                ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(
                                '/login',
                              ), // ✅ thay vì Navigator.pop
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Log In',
                                      style: TextStyle(
                                        color: Color(0xFF00D09E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
