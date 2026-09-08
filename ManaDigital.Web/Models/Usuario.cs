using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ManaDigital.Web.Models;

[Table("usuarios")]
public class Usuario
{
    [Key]
    [Column("id")]
    public Guid Id {get; set;} = Guid.NewGuid();

    [Column("email")]
    [Required]
    public string Email {get; set;} = string.Empty;

    [Column("senha_hash")]
    [Required]
    public string SenhaHash {get; set;} = string.Empty;

    [Column("nome")]
    [Required]
    public string Nome {get; set;} = string.Empty;

    [Column("apelido")]
    public string Apelido {get; set;} = string.Empty;

    [Column("cargo")] 
    public string Cargo {get; set;} = "comum"; // 'comum' ou 'adm'

    [Column("pontos")]
    public int Pontos {get; set;} = 50;  // Começa com os 50 XP do bônus!

    [Column("convidado_por")]
    public string? ConvidadoPor { get; set; }

    [Column("data_criacao")]
    public DateTime DataCriacao {get; set;} = DateTime.UtcNow;

}