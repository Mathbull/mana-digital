using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("games")]
public class Game
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Column("titulo")]
    public string Titulo { get; set; } = string.Empty;

    [Column("descricao")]
    public string Descricao { get; set; } = string.Empty;

    [Column("pontos_total")]
    public int PontosTotal { get; set; } = 10;

    // Relacionamento 1:N com as perguntas do jogo
    public virtual ICollection<GamePergunta> Perguntas { get; set; } = new List<GamePergunta>();
}