import 'dart:convert';

import 'package:flutter/material.dart';

import '/models/game_details.dart';
import '/models/game_perguntas.dart';
import '/widgets/app_layout.dart';
import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import '/utils/responsive.dart';
import '/services/auth_service.dart';

class QuizScreen extends StatefulWidget {
  final GameDetails jogo;
  final Future<void> Function(int novoTotalXp)? onXpAtualizado;

  const QuizScreen({
    super.key,
    required this.jogo,
    this.onXpAtualizado,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int perguntaAtual = 0;

  bool respondida = false;
  bool enviando = false;

  String? opcaoSelecionada;

  final Map<String, String> respostasSelecionadas = {};

  GameQuestion get pergunta => widget.jogo.perguntas[perguntaAtual];

  int get totalPerguntas => widget.jogo.perguntas.length;

  bool get ultimaPergunta => perguntaAtual == totalPerguntas - 1;

  // ------------------------------------------------------------
  // SELECIONAR RESPOSTA
  // ------------------------------------------------------------

  void _selecionarOpcao(String respostaId) {
    if (respondida || enviando) return;

    setState(() {
      opcaoSelecionada = respostaId;
    });
  }

  // ------------------------------------------------------------
  // CONFIRMAR RESPOSTA
  // ------------------------------------------------------------

  void _confirmarResposta() {
    if (opcaoSelecionada == null || respondida) return;

    setState(() {
      respostasSelecionadas[pergunta.id] = opcaoSelecionada!;
      respondida = true;
    });
  }

  // ------------------------------------------------------------
  // PRÓXIMA PERGUNTA
  // ------------------------------------------------------------

  void _proximaPergunta() {
    if (ultimaPergunta) {
      _finalizarJogo();
      return;
    }

    setState(() {
      perguntaAtual++;
      opcaoSelecionada = null;
      respondida = false;
    });
  }

  // ------------------------------------------------------------
  // FINALIZAR JOGO
  // ------------------------------------------------------------

  Future<void> _finalizarJogo() async {
    if (enviando) return;

    setState(() {
      enviando = true;
    });

    try {
      final response = await ApiService.finalizarJogo(
        gameId: widget.jogo.id,
        respostasSelecionadas: respostasSelecionadas,
      );

      if (!mounted) return;

      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final int acertos = _toInt(data['acertos']);
        final int pontosGanhos = _toInt(data['pontosGanhos']);
        final int novoTotalXp = _toInt(data['novoTotalXp']);

        await widget.onXpAtualizado?.call(novoTotalXp);

        if (!mounted) return;

        await _mostrarResultado(
          acertos: acertos,
          pontosGanhos: pontosGanhos,
        );
      } else {
        final mensagem =
            data['message']?.toString() ??
            'Não foi possível finalizar o quiz.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro de conexão ao finalizar o quiz.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ------------------------------------------------------------
  // RESULTADO
  // ------------------------------------------------------------

  Future<void> _mostrarResultado({
    required int acertos,
    required int pontosGanhos,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Quiz finalizado!',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$acertos/$totalPerguntas acertos',
                style: AppTextStyles.lg,
              ),
              const SizedBox(height: AppSpacing.s3),
              Text(
                '+$pontosGanhos XP',
                style: AppTextStyles.xl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Concluir',
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Proteção contra jogo sem perguntas.
    if (totalPerguntas == 0) {
      return AppLayout(
        scrollable: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  'Este jogo ainda não possui perguntas.',
                  style: AppTextStyles.lg,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppLayout(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),

            const SizedBox(
              height: AppSpacing.s4,
            ),

            Responsive.isTablet(context)
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildQuestionCard(),
                        ),

                        const SizedBox(
                          width: AppSpacing.s4,
                        ),

                        Expanded(
                          child: _buildScoreCard(),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      _buildQuestionCard(),

                      const SizedBox(
                        height: AppSpacing.s4,
                      ),

                      _buildScoreCard(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CABEÇALHO
  // ------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.s4,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.lg,
                ),
              ),
              child: const Icon(
                Icons.psychology_alt_outlined,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(
              width: AppSpacing.s3,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment:
                        WrapCrossAlignment.center,
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s1,
                    children: [
                      Text(
                        'Questão ${perguntaAtual + 1} de $totalPerguntas',
                        style:
                            AppTextStyles.sectionTitle,
                      ),

                      _buildChip(
                        'Quiz',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.s1,
                  ),

                  Text(
                    widget.jogo.titulo,
                    style:
                        AppTextStyles.bodySecondary,
                  ),

                  const SizedBox(
                    height: AppSpacing.s3,
                  ),

                  _buildProgressDots(),
                ],
              ),
            ),

            const SizedBox(
              width: AppSpacing.s3,
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(
                      width: AppSpacing.s1,
                    ),
                    Text(
                      'RECOMPENSA TOTAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.s1,
                ),

                Text(
                  '+${widget.jogo.pontosTotal} XP',
                  style: AppTextStyles.value,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROGRESSO
  // ------------------------------------------------------------

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(
        totalPerguntas,
        (index) {
          final ativo = index <= perguntaAtual;

          return Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.s1,
            ),
            child: Container(
              height: 6,
              width: index == perguntaAtual
                  ? 28
                  : 16,
              decoration: BoxDecoration(
                color: ativo
                    ? AppColors.secondary
                    : AppColors.border,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.full,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // CARD DA PERGUNTA
  // ------------------------------------------------------------

  Widget _buildQuestionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.s5,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),

                const SizedBox(
                  width: AppSpacing.s1_5,
                ),

                Text(
                  'PERGUNTA ${pergunta.ordem}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.s3,
            ),

            Text(
              pergunta.pergunta,
              style: AppTextStyles.xl,
            ),

            const SizedBox(
              height: AppSpacing.s5,
            ),

            for (
              var i = 0;
              i < pergunta.respostas.length;
              i++
            ) ...[
              _buildOpcao(i),

              if (
                i !=
                pergunta.respostas.length - 1
              )
                const SizedBox(
                  height: AppSpacing.s3,
                ),
            ],

            const SizedBox(
              height: AppSpacing.s5,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviando
                    ? null
                    : !respondida
                        ? (
                            opcaoSelecionada != null
                                ? _confirmarResposta
                                : null
                          )
                        : _proximaPergunta,
                child: Text(
                  !respondida
                      ? 'Confirmar resposta'
                      : ultimaPergunta
                          ? 'Finalizar quiz'
                          : 'Próxima pergunta',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // OPÇÃO
  // ------------------------------------------------------------

  Widget _buildOpcao(int index) {
    final resposta =
        pergunta.respostas[index];

    final selecionada =
        opcaoSelecionada == resposta.id;

    Color borderColor =
        AppColors.border;

    Color background =
        AppColors.surface;

    IconData icone = selecionada
        ? Icons.radio_button_checked
        : Icons.radio_button_unchecked;

    Color iconeCor =
        AppColors.textMuted;

    if (respondida && selecionada) {
      borderColor = AppColors.primary;

      background =
          AppColors.primary;

      icone =
          Icons.check_circle_outline;

      iconeCor =
          AppColors.primary;
    } else if (selecionada) {
      borderColor = AppColors.primary;
      background = AppColors.primary;
      iconeCor = AppColors.primary;
          }

    return InkWell(
      onTap: respondida
          ? null
          : () => _selecionarOpcao(
                resposta.id,
              ),
      borderRadius:
          BorderRadius.circular(
        AppRadius.lg,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(
          AppSpacing.s3_5,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius:
              BorderRadius.circular(
            AppRadius.lg,
          ),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surfaceElevated,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
              child: Text(
                String.fromCharCode(
                  65 + index,
                ),
                style:
                    AppTextStyles.sm.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(
              width: AppSpacing.s3,
            ),

            Expanded(
              child: Text(
                resposta.resposta,
                style:
                    AppTextStyles.base,
              ),
            ),

            const SizedBox(
              width: AppSpacing.s2,
            ),

            Icon(
              icone,
              color: iconeCor,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CARD DO PLACAR
  // ------------------------------------------------------------

  Widget _buildScoreCard() {
    final progresso =
        totalPerguntas == 0
            ? 0.0
            : respostasSelecionadas.length /
                totalPerguntas;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.s5,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),

                const SizedBox(
                  width: AppSpacing.s1_5,
                ),

                Expanded(
                  child: Text(
                    'Progresso da Rodada',
                    style:
                        AppTextStyles.lg,
                  ),
                ),

                _buildChip(
                  '${respostasSelecionadas.length}/$totalPerguntas',
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.s4,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                AppSpacing.s4,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surfaceElevated,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.lg,
                ),
                border: Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        'PROGRESSO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color: AppColors
                              .textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),

                      _buildChip(
                        respondida
                            ? 'RESPONDIDA'
                            : 'RODADA ATIVA',
                        highlighted:
                            true,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.s2,
                  ),

                  Text(
                    '${respostasSelecionadas.length} / $totalPerguntas',
                    style:
                        AppTextStyles.display,
                  ),

                  const SizedBox(
                    height: AppSpacing.s2,
                  ),

                  Text(
                    'Perguntas respondidas',
                    style:
                        AppTextStyles.caption,
                  ),

                  const SizedBox(
                    height: AppSpacing.s3,
                  ),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.full,
                    ),
                    child:
                        LinearProgressIndicator(
                      value: progresso.clamp(
                        0.0,
                        1.0,
                      ),
                      minHeight: 6,
                      backgroundColor:
                          AppColors.border,
                      valueColor:
                          const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.s2,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        '${respostasSelecionadas.length} respondidas',
                        style:
                            AppTextStyles.caption,
                      ),

                      Text(
                        'Meta: ${widget.jogo.pontosTotal} XP',
                        style:
                            AppTextStyles.caption
                                .copyWith(
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CHIP
  // ------------------------------------------------------------

  Widget _buildChip(
    String texto, {
    bool highlighted = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            AppSpacing.s2_5,
        vertical:
            AppSpacing.s0_5,
      ),
      decoration:
          BoxDecoration(
        color: highlighted
            ? AppColors.primary
            : AppColors.surfaceElevated,
        borderRadius:
            BorderRadius.circular(
          AppRadius.full,
        ),
        border: Border.all(
          color: highlighted
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          letterSpacing: 0.5,
          color: highlighted
              ? AppColors.primary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}