using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("historico_pontuacao_log")]
public class HistoricoPontuacaoLog
{
    [Key]
    [Column("id")]
    public Guid? Id { get; set; } = Guid.NewGuid();

    [Column("usuario_id")]
    public Guid UsuarioId { get; set; }

    [Column("tipo_conteudo")]
    public string TipoConteudo { get; set; } = string.Empty; // "leitura", "video", "game"

    [Column("conteudo_id")]
    public Guid? ConteudoId { get; set; }

    [Column("pontos_ganhos")]
    public int PontosGanhos { get; set; }

    [Column("descricao")]
    public string Descricao { get; set; } = string.Empty;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}