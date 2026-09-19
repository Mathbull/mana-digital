import 'package:flutter/material.dart';

import '/widgets/content_layout.dart';
import '/models/content_item.dart';

class JogosScreen extends StatelessWidget {
  const JogosScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final jogos = [
        ContentItem(
          id: '1',
          titulo: 'Simulado anti-racismo',
          descricao:
          'Simulado de consientizaçõa anti-racismo.',
          categoria: 'Simulado',
          pontos: 45,
        ),
    ];
    
    return ContentPageLayout(
      titulo: 'Jogos',
      descricao:
          'Base de conhecimento para qualificação em equidade racial.',
      icon: Icons.sports_esports,
      contents: jogos,
    );
  }
}