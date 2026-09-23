import 'package:flutter/material.dart';

import '/models/content_item.dart';
import 'leitura_card.dart';
import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import 'app_layout.dart';

class ContentPageLayout extends StatefulWidget {
  final String titulo;
  final String descricao;
  final IconData icon;

  /// Texto pequeno acima do título. Ex: "Módulo regulatório · Trilha XP".
  final String? etiqueta;

  /// Filtros exibidos como chips (o "Todos" é adicionado automaticamente).
  /// Cada [ContentItem.filtro] deve bater com um destes valores.
  final List<String> filtros;

  final List<ContentItem> contents;

  final Future<void> Function(ContentItem content)? onContentTap;

  const ContentPageLayout({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.contents,
    this.etiqueta,
    this.filtros = const [],
    this.onContentTap,
  });

  @override
  State<ContentPageLayout> createState() => _ContentPageLayoutState();
}

class _ContentPageLayoutState extends State<ContentPageLayout> {
  static const String _todos = 'Todos';

  String _filtroAtivo = _todos;

  List<ContentItem> get _conteudosVisiveis {
    if (_filtroAtivo == _todos) return widget.contents;
    return widget.contents.where((c) => c.filtro == _filtroAtivo).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayout(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.s4),
            _buildHeader(),
            if (widget.filtros.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s4),
              _buildFiltros(),
            ],
            SizedBox(height: AppSpacing.s5),

            // Lista de conteúdos
            ..._conteudosVisiveis.map(
              (content) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.s4),
                child: ContentCard(
                  categoria: content.categoria,
                  titulo: content.titulo,
                  descricao: content.descricao,
                  pontos: content.pontos,
                  minutos: content.tempoLeitura,
                  referencia: content.referencia,
                  concluida: content.concluida,
                  botaoLabel: content.concluida
                    ? 'Concluída'
                    : 'Ler síntese',
                  onTap: () => widget.onContentTap?.call(content),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s4),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CABEÇALHO
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, color: AppColors.primary, size: 14),
            if (widget.etiqueta != null) ...[
              SizedBox(width: AppSpacing.s1_5),
              Flexible(
                child: Text(
                  widget.etiqueta!.toUpperCase(),
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
          ],
        ),
        SizedBox(height: AppSpacing.s1_5),
        Text(
          widget.titulo,
          style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.s1),
        Text(
          widget.descricao,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTROS (chips com scroll horizontal)
  // ============================================================

  Widget _buildFiltros() {
    final opcoes = [_todos, ...widget.filtros];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filtro in opcoes)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.s2),
              child: _FiltroChip(
                label: filtro,
                selecionado: filtro == _filtroAtivo,
                onTap: () => setState(() => _filtroAtivo = filtro),
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
      side: BorderSide(
        color: selecionado ? AppColors.secondary : AppColors.border,
      ),
    );

    return Material(
      color: selecionado
          ? AppColors.secondary.withValues(alpha: 0.2)
          : Colors.transparent,
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
              if (selecionado) ...[
                const Icon(
                  Icons.filter_alt_outlined,
                  size: 14,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: AppSpacing.s1),
              ],
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selecionado
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}