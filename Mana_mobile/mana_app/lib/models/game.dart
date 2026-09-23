class Game {
  final String id;
  final String titulo;
  final String descricao;
  final int pontosTotal;
  final bool concluido;

  Game({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.pontosTotal,
    required this.concluido,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      pontosTotal: json['pontosTotal'] ?? 0,
      concluido: json['concluido'] ?? false,
    );
  }

  Game copyWith({
    String? id,
    String? titulo,
    String? descricao,
    int? pontosTotal,
    bool? concluido,
  }) {
    return Game(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      pontosTotal: pontosTotal ?? this.pontosTotal,
      concluido: concluido ?? this.concluido,
    );
  }
}