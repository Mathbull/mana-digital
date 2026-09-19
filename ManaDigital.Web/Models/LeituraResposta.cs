using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("leitura_respostas")]
public class LeituraResposta
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Column("leitura_id")]
    public Guid LeituraId { get; set; }

    [Column("afirmacao")]
    public string Afirmacao { get; set; } = string.Empty;

    [Column("is_correta")]
    public bool IsCorreta { get; set; }

    [Column("pontos")]
    public int Pontos { get; set; } = 5;

    [Column("explicacao")]
    public string Explicacao { get; set; } = string.Empty;
}