import 'package:flutter/material.dart';

import '/services/auth_service.dart';

import '/models/game.dart';

import '/widgets/app_layout.dart';
import '/widgets/game_card.dart';

import '/theme/app_colors.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import 'perguntas_jogos.dart';

class JogosScreen extends StatefulWidget {
  const JogosScreen({
    super.key,
  });

  @override
  State<JogosScreen> createState() => _JogosScreenState();
}

class _JogosScreenState extends State<JogosScreen> {
  late Future<List<Game>> _jogosFuture;
  String? _jogoCarregandoId;

  @override
  void initState() {
    super.initState();

    _jogosFuture = ApiService.fetchJogos();
  }

  Future<void> _recarregarJogos() async {
    setState(() {
      _jogosFuture = ApiService.fetchJogos();
    });

    await _jogosFuture;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayout(
        scrollable: true,
        child: FutureBuilder<List<Game>>(
          future: _jogosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _buildError();
            }

            final jogos = snapshot.data ?? [];

            if (jogos.isEmpty) {
              return _buildEmpty();
            }

            return _buildJogos(jogos);
          },
        ),
      ),
    );
  }

  // ============================================================
  // LISTA DE JOGOS
  // ============================================================

  Widget _buildJogos(List<Game> jogos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.s4),

        _buildHeader(),

        SizedBox(height: AppSpacing.s5),

        ...jogos.map(
          (game) => Padding(
            padding: EdgeInsets.only(
              bottom: AppSpacing.s4,
            ),
            child: GameCard(
              titulo: game.titulo,
              descricao: game.descricao,
              pontos: game.pontosTotal,
              concluido: game.concluido,
              onTap: () => _abrirJogo(game),
            ),
          ),
        ),

        SizedBox(height: AppSpacing.s4),
      ],
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
            const Icon(
              Icons.sports_esports_outlined,
              color: AppColors.primary,
              size: 14,
            ),

            SizedBox(width: AppSpacing.s1_5),

            Text(
              'TRILHA DE JOGOS',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.s1_5),

        Text(
          'Jogos',
          style: AppTextStyles.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: AppSpacing.s1),

        Text(
          'Teste seus conhecimentos e conquiste XP.',
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NAVEGAÇÃO PARA O JOGO
  // ============================================================

  Future<void> _abrirJogo(Game game) async {
    if (_jogoCarregandoId != null) return;

    setState(() {
      _jogoCarregandoId = game.id;
    });

    try {
      final jogoCompleto =
          await ApiService.fetchJogo(game.id);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            jogo: jogoCompleto,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar o jogo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _jogoCarregandoId = null;
        });
      }
    }
  }

  // ============================================================
  // ESTADOS DA TELA
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.redAccent,
            ),

            SizedBox(height: AppSpacing.s3),

            Text(
              'Não foi possível carregar os jogos.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),

            SizedBox(height: AppSpacing.s3),

            ElevatedButton(
              onPressed: _recarregarJogos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s5),
        child: Text(
          'Nenhum jogo disponível no momento.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
      ),
    );
  }
}