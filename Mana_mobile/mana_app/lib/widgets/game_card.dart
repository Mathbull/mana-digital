import 'package:flutter/material.dart';

import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import '/utils/responsive.dart';

class GameCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final int pontos;
  final bool concluido;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.pontos,
    this.concluido = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = Responsive.value(
      context: context,
      compact: AppSpacing.s3,
      normal: AppSpacing.s4,
      large: AppSpacing.s4,
      tablet: AppSpacing.s5,
    );

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(),

          SizedBox(height: AppSpacing.s3),

          _buildTitle(),

          SizedBox(height: AppSpacing.s2),

          _buildDescription(),

          SizedBox(height: AppSpacing.s3),

          _buildFooter(),
        ],
      ),
    );
  }

  // ============================================================
  // LINHA SUPERIOR
  // ============================================================

  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildCategoriaChip(),
            ],
          ),
        ),

        SizedBox(width: AppSpacing.s2),

        _buildXpBadge(),
      ],
    );
  }

  Widget _buildCategoriaChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s0_5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sports_esports_outlined,
            size: 12,
            color: AppColors.primary,
          ),

          SizedBox(width: AppSpacing.s1),

          Text(
            'QUIZ',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s0_5,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        '+$pontos XP',
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          color: AppColors.violet300,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: AppTextStyles.xl.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),

        if (concluido) ...[
          SizedBox(width: AppSpacing.s2),

          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 22,
          ),
        ],
      ],
    );
  }

  // ============================================================
  // DESCRIÇÃO
  // ============================================================

  Widget _buildDescription() {
    return Text(
      descricao,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodySecondary.copyWith(
        fontSize: 13,
        height: 1.45,
      ),
    );
  }

  // ============================================================
  // RODAPÉ
  // ============================================================

  Widget _buildFooter() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(
        color: AppColors.border,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            concluido ? 'Quiz concluído' : 'Teste seus conhecimentos',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textMuted,
              fontFamily: 'monospace',
            ),
          ),
        ),

        SizedBox(width: AppSpacing.s2),

        Material(
          color: AppColors.surfaceElevated,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s3,
                vertical: AppSpacing.s1_5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    concluido ? 'Revisar' : 'Jogar agora',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: AppSpacing.s1),

                  const Icon(
                    Icons.arrow_forward,
                    size: 13,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}