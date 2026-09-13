namespace ManaDigital.Web.ViewModels;

public class HomeViewModel
{
    public string Nome { get; set; } = string.Empty;
    public string Apelido { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Cargo { get; set; } = string.Empty;
    public int Pontos { get; set; }

    // --- Métricas de Desempenho (Card de Performance) ---
    // Leituras
    public int LeiturasConcluidas { get; set; }
    public int TotalLeituras { get; set; }
    public int PercentualLeituras => TotalLeituras > 0 ? (int)Math.Round((double)LeiturasConcluidas / TotalLeituras * 100) : 0;

    // Vídeos (caso ainda não tenha a tabela de vídeos, pode deixar default ou estático por enquanto)
    public int VideosConcluidos { get; set; }
    public int TotalVideos { get; set; }
    public int PercentualVideos => TotalVideos > 0 ? (int)Math.Round((double)VideosConcluidos / TotalVideos * 100) : 0;

    // Jogos / Quizzes
    public int JogosConcluidos { get; set; }
    public int TotalJogos { get; set; }
    public int PercentualJogos => TotalJogos > 0 ? (int)Math.Round((double)JogosConcluidos / TotalJogos * 100) : 0;

    // Ranking
    public RankingContainerDto Rankings { get; set; } = new();



    // Patente atual
    public string Patente => Pontos switch
    {
        >= 1000 => "Diamante",
        >= 300 => "Ouro",
        >= 100 => "Prata",
        _ => "Bronze"
    };
    
    public string ProximaPatente => Pontos switch
    {
        >= 300 => "Diamante",
        >= 100 => "Ouro",
        _ => "Prata"
    };

    // Pontuação necessária para desbloquear a próxima patente
    public int PontosProximaPatente => Pontos switch
    {
        >= 1000 => 1000,
        >= 300 => 1000,
        >= 100 => 300,
        _ => 100
    };

    // Início da patente atual
    public int PontosInicioPatente => Pontos switch
    {
        >= 1000 => 1000,
        >= 300 => 300,
        >= 100 => 100,
        _ => 0
    };

     public int ProximoNivelPontos => Pontos switch
    {
        >= 600 => (1000 - Pontos),
        >= 300 => (600 - Pontos),
        >= 100 => (300 -Pontos),
        _ => (100 - Pontos)
    };

    // Progresso dentro da patente atual
    public int ProgressoPercentual
    {
        get
        {
            if (Pontos >= 1000)
                return 100;

            var pontosNaPatente = Pontos - PontosInicioPatente;
            var pontosNecessarios = PontosProximaPatente - PontosInicioPatente;

            return (pontosNaPatente * 100) / pontosNecessarios;
        }
    }

    // Percentual Global (Média ponderada do que já foi feito)
    public double PercentualGlobal
    {
        get
        {
            int totalItens = TotalLeituras + TotalVideos + TotalJogos;
            int totalFeitos = LeiturasConcluidas + VideosConcluidos + JogosConcluidos;
            return totalItens > 0 ? Math.Round(((double)totalFeitos / totalItens) * 100, 1) : 0.0;
        }
    }
}