import 'package:flutter/material.dart';

import '/theme/app_colors.dart';
import '/theme/app_spacing.dart';

import 'home.dart';
import 'leituras.dart';
import 'videos.dart';
import 'jogos.dart';
import 'iniciativas.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    HomeDashboardScreen(),
    LeiturasScreen(),
    VideosScreen(),
    JogosScreen(),
    IniciativasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

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
          color: AppColors.background,
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) {
              final active = index == _navIndex;
              final (icon, label) = items[index];

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