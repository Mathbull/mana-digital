namespace ManaDigital.Web.ViewModels;

public class RankingItemDto
{
    public string Rank { get; set; } = string.Empty; // "1º", "2º", etc.
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty; // Cargo/Unidade
    public string Xp { get; set; } = string.Empty;   // "2.140 XP"
    public bool IsUser { get; set; }
}

public class RankingContainerDto
{
    public List<RankingItemDto> Semanal {get; set;} = new();
    public List<RankingItemDto> Mensal  {get; set;} = new();
    public List<RankingItemDto> Geral  {get; set;} = new();
}