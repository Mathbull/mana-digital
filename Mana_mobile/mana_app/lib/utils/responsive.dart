import 'package:flutter/material.dart';

class Responsive {
  /// Largura disponível da tela.
  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  /// Altura disponível da tela.
  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  // ============================================================
  // BREAKPOINTS MOBILE
  // ============================================================

  /// Celulares muito pequenos.
  ///
  /// Aproximadamente:
  /// 320 - 359 px
  static bool isCompact(BuildContext context) {
    return width(context) < 360;
  }

  /// Celulares comuns.
  ///
  /// Aproximadamente:
  /// 360 - 411 px
  static bool isNormal(BuildContext context) {
    final width = Responsive.width(context);

    return width >= 360 && width < 412;
  }


  static bool isLarge(BuildContext context) {
    return width(context) >= 412 && width(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= 600;
  }

  // ============================================================
  // LAYOUT
  // ============================================================

  /// Retorna um valor diferente dependendo da largura.
  static double value({
    required BuildContext context,
    required double compact,
    required double normal,
    required double large,
    required double tablet,
  }) {
    if (isCompact(context)) {
      return compact;
    }

    if (isLarge(context)) {
      return large;
    }

    if (isNormal(context)) {
      return normal;
    }

    return tablet;
  }
}