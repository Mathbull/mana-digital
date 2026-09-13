using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using ManaDigital.Web.Models;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Data;
using ManaDigital.Web.ViewModels;

namespace ManaDigital.Web.Controllers;

[Authorize] // Só acessa se estiver autenticado no sistema!
public class HomeController : Controller
{
    
    private readonly AppDbContext _context;

    // Injeta o banco no Controller
    public HomeController(AppDbContext context)
    {
        _context = context;
    }

    public async  Task<IActionResult> Index()
    {
        // 1. Resgata o ID que foi gravado no Claim
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userID))
        {
            return RedirectToAction("Login", "Account");
        }

        // 2. Busca do SupaBase os dados ATUTALIZADOS do user
        // AsNoTracking() deixa a consulta mais rápida pois é apenas leitura
        var usuario = await _context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id ==userID);
        
        if (usuario == null)
        {
            return RedirectToAction("Login", "Account");
        }

        // 3. Busca totais de conteúdos disponíveis no sistema
        var totalLeituras = await _context.Leituras.CountAsync();
        var totalGames = await _context.Games.CountAsync();
        var totalVideos = 10; // Exemplo fixo provisório enquanto não cria a tabela de vídeos
        
        // 3. Busca o que ESSE usuário já concluiu olhando o log (usando Distinct para não contar repetido)
        var logsUsuario = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(l => l.UsuarioId == userID)
            .Select(l => new {l.TipoConteudo, l.ConteudoId})
            .ToListAsync();
            
        var leiturasFeitas = logsUsuario
            .Where(l=> l.TipoConteudo == "leitura")
            .Select(l => l.ConteudoId)
            .Distinct()
            .Count();

        var gamesFeitos = logsUsuario
            .Where(l => l.TipoConteudo == "game")
            .Select(l => l.ConteudoId)
            .Distinct()
            .Count();
        
        var videosFeitos = logsUsuario
            .Where(l => l.TipoConteudo == "video")
            .Select ( l => l.ConteudoId)
            .Distinct()
            .Count();

        // 4. Monta o ViewModel com os dados frescos do banco
        var model = new HomeViewModel
        {
            Nome = usuario.Nome,
            Apelido = usuario.Apelido,
            Pontos = usuario.Pontos,

            TotalLeituras = totalLeituras,
            LeiturasConcluidas = leiturasFeitas,

            TotalJogos = totalGames,
            JogosConcluidos = gamesFeitos,

            TotalVideos = totalVideos,
            VideosConcluidos = videosFeitos
        };
        model.Rankings = await ObterRankingsAsync(userID);

        // 4. Envia o modelo para a View
        return View(model);
    }

    private async Task<RankingContainerDto> ObterRankingsAsync(Guid usuarioLogadoId)
    {
        var container = new RankingContainerDto();
        var agora = DateTime.UtcNow;
        var seteDiasAtras = agora.AddDays(-7);
        var trintaDiasAtras = agora.AddDays(-30);

        // 1. RANKING GERAL (Direto da tabela de usuários)
        var topGeral = await _context.Usuarios
            .AsNoTracking()
            .OrderByDescending(u => u.Pontos)
            .Take(5)
            .ToListAsync();
        
        container.Geral = topGeral.Select((u, index) => new RankingItemDto
        {
            Rank = $"{index + 1}º",
            Name = u.Apelido,
            Role = u.Cargo == "adm" ? "Diretoria ESG" : "Operações",
            Xp = $"{u.Pontos:N0} XP",
            IsUser = (u.Id == usuarioLogadoId)
        }).ToList();

        // Função local para buscar rankings por período de forma compatível com EF Core / PostgreSQL
        async Task<List<RankingItemDto>> ObterRankingPeriodoAsync(DateTime dataCorte)
        {
            // 1. O EF Core agrupa e soma no banco apenas a tabela de logs (100% traduzível para SQL)
            var topLogs = await _context.HistoricoLogs
                .AsNoTracking()
                .Where(l => l.CreatedAt >= dataCorte)
                .GroupBy(l => l.UsuarioId)
                .Select(g => new
                {
                    UsuarioId = g.Key,
                    TotalXp = g.Sum(x => x.PontosGanhos)
                })
                .OrderByDescending(x => x.TotalXp)
                .Take(5)
                .ToListAsync();

            if (!topLogs.Any())
                return new List<RankingItemDto>();

            // 2. Busca no banco apenas os usuários que entraram no Top 5
            var userIds = topLogs.Select(x => x.UsuarioId).ToList();
            var usuarios = await _context.Usuarios
                .AsNoTracking()
                .Where(u => userIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id);

            // 3. Monta o DTO preservando a ordem da pontuação
            return topLogs
                .Where(x => usuarios.ContainsKey(x.UsuarioId))
                .Select((item, index) =>
                {
                    var u = usuarios[item.UsuarioId];
                    return new RankingItemDto
                    {
                        Rank = $"{index + 1}º",
                        Name = u.Apelido,
                        Role = u.Cargo == "adm" ? "Diretoria ESG" : "Operações",
                        Xp = $"{item.TotalXp:N0} XP",
                        IsUser = (u.Id == usuarioLogadoId)
                    };
                })
                .ToList();
        }

        // 2. RANKING SEMANAL (Últimos 7 dias)
        container.Semanal = await ObterRankingPeriodoAsync(seteDiasAtras);

        // 3. RANKING MENSAL (Últimos 30 dias)
        container.Mensal = await ObterRankingPeriodoAsync(trintaDiasAtras);

        // Se ainda não houver dados no log para o período, mantém o geral como fallback
        if (!container.Semanal.Any()) container.Semanal = container.Geral;
        if (!container.Mensal.Any()) container.Mensal = container.Geral;

        return container;
    }

    // Ação para deslogar (sair)
     public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync();
        return RedirectToAction("Login", "Account");
    }
}
