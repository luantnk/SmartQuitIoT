import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static void showTopNotification(
      BuildContext context, {
        required String title,
        required String message,
        bool isError = false,
        Color? customColor,
      }) {

    final Color notificationColor = customColor ?? (isError ? Colors.red.shade600 : Color(0xFF00D09E));
    final IconData notificationIcon = isError ? Icons.error_outline : Icons.check_circle_outline;

    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: notificationColor,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        notificationIcon,
        size: 28.0,
        color: Colors.white,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 3,
        ),
      ],
    ).show(context);
  }
}