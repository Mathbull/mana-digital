using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("games")]
public class Game
{
    [Key]
    [Column("id")]
    public Guid Id {get; set;} = Guid.NewGuid();

    [Column("titulo")]
    public string Titulo {get; set;} = string.Empty;

    [Column("descricao")]
    public string Descricao {get; set;} = string.Empty;

    [Column("pontos_total")]
    public int Pontos_total {get; set;} = 10;
}