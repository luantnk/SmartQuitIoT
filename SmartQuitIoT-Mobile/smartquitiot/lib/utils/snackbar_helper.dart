import 'package:flutter/material.dart';
class SnackBarHelper {
  SnackBarHelper._();

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.only(bottom: 24, right: 16, left: 16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      backgroundColor: const Color(0xFF00D09E), // Sử dụng màu xanh của bạn
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      // THAY ĐỔI: Chỉnh margin để SnackBar nằm sát cạnh dưới
      margin: const EdgeInsets.only(bottom: 24, right: 16, left: 16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}