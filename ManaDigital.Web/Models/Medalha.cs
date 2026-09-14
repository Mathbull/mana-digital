using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("medalhas")]
public class Medalha
{
    [Column("id")]
    public Guid Id { get; set; }

    [Column("titulo")]
    public string Titulo { get; set; } = string.Empty;

    [Column("descricao")]
    public string Descricao { get; set; } = string.Empty;

    [Column("figurinha")]
    public string Figurinha { get; set; } = string.Empty;

    [Column("pontos")]
    public int Pontos { get; set; }

    [Column("codigo_criterio")]
    public string CodigoCriterio { get; set; } = string.Empty;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}