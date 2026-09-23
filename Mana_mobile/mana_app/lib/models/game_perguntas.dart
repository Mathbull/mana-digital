import 'game_resposta.dart';

class GameQuestion {
  final String id;
  final String pergunta;
  final int ordem;
  final int pontos;
  final List<GameAnswer> respostas;

  const GameQuestion({
    required this.id,
    required this.pergunta,
    required this.ordem,
    required this.pontos,
    required this.respostas,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    final respostasJson =
        json['respostas'] as List<dynamic>? ?? [];

    return GameQuestion(
      id: json['id']?.toString() ?? '',
      pergunta: json['pergunta'] ?? '',
      ordem: json['ordem'] ?? 0,
      pontos: json['pontos'] ?? 2,
      respostas: respostasJson
          .map(
            (item) => GameAnswer.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}