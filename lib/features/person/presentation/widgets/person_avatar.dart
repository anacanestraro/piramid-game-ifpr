import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// Círculo com as iniciais da pessoa (ex.: "João Pedro" -> "JP").
class PersonAvatar extends StatelessWidget {
  final String name;
  final double size;

  const PersonAvatar({super.key, required this.name, this.size = 48});

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
      ),
      child: Text(
        _initials,
        style: AppTextStyles.sora(
          fontSize: size * .38,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}