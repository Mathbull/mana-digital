namespace ManaDigital.Web.ViewModels;

// Para a tela de listagem de Quizzes (/Jogos)
public class JogosViewModel : HomeViewModel
{
    public int TotalJogos { get; set; }
    public int JogosConcluidos { get; set; }
    public List<GameCardDto> Games { get; set; } = new();
}

public class GameCardDto
{
    public Guid Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public int PontosTotal { get; set; }
    public bool Concluido { get; set; }
}

// Para a tela do Simulador / Player (/Jogos/Jogar/{id})
public class GamePlayViewModel : HomeViewModel
{
    public Guid GameId { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public int PontosTotal { get; set; }
    public bool JaConcluido { get; set; }
    public List<PerguntaPlayDto> Perguntas { get; set; } = new();
}

public class PerguntaPlayDto
{
    public Guid Id { get; set; }
    public string Pergunta { get; set; } = string.Empty;
    public int Ordem { get; set; }
    public int Pontos { get; set; } = 2;
    public List<RespostaPlayDto> Respostas { get; set; } = new();
}

public class RespostaPlayDto
{
    public Guid Id { get; set; }
    public string Resposta { get; set; } = string.Empty;
    public bool IsCorreta { get; set; }
}

// DTO para receber a submissão final do jogo via AJAX
public class SubmissaoGameDto
{
    public Guid GameId { get; set; }
    public Dictionary<Guid, Guid> RespostasSelecionadas { get; set; } = new(); // PerguntaId -> RespostaId
}