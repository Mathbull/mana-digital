using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Models;

namespace ManaDigital.Web.Data;

public class AppDbContext: DbContext
{
    public AppDbContext(DbContextOptions <AppDbContext> options): base(options) { }

    public DbSet<Usuario> Usuarios => Set<Usuario>();

    public DbSet<Leitura> Leituras => Set<Leitura>();
    public DbSet<LeituraResposta> LeituraRespostas => Set<LeituraResposta>();


    public DbSet<Game> Games => Set<Game>();
    public DbSet<GamePergunta> GamePerguntas => Set<GamePergunta>();
    public DbSet<GameResposta> GameRespostas => Set<GameResposta>();

    public DbSet<UsuarioMedalha> UsuarioMedalhas => Set<UsuarioMedalha>();
    public DbSet<Medalha> Medalhas => Set<Medalha>();

    public DbSet<HistoricoPontuacaoLog> HistoricoLogs => Set<HistoricoPontuacaoLog>();

    public DbSet<Iniciativa> Iniciativas => Set<Iniciativa>();
}