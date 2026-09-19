import 'package:flutter/material.dart';

import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_shadows.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import '/utils/responsive.dart';

class ContentCard extends StatelessWidget {
  final String categoria;
  final String titulo;
  final String descricao;
  final int pontos;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.categoria,
    required this.titulo,
    required this.descricao,
    required this.pontos,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Padding responsivo: menor em telas compactas, maior em tablet
    final cardPadding = Responsive.value(
      context: context,
      compact: AppSpacing.s2,
      normal: AppSpacing.s3,
      large: AppSpacing.s3,
      tablet: AppSpacing.s4,
    );

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Categoria + pontos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  categoria.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s1),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s1,
                  vertical: AppSpacing.s0_5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '+$pontos XP',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s2),

          // Título
          Text(
            titulo,
            style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.s1),

          // Descrição
          Text(
            descricao,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(fontSize: 11, height: 1.4),
          ),
          SizedBox(height: AppSpacing.s2),

          // Botão
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: AppSpacing.s1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Começar',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppSpacing.s0_5),
                      const Icon(Icons.arrow_forward, size: 12, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}