import 'package:flutter/material.dart';
 
/// ============================================================
/// PALETA DE CORES — extraída do tema Tailwind original (dark mode)
/// ============================================================
class AppColors {
  AppColors._();
 
  static const primary = Color(0xFFC3C0FF);
  static const onPrimary = Color(0xFF1F00A4);
  static const primaryContainer = Color(0xFF4338CA);
  static const onPrimaryContainer = Color(0xFFC1BEFF);
 
  static const secondary = Color(0xFF4CD7F6);
  static const secondaryContainer = Color(0xFF03B5D3);
  static const onSecondaryContainer = Color(0xFF00424E);
 
  static const tertiary = Color(0xFF7BD0FF);
  static const tertiaryContainer = Color(0xFF005878);
 
  static const surface = Color(0xFF0B1326);
  static const surfaceContainerLowest = Color(0xFF060E20);
  static const surfaceContainerLow = Color(0xFF131B2E);
  static const surfaceContainer = Color(0xFF171F33);
  static const surfaceContainerHigh = Color(0xFF222A3D);
  static const surfaceContainerHighest = Color(0xFF2D3449);
 
  static const onSurface = Color(0xFFDAE2FD);
  static const onSurfaceVariant = Color(0xFFC7C4D7);
  static const outlineVariant = Color(0xFF464554);
}
 
/// ============================================================
/// ESPAÇAMENTOS PADRÃO — equivalentes ao "spacing" do Tailwind
/// ============================================================
class AppSpacing {
  AppSpacing._();
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
 
/// ============================================================
/// CONTAINER RESPONSIVO
/// Limita a largura do conteúdo em telas grandes (tablet/web) e
/// aplica o "gutter" lateral que existia no HTML (px-gutter-mobile).
/// ============================================================
class _ResponsiveContainer extends StatelessWidget {
  final Widget child;
  const _ResponsiveContainer({required this.child});
 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // gutter menor em telas de celular, maior em telas largas
    final horizontalPadding = width < 400 ? AppSpacing.base : AppSpacing.lg;
 
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
 
/// ============================================================
/// TELA PRINCIPAL — Home Dashboard "Mana Digital"
/// ============================================================
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});
 
  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}
 
