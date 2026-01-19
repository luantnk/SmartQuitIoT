import 'package:flutter/material.dart';

class AiChatLogoSection extends StatelessWidget {
  final double width;
  final double height;

  const AiChatLogoSection({super.key, this.width = 150, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset('lib/assets/logo/logo-2.png'),
      ),
    );
  }
}
