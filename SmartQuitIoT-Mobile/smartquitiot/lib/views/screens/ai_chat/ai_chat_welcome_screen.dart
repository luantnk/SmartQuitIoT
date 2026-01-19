import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ai_chat_welcome_content.dart';

class AiChatWelcomeScreen extends StatelessWidget {
  const AiChatWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E), // Đồng bộ màu header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AiChatWelcomeContent(
            title: 'Welcome to SmartQuit AI',
            subtitle: 'Start chatting with your personal AI assistant',
            buttonText: 'Get Started',
            onButtonPressed: () {
              context.push('/ai-chat');
            },
          ),
        ),
      ),
    );
  }
}
