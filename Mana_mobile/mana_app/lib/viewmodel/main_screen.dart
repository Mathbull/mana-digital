import 'package:flutter/material.dart';
import 'dart:convert';

import '/theme/app_colors.dart';
import '/theme/app_spacing.dart';
import '/theme/app_shadows.dart';
import '/theme/app_text_styles.dart';
import '/theme/app_radius.dart';
import '/utils/responsive.dart';

import '/views/home.dart';
import '/views/leituras.dart';
import '/views/videos.dart';
import '/views/jogos.dart';
import '/views/iniciativas.dart';

import '/models/usuario.dart';
import '/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  Usuario? _usuario;  
  int _navIndex = 0;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final response = await ApiService.getMe();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          _usuario = Usuario.fromJson(data);  
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

  void _atualizarXp(int novoXp) {
  if (!mounted || _usuario == null) return;

  setState(() {
    _usuario = _usuario!.copyWith(
      pontos: novoXp,
    );
  });
}

  List<Widget> get _pages => [
    const HomeDashboardScreen(),

    LeiturasScreen(
      onXpAtualizado: _atualizarXp,
    ),

    const VideosScreen(),
    const JogosScreen(),
    const IniciativasScreen(),
  ];

  static const List<(IconData, String)> _navItems = [
    (Icons.dashboard, 'Home'),
    (Icons.menu_book, 'Leituras'),
    (Icons.play_circle, 'Vídeos'),
    (Icons.sports_esports, 'Jogos'),
    (Icons.diversity_3, 'Iniciativas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children:[
          _buildHeader(),
          Expanded(
            child: IndexedStack(
              index: _navIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: AppShadows.base,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isTablet(context) ? 900 : double.infinity,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: AppSpacing.s2),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mana Digital',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.base.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _navItems[_navIndex].$2.toUpperCase(),
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
                const SizedBox(width: AppSpacing.s2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s2,
                        vertical: AppSpacing.s0_5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: AppColors.secondary, size: 16),
                          const SizedBox(width: AppSpacing.s0_5),
                          const SizedBox(width: AppSpacing.s0_5),
                          Text(
                            '${_usuario?.pontos ?? 0} XP',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.cyan700, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        
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


  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final active = index == _navIndex;
            final (icon, label) = _navItems[index];
            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _navIndex = index;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: active
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                      ),

                      const SizedBox(
                        height: AppSpacing.s0_5,
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          color: active
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}