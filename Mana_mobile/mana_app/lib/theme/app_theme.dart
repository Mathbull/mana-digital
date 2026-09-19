import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    // ==========================================================
    // CORES
    // ==========================================================

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // ==========================================================
    // TIPOGRAFIA
    // ==========================================================

    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.xxxl,
      headlineMedium: AppTextStyles.xxl,
      titleLarge: AppTextStyles.xl,
      titleMedium: AppTextStyles.lg,
      bodyLarge: AppTextStyles.base,
      bodyMedium: AppTextStyles.sm,
      bodySmall: AppTextStyles.xs,
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // ==========================================================
    // CARDS
    // ==========================================================

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
    ),

    // ==========================================================
    // CAMPOS DE TEXTO
    // ==========================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),

      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),

      hintStyle: const TextStyle(
        color: AppColors.textMuted,
      ),
    ),

    // ==========================================================
    // BOTÕES
    // ==========================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,

        minimumSize: const Size(
          0,
          48,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        textStyle: AppTextStyles.button,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
        ),

        elevation: 0,
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,

        minimumSize: const Size(
          0,
          48,
        ),

        side: const BorderSide(
          color: AppColors.primary,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
        ),
      ),
    ),

    // ==========================================================
    // DIVIDERS
    // ==========================================================

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // ==========================================================
    // ICONES
    // ==========================================================

    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: AppTextStyles.sm,
      behavior: SnackBarBehavior.floating,
    ),
  );
}