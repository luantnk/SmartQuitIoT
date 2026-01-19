import 'package:flutter/material.dart';

/// MessageInput
/// - Accepts optional [controller] and [focusNode] so parent can control scrolling/focus.
/// - If parent doesn't provide controller/focusNode, this widget creates and disposes them.
/// - Disables send button when input is empty.
/// - Keeps visual style consistent with the app.
class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;

  const MessageInput({
    super.key,
    required this.onSend,
    this.controller,
    this.focusNode,
    this.hintText = 'Type your message...',
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _canSend = false;

  TextEditingController get _controller => widget.controller ?? _internalController;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _internalController = TextEditingController();
      _ownsController = true;
    } else {
      _internalController = widget.controller!;
    }

    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _internalFocusNode = widget.focusNode!;
    }

    _controller.addListener(_onTextChanged);
    _onTextChanged(); // init _canSend
  }

  void _onTextChanged() {
    final can = _controller.text.trim().isNotEmpty;
    if (can != _canSend) {
      setState(() => _canSend = can);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _internalController.dispose();
    }
    if (_ownsFocusNode) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF00D09E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF00D09E), width: 2),
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _canSend ? _handleSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _canSend ? const Color(0xFF00D09E) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: _canSend ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
