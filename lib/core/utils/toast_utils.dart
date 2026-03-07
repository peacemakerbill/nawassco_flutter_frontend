import 'package:flutter/material.dart';
import 'package:nawassco/main.dart'; // <-- path to scaffoldMessengerKey

class ToastUtils {
  static void showSuccessToast(
      String message, {
        GlobalKey<ScaffoldMessengerState>? key,
      }) {
    _show(message, Colors.green, Icons.check_circle, key);
  }

  static void showErrorToast(
      String message, {
        GlobalKey<ScaffoldMessengerState>? key,
      }) {
    _show(message, Colors.red, Icons.error, key);
  }

  static void showInfoToast(
      String message, {
        GlobalKey<ScaffoldMessengerState>? key,
      }) {
    _show(message, Colors.blue, Icons.info, key);
  }

  static void showWarningToast(
      String message, {
        GlobalKey<ScaffoldMessengerState>? key,
      }) {
    _show(message, Colors.orange, Icons.warning, key);
  }

  static void _show(
      String message,
      Color color,
      IconData icon,
      GlobalKey<ScaffoldMessengerState>? key,
      ) {
    final messenger = key?.currentState ??
        ScaffoldMessenger.of(scaffoldMessengerKey.currentContext!);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }
}