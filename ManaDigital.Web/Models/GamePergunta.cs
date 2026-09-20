using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("game_perguntas")]
public class GamePergunta
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Column("game_id")]
    public Guid GameId { get; set; }

    [Column("pergunta")]
    public string Pergunta { get; set; } = string.Empty;

    [Column("pontos")]
    public int Pontos { get; set; } = 2;

    [Column("ordem")]
    public int Ordem { get; set; }

    // Relacionamentos
    [ForeignKey("GameId")]
    public virtual Game? Game { get; set; }

    public virtual ICollection<GameResposta> Respostas { get; set; } = new List<GameResposta>();
}