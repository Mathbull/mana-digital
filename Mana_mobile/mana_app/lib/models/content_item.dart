import 'package:flutter/material.dart';

class ContentItem {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria;
  final int pontos;

  final String? filtro;
  final int? tempoLeitura;
  final String? referencia;
  final IconData? icone;

  final bool concluida;
  final List<Pergunta> perguntas;

  ContentItem({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.pontos,
    this.referencia,
    this.icone,
    this.tempoLeitura,
    this.filtro,
    this.concluida = false,
    this.perguntas = const [],
  });

  ContentItem copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? categoria,
    int? pontos,
    String? filtro,
    int? tempoLeitura,
    String? referencia,
    IconData? icone,
    bool? concluida,
    List<Pergunta>? perguntas,
  }) {
    return ContentItem(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      pontos: pontos ?? this.pontos,
      filtro: filtro ?? this.filtro,
      tempoLeitura: tempoLeitura ?? this.tempoLeitura,
      referencia: referencia ?? this.referencia,
      icone: icone ?? this.icone,
      concluida: concluida ?? this.concluida,
      perguntas: perguntas ?? this.perguntas,
    );
  }

  static String formatarCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'TRECHO_LIVRO':
        return 'Trecho de Livros';

      case 'FATO_ATUAL':
        return 'Fato';

      case 'ARTIGO_LEI':
        return 'Artigos de Lei';

      default:
        return categoria;
    }
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id']?.toString() ?? '',

      titulo: json['titulo'] ?? '',

      descricao: json['conteudo'] ?? '',

      categoria: formatarCategoria(json['tipo'] ?? '',),

      filtro: formatarCategoria(json['tipo'] ?? '',),

      pontos: json['pontosTotal'] ?? 0,

      tempoLeitura: json['tempoMinutos'] ?? 2,

      concluida: json['concluida'] ?? false,

      perguntas: (json['perguntas'] as List<dynamic>? ?? [])
          .map(
            (pergunta) => Pergunta.fromJson(
              pergunta as Map<String, dynamic>,
            ),
          )
          .toList(),

      referencia: json['referencia'],
    );
  }
}

class Pergunta {
  final String id;
  final String afirmacao;
  final String explicacao;

  Pergunta({
    required this.id,
    required this.afirmacao,
    required this.explicacao,
  });

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id']?.toString() ?? '',
      afirmacao: json['afirmacao'] ?? '',
      explicacao: json['explicacao'] ?? '',
    );
  }
}