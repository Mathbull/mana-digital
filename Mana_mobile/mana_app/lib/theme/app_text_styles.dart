import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {

  // ------------------------------------------------------------
  // text-xs
  // 12px
  // ------------------------------------------------------------

  static const TextStyle xs = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-sm
  // 14px
  // ------------------------------------------------------------

  static const TextStyle sm = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-base
  // 16px
  // ------------------------------------------------------------

  static const TextStyle base = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-lg
  // 18px
  // ------------------------------------------------------------

  static const TextStyle lg = TextStyle(
    fontSize: 18,
    height: 1.56,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-xl
  // 20px
  // ------------------------------------------------------------

  static const TextStyle xl = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-2xl
  // 24px
  // ------------------------------------------------------------

  static const TextStyle xxl = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-3xl
  // 30px
  // ------------------------------------------------------------

  static const TextStyle xxxl = TextStyle(
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------
  // text-4xl
  // 36px
  // ------------------------------------------------------------

  static const TextStyle display = TextStyle(
    fontSize: 36,
    height: 1.11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ============================================================
  // VARIAÇÕES SEMÂNTICAS
  // ============================================================

  /// Título principal de uma página.
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Título de uma seção.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Texto normal.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Texto secundário.
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Texto pequeno para informações auxiliares.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Texto de botões.
  static const TextStyle button = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Texto para valores importantes, como XP ou pontuação.
  static const TextStyle value = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}