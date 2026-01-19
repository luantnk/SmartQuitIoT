import 'package:SmartQuitIoT/views/screens/questionaires/question_card.dart';
import 'package:flutter/material.dart';

class QuestionOptionsCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final EdgeInsetsGeometry? margin;
  final void Function(String)? onSelected;
  final String? errorText; // <-- bổ sung

  const QuestionOptionsCard({
    super.key,
    required this.question,
    required this.options,
    this.margin,
    this.onSelected,
    this.errorText, // <-- bổ sung
  });

  @override
  State<QuestionOptionsCard> createState() => _QuestionOptionsCardState();
}

class _QuestionOptionsCardState extends State<QuestionOptionsCard> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: widget.question,
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.options.map((option) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: option,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() => _selectedValue = value);
                  if (value != null && widget.onSelected != null) {
                    widget.onSelected!(value);
                  }
                },
                activeColor: const Color(0xFF00D09E),
              ),
              title: Text(option),
            );
          }),

          // Hiển thị error text nếu có
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 16.0),
              child: Text(
                widget.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
