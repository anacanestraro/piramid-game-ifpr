import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// Logo + título + subtítulo do topo das telas de autenticação.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textDim = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.green, AppColors.greenDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: .35),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            size: 40,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          style: AppTextStyles.screenTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.jakarta(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textDim,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}