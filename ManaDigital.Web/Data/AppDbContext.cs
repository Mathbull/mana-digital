using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Models;

namespace ManaDigital.Web.Data;

public class AppDbContext: DbContext
{
    public AppDbContext(DbContextOptions <AppDbContext> options): base(options) { }

    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Leitura> Leituras => Set<Leitura>();
    public DbSet<Game> Games => Set<Game>();
    public DbSet<HistoricoPontuacaoLog> HistoricoLogs => Set<HistoricoPontuacaoLog>();
    public DbSet<UsuarioMedalha> UsuarioMedalhas => Set<UsuarioMedalha>();
    public DbSet<Medalha> Medalhas => Set<Medalha>();
    public DbSet<LeituraResposta> LeituraRespostas => Set<LeituraResposta>();
}