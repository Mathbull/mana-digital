using ManaDigital.Web.Models;

namespace ManaDigital.Web.ViewModels;

public class IniciativasViewModel : HomeViewModel
{
    public bool IsAdmin { get; set; }

    // Minhas submissões (para o colaborador acompanhar o status)
    public List<IniciativaItemDto> MinhasIniciativas { get; set; } = new();

    // Fila de Moderação (exclusiva para administradores)
    public List<IniciativaItemDto> FilaModeracao { get; set; } = new();
}

public class IniciativaItemDto
{
    public Guid Id { get; set; }
    public string ColaboradorNome { get; set; } = string.Empty;
    public string Tipo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public string? AnexoUrl { get; set; }
    public int PontosSugeridos { get; set; }
    public int? PontosAtribuidos { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? JustificativaAdmin { get; set; }
    public DateTime DataEnvio { get; set; }
}

public class NovaIniciativaDto
{
    public string Tipo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public string? AnexoUrl { get; set; }
}

public class DecisaoModeracaoDto
{
    public Guid IniciativaId { get; set; }
    public bool Aprovado { get; set; }
    public int Pontos { get; set; }
    public string? Justificativa { get; set; }
}