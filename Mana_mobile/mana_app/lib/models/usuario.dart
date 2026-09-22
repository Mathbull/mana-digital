class Usuario {
  final String id;
  final String nome;
  final String email;
  final int pontos;
  final String? apelido;
  final String? cargo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.pontos,
    this.apelido,
    this.cargo,
  });

  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    int? pontos,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      pontos: pontos ?? this.pontos,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      apelido: json['apelido'],
      email: json['email'] ?? '',
      cargo: json['cargo'] ?? 'comum',
      pontos: json['pontos'] ?? 0,
    );
  }
}