class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // Aba ativa do ranking (Semanal / Mensal / Geral)
  String _rankingTab = 'semanal';
  // Item ativo da navegação inferior
  int _navIndex = 0;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                child: _ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHero(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRankTimeline(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDailyMission(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPerformanceMetrics(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildLeaderboard(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildBadges(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
 
  // ---------------------------------------------------------
  // HEADER — logo, nível/XP, avatar do perfil
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: _ResponsiveContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida/AEtjO1WQhiQ5mZC-fBQYK9XIBiTNeobI_-mGBAXYGrYerLnWCQyf5uAOMrFUHV22zM6o2DHNP8ME-XCdbKHrJNgryzYgpdTv-VW-8ADvZsl-3YPFySPa7vYVKJ8rz2lK3SgNge1A61UFc_BhqPGVOmi522PL-798xmehxSayWLCcGEcs_jUgYXtRD1YbFIzn88DM6qilw-DZS0m2yRg1vXTxaQAyaX8hG5P6spyCoUm9Ei-PoGW3uspACXjQwbI',
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mana Digital',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'HOME',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: AppColors.secondary, size: 16),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'NÍV 04',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            '1.420 XP',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primaryContainer, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://lh3.googleusercontent.com/aida/AEtjO1U0pxeb0X8CXLNjJFE9iy31XUHJh1FD09Dcv6OzYbwhVsWusosjRuwfUTdg4RMhJeI52SEVZ4Dn1gqG3_d0E91T9X8ZYFYL3LSj2JcPy8DA_BNOND97_YyWfW5SDURmGWZFAqaOHkc94y_laM6AEcqyZwnzDDU4vzqGR5HUbPlKcnCKMZ6qJtAVc18uHtnBAoTewq4PZafdUX1YqikXxLpwfYWQ0Eq2GkVIlWl8v-c7AnU8tuFexuvbP0M',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  // ---------------------------------------------------------
  // PROFILE HERO — avatar, nome, streak, barra de XP
  // ---------------------------------------------------------
  Widget _buildProfileHero() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
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
                          backgroundImage: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDYYSFwFpZgTfN_issqqlOwHxMAdA4vyZ51jw0IDQ1iw026lHdVPn1uKAAUKPyQqe_njza6EWM6ujcz9vWDmdSQ1c1-1O1sYWYerJXuXniF3huhqN8HGLlfl7X5Q6JxjdUSP9em-i-xlopiNIwFug-9i7k5LzWfR2sALrnC5TsVENT255A9dNLjxCQeNrfQSSvgBLVRc9Gl7_GVD_zvq-S7LUzgno8Y8QT7TZFG_v0cXDSjYc1wr10f',
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'N03',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Aisha_CyberLog',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              Icon(Icons.verified, color: AppColors.secondary, size: 16),
                            ],
                          ),
                          Text(
                            'OPERAÇÕES INTEGRADAS',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, color: AppColors.secondary, size: 16),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '7D AZUL',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('Streak Ativo', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Medidor de XP
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
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
                          Icon(Icons.show_chart, color: AppColors.primary, size: 14),
                          const SizedBox(width: AppSpacing.xxs),
                          Flexible(
                            child: Text(
                              '1.850 / 2.500 XP',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Faltam 650 XP p/ Diamante',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.74,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                  ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(Icons.military_tech, 'Patente Corporativa'),
            Text('Status: Ouro (65%)', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _rankStep(icon: Icons.check_circle, label: 'Bronze', percent: '100%', active: false, done: true)),
                  Expanded(child: _rankStep(icon: Icons.check_circle, label: 'Prata', percent: '100%', active: false, done: true)),
                  Expanded(child: _rankStep(icon: Icons.shield, label: 'Ouro', percent: '65%', active: true, done: false)),
                  Expanded(child: _rankStep(icon: Icons.lock, label: 'Diamante', percent: '0%', active: false, done: false, locked: true)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Requisito: Estatuto Igualdade Racial Art. 39',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                      ),
                    ),
                    Text('2/3 Módulos', style: TextStyle(color: AppColors.tertiary, fontSize: 12, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _rankStep({
    required IconData icon,
    required String label,
    required String percent,
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
                ? AppColors.primaryContainer
                : locked
                    ? AppColors.surfaceContainerHighest
                    : AppColors.surfaceContainerHigh,
          ),
          child: Icon(
            icon,
            size: 20,
            color: active
                ? AppColors.onPrimaryContainer
                : locked
                    ? AppColors.onSurfaceVariant
                    : AppColors.tertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.secondary : (locked ? AppColors.onSurfaceVariant : AppColors.onSurface),
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            color: active ? AppColors.secondary : AppColors.onSurfaceVariant,
            fontSize: 10,
            fontFamily: 'monospace',
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'BÔNUS 1.5X XP',
                style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: AppColors.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 128,
                      width: double.infinity,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAV1llh54hWTg-eCRigexJSNH-AvfJxEaBlfYcVG3zjJ8dG7qq7-NMLpNNnCkRy1Ox5paNDgE__WpO_GOVpqDtzwXsFPp4fwnZh7A_J3PCX7Jj4DJPfHjLEhxu6bjGZ9qKK1Q0ypEWgXudLkzmKBZikI36lSrz-OCBCopdFJZwsZwNm8S5LyLISzHYiU36SiXiop_3K-8D_LVabu3i7uNcclWzjqoeABS-1qVj-w6rPYhBQeCMFtRVy',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerHigh],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LEI 14.532/23',
                          style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Microagressões no Hub de Cargas',
                        style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Um líder operacional utiliza apelidos velados para deslegitimar a promoção de um supervisor negro durante o turno noturno.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Em telas estreitas, quebra para a linha de baixo em vez de estourar
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: AppSpacing.sm,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, color: AppColors.onSurfaceVariant, size: 14),
                              const SizedBox(width: AppSpacing.xxs),
                              Text('4 min', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              const SizedBox(width: AppSpacing.xs),
                              Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(Icons.psychology, color: AppColors.onSurfaceVariant, size: 14),
                              const SizedBox(width: AppSpacing.xxs),
                              Text('Decisão Crítica', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            _sectionTitle(Icons.insights, 'Desempenho do Ciclo'),
            Text('Meta Trimestral', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(child: _metricCard(icon: Icons.menu_book, label: 'Leituras', percent: 0.78, color: AppColors.secondary)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: _metricCard(icon: Icons.play_circle, label: 'Vídeos', percent: 0.60, color: AppColors.tertiary)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: _metricCard(icon: Icons.sports_esports, label: 'Jogos', percent: 0.85, color: AppColors.primary)),
          ],
        ),
      ],
    );
  }
 
  Widget _metricCard({required IconData icon, required String label, required double percent, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text('${(percent * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: TextStyle(color: AppColors.onSurface, fontSize: 12), overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.xxs),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
 
  // ---------------------------------------------------------
  // QUADRO DE HONRA — ranking com abas e destaque do usuário
  // ---------------------------------------------------------
  Widget _buildLeaderboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: AppSpacing.xs,
          children: [
            _sectionTitle(Icons.leaderboard, 'Quadro de Honra'),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _rankingTabButton('semanal', 'Semanal'),
                  _rankingTabButton('mensal', 'Mensal'),
                  _rankingTabButton('geral', 'Geral'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              _leaderboardRow(
                position: '1',
                name: 'Thiago_LogGov',
                subtitle: 'Auditoria Racial',
                xp: '2.410 XP',
                imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCkOM9oJZPgHyc_rguvFZMnRJ2A5YggWnYU7RqCPAcGPfrxcjLb_fjLdMdpNC8RhLdaHKFhdk6Fnsx-r-IeAn2qYaO9if29qu4_Upfin2l_FLfaOZVb9fqM3wQywh0xf4qcGTpL-cktqomY9BC6O0qNY6wrUBGZGZNo6x91iyXmTN00hO-OxmELuqtKo1yZQ20LGulqTXDESLiE-HHNStKIvBcRmNd1h5mLg90jOChcZibdPwOyaE6f',
                highlight: true,
                bgColor: AppColors.surfaceContainerHigh,
                positionColor: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              _leaderboardRow(
                position: '2',
                name: 'Mayara_Frotas',
                subtitle: 'Distribuição Norte',
                xp: '2.180 XP',
                imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuACF3vyewmB-nTBDxR9_D0Im4q2KTybZG6bsyBRWQNzpLdx2lPNx-frrw0g_BnmL_9a8DKHqibww2IgDGxJsZwZGEWW7Yh4aC4Nm3zHWv4LLCnSoJMUC1bG4WGBtgZo6NqwfV_UkaFDoSU3F5WDfFRimcY4vzyo2vvufFp5_Y2vcwi84I7qTE0iJctLQj_J3OBjiagnMaWUcRrxPCZWFVfJmmqD-YjUvxcm0UOvVXAj3ZLqdPqYu6_P',
                bgColor: AppColors.surfaceContainerLow,
                positionColor: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.xs),
              _leaderboardRow(
                position: '3',
                name: 'Carlos_ESG',
                subtitle: 'Compliance Hub',
                xp: '1.940 XP',
                imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBhGx5dbXfeqiCTx2Slue_kQEC9A4QFPBeBSv4cOf4lgEzI54S9Bm5Bi99SpMwI7SgHT3FKL1GoDujl49HrDdWltlrnHmeQnGTO15BLa4OMZII9Ed2Yhu-f1U9EubX3cDe0s1GG2uZaor9_wVw4aKpk_q98E4KQgn4GV1ZLTrp-faH2e-62X4NKtw-GK5HskumEzSYjsunNPL5OntUsDP_v07aJNxBH8HLTJZcg9FQoGqfprxmCJF6C',
                bgColor: AppColors.surfaceContainerLow,
                positionColor: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Posição do usuário atual (4º lugar, sem foto — iniciais)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text('4', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(width: AppSpacing.sm),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.secondaryContainer,
                      child: Text('VOCÊ', style: TextStyle(color: AppColors.onSecondaryContainer, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Aisha_CyberLog', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Sua Posição Atual', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, color: AppColors.secondary, size: 14),
                            Text('1.850 XP', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                          ],
                        ),
                        Text('-90 XP p/ Top 3', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      ],
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
 
  Widget _rankingTabButton(String value, String label) {
    final bool active = _rankingTab == value;
    return GestureDetector(
      onTap: () => setState(() => _rankingTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
 
  Widget _leaderboardRow({
    required String position,
    required String name,
    required String subtitle,
    required String xp,
    required String imageUrl,
    required Color bgColor,
    required Color positionColor,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          SizedBox(width: 20, child: Text(position, textAlign: TextAlign.center, style: TextStyle(color: positionColor, fontWeight: FontWeight.bold, fontSize: 18))),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (highlight) Icon(Icons.social_distance, color: AppColors.secondary, size: 14),
          Text(xp, style: TextStyle(color: highlight ? AppColors.secondary : AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
        ],
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
            Text('Ver Todas (12)', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(child: _badgeCard(icon: Icons.login, title: '1º Login', subtitle: 'Início da Trilha', color: AppColors.secondary)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: _badgeCard(icon: Icons.hub, title: 'Multi-trilhas', subtitle: '3 Áreas Ativas', color: AppColors.primary)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: _badgeCard(icon: Icons.workspace_premium, title: 'Mestre Legal', subtitle: 'Estatuto 100%', color: AppColors.tertiary)),
          ],
        ),
      ],
    );
  }
 
  Widget _badgeCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerHigh),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
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
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
 
  // ---------------------------------------------------------
  // NAVEGAÇÃO INFERIOR
  // ---------------------------------------------------------
  Widget _buildBottomNav() {
    final items = [
      (Icons.dashboard, 'Home'),
      (Icons.menu_book, 'Leituras'),
      (Icons.play_circle, 'Vídeos'),
      (Icons.sports_esports, 'Jogos'),
      (Icons.diversity_3, 'Iniciativas'),
    ];
 
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final active = index == _navIndex;
            final (icon, label) = items[index];
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _navIndex = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: active ? AppColors.secondary : AppColors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      label,
                      style: TextStyle(fontSize: 10, color: active ? AppColors.secondary : AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}