import 'game_perguntas.dart';

class GameDetails {
  final String id;
  final String titulo;
  final String descricao;
  final int pontosTotal;
  final List<GameQuestion> perguntas;

  const GameDetails({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.pontosTotal,
    required this.perguntas,
  });

  factory GameDetails.fromJson(Map<String, dynamic> json) {
    final perguntasJson =
        json['perguntas'] as List<dynamic>? ?? [];

    return GameDetails(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      pontosTotal: json['pontosTotal'] ?? 0,
      perguntas: perguntasJson
          .map(
            (item) => GameQuestion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}