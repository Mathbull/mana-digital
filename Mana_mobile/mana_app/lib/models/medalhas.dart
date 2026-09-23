class Medalhas {
  final String id;

  final String titulo;

  final String descricao;

  final String figurinha;

  final int pontos;

  final bool desbloqueada;

  final DateTime? dataConquista;

  const Medalhas({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.figurinha,
    required this.pontos,
    required this.desbloqueada,
    this.dataConquista,
  });

  // ============================================================
  // JSON -> MODEL
  // ============================================================

  factory Medalhas.fromJson(
    Map<String, dynamic> json,
  ) {
    return Medalhas(
      id: json['id']?.toString() ?? '',

      titulo:
          json['titulo']?.toString() ?? '',

      descricao:
          json['descricao']?.toString() ?? '',

      figurinha:
          json['figurinha']?.toString() ?? '',

      pontos:
          (json['pontos'] as num?)
                  ?.toInt() ??
              0,

      desbloqueada:
          json['desbloqueada'] == true,

      dataConquista:
          json['dataConquista'] != null
              ? DateTime.tryParse(
                  json['dataConquista']
                      .toString(),
                )
              : null,
    );
  }

  // ============================================================
  // MODEL -> JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'figurinha': figurinha,
      'pontos': pontos,
      'desbloqueada': desbloqueada,
      'dataConquista':
          dataConquista?.toIso8601String(),
    };
  }

  // ============================================================
  // AUXILIARES
  // ============================================================

  String get statusLabel {
    return desbloqueada
        ? 'Conquistada'
        : 'Bloqueada';
  }

  String get pontosLabel {
    return '+$pontos XP';
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Medalhas copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? figurinha,
    int? pontos,
    bool? desbloqueada,
    DateTime? dataConquista,
  }) {
    return Medalhas(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao:
          descricao ?? this.descricao,
      figurinha:
          figurinha ?? this.figurinha,
      pontos:
          pontos ?? this.pontos,
      desbloqueada:
          desbloqueada ??
              this.desbloqueada,
      dataConquista:
          dataConquista ??
              this.dataConquista,
    );
  }
}