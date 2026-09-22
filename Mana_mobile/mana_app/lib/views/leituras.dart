import 'package:flutter/material.dart';
import 'dart:convert';

import '/services/auth_service.dart';
import '/models/content_item.dart';
import '/widgets/content_layout.dart';

import 'perguntas.dart';

class LeiturasScreen extends StatefulWidget {
  final ValueChanged<int>? onXpAtualizado;

  const LeiturasScreen({
    super.key,
    this.onXpAtualizado,
  });

  @override
  State<LeiturasScreen> createState() => _LeiturasScreenState();
}

class _LeiturasScreenState extends State<LeiturasScreen> {
  List<ContentItem> leituras = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarLeituras();
  }


    Future<void> _carregarLeituras() async {
    try {
      final response = await ApiService.getLeituras();

      if (response.statusCode != 200) {
        throw Exception('Erro ao carregar leituras');
      }

      final data = jsonDecode(response.body);

      final List<dynamic> lista = data['leituras'] ?? data;

      final itens = lista
          .map(
            (item) => ContentItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        leituras = itens;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _abrirQuiz(ContentItem content) async {
    if (content.perguntas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta leitura não possui perguntas.'),
        ),
      );
      return;
    }

    await QuizPerguntas.show(
      context,
      titulo: content.titulo,
      sintese: content.descricao,
      pontos: content.pontos,
      perguntas: content.perguntas,
      rotulo: content.categoria,
      onValidar: (respostas) async {
        final response = await ApiService.responderLeitura(
          leituraId: content.id,
          respostas: respostas,
        );

        final data = jsonDecode(response.body);

        if (response.statusCode != 200) {
          throw Exception(
            data['message'] ?? 'Erro ao validar a leitura.',
          );
        }

        final pontosGanhos = data['pontosGanhos'] as int;
        final novoTotalXp = data['novoTotalXp'] as int;

        widget.onXpAtualizado?.call(novoTotalXp);

        if (!mounted) return;

        setState(() {
          leituras = leituras.map((leitura) {
            if (leitura.id == content.id) {
              return leitura.copyWith(
                concluida: true,
              );
            }

            return leitura;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Você ganhou $pontosGanhos XP! '
              'Total: $novoTotalXp XP',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!),
      );
    }

    return ContentPageLayout(
      titulo: 'Base de Conhecimento',
      descricao:
          'Parâmetros jurídicos, diretrizes do Estatuto da Igualdade Racial e letramento estratégico para governança na logística.',
      icon: Icons.menu_book_outlined,
      etiqueta: 'Módulo Regulatório · Trilha XP',
      filtros: const [
        'Artigos de Lei',
        'Trecho de Livros',
        'Fato',
      ],
      contents: leituras,
      onContentTap: (content) async {
        await _abrirQuiz(content);
      },
    );
  }
}