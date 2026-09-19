import 'package:flutter/material.dart';

import '/widgets/content_layout.dart';
import '/models/content_item.dart';

class LeiturasScreen extends StatelessWidget {
  const LeiturasScreen({super.key});

    @override
    Widget build(BuildContext context) {

    final leituras = [
      ContentItem(
        id: '1',
        titulo: 'Estatuto da Igualdade Racial',
        descricao:
         'Análise aplicativa da Lei 12.288/2010 sobre igualdade de oportunidades.',
        categoria: 'Legislação',
        pontos: 45,
     ),

      ContentItem(
      id: '2',
      titulo: 'Pequeno Manual Antirracista',
      descricao:
        'Síntese didática da obra de Djamila Ribeiro.',
      categoria: 'Literatura Crítica',
      pontos: 35,
      ),
    ];

    return ContentPageLayout(
      titulo: 'Leituras',
      descricao:
          'Base de conhecimento para qualificação em equidade racial.',
      icon: Icons.menu_book,
      contents: leituras,
    );
  }
}