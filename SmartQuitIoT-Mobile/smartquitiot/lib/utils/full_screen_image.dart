import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String heroTag; // Tag để tạo hiệu ứng animation

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen giống Facebook
      // Nút tắt/back
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: heroTag, // Quan trọng: tag phải trùng với tag ở màn hình trước
          child: InteractiveViewer(
            panEnabled: true, // Cho phép kéo ảnh
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0, // Zoom tối đa 4 lần
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}