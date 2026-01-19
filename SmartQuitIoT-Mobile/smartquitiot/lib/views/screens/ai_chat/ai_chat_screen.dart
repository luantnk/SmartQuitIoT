import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_message_bubble.dart';
import 'package:SmartQuitIoT/providers/chatbot_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize chatbot when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatbotViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showFlushbar(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red : const Color(0xFF00D09E),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatbotViewModelProvider);

    // Listen for errors
    ref.listen(chatbotViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        _showFlushbar(next.errorMessage!, isError: true);
        ref.read(chatbotViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 40,
          child: Image.asset('lib/assets/logo/logo-2.png', fit: BoxFit.contain),
        ),
        centerTitle: true,
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: chatState.isConnected
                      ? Colors.white
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: chatState.isConnected
                        ? Colors.green[700]!
                        : Colors.orange[700]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: chatState.isConnected
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: chatState.isConnected
                            ? Colors.green[700]
                            : Colors.orange[700],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      chatState.isConnected ? 'Online' : 'Connecting...',
                      style: TextStyle(
                        color: chatState.isConnected
                            ? Colors.green[900]
                            : Colors.orange[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(chatbotViewModelProvider.notifier).reloadHistory();
            },
          ),
        ],
      ),
      body: chatState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: chatState.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation with AI!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 80,
                              ),
                              itemCount: chatState.messages.length,
                              itemBuilder: (context, index) {
                                final message = chatState.messages[index];
                                return AiChatMessageBubble(
                                  text: message.text,
                                  isUser: message.isUser,
                                  time: _formatTime(message.timestamp),
                                  media: message.media,
                                  isLoading: message.isLoading,
                                );
                              },
                            ),
                            // Metrics button (only show when there are messages)
                            //   if (chatState.messages.isNotEmpty)
                            //     // Positioned(
                            //     //   top: 16,
                            //     //   right: 16,
                            //   child: _buildMetricsButton(),
                            // ),
                          ],
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Widget _buildMetricsButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF00D09E),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF00D09E).withOpacity(0.3),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: () {
  //           _sendMetricsRequest();
  //         },
  //         borderRadius: BorderRadius.circular(20),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: const [
  //               Icon(Icons.analytics_outlined, color: Colors.white, size: 18),
  //               SizedBox(width: 6),
  //               Text(
  //                 'Metrics',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _sendMetricsRequest() async {
    if (!ref.read(chatbotViewModelProvider).isConnected) {
      _showFlushbar('Not connected to server. Please wait...', isError: true);
      return;
    }

    try {
      // Send metrics request - backend may expect "Cac chi so" but UI shows "Metrics"
      await ref
          .read(chatbotViewModelProvider.notifier)
          .sendMessage('Cac chi so', null);
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending metrics request: $e');
      _showFlushbar('Failed to request metrics: $e', isError: true);
    }
  }

  Widget _buildMessageInput() {
    final chatState = ref.watch(chatbotViewModelProvider);
    final isSending = chatState.isSending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 150, // Cho phép text field mở rộng khi chat dài
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00D09E),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D09E).withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  enabled: !isSending,
                  maxLines: null, // Cho phép nhiều dòng
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none, // Thêm dòng này
                    focusedBorder: InputBorder.none, // Thêm dòng này
                    filled: false, // Quan trọng: không fill background
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  onSubmitted: (_) {
                    if (_messageController.text.trim().isNotEmpty) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: isSending ? Colors.grey[400] : const Color(0xFF00D09E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D09E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                onPressed: isSending
                    ? null
                    : () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _sendMessage();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (!ref.read(chatbotViewModelProvider).isConnected) {
      _showFlushbar('Not connected to server. Please wait...', isError: true);
      return;
    }

    try {
      // Clear input immediately
      _messageController.clear();

      // Send message via ViewModel (text only, no media)
      await ref.read(chatbotViewModelProvider.notifier).sendMessage(text, null);

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      _showFlushbar('Failed to send message: $e', isError: true);
    }
  }
}
