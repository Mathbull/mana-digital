import 'package:flutter/material.dart';

import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import '/utils/responsive.dart';

class ContentCard extends StatelessWidget {
  final String categoria;
  final IconData? categoriaIcon;
  final String titulo;
  final String descricao;
  final int pontos;
  final int? minutos;
  final String? referencia;
  final String botaoLabel;
  final bool concluida;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.categoria,
    required this.titulo,
    required this.descricao,
    required this.pontos,
    this.categoriaIcon,
    this.minutos,
    this.referencia,
    this.botaoLabel = 'Ler síntese',
    this.concluida = false,
    this.onTap,
  });

  

  
  @override
  Widget build(BuildContext context) {
    // Padding responsivo: menor em telas compactas, maior em tablet
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(),
          SizedBox(height: AppSpacing.s3),

          // Título
         Row(
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

              if (concluida) ...[
                SizedBox(width: AppSpacing.s2),
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 22,
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.s2),

          // Descrição
          Text(
            descricao,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              height: 1.45,
            ),
          ),
          SizedBox(height: AppSpacing.s3),

          _buildFooter(),
        ],
      ),
    );
  }

  // ============================================================
  // LINHA SUPERIOR: categoria + tempo de leitura | XP
  // ============================================================

  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(child: _buildCategoriaChip()),
              if (minutos != null) ...[
                SizedBox(width: AppSpacing.s2),
                const Icon(
                  Icons.schedule,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.s1),
                Text(
                  '$minutos min',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (categoriaIcon != null) ...[
            Icon(categoriaIcon, size: 11, color: AppColors.primary),
            SizedBox(width: AppSpacing.s1),
          ],
          Flexible(
            child: Text(
              categoria.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
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
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
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
  // RODAPÉ: referência | botão
  // ============================================================

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: referencia == null
              ? const SizedBox.shrink()
              : Text(
                  referencia!,
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
        _buildBotao(),
      ],
    );
  }

  Widget _buildBotao() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.border),
    );

    return Material(
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
                botaoLabel,
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
    );
  }
}