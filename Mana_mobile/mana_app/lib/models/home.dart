import 'usuario.dart';

class HomeData {
  final Usuario usuario;

  final int totalLeituras;
  final int leiturasConcluidas;

  final int totalJogos;
  final int jogosConcluidos;

  final int totalVideos;
  final int videosConcluidos;

  final RankingContainer rankings;

  HomeData({
    required this.usuario,
    required this.totalLeituras,
    required this.leiturasConcluidas,
    required this.totalJogos,
    required this.jogosConcluidos,
    required this.totalVideos,
    required this.videosConcluidos,
    required this.rankings,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      usuario: Usuario(
        id: '',
        nome: json['nome'] ?? '',
        apelido: json['apelido'],
        email: json['email'] ?? '',
        cargo: json['cargo'] ?? 'comum',
        pontos: json['pontos'] ?? 0,
      ),

      totalLeituras: json['totalLeituras'] ?? 0,
      leiturasConcluidas: json['leiturasConcluidas'] ?? 0,

      totalJogos: json['totalJogos'] ?? 0,
      jogosConcluidos: json['jogosConcluidos'] ?? 0,

      totalVideos: json['totalVideos'] ?? 0,
      videosConcluidos: json['videosConcluidos'] ?? 0,

      rankings: RankingContainer.fromJson(
        json['rankings'] ?? {},
      ),
    );
  }
}

class RankingContainer {
  final List<RankingItem> geral;
  final List<RankingItem> semanal;
  final List<RankingItem> mensal;

  RankingContainer({
    required this.geral,
    required this.semanal,
    required this.mensal,
  });

  factory RankingContainer.fromJson(Map<String, dynamic> json) {
    return RankingContainer(
      geral: _parseRanking(json['geral']),
      semanal: _parseRanking(json['semanal']),
      mensal: _parseRanking(json['mensal']),
    );
  }

  static List<RankingItem> _parseRanking(dynamic data) {
    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => RankingItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}

class RankingItem {
  final String rank;
  final String name;
  final String role;
  final String xp;
  final bool isUser;

  RankingItem({
    required this.rank,
    required this.name,
    required this.role,
    required this.xp,
    required this.isUser,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    return RankingItem(
      rank: json['rank'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      xp: json['xp'] ?? '0 XP',
      isUser: json['isUser'] ?? false,
    );
  }
}