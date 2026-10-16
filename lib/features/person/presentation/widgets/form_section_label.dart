import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

// Título pequeno que separa as seções de um formulário.
class FormSectionLabel extends StatelessWidget {
  final String text;

  const FormSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.jakarta(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}