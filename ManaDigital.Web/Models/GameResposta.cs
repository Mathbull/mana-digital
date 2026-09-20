using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("game_respostas")]
public class GameResposta
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Column("pergunta_id")]
    public Guid PerguntaId { get; set; }

    [Column("resposta")]
    public string Resposta { get; set; } = string.Empty;

    [Column("is_correta")]
    public bool IsCorreta { get; set; }

    // Relacionamento com a pergunta pai
    [ForeignKey("PerguntaId")]
    public virtual GamePergunta? Pergunta { get; set; }
}