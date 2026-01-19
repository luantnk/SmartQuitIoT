import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_logo_section.dart';
import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

import 'package:SmartQuitIoT/views/widgets/cards/instruction_card.dart';
import 'ai_chat_message_input.dart';

class AiChatInstructionsScreen extends StatelessWidget {
  const AiChatInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // cho keyboard đẩy view lên
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Instructions',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Phần trên scroll được
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Logo ở trên
                    const AiChatLogoSection(),
                    const SizedBox(height: 32),
                    // 3 instruction cards
                    _buildInstructionsList(),
                  ],
                ),
              ),
            ),

            // TextField luôn nằm sát bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMessageInput(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsList() {
    final instructions = [
      'Remembers what user said earlier in the conversation',
      'Allows user to provide follow-up corrections with AI',
      'Limited knowledge of world and events after 2021',
    ];

    return Column(
      children: instructions
          .map((instruction) => InstructionCard(instruction: instruction))
          .toList(),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return AiChatMessageInput(
      onSubmitted: (text) {
        if (text.trim().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiChatScreen()),
          );
        }
      },
      onSend: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiChatScreen()),
        );
      },
    );
  }
}
