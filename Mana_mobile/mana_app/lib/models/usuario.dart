class Usuario {
  final String id;
  final String nome;
  final String? apelido;
  final String email;
  final String cargo;
  final int pontos;

  Usuario({
    required this.id,
    required this.nome,
    this.apelido,
    required this.email,
    required this.cargo,
    required this.pontos,
  });

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