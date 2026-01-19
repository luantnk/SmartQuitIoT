import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/models/chat_message.dart';

class AiChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;
  final List<ChatMessageMedia>? media;
  final bool isLoading;

  const AiChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
    this.media,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00D09E),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'AI is typing...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        : _buildFormattedText(),
                  ),
                  if (media != null && media!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildMediaPreview(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (isUser) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (media != null && media!.isNotEmpty) ...[
                    _buildMediaPreview(),
                    const SizedBox(height: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedText() {
    // Simple markdown parsing for bold (**text**) and bullet points
    final textSpans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if it's a bullet point
      if (line.trim().startsWith('*   ') || line.trim().startsWith('- ')) {
        final bulletText = line.replaceFirst(RegExp(r'^[\*\-\s]+'), '');
        final spans = _parseMarkdown(bulletText);
        textSpans.addAll([
          const TextSpan(
            text: '• ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...spans,
        ]);
      } else {
        final spans = _parseMarkdown(line);
        textSpans.addAll(spans);
      }

      // Add newline except for last line
      if (i < lines.length - 1) {
        textSpans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.5),
        children: textSpans,
      ),
    );
  }

  List<TextSpan> _parseMarkdown(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    // If no markdown found, return the whole text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  Widget _buildMediaPreview() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: media!.map((mediaItem) {
        if (mediaItem.isImage) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              mediaItem.mediaUrl,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          );
        } else {
          // Video
          return Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  size: 50,
                  color: Colors.white,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'VIDEO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }).toList(),
    );
  }
}
