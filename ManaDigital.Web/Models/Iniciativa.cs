using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("iniciativas")]
public class Iniciativa
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Column("usuario_id")]
    public Guid UsuarioId { get; set; }

    [Column("tipo")]
    public string Tipo { get; set; } = "livro_resumo"; // 'livro_resumo', 'linkedin', 'convite', 'acao_interna'

    [Column("titulo")]
    [Required]
    public string Titulo { get; set; } = string.Empty;

    [Column("descricao")]
    [Required]
    public string Descricao { get; set; } = string.Empty;

    [Column("anexo_url")]
    public string? AnexoUrl { get; set; }

    [Column("pontos_sugeridos")]
    public int PontosSugeridos { get; set; } = 50;

    [Column("pontos_atribuidos")]
    public int? PontosAtribuidos { get; set; }

    [Column("status")]
    public string Status { get; set; } = "pendente"; // 'pendente', 'aprovado', 'rejeitado'

    [Column("validado_por")]
    public Guid? ValidadoPor { get; set; }

    [Column("justificativa_admin")]
    public string? JustificativaAdmin { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("validado_em")]
    public DateTime? ValidadoEm { get; set; }

    // Relacionamentos
    [ForeignKey("UsuarioId")]
    public virtual Usuario? Usuario { get; set; }

    [ForeignKey("ValidadoPor")]
    public virtual Usuario? Administrador { get; set; }
}