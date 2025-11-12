import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showCustomSnackbar({
  required BuildContext context,
  required String message,
  required String lottiePath,
  Color backgroundColor = Colors.white,
  Color textColor = Colors.black,
  String? actionLabel,
  VoidCallback? onActionPressed,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: duration,
      content: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Lottie.asset(lottiePath, repeat: false, fit: BoxFit.contain),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      action:
          (actionLabel != null && onActionPressed != null)
              ? SnackBarAction(
                label: actionLabel!,
                textColor: textColor,
                onPressed: onActionPressed!,
              )
              : null,
    ),
  );
}
