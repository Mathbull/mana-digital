import 'package:flutter/material.dart';
import 'dart:convert';

import '/utils/responsive.dart';
import '/services/auth_service.dart';
import '/services/rank_service.dart';

import '/theme/app_colors.dart';
import '/theme/app_radius.dart';
import '/theme/app_shadows.dart';
import '/theme/app_spacing.dart';
import '/theme/app_text_styles.dart';
import '/widgets/app_layout.dart';

import '/models/home.dart';


/// ============================================================
/// TELA PRINCIPAL — Home Dashboard "Mana Digital"
/// ============================================================
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadHome();
  }

  
  bool _isLoadingUser = true;
  String _rankingPeriodo = 'semanal';

  HomeData? _homeData;
  bool _isLoadingHome = true;

  Future<void> _loadHome() async {
    try {
      final response = await ApiService.getHome();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          _homeData = HomeData.fromJson(data);
          _isLoadingHome = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _isLoadingHome = false;
        });

        debugPrint(
          'Erro ao carregar Home: ${response.statusCode}',
        );
        debugPrint(response.body);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingHome = false;
      });
    }
  }

  //precisa iniciar para o _homeData ser construido ja que depende do model do usuario.
  Future<void> _loadUser() async {
    try {
      // chame o getMe para pegar os dados do usuario
      final response = await ApiService.getMe();
 
      if (response.statusCode == 200) {
        // sucesso 
        // checa se ainda esta na tela
        if (!mounted) return;
        setState(() {
          _isLoadingUser = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingUser = false;
      });

      debugPrint('Erro ao carregar usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AppLayout(
              scrollable: true,
              // Em telas de tablet/desktop, limita a largura do conteúdo
              // e o centraliza, seguindo o mesmo padrão do header.
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.isTablet(context) ? 900 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHero(),

                      const SizedBox(
                        height: AppSpacing.s6,
                      ),

                      _buildRankTimeline(),

                      const SizedBox(
                        height: AppSpacing.s6,
                      ),

                      _buildDailyMission(),

                      const SizedBox(
                        height: AppSpacing.s6,
                      ),

                      _buildPerformanceMetrics(),

                      const SizedBox(
                        height: AppSpacing.s6,
                      ),

                      _buildLeaderboard(),

                      const SizedBox(
                        height: AppSpacing.s6,
                      ),

                      _buildBadges(),

                      const SizedBox(
                        height: AppSpacing.s8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------
  // PROFILE HERO — avatar, nome, streak, barra de XP
  // ---------------------------------------------------------
  Widget _buildProfileHero() {
    final pontos = _homeData?.usuario.pontos ?? 0;

    final rankAtual = RankService.getRank(pontos);
    final proximoRank = RankService.getNextRank(pontos);

    // Calcula o progresso entre a patente atual e a próxima.
    double progresso = 1.0;
    int xpRestante = 0;

    if (proximoRank != null) {
      final xpInicio = rankAtual.pontosMinimos;
      final xpFim = proximoRank.pontosMinimos;

      final xpNoNivelAtual = pontos - xpInicio;
      final xpNecessario = xpFim - xpInicio;

      progresso = xpNoNivelAtual / xpNecessario;

      // Garante que o valor fique entre 0 e 1.
      progresso = progresso.clamp(0.0, 1.0);

      xpRestante = xpFim - pontos;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.red950,
                        ),
                      ],
                    ),

                    const SizedBox(width: AppSpacing.s3),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _isLoadingUser
                                      ? 'Carregando...'
                                      : (_homeData?.usuario.apelido?.isNotEmpty == true
                                      ? _homeData!.usuario.apelido!
                                      : _homeData?.usuario.nome ?? 'Usuário'),
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.xl,
                                ),
                              ),

                              const SizedBox(
                                width: AppSpacing.s0_5,
                              ),

                              Icon(
                                Icons.verified,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                            ],
                          ),

                          Text(
                            'OPERAÇÕES INTEGRADAS',
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s3),

          // ============================================================
          // MEDIDOR DE XP
          // ============================================================

          Container(
            padding: const EdgeInsets.all(AppSpacing.s2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.show_chart,
                            color: AppColors.primary,
                            size: 14,
                          ),

                          const SizedBox(
                            width: AppSpacing.s0_5,
                          ),

                          Flexible(
                            child: Text(
                              '$pontos XP',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      proximoRank != null
                          ? '${proximoRank.pontosMinimos} XP'
                          : 'MAX',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.s1,
                ),

                // ======================================================
                // BARRA DE PROGRESSO
                // ======================================================

                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.s1,
                ),

                // ======================================================
                // INFORMAÇÕES DO RANK
                // ======================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rankAtual.nome,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (proximoRank != null)
                      Text(
                        'Faltam $xpRestante XP para ${proximoRank.nome}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      )
                    else
                      Text(
                        'Patente máxima',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // PATENTE CORPORATIVA — timeline Bronze/Prata/Ouro/Diamante
  // ---------------------------------------------------------
  Widget _buildRankTimeline() {
    final pontos = _homeData?.usuario.pontos ?? 0;
    final rankAtual = RankService.getRank(pontos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(
              Icons.military_tech,
              'Patente Corporativa',
            ),

            Text(
              'Status: ${rankAtual.nome}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.s1),

        Container(
          padding: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxxl),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: RankService.ranks.map((rank) {
                  final desbloqueado = RankService.isUnlocked(pontos, rank,);
                  final ativo = rank.nome == rankAtual.nome;

                  return Expanded(
                    child: _rankStep(
                      icon: _getRankIcon(rank.nome),
                      label: rank.nome,
                      active: ativo,
                      done: desbloqueado && !ativo,
                      locked: !desbloqueado,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.s3),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s2,
                  vertical: AppSpacing.s1,
                ),

                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [
                    Flexible(
                      child: Text(
                        'XP atual: $pontos XP',
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Text(
                      'Patente ${rankAtual.nome}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.violet400,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getRankIcon(String rank) {
    switch (rank) {
      case 'Bronze':
        return Icons.workspace_premium;

      case 'Prata':
        return Icons.military_tech;

      case 'Ouro':
        return Icons.shield;

      case 'Diamante':
        return Icons.diamond;

      default:
        return Icons.lock;
    }
  }

  Widget _rankStep({
    required IconData icon,
    required String label,
    required bool active,
    required bool done,
    bool locked = false,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: active
                ? AppColors.cyan700
                : AppColors.surfaceElevated,
          ),

          child: Icon(
            locked
                ? Icons.lock
                : done
                ? Icons.check_circle
                : icon,

            size: 20,

            color: active
                ? AppColors.textPrimary
                : locked
                ? AppColors.textSecondary
                : AppColors.violet400,
          ),
        ),

        const SizedBox(height: AppSpacing.s0_5),

        Text(
          label,

          style: AppTextStyles.caption.copyWith(
            color: active
                ? AppColors.secondary
                : locked
                ? AppColors.textSecondary
                : AppColors.textPrimary,

            fontWeight:
            active ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // DESAFIO DO DIA
  // ---------------------------------------------------------
  Widget _buildDailyMission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(Icons.offline_bolt, 'Desafio do Dia'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
              decoration: BoxDecoration(
                color: AppColors.cyan700,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'BÔNUS 1.5X XP',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s1),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxxl),
          child: Container(
            color: AppColors.surfaceElevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Microagressões no Hub de Cargas',
                        style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.s0_5),
                      Text(
                        'Um líder operacional utiliza apelidos velados para deslegitimar a promoção de um supervisor negro durante o turno noturno.',

                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sm.copyWith(color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      // Em telas estreitas, quebra para a linha de baixo em vez de estourar
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: AppSpacing.s2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, color: AppColors.textSecondary, size: 14),
                              const SizedBox(width: AppSpacing.s0_5),
                              Text('04h 22mx', style: AppTextStyles.caption),
                              const SizedBox(width: AppSpacing.s1),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cyan700,
                              foregroundColor: AppColors.slate950,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
                            ),
                            icon: const Text('Iniciar (+80 XP)'),
                            label: const Icon(Icons.arrow_forward, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // DESEMPENHO DO CICLO — 3 cartões de métricas
  // ---------------------------------------------------------
  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(Icons.insights, 'Desempenho do Atual'),
          ],
        ),
        const SizedBox(height: AppSpacing.s1),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                icon: Icons.menu_book,
                label: 'Livros',
                concluidos: _homeData?.leiturasConcluidas ?? 0,total: _homeData?.totalLeituras ?? 0,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(
              width: AppSpacing.s2,
            ),
            Expanded(
              child: _metricCard(
                icon: Icons.sports_esports,
                label: 'Jogos',
                concluidos: _homeData?.jogosConcluidos ?? 0,
                total: _homeData?.totalJogos ?? 0,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(
              width: AppSpacing.s2,
            ),
            Expanded(
              child: _metricCard(
                icon: Icons.play_circle,
                label: 'vídeos',
                concluidos: _homeData?.videosConcluidos?? 0,
                total: _homeData?.totalVideos ?? 0,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(
              width: AppSpacing.s2,
            )
          ],
        ),
      ],
    );
  }

  Widget _metricCard(
      {
        required IconData icon,
        required String label,
        required int concluidos,
        required int total,
        required Color color
      }) {
    final progresso = total > 0
        ?(concluidos / total ).clamp(0.0, 1.0)
        :0.0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text('$concluidos/$total', style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: AppSpacing.s0_5),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.s0_5),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // QUADRO DE CASSIFICAÇÂO — ranking com abas
  // ---------------------------------------------------------
  Widget _buildLeaderboard() {
    final rankings = _homeData?.rankings;

    if (rankings == null) {
      return const SizedBox.shrink();
    }

    List<RankingItem> rankingAtual;

    switch (_rankingPeriodo) {
      case 'mensal':
        rankingAtual = rankings.mensal;
        break;

      case 'geral':
        rankingAtual = rankings.geral;
        break;

      case 'semanal':
      default:
        rankingAtual = rankings.semanal;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: AppSpacing.s1,
          children: [
            _sectionTitle(
              Icons.leaderboard,
              'Classificação',
            ),

            Container(
              padding: const EdgeInsets.all(
                AppSpacing.s0_5,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _rankingTabButton(
                    'semanal',
                    'Semanal',
                  ),

                  _rankingTabButton(
                    'mensal',
                    'Mensal',
                  ),

                  _rankingTabButton(
                    'geral',
                    'Geral',
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.s2,
        ),

        Container(
          padding: const EdgeInsets.all(
            AppSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxxl),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rankingAtual.length; i++) ...[
                _leaderboardRowFromApi(
                  rankingAtual[i],
                ),

                if (i < rankingAtual.length - 1)
                  const SizedBox(
                    height: AppSpacing.s1,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  Widget _leaderboardRowFromApi(
      RankingItem item,
      ) {
    final position = int.tryParse(
      item.rank.replaceAll('º', ''),
    ) ??
        0;

    final isUser = item.isUser;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.cyan950
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        children: [
          // ==========================================================
          // POSIÇÃO
          // ==========================================================

          SizedBox(
            width: 28,
            child: Text(
              '$position',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: position == 1
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(
            width: AppSpacing.s2,
          ),

          // ==========================================================
          // NOME + CARGO
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isUser
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                    fontWeight: isUser
                        ? FontWeight.bold
                        : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                Text(
                  isUser
                      ? 'Sua posição atual'
                      : item.role,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: AppSpacing.s2,
          ),

          // ==========================================================
          // XP
          // ==========================================================

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                color: AppColors.secondary,
                size: 14,
              ),

              const SizedBox(
                width: 2,
              ),

              Text(
                item.xp,
                style: AppTextStyles.caption.copyWith(
                  color: isUser
                      ? AppColors.secondary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rankingTabButton(
      String periodo,
      String label,
      ) {
    final ativo = _rankingPeriodo == periodo;

    return GestureDetector(
      onTap: () {
        setState(() {
          _rankingPeriodo = periodo;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s1,
        ),
        decoration: BoxDecoration(
          color: ativo
              ? AppColors.surfaceElevated
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo
                ? AppColors.secondary
                : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: ativo
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // CONQUISTAS RECENTES — grade de 3 badges
  // ---------------------------------------------------------
  Widget _buildBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(Icons.stars, 'Conquistas Recentes'),
            Text('Ver Todas (12)', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: AppSpacing.s1),
        Row(
          children: [
            Expanded(child: _badgeCard(icon: Icons.login, title: '1º Login', subtitle: 'Início da Trilha', color: AppColors.secondary)),
            const SizedBox(width: AppSpacing.s1),
            Expanded(child: _badgeCard(icon: Icons.hub, title: 'Multi-trilhas', subtitle: '3 Áreas Ativas', color: AppColors.primary)),
            const SizedBox(width: AppSpacing.s1),
            Expanded(child: _badgeCard(icon: Icons.workspace_premium, title: 'Mestre Legal', subtitle: 'Estatuto 100%', color: AppColors.violet400)),
          ],
        ),
      ],
    );
  }

  Widget _badgeCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xxl)),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceElevated),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.s0_5),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // TÍTULO DE SEÇÃO (reutilizável)
  // ---------------------------------------------------------
  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.secondary, size: 18),
        const SizedBox(width: AppSpacing.s1),
        Text(text, style: AppTextStyles.base.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}