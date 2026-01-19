import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback? onToggle;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.onToggle,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const greenBorderColor = Color(0xFF00D09E);
    final BorderRadius borderRadius = BorderRadius.circular(12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 14,
                ),
                children: const [
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
          ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            // 1. Border khi không focus
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius, // Dùng giá trị đã đồng nhất
              borderSide: const BorderSide(
                color: greenBorderColor,
                width: 1.0,
              ),
            ),
            // 2. Border khi focus
            focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius, // Dùng giá trị đã đồng nhất
                borderSide: const BorderSide(
                  color: greenBorderColor,
                  width: 2.0,
                )
            ),
            // Các border khác (lỗi,...)
            border: OutlineInputBorder(
              borderRadius: borderRadius, // Dùng giá trị đã đồng nhất
            ),
            // Thêm border khi có lỗi để đảm bảo bo cong
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
            suffixIcon: onToggle != null
                ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggle,
            )
                : null,
          ),
        ),
      ],
    );
  }
}