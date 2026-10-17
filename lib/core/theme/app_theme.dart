import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Identidade visual do app (arquivo próprio de tema, seção 2 da spec).
class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        bg: AppColors.lightBg,
        surface: AppColors.lightSurface,
        text: AppColors.lightText,
        textDim: AppColors.lightTextDim,
        border: AppColors.lightBorder,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        textDim: AppColors.darkTextDim,
        border: AppColors.darkBorder,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textDim,
    required Color border,
  }) {
    final base = ThemeData(brightness: brightness);
    final isDark = brightness == Brightness.dark;
    final greenSoft = AppColors.green.withValues(alpha: isDark ? .25 : .12);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: AppColors.green,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        secondaryContainer: greenSoft,
        onSecondaryContainer: AppColors.green,
        tertiary: AppColors.green,
        tertiaryContainer: greenSoft,
        onTertiaryContainer: AppColors.green,
        error: AppColors.red,
        surface: surface,
        onSurface: text,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      dividerColor: border,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: greenSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.green : textDim,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.green : textDim,
          );
        }),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        headerBackgroundColor: AppColors.green,
        headerForegroundColor: Colors.white,
        todayBorder: const BorderSide(color: AppColors.green),
        dayOverlayColor: WidgetStateProperty.all(
          AppColors.green.withValues(alpha: .1),
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.green;
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return text;
        }),
        yearOverlayColor: WidgetStateProperty.all(
          AppColors.green.withValues(alpha: .1),
        ),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.green;
          return null;
        }),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return text;
        }),
      ),
    );
  }
}