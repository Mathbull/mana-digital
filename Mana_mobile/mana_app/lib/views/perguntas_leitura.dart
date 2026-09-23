  import 'package:flutter/material.dart';

  import '/models/content_item.dart';
  import '/theme/app_colors.dart';
  import '/theme/app_radius.dart';
  import '/theme/app_spacing.dart';
  import '/theme/app_text_styles.dart';

  

  class QuizPerguntas extends StatefulWidget {
    final String titulo;
    final String sintese;
    final int pontos;
    final List<Pergunta> perguntas;

    /// Texto/ícone do rótulo no topo (ex.: "Trecho Livro", "Trecho Artigo").
    final String rotulo;
    final IconData rotuloIcon;

    final Future<void> Function(Map<String, bool> respostas)? onValidar;

    const QuizPerguntas({
      super.key,
      required this.titulo,
      required this.sintese,
      required this.pontos,
      required this.perguntas,
      this.rotulo = '',
      this.rotuloIcon = Icons.menu_book_outlined,
      this.onValidar,
    });

    /// Atalho para abrir o modal.
    static Future<void> show(
      BuildContext context, {
      required String titulo,
      required String sintese,
      required int pontos,
      required List<Pergunta> perguntas,
      String rotulo = 'Trecho Livro',
      IconData rotuloIcon = Icons.menu_book_outlined,
      Future<void> Function(Map<String, bool> respostas)? onValidar,
    }) {
      return showDialog(
        context: context,
        builder: (_) => QuizPerguntas(
          titulo: titulo,
          sintese: sintese,
          pontos: pontos,
          perguntas: perguntas,
          rotulo: rotulo,
          rotuloIcon: rotuloIcon,
          onValidar: onValidar,
        ),
      );
    }

    @override
    State<QuizPerguntas> createState() =>
        _QuizPerguntasState();
  }

  class _QuizPerguntasState
      extends State<QuizPerguntas> {
    final Map<String, bool> _respostas = {};
    bool _validando = false;
    bool _validado = false;

    bool get _todasRespondidas =>
        widget.perguntas.every((p) => _respostas.containsKey(p.id));

    void _selecionar(String perguntaId, bool valor) {
      if (_validado) return; // já enviado, trava a seleção
      setState(() => _respostas[perguntaId] = valor);
    }

    Future<void> _validar() async {
      setState(() => _validando = true);
      try {
        await widget.onValidar?.call(_respostas);
        if (mounted) setState(() => _validado = true);
      } finally {
        if (mounted) setState(() => _validando = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s6,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.s5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSintese(),
                        const SizedBox(height: AppSpacing.s5),
                        _buildSecaoTitulo(),
                        const SizedBox(height: AppSpacing.s3),
                        for (var i = 0; i < widget.perguntas.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.s3,
                            ),
                            child: _AfirmacaoCard(
                              numero: i + 1,
                              pergunta: widget.perguntas[i],
                              valorSelecionado:
                                  _respostas[widget.perguntas[i].id],
                              mostrarExplicacao: _validado,
                              onSelecionar: (valor) =>
                                  _selecionar(widget.perguntas[i].id, valor),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildRodape(),
              ],
            ),
          ),
        ),
      );
    }

    // ============================================================
    // CABEÇALHO
    // ============================================================

    Widget _buildHeader() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s5,
          AppSpacing.s5,
          AppSpacing.s3,
          AppSpacing.s4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.rotuloIcon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.rotulo.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    widget.titulo,
                    style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
              color: AppColors.textSecondary,
              splashRadius: 20,
            ),
          ],
        ),
      );
    }

    // ============================================================
    // SÍNTESE
    // ============================================================

    Widget _buildSintese() {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s1_5),
                Text(
                  'CONTEÚDO DA SÍNTESE',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              widget.sintese,
              style: AppTextStyles.sm.copyWith(height: 1.6),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // TÍTULO DA SEÇÃO + XP
    // ============================================================

    Widget _buildSecaoTitulo() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validação de Conhecimento',
                  style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.s0_5),
                Text(
                  'Classifique as afirmativas como Verdadeiro ou Falso.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          Container(
            padding: const EdgeInsets.symmetric(
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
              '+${widget.pontos} XP',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.violet300,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      );
    }

    // ============================================================
    // RODAPÉ
    // ============================================================

    Widget _buildRodape() {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Fechar'),
            ),
            const SizedBox(width: AppSpacing.s3),
            ElevatedButton.icon(
              onPressed: (_todasRespondidas && !_validado && !_validando)
                  ? _validar
                  : null,
              icon: _validando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(_validado ? 'Respostas enviadas' : 'Validar Respostas'),
            ),
          ],
        ),
      );
    }
  }

  // ==================================================================
  // CARD DE AFIRMAÇÃO
  // ==================================================================

  class _AfirmacaoCard extends StatelessWidget {
    final int numero;
    final Pergunta pergunta;
    final bool? valorSelecionado;
    final bool mostrarExplicacao;
    final ValueChanged<bool> onSelecionar;

    const _AfirmacaoCard({
      required this.numero,
      required this.pergunta,
      required this.valorSelecionado,
      required this.mostrarExplicacao,
      required this.onSelecionar,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Afirmação $numero',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Fixação de Conceito',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              pergunta.afirmacao,
              style: AppTextStyles.sm.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.s3),
            Row(
              children: [
                Expanded(
                  child: _OpcaoBotao(
                    label: 'Verdadeiro',
                    selecionado: valorSelecionado == true,
                    habilitado: !mostrarExplicacao,
                    onTap: () => onSelecionar(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: _OpcaoBotao(
                    label: 'Falso',
                    selecionado: valorSelecionado == false,
                    habilitado: !mostrarExplicacao,
                    onTap: () => onSelecionar(false),
                  ),
                ),
              ],
            ),
            if (mostrarExplicacao && pergunta.explicacao.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s3),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s1_5),
                    Expanded(
                      child: Text(
                        pergunta.explicacao,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
  }

  class _OpcaoBotao extends StatelessWidget {
    final String label;
    final bool selecionado;
    final bool habilitado;
    final VoidCallback onTap;

    const _OpcaoBotao({
      required this.label,
      required this.selecionado,
      required this.habilitado,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return Material(
        color: selecionado
            ? AppColors.secondary.withValues(alpha: 0.18)
            : AppColors.surfaceElevated,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selecionado ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: habilitado ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: habilitado
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }