class Pergunta {
  final int id;
  final String texto;
  final List<Alternativa> alternativas;

  Pergunta({
    required this.id,
    required this.texto,
    required this.alternativas,
  });

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'] ?? 0,
      texto: json['pergunta'] ?? json['texto'] ?? '',
      alternativas: (json['alternativas'] as List<dynamic>? ?? [])
          .map(
            (item) => Alternativa.fromJson(item),
          )
          .toList(),
    );
  }
}

class Alternativa {
  final String texto;
  final bool isCorrect;

  Alternativa({
    required this.texto,
    required this.isCorrect,
  });

  factory Alternativa.fromJson(Map<String, dynamic> json) {
    return Alternativa(
      texto: json['texto'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}