import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const AppLayout({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(
      context: context,
      compact: AppSpacing.s3,
      normal: AppSpacing.s4,
      large: AppSpacing.s6, 
      tablet: AppSpacing.s8,
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: child,
    );

    return SafeArea(
      child: scrollable
          ? SingleChildScrollView(
              child: content,
            )
          : content,
    );
  }
}