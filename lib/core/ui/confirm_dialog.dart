import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Diálogo padrão de confirmação. Retorna true só se o usuário confirmar.
class ConfirmDialog {
  ConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: AppColors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    // Fechar o diálogo tocando fora conta como "não confirmou".
    return confirmed ?? false;
  }
}