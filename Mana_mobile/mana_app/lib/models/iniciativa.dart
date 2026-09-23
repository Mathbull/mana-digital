class Iniciativa {
  
  final String id;
  final String? colaboradorNome;
  final String tipo;
  final String titulo;
  final String descricao;
  final String? anexoUrl;
  final int pontosSugeridos;
  final int? pontosAtribuidos;
  final String status;
  final String? justificativaAdmin;
  final DateTime? dataEnvio;

  const Iniciativa({
    required this.id,
    this.colaboradorNome,
    required this.tipo,
    required this.titulo,
    required this.descricao,
    this.anexoUrl,
    required this.pontosSugeridos,
    this.pontosAtribuidos,
    required this.status,
    this.justificativaAdmin,
    this.dataEnvio,
  });

  factory Iniciativa.fromJson(
    Map<String, dynamic> json,
  ) {
    return Iniciativa(
      id: json['id']?.toString() ?? '',
      colaboradorNome:json['colaboradorNome']?.toString(),
      tipo:json['tipo']?.toString() ?? '',
      titulo:json['titulo']?.toString() ?? '',
      descricao:json['descricao']?.toString() ?? '',
      anexoUrl:json['anexoUrl']?.toString(),
      pontosSugeridos:(json['pontosSugeridos'] as num?) ?.toInt() ?? 0,
      pontosAtribuidos:(json['pontosAtribuidos'] as num?) ?.toInt(),
      status: json['status']?.toString() ?? 'pendente',

      justificativaAdmin:json['justificativaAdmin'] ?.toString(),

      dataEnvio: json['dataEnvio'] != null ? DateTime.tryParse
        (
          json['dataEnvio'].toString(),
        ): null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colaboradorNome': colaboradorNome,
      'tipo': tipo,
      'titulo': titulo,
      'descricao': descricao,
      'anexoUrl': anexoUrl,
      'pontosSugeridos': pontosSugeridos,
      'pontosAtribuidos': pontosAtribuidos,
      'status': status,
      'justificativaAdmin':
          justificativaAdmin,
      'dataEnvio':
          dataEnvio?.toIso8601String(),
    };
  }

  bool get pendente => status.toLowerCase() == 'pendente';
  bool get aprovada => status.toLowerCase() == 'aprovado';
  bool get rejeitada => status.toLowerCase() == 'rejeitado';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return 'Aprovado';

      case 'rejeitado':
        return 'Rejeitado';

      case 'pendente':
      default:
        return 'Em análise';
    }
  }

  String get tipoLabel {
    switch (tipo.toLowerCase()) {
      case 'livro_resumo':
        return 'Leitura Antirracista';

      case 'convite':
        return 'Indicação de Colega';

      case 'linkedin':
        return 'LinkedIn';

      case 'acao_interna':
        return 'Ação Interna';

      default:
        return tipo
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }

  int get pontos { 
    if (aprovada) {
      return pontosAtribuidos
      ??  pontosSugeridos;
    }
    return pontosSugeridos;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Iniciativa copyWith({
    String? id,
    String? colaboradorNome,
    String? tipo,
    String? titulo,
    String? descricao,
    String? anexoUrl,
    int? pontosSugeridos,
    int? pontosAtribuidos,
    String? status,
    String? justificativaAdmin,
    DateTime? dataEnvio,
  }) {
    return Iniciativa(
      id: id ?? this.id,
      colaboradorNome:
          colaboradorNome ??
              this.colaboradorNome,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descricao:
          descricao ?? this.descricao,
      anexoUrl:
          anexoUrl ?? this.anexoUrl,
      pontosSugeridos:
          pontosSugeridos ??
              this.pontosSugeridos,
      pontosAtribuidos:
          pontosAtribuidos ??
              this.pontosAtribuidos,
      status: status ?? this.status,
      justificativaAdmin:
          justificativaAdmin ??
              this.justificativaAdmin,
      dataEnvio:
          dataEnvio ?? this.dataEnvio,
    );
  }
}