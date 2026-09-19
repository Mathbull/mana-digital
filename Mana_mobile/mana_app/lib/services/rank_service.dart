class RankInfo {
  final String nome;
  final int pontosMinimos;

  RankInfo({
    required this.nome,
    required this.pontosMinimos
  });
}

class RankService {
  static List<RankInfo> ranks = [
    RankInfo(nome: 'Bronze', pontosMinimos: 0),
    RankInfo(nome: 'Prata', pontosMinimos: 100),
    RankInfo(nome: 'Ouro', pontosMinimos: 300),
    RankInfo(nome: 'Diamante', pontosMinimos: 1000),
  ];

  static RankInfo getRank(int pontos) {
    RankInfo rankAtual = ranks.first;

    for (final rank in ranks) {
      if (pontos >= rank.pontosMinimos) {
        rankAtual = rank;
      }
    }

    return rankAtual;
  }
  static bool isUnlocked(int pontos, RankInfo rank) {
    return pontos >= rank.pontosMinimos;
  }

  static RankInfo? getNextRank(int pontos) {
    for (final rank in ranks) {
      if (pontos < rank.pontosMinimos) {
        return rank;
      }
    }

    return null;
  }
}