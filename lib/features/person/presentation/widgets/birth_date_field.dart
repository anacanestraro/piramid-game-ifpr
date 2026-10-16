import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_date_format.dart';

// Campo que mostra a data escolhida e abre o DatePicker ao tocar.
class BirthDateField extends StatelessWidget {
  final Signal<DateTime?> signal;
  final VoidCallback onTap;

  const BirthDateField({super.key, required this.signal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SignalBuilder(
      builder: (context) {
        final date = signal.value;

        return Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.dividerColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    date == null
                        ? 'Selecionar data'
                        : AppDateFormat.short(date),
                    style: AppTextStyles.jakarta(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: date == null
                          ? theme.colorScheme.onSurface.withValues(alpha: .5)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}