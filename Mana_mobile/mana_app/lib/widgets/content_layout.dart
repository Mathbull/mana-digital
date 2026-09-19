import 'package:flutter/material.dart';
import '/models/content_item.dart';

import '/widgets/content_card.dart';
import '/theme/app_colors.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import 'app_layout.dart';

class ContentPageLayout extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icon;
  final List<ContentItem> contents;

  const ContentPageLayout({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayout(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,  
          children: [
            // Cabeçalho
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: AppTextStyles.pageTitle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s1),
                      Text(
                        descricao,
                        style: AppTextStyles.caption.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s4),
            // Lista de conteúdos
            ...contents.map(
              (content) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.s2),
                child: ContentCard(
                  categoria: content.categoria,
                  titulo: content.titulo,
                  descricao: content.descricao,
                  pontos: content.pontos,
                  onTap: () {
                    // Futuramente abrir conteúdo
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}