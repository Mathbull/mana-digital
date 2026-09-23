class GameAnswer {
  final String id;
  final String resposta;

  const GameAnswer({
    required this.id,
    required this.resposta,
  });

  factory GameAnswer.fromJson(Map<String, dynamic> json) {
    return GameAnswer(
      id: json['id']?.toString() ?? '',
      resposta: json['resposta'] ?? '',
    );
  }
}