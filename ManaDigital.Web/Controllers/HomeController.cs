using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using ManaDigital.Web.Models;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Data;
using ManaDigital.Web.ViewModels;
using Microsoft.AspNetCore.Authentication.JwtBearer;

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

        // Busca todas as medalhas e verifica quais o usuário logado já desbloqueou
        var medalhasDoUsuario = await _context.UsuarioMedalhas
            .Where(um => um.UsuarioId == userID)
            .Select(um => um.MedalhaId)
            .ToListAsync();

        var todasMedalhas = await _context.Medalhas
            .AsNoTracking()
            .ToListAsync();

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

        model.Medalhas = todasMedalhas.Select(m => new MedalhaItemDto
        {
            Id = m.Id,
            Titulo = m.Titulo,
            Descricao = m.Descricao,
            Figurinha = m.Figurinha,
            Pontos = m.Pontos,
            Desbloqueada = medalhasDoUsuario.Contains(m.Id)
        }).ToList();

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

    // ============================================================
    // API DA HOME PARA O FLUTTER
    // ============================================================

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpGet("/api/home")]
    public async Task<IActionResult> ApiHome()
    {
        // 1. Recupera o ID do usuário através do JWT
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userID))
        {
            return Unauthorized(new
            {
                message = "Token inválido."
            });
        }

        // 2. Busca o usuário no banco
        var usuario = await _context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userID);

        if (usuario == null)
        {
            return NotFound(new
            {
                message = "Usuário não encontrado."
            });
        }

        // 3. Busca os totais disponíveis
        var totalLeituras = await _context.Leituras.CountAsync();
        var totalGames = await _context.Games.CountAsync();

        // Temporário enquanto a tabela de vídeos não existe
        var totalVideos = 10;

        // 4. Busca os conteúdos concluídos pelo usuário
        var logsUsuario = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(l => l.UsuarioId == userID)
            .Select(l => new
            {
                l.TipoConteudo,
                l.ConteudoId
            })
            .ToListAsync();

        var leiturasFeitas = logsUsuario
            .Where(l => l.TipoConteudo == "leitura")
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
            .Select(l => l.ConteudoId)
            .Distinct()
            .Count();

        // 5. Busca os rankings
        var rankings = await ObterRankingsAsync(userID);

        // 6. BUSCA AS CONQUISTAS / MEDALHAS
        // Medalhas já conquistadas pelo usuário
        var medalhasUsuario = await _context.UsuarioMedalhas
            .AsNoTracking()
            .Where(um => um.UsuarioId == userID)
            .ToListAsync();

        // Todas as medalhas existentes
        var todasMedalhas = await _context.Medalhas
            .AsNoTracking()
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();

        // Monta a lista completa de conquistas
        var conquistas = todasMedalhas
            .Select(m =>
            {
                var conquistaUsuario = medalhasUsuario
                    .FirstOrDefault(um => um.MedalhaId == m.Id);

                return new
                {
                    id = m.Id,
                    titulo = m.Titulo,
                    descricao = m.Descricao,
                    figurinha = m.Figurinha,
                    pontos = m.Pontos,

                    desbloqueada = conquistaUsuario != null,

                    dataConquista = conquistaUsuario?.DataConquista
                };
            })
            .ToList();
            var conquistasRecentes = conquistas
                .Where(c => c.desbloqueada)
                .OrderByDescending(c => c.dataConquista)
                .Take(3)
                .ToList();

        // 7. Retorna os dados para o Flutter
        return Ok(new
        {
            nome = usuario.Nome,
            apelido = usuario.Apelido,
            email = usuario.Email,
            cargo = usuario.Cargo,
            pontos = usuario.Pontos,

            totalLeituras = totalLeituras,
            leiturasConcluidas = leiturasFeitas,

            totalJogos = totalGames,
            jogosConcluidos = gamesFeitos,

            totalVideos = totalVideos,
            videosConcluidos = videosFeitos,

            rankings = rankings,

            totalConquistas = conquistas.Count,
            conquistasDesbloqueadas = conquistas.Count(c => c.desbloqueada),
            conquistasRecentes = conquistasRecentes,
            conquistas = conquistas

        });

    }
    
    // Ação para deslogar (sair)
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync();
        return RedirectToAction("Login", "Account");
    }

}
