import 'package:SmartQuitIoT/views/screens/questionaires/question_card.dart';
import 'package:flutter/material.dart';

class QuestionInputCard extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  final String hintText;
  final String? errorText; // <-- thêm errorText
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? margin;

  const QuestionInputCard({
    super.key,
    required this.question,
    required this.controller,
    required this.hintText,
    this.errorText, // <-- thêm
    this.keyboardType,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: question,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00D09E),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Hiển thị error text nếu có
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 4.0),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
