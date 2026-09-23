import 'package:flutter/material.dart';

import '/models/iniciativa.dart';
import '/services/auth_service.dart';
import '/widgets/app_layout.dart';
import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';

// ============================================================
// MODELOS VISUAIS DA TELA
//
// O model real das submissões é Iniciativa, vindo da API.
// Estes modelos abaixo existem apenas para representar as
// oportunidades fixas e a seção de atividade da comunidade.
// ============================================================

enum TipoOportunidade { leitura, indicacao, linkedin }

class Oportunidade {
  final TipoOportunidade tipo;
  final String titulo;
  final String descricao;
  final int xp;

  const Oportunidade({
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.xp,
  });
}

class AtividadeComunidade {
  final String nome;
  final String detalhe;
  final String tempoAtras;
  final int xp;

  const AtividadeComunidade({
    required this.nome,
    required this.detalhe,
    required this.tempoAtras,
    required this.xp,
  });
}

class IniciativasScreen extends StatefulWidget {
  final List<Oportunidade> oportunidades;
  final List<AtividadeComunidade> atividadesComunidade;

  const IniciativasScreen({
    super.key,
    this.oportunidades = const [
      Oportunidade(
        tipo: TipoOportunidade.leitura,
        titulo: 'Compartilhar Leitura Antirracista',
        descricao: 'Reflita e compartilhe uma leitura antirracista.',
        xp: 60,
      ),
      Oportunidade(
        tipo: TipoOportunidade.indicacao,
        titulo: 'Indicar um Colega de Trabalho',
        descricao: 'Amplie a rede engajada com equidade.',
        xp: 30,
      ),
      Oportunidade(
        tipo: TipoOportunidade.linkedin,
        titulo: 'Multiplicador no LinkedIn',
        descricao: 'Compartilhe iniciativas no LinkedIn.',
        xp: 50,
      ),
    ],
    this.atividadesComunidade = const [],
  });

  @override
  State<IniciativasScreen> createState() => _IniciativasScreenState();
}

class _IniciativasScreenState extends State<IniciativasScreen> {
  bool submissoesExpandido = true;

  late Future<List<Iniciativa>> _iniciativasFuture;

  bool _enviandoConvite = false;
  bool _enviandoLinkedin = false;
  bool _enviandoLeitura = false;

