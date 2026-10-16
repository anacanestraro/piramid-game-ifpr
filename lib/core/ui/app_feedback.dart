import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Mensagens rápidas (SnackBar) padronizadas para o app inteiro.
class AppFeedback {
  AppFeedback._();

  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.red);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.green);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}