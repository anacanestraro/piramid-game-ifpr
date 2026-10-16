import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// Campo de texto ligado a um Signal<String> da ViewModel.
// O valor inicial é lido uma vez; para recarregar (ex.: ao editar),
// a tela recria o campo trocando a Key.
class SignalTextField extends StatelessWidget {
  final Signal<String> signal;
  final String hint;
  final IconData icon;

  const SignalTextField({
    super.key,
    required this.signal,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      // peek(): lê o valor sem "assinar" o signal.
      initialValue: signal.peek(),
      onChanged: (value) => signal.value = value,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(theme.dividerColor, 1.5),
        enabledBorder: border(theme.dividerColor, 1.5),
        focusedBorder: border(AppColors.green, 1.8),
      ),
    );
  }
}