  final _colegaController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _iniciativasFuture = ApiService.fetchIniciativas();
  }

  @override
  void dispose() {
    _colegaController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _recarregarIniciativas() async {
    final future = ApiService.fetchIniciativas();

    setState(() {
      _iniciativasFuture = future;
    });

    await future;
  }

  void _mostrarMensagem(
    String mensagem, {
    bool erro = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? AppColors.error : AppColors.success,
      ),
    );
  }

  String _mensagemErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  // ============================================================
  // ENVIOS PARA A API
  // ============================================================

  Future<void> _enviarConvite() async {
    final email = _colegaController.text.trim();

    if (email.isEmpty) {
      _mostrarMensagem(
        'Informe o e-mail do colega.',
        erro: true,
      );
      return;
    }

    setState(() {
      _enviandoConvite = true;
    });

    try {
      await ApiService.enviarIniciativa(
        tipo: 'convite',
        emailIndicado: email,
      );

      _colegaController.clear();
      await _recarregarIniciativas();

      _mostrarMensagem(
        'Indicação enviada para análise.',
      );
    } catch (e) {
      _mostrarMensagem(
        _mensagemErro(e),
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoConvite = false;
        });
      }
    }
  }

  Future<void> _enviarLinkedin() async {
    final link = _linkedinController.text.trim();

    if (link.isEmpty) {
      _mostrarMensagem(
        'Informe o link da publicação.',
        erro: true,
      );
      return;
    }

    final uri = Uri.tryParse(link);

    if (uri == null ||
        !uri.hasScheme ||
        !(uri.scheme == 'http' || uri.scheme == 'https')) {
      _mostrarMensagem(
        'Informe um link válido.',
        erro: true,
      );
      return;
    }

    setState(() {
      _enviandoLinkedin = true;
    });

    try {
      await ApiService.enviarIniciativa(
        tipo: 'linkedin',
        anexoUrl: link,
      );

      _linkedinController.clear();
      await _recarregarIniciativas();

      _mostrarMensagem(
        'Publicação enviada para análise.',
      );
    } catch (e) {
      _mostrarMensagem(
        _mensagemErro(e),
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoLinkedin = false;
        });
      }
    }
  }

  Future<void> _abrirFormularioLeitura() async {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final anexoController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Compartilhar leitura',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título da obra',
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.s3,
                ),

                TextField(
                  controller: descricaoController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Sua reflexão',
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.s3,
                ),

                TextField(
                  controller: anexoController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Link ou anexo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () async {
                final titulo =
                    tituloController.text.trim();

                final descricao =
                    descricaoController.text.trim();

                final anexo =
                    anexoController.text.trim();

                if (titulo.isEmpty) {
                  return;
                }

                if (descricao.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);

                await _enviarLeitura(
                  titulo: titulo,
                  descricao: descricao,
                  anexoUrl:
                      anexo.isEmpty ? null : anexo,
                );
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarLeitura({
    required String titulo,
    required String descricao,
    String? anexoUrl,
  }) async {
    if (_enviandoLeitura) return;

    setState(() {
      _enviandoLeitura = true;
    });

    try {
      await ApiService.enviarIniciativa(
        tipo: 'livro_resumo',
        titulo: titulo,
        descricao: descricao,
        anexoUrl: anexoUrl?.isNotEmpty == true ? anexoUrl : null,
      );

      await _recarregarIniciativas();

      _mostrarMensagem(
        'Leitura enviada para análise.',
      );
    } catch (e) {
      _mostrarMensagem(
        _mensagemErro(e),
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoLeitura = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciativas e Ações Práticas',
              style: AppTextStyles.pageTitle,
            ),
            const SizedBox(height: AppSpacing.s1_5),
            Text(
              'Coloque em prática ações antirracistas no seu dia a dia e '
              'ganhe XP compartilhando iniciativas com validação de impacto.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.s6),

            // ==================================================
            // OPORTUNIDADES
            // ==================================================

            _buildSectionHeader(
              'Oportunidades Ativas',
              chip: '${widget.oportunidades.length} Disponíveis',
            ),
            const SizedBox(height: AppSpacing.s3),

            for (final oportunidade in widget.oportunidades) ...[
              _buildOportunidadeCard(oportunidade),
              const SizedBox(height: AppSpacing.s3),
            ],

            const SizedBox(height: AppSpacing.s3),

            // ==================================================
            // MINHAS SUBMISSÕES
            // ==================================================

            _buildSubmissoesHeader(),

            if (submissoesExpandido) ...[
              const SizedBox(height: AppSpacing.s3),
              _buildMinhasSubmissoes(),
            ],

            // ==================================================
            // ATIVIDADE DA COMUNIDADE
            // ==================================================

            const SizedBox(height: AppSpacing.s6),
            _buildSectionHeader('Atividades Recentes da Comunidade'),
            const SizedBox(height: AppSpacing.s3),

            if (widget.atividadesComunidade.isEmpty)
              _buildVazio(
                'Nenhuma atividade recente por aqui ainda.',
              )
            else
              for (final atividade in widget.atividadesComunidade) ...[
                _buildAtividadeTile(atividade),
                const SizedBox(height: AppSpacing.s2),
              ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CABEÇALHOS DE SEÇÃO
  // ------------------------------------------------------------

  Widget _buildSectionHeader(
    String titulo, {
    String? chip,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        if (chip != null)
          _buildChip(
            chip,
            highlighted: true,
          ),
      ],
    );
  }

  Widget _buildSubmissoesHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          submissoesExpandido = !submissoesExpandido;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Minhas Submissões',
              style: AppTextStyles.sectionTitle,
            ),
          ),
          Icon(
            submissoesExpandido
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // OPORTUNIDADES
  // ------------------------------------------------------------

  Widget _buildOportunidadeCard(
    Oportunidade oportunidade,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _iconePara(oportunidade.tipo),
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        oportunidade.titulo,
                        style: AppTextStyles.lg,
                      ),
                      const SizedBox(height: AppSpacing.s0_5),
                      Text(
                        oportunidade.descricao,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                _buildChip(
                  '+${oportunidade.xp} XP',
                  highlighted: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            ..._buildAcaoOportunidade(oportunidade),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAcaoOportunidade(
    Oportunidade oportunidade,
  ) {
    switch (oportunidade.tipo) {
      case TipoOportunidade.leitura:
        return [
          Row(
            children: [
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: ElevatedButton(
                  onPressed: _enviandoLeitura
                      ? null
                      : _abrirFormularioLeitura,
                  child: Text(
                    _enviandoLeitura
                        ? 'Enviando...'
                        : 'Enviar Resposta',
                  ),
                ),
              ),
            ],
          ),
        ];

      case TipoOportunidade.indicacao:
        return [
          TextField(
            controller: _colegaController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'nome@empresa.com.br',
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enviandoConvite
                  ? null
                  : _enviarConvite,
              child: Text(
                _enviandoConvite
                    ? 'Enviando...'
                    : 'Enviar Convite',
              ),
            ),
          ),
        ];

      case TipoOportunidade.linkedin:
        return [
          TextField(
            controller: _linkedinController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'Cole o link aqui',
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enviandoLinkedin
                  ? null
                  : _enviarLinkedin,
              child: Text(
                _enviandoLinkedin
                    ? 'Enviando...'
                    : 'Validar Post',
              ),
            ),
          ),
        ];
    }
  }

  IconData _iconePara(TipoOportunidade tipo) {
    switch (tipo) {
      case TipoOportunidade.leitura:
        return Icons.menu_book_outlined;
      case TipoOportunidade.indicacao:
        return Icons.person_add_alt_outlined;
      case TipoOportunidade.linkedin:
        return Icons.link_rounded;
    }
  }

  // ------------------------------------------------------------
  // MINHAS SUBMISSÕES
  // ------------------------------------------------------------

  Widget _buildMinhasSubmissoes() {
    return FutureBuilder<List<Iniciativa>>(
      future: _iniciativasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.s4,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVazio(
                'Não foi possível carregar suas submissões.',
              ),
              TextButton(
                onPressed: _recarregarIniciativas,
                child: const Text('Tentar novamente'),
              ),
            ],
          );
        }

        final iniciativas = snapshot.data ?? [];

        if (iniciativas.isEmpty) {
          return _buildVazio(
            'Você ainda não enviou nenhuma submissão.',
          );
        }

        return Column(
          children: [
            for (final iniciativa in iniciativas) ...[
              _buildIniciativaTile(iniciativa),
              const SizedBox(height: AppSpacing.s2),
            ],
          ],
        );
      },
    );
  }

  Widget _buildIniciativaTile(
    Iniciativa iniciativa,
  ) {
    Color statusColor;

    if (iniciativa.aprovada) {
      statusColor = AppColors.success;
    } else if (iniciativa.rejeitada) {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.warning;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s3_5),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    iniciativa.titulo,
                    style: AppTextStyles.base.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s0_5),
                  Text(
                    iniciativa.tipoLabel,
                    style: AppTextStyles.caption,
                  ),
                  if (iniciativa.justificativaAdmin != null &&
                      iniciativa.justificativaAdmin!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      iniciativa.justificativaAdmin!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChip(
                  iniciativa.statusLabel,
                  color: statusColor,
                ),
                if (iniciativa.aprovada) ...[
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    '+${iniciativa.pontos} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    '${iniciativa.pontosSugeridos} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ATIVIDADES DA COMUNIDADE
  // ------------------------------------------------------------

  Widget _buildAtividadeTile(
    AtividadeComunidade atividade,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s3_5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary.withOpacity(0.15),
              child: Text(
                atividade.nome.isNotEmpty
                    ? atividade.nome[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    atividade.nome,
                    style: AppTextStyles.base.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s0_5),
                  Text(
                    '${atividade.detalhe} · ${atividade.tempoAtras}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Text(
              '+${atividade.xp} XP',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // AUXILIARES
  // ------------------------------------------------------------

  Widget _buildVazio(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s3,
      ),
      child: Text(
        texto,
        style: AppTextStyles.bodySecondary,
      ),
    );
  }

  Widget _buildChip(
    String texto, {
    bool highlighted = false,
    Color? color,
  }) {
    final corBase = color ??
        (highlighted ? AppColors.primary : null);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2_5,
        vertical: AppSpacing.s0_5,
      ),
      decoration: BoxDecoration(
        color: corBase != null
            ? corBase.withOpacity(0.15)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
        border: Border.all(
          color: corBase ?? AppColors.border,
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: corBase ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _LeituraFormResult {
  final String titulo;
  final String descricao;
  final String anexoUrl;

  const _LeituraFormResult({
    required this.titulo,
    required this.descricao,
    required this.anexoUrl,
  });
}
