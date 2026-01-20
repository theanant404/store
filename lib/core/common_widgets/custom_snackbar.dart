import 'package:flutter/material.dart';

/// Shows a beautiful customized SnackBar at the top of the screen
void showCustomSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.info_outline,
  Color? backgroundColor,
  Color iconColor = Colors.white,
  Color textColor = Colors.white,
  Duration duration = const Duration(seconds: 3),
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final screenHeight = MediaQuery.of(context).size.height;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? colorScheme.primary,
      behavior: behavior,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: duration,
      elevation: 6,
      dismissDirection: DismissDirection.up,
    ),
  );
}

/// Predefined success SnackBar
void showSuccessSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  showCustomSnackBar(
    context,
    message: message,
    icon: Icons.check_circle_outline,
    backgroundColor: Colors.green,
    duration: duration,
  );
}

/// Predefined error SnackBar
void showErrorSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  showCustomSnackBar(
    context,
    message: message,
    icon: Icons.error_outline,
    backgroundColor: Colors.red,
    duration: duration,
  );
}

/// Predefined warning SnackBar
void showWarningSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  showCustomSnackBar(
    context,
    message: message,
    icon: Icons.warning_outlined,
    backgroundColor: Colors.orange,
    duration: duration,
  );
}

/// Predefined info SnackBar
void showInfoSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  final colorScheme = Theme.of(context).colorScheme;
  showCustomSnackBar(
    context,
    message: message,
    icon: Icons.info_outline,
    backgroundColor: colorScheme.primary,
    duration: duration,
  );
}
