using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("leitura")]
public class Leitura
{
    [Key]
    [Column("id")]
    public Guid Id {get; set; } = Guid.NewGuid();

    [Column("titulo")]
    public string Titulo {get; set; } = string.Empty;

    [Column("conteudo")]
    public string Conteudo {get; set; } = string.Empty;

    [Column("tipo")]
    public string Tipo {get; set; } = string.Empty;

    [Column("pontos_total")]
    public int PontosTotal  {get; set; } = 10;
}