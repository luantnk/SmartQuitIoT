import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SmartQuitIoT/viewmodels/user_view_model.dart';
import 'package:SmartQuitIoT/viewmodels/reminder_settings_view_model.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:SmartQuitIoT/utils/avatar_helper.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Form Key để quản lý validation
  final _formKey = GlobalKey<FormState>();

  // Editable fields controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Reminder settings controllers
  final TextEditingController morningReminderTimeController =
  TextEditingController();
  final TextEditingController quietStartController = TextEditingController();
  final TextEditingController quietEndController = TextEditingController();

  // Avatar
  File? avatarImageFile;
  String? avatarUrl; // Current avatar URL from API
  final picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    // Load user profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userViewModelProvider.notifier).loadUserProfile();
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    morningReminderTimeController.dispose();
    quietStartController.dispose();
    quietEndController.dispose();
    super.dispose();
  }

  // --- VALIDATION LOGIC ---
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field must not be empty';
    }
    if (value.trim().length < 3) {
      return 'Have at least 3 character';
    }

    final RegExp nameRegExp = RegExp(
        r'^[a-zA-Z0-9\sàáãạèéẹêìíòóõọôùúụưđÀÁÃẠÈÉẸÊÌÍÒÓÕỌÔÙÚỤƯĐ]+$');

    if (!nameRegExp.hasMatch(value)) {
      return 'Cannot contain special characters';
    }
    return null;
  }
  // ------------------------

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        avatarImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        controller.text = '$hour:$minute';
      });
    }
  }

  String _formatTimeFromApi(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    // Convert "07:00:00" to "07:00"
    if (timeString.contains(':')) {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return timeString;
  }

  Future<void> _updateProfile() async {
    // 1. Kiểm tra validation của Form (First Name, Last Name)
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      _showFlushbar('Please check again your personal information', Colors.orange);
      return;
    }

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final dob = dobController.text.trim();

    // Validation DOB
    if (dob.isEmpty) {
      _showFlushbar('Please fill all required fields', Colors.orange);
      return;
    }

    String finalAvatarUrl = avatarUrl ?? '';

    // Upload new avatar if selected
    if (avatarImageFile != null) {
      setState(() => _isUploadingAvatar = true);
      try {
        print('📸 [EditProfile] Uploading avatar...');
        finalAvatarUrl = await _cloudinaryService.uploadImage(avatarImageFile!);
        print('✅ [EditProfile] Avatar uploaded: $finalAvatarUrl');
      } catch (e) {
        setState(() => _isUploadingAvatar = false);
        _showFlushbar('Failed to upload avatar: $e', Colors.red);
        return;
      }
      setState(() => _isUploadingAvatar = false);
    }

    // Update profile
    await ref
        .read(userViewModelProvider.notifier)
        .updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      avatarUrl: finalAvatarUrl,
    );

    if (mounted) {
      final userError = ref.read(userViewModelProvider).error;
      if (userError != null) {
        _showFlushbar('Error: $userError', Colors.red);
        return;
      }
    }

    // Update reminder settings if they have values
    final morningTime = morningReminderTimeController.text.trim();
    final quietStart = quietStartController.text.trim();
    final quietEnd = quietEndController.text.trim();

    if (morningTime.isNotEmpty ||
        quietStart.isNotEmpty ||
        quietEnd.isNotEmpty) {
      // Validate all reminder fields are filled if any is filled
      if (morningTime.isEmpty || quietStart.isEmpty || quietEnd.isEmpty) {
        _showFlushbar('Please fill all reminder time fields', Colors.orange);
        return;
      }

      // 2. Logic Validation Quiet Start < Quiet End
      // try {
      //   final startParts = quietStart.split(':');
      //   final endParts = quietEnd.split(':');

      //   final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      //   final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      //   if (startMinutes >= endMinutes) {
      //     _showFlushbar('Quiet Start Time must be before quiet end time', Colors.orange);
      //     return;
      //   }
      // } catch (e) {
      //   _showFlushbar('Lỗi định dạng thời gian', Colors.red);
      //   return;
      // }

      await ref
          .read(reminderSettingsViewModelProvider.notifier)
          .updateReminderSettings(
        morningReminderTime: morningTime,
        quietStart: quietStart,
        quietEnd: quietEnd,
      );

      if (mounted) {
        final reminderError = ref.read(reminderSettingsViewModelProvider).error;
        if (reminderError != null) {
          _showFlushbar(
            'Error updating reminder settings: $reminderError',
            Colors.red,
          );
          return;
        }
      }
    }

    if (mounted) {
      _showFlushbar('Profile updated successfully!', const Color(0xFF00D09E));
      // Refresh profile data để UI cập nhật
      await ref.read(userViewModelProvider.notifier).loadUserProfile();
      // Navigate to profile screen để user thấy thay đổi
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/profile');
        }
      });
    }
  }

  void _showFlushbar(String message, Color backgroundColor) {
    Flushbar(
      message: message,
      icon: Icon(
        backgroundColor == Colors.red
            ? Icons.error_outline
            : Icons.check_circle,
        color: Colors.white,
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final user = userState.user;
    final isLoading = userState.isLoading;
    final isUpdating = userState.isUpdating;
    final reminderSettingsState = ref.watch(reminderSettingsViewModelProvider);
    final isUpdatingReminder = reminderSettingsState.isUpdating;

    // Populate controllers when user data is loaded
    if (user != null && firstNameController.text.isEmpty) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      dobController.text = user.dob;
      avatarUrl = user.avatarUrl;

      // Populate reminder settings
      if (user.morningReminderTime != null) {
        morningReminderTimeController.text = _formatTimeFromApi(
          user.morningReminderTime,
        );
      }
      if (user.quietStart != null) {
        quietStartController.text = _formatTimeFromApi(user.quietStart);
      }
      if (user.quietEnd != null) {
        quietEndController.text = _formatTimeFromApi(user.quietEnd);
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF1DD1A1), Color(0xFF00D09E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Avatar
              if (isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: avatarImageFile != null
                              ? Image.file(
                            avatarImageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : (avatarUrl != null && avatarUrl!.isNotEmpty)
                              ? _buildNetworkAvatar(formatAvatarUrl(avatarUrl!))
                              : Image.asset(
                            "lib/assets/images/profile.png",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Color(0xFF00D09E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00D09E),
                      ),
                    )
                        : Form(
                      key: _formKey, // Bắt đầu Form
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Read-only section
                          const Text(
                            'Account Information (Read-only)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D09E),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Username (read-only)
                          _buildReadOnlyField(
                            'Username',
                            user?.account.username ?? '-',
                          ),
                          const SizedBox(height: 12),

                          // Email (read-only)
                          _buildReadOnlyField(
                            'Email',
                            user?.account.email ?? '-',
                          ),
                          const SizedBox(height: 12),

                          // Role (read-only)
                          _buildReadOnlyField(
                            'Role',
                            user?.account.role ?? '-',
                          ),
                          const SizedBox(height: 12),

                          // Gender (read-only)
                          _buildReadOnlyField(
                            'Gender',
                            user?.gender ?? '-',
                          ),
                          const SizedBox(height: 12),

                          // Age (read-only)
                          _buildReadOnlyField(
                            'Age',
                            user?.age.toString() ?? '-',
                          ),
                          const SizedBox(height: 25),

                          // Editable section
                          const Text(
                            'Personal Information (Editable)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D09E),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // First Name
                          TextFormField(
                            controller: firstNameController,
                            validator: _validateName, // Validator
                            autovalidateMode: AutovalidateMode.onUserInteraction, // Show lỗi khi gõ
                            decoration: InputDecoration(
                              labelText: "First Name *",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Last Name
                          TextFormField(
                            controller: lastNameController,
                            validator: _validateName, // Validator
                            autovalidateMode: AutovalidateMode.onUserInteraction, // Show lỗi khi gõ
                            decoration: InputDecoration(
                              labelText: "Last Name *",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Date of Birth
                          TextFormField(
                            controller: dobController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(
                              labelText: "Date of Birth *",
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Reminder Settings section
                          const Text(
                            'Reminder Settings (Editable)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D09E),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Morning Reminder Time
                          TextFormField(
                            controller: morningReminderTimeController,
                            readOnly: true,
                            onTap: () => _selectTime(
                              context,
                              morningReminderTimeController,
                            ),
                            decoration: InputDecoration(
                              labelText: "Morning Reminder Time",
                              hintText: "HH:mm",
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Quiet Start Time
                          TextFormField(
                            controller: quietStartController,
                            readOnly: true,
                            onTap: () =>
                                _selectTime(context, quietStartController),
                            decoration: InputDecoration(
                              labelText: "Quiet Start Time",
                              hintText: "HH:mm",
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Quiet End Time
                          TextFormField(
                            controller: quietEndController,
                            readOnly: true,
                            onTap: () =>
                                _selectTime(context, quietEndController),
                            decoration: InputDecoration(
                              labelText: "Quiet End Time",
                              hintText: "HH:mm",
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                              (isUpdating ||
                                  _isUploadingAvatar ||
                                  isUpdatingReminder)
                                  ? null
                                  : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D09E),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                              child:
                              (isUpdating ||
                                  _isUploadingAvatar ||
                                  isUpdatingReminder)
                                  ? const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Updating...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                                  : const Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNetworkAvatar(String url) {
    try {
      final uri = Uri.parse(url);
      final encodedUrl = uri.toString();

      return Image.network(
        encodedUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        headers: {'Accept': 'image/*'},
        errorBuilder: (context, error, stackTrace) {
          print('❌ [EditProfileScreen] Error loading avatar: $error');
          print('❌ [EditProfileScreen] URL: $url');

          // Fallback: Try loading with http package
          return FutureBuilder<http.Response>(
            future: http.get(Uri.parse(url)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                return Image.memory(
                  snapshot.data!.bodyBytes,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              }

              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('❌ [EditProfileScreen] Error parsing URL: $e');
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      );
    }
  }
}