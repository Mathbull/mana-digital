using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("usuario_medalhas")]
public class UsuarioMedalha
{
    [Column("id")]
    public Guid Id { get; set; }

    [Column("usuario_id")]
    public Guid UsuarioId { get; set; }

    [Column("medalha_id")]
    public Guid MedalhaId { get; set; }

    [Column("data_conquista")]
    public DateTime DataConquista { get; set; } = DateTime.UtcNow;

    // Navegações opcionais
    public virtual Medalha? Medalha { get; set; }
    public virtual Usuario? Usuario { get; set; }
}