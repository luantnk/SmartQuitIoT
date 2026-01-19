// components/connect_button.dart
import 'package:flutter/material.dart';

class ConnectButton extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final AnimationController animationController;
  final VoidCallback onPressed;

  const ConnectButton({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.animationController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isConnected || isConnecting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected
              ? Colors.grey[400]
              :  Color(0xFF00D09E),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isConnected ? 0 : 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isConnecting) ...[
              RotationTransition(
                turns: animationController,
                child: Icon(
                  Icons.sync,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
            ] else if (isConnected) ...[
              Icon(
                Icons.check_circle,
                size: 20,
              ),
              SizedBox(width: 12),
            ] else ...[
              Icon(
                Icons.add,
                size: 20,
              ),
              SizedBox(width: 12),
            ],
            Text(
              isConnecting
                  ? 'Connecting...'
                  : isConnected
                  ? 'Connected to IoT device'
                  : 'Connect IoT device',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}