namespace ManaDigital.Web.ViewModels;

public class LeiturasViewModel : HomeViewModel
{
    public int TotalConcluidas { get; set; }
    public int TotalGeral { get; set; }
    public int PontosUsuario { get; set; }
    public List<LeituraCardItemDto> Leituras { get; set; } = new();
}

public class LeituraCardItemDto
{
    public Guid Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Conteudo { get; set; } = string.Empty;
    public string Tipo { get; set; } = string.Empty; // "artigo_lei", "trecho_livro", "esg"
    public int PontosTotal { get; set; }
    public bool Concluida { get; set; }
    public int TempoMinutos => Math.Max(2, Conteudo.Split(' ').Length / 80); // estimativa de leitura
    public List<PerguntaDto> Perguntas { get; set; } = new();
}

public class PerguntaDto
{
    public Guid Id { get; set; }
    public string Afirmacao { get; set; } = string.Empty;
    public bool IsCorreta { get; set; }
    public string Explicacao { get; set; } = string.Empty;
}

public class SubmissaoLeituraDto
{
    public Guid LeituraId { get; set; }
    public Dictionary<Guid, bool> Respostas { get; set; } = new();
}