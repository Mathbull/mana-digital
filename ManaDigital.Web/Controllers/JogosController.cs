using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Data;
using ManaDigital.Web.Models;
using ManaDigital.Web.Services;
using ManaDigital.Web.ViewModels;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace ManaDigital.Web.Controllers;

[Authorize]
public class JogosController : Controller
{
    private readonly AppDbContext _context;
    private readonly MedalhaService _medalhaService;

    public JogosController(AppDbContext context, MedalhaService medalhaService)
    {
        _context = context;
        _medalhaService = medalhaService;
    }

    // 1. TELA DE LISTAGEM DOS JOGOS (Estilo Leituras)
    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId)) return RedirectToAction("Login", "Account");

        var usuario = await _context.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId);
        if (usuario == null) return RedirectToAction("Login", "Account");

        // Busca quais quizzes o usuário já completou no log
        var jogosConcluidosIds = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(l => l.UsuarioId == userId && l.TipoConteudo == "game" && l.ConteudoId != null)
            .Select(l => l.ConteudoId!.Value)
            .Distinct()
            .ToListAsync();

        var gamesDb = await _context.Games.AsNoTracking().OrderBy(g => g.Titulo).ToListAsync();

        var viewModel = new JogosViewModel
        {
            Nome = usuario.Nome,
            Apelido = usuario.Apelido,
            Email = usuario.Email,
            Cargo = usuario.Cargo,
            Pontos = usuario.Pontos,
            TotalJogos = gamesDb.Count,
            JogosConcluidos = jogosConcluidosIds.Count,
            Games = gamesDb.Select(g => new GameCardDto
            {
                Id = g.Id,
                Titulo = g.Titulo,
                Descricao = g.Descricao,
                PontosTotal = g.PontosTotal,
                Concluido = jogosConcluidosIds.Contains(g.Id)
            }).ToList()
        };

        return View(viewModel);
    }

    // 2. TELA DO SIMULADOR (O player interativo)
    [HttpGet]
    public async Task<IActionResult> Jogar(Guid id)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId)) return RedirectToAction("Login", "Account");

        var usuario = await _context.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId);
        if (usuario == null) return RedirectToAction("Login", "Account");

        var game = await _context.Games
            .Include(g => g.Perguntas.OrderBy(p => p.Ordem))
                .ThenInclude(p => p.Respostas)
            .AsNoTracking()
            .FirstOrDefaultAsync(g => g.Id == id);

        if (game == null) return NotFound("Quiz não encontrado.");

        var jaConcluido = await _context.HistoricoLogs
            .AnyAsync(l => l.UsuarioId == userId && l.TipoConteudo == "game" && l.ConteudoId == id);

        var viewModel = new GamePlayViewModel
        {
            Nome = usuario.Nome,
            Apelido = usuario.Apelido,
            Email = usuario.Email,
            Cargo = usuario.Cargo,
            Pontos = usuario.Pontos,
            GameId = game.Id,
            Titulo = game.Titulo,
            Descricao = game.Descricao,
            PontosTotal = game.PontosTotal,
            JaConcluido = jaConcluido,
            Perguntas = game.Perguntas.Select(p => new PerguntaPlayDto
            {
                Id = p.Id,
                Pergunta = p.Pergunta,
                Ordem = p.Ordem,
                Pontos = p.Pontos,
                Respostas = p.Respostas.Select(r => new RespostaPlayDto
                {
                    Id = r.Id,
                    Resposta = r.Resposta,
                    IsCorreta = r.IsCorreta
                }).ToList()
            }).ToList()
        };

        return View(viewModel);
    }

    // 3. FINALIZAR O JOGO E SALVAR OS PONTOS
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Finalizar([FromBody] SubmissaoGameDto submissao)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId)) return Unauthorized();

        var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Id == userId);
        if (usuario == null) return NotFound();

        // Se já pontuou nesse jogo antes, bloqueia nova concessão de XP
        var jaPontuou = await _context.HistoricoLogs
            .AnyAsync(l => l.UsuarioId == userId && l.TipoConteudo == "game" && l.ConteudoId == submissao.GameId);

        if (jaPontuou)
        {
            return BadRequest(new { message = "Você já concluiu este quiz anteriormente. Os pontos já foram creditados." });
        }

        var game = await _context.Games.FirstOrDefaultAsync(g => g.Id == submissao.GameId);
        if (game == null) return NotFound("Quiz não encontrado.");

        // Busca as respostas corretas do banco para conferir
        var respostasIds = submissao.RespostasSelecionadas.Values.ToList();
        var respostasCorretas = await _context.GameRespostas
            .Where(r => respostasIds.Contains(r.Id) && r.IsCorreta)
            .CountAsync();

        // Cada acerto vale 2 pontos
        int pontosGanhos = respostasCorretas * 2;

        // Registra no Log Contábil
        var log = new HistoricoPontuacaoLog
        {
            Id = Guid.NewGuid(),
            UsuarioId = userId,
            TipoConteudo = "game",
            ConteudoId = submissao.GameId,
            PontosGanhos = pontosGanhos,
            Descricao = $"{game.Titulo} ({respostasCorretas}/5 acertos)",
            CreatedAt = DateTime.UtcNow
        };

        _context.HistoricoLogs.Add(log);
        usuario.Pontos += pontosGanhos;

        await _context.SaveChangesAsync();

        // Avalia se atingiu medalhas (ex: game_perfeito, mito_democracia)
        var novasMedalhas = await _medalhaService.AvaliarEConcederMedalhasAsync(userId);

        return Ok(new
        {
            sucesso = true,
            acertos = respostasCorretas,
            pontosGanhos,
            novoTotalXp = usuario.Pontos,
            novasMedalhas = novasMedalhas.Select(m => new { m.Titulo, m.Figurinha, m.Pontos })
        });
    }

    // ============================================================
    // API DE JOGOS PARA O FLUTTER
    // ============================================================

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpGet("/api/jogos")]
    public async Task<IActionResult> ApiJogos()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (userIdClaim == null ||
            !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new
            {
                message = "Token inválido."
            });
        }

        var jogosConcluidosIds = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(log =>
                log.UsuarioId == userId &&
                log.TipoConteudo == "game" &&
                log.ConteudoId != null)
            .Select(log => log.ConteudoId!.Value)
            .Distinct()
            .ToListAsync();

        var jogosDb = await _context.Games
            .AsNoTracking()
            .OrderBy(game => game.Titulo)
            .ToListAsync();

        var jogos = jogosDb
            .Select(game => new
            {
                id = game.Id,
                titulo = game.Titulo,
                descricao = game.Descricao,
                pontosTotal = game.PontosTotal,
                concluido = jogosConcluidosIds.Contains(game.Id)
            })
            .ToList();

        return Ok(new
        {
            jogos
        });
    }

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpGet("/api/jogos/{id:guid}")]
    public async Task<IActionResult> ApiJogo(Guid id)
    {

        var game = await _context.Games
            .AsNoTracking()
            .Include(g => g.Perguntas.OrderBy(p => p.Ordem))
            .ThenInclude(p => p.Respostas)
            .FirstOrDefaultAsync(g => g.Id == id);

        if (game == null)
        {
            return NotFound(new
            {
                message = "Jogo não encontrado."
            });
        }

        return Ok(new
        {
            id = game.Id,
            titulo = game.Titulo,
            descricao = game.Descricao,
            pontosTotal = game.PontosTotal,

            perguntas = game.Perguntas.Select(p => new
            {
                id = p.Id,
                pergunta = p.Pergunta,
                ordem = p.Ordem,
                pontos = p.Pontos,

                respostas = p.Respostas.Select(r => new
                {
                    id = r.Id,
                    resposta = r.Resposta
                })
            })
        });
    }

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpPost("/api/jogos/finalizar")]
    public async Task<IActionResult> ApiFinalizar(
        [FromBody] SubmissaoGameDto submissao)
    {
        // ============================================================
        // 1. IDENTIFICAR USUÁRIO
        // ============================================================

        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized(new
            {
                message = "Usuário não autenticado."
            });
        }

        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (usuario == null)
        {
            return NotFound(new
            {
                message = "Usuário não encontrado."
            });
        }

        // ============================================================
        // 2. VALIDAR SUBMISSÃO
        // ============================================================

        if (submissao.GameId == Guid.Empty)
        {
            return BadRequest(new
            {
                message = "GameId inválido."
            });
        }

        if (submissao.RespostasSelecionadas == null ||
            submissao.RespostasSelecionadas.Count == 0)
        {
            return BadRequest(new
            {
                message = "Nenhuma resposta foi enviada."
            });
        }

        // ============================================================
        // 3. BUSCAR O JOGO COMPLETO
        // ============================================================

        var game = await _context.Games
            .Include(g => g.Perguntas)
                .ThenInclude(p => p.Respostas)
            .FirstOrDefaultAsync(g => g.Id == submissao.GameId);

        if (game == null)
        {
            return NotFound(new
            {
                message = "Quiz não encontrado."
            });
        }

        // ============================================================
        // 4. VERIFICAR SE JÁ FOI CONCLUÍDO
        // ============================================================

        var jaPontuou = await _context.HistoricoLogs
            .AnyAsync(log =>
                log.UsuarioId == userId &&
                log.TipoConteudo == "game" &&
                log.ConteudoId == game.Id);

        if (jaPontuou)
        {
            return BadRequest(new
            {
                message =
                    "Você já concluiu este quiz anteriormente. " +
                    "Os pontos já foram creditados."
            });
        }

        int respostasCorretas = 0;
        int pontosGanhos = 0;

        foreach (var pergunta in game.Perguntas)
        {
            if (!submissao.RespostasSelecionadas.TryGetValue(
                    pergunta.Id,
                    out var respostaSelecionadaId))
            {
                continue;
            }

            var respostaSelecionada = pergunta.Respostas
                .FirstOrDefault(r =>
                    r.Id == respostaSelecionadaId);

            // A resposta enviada não pertence a esta pergunta.
            if (respostaSelecionada == null)
            {
                continue;
            }

            if (respostaSelecionada.IsCorreta)
            {
                respostasCorretas++;
                // Usa os pontos configurados na própria pergunta.
                pontosGanhos += pergunta.Pontos;
            }
        }

        // Segurança extra:
        // o usuário nunca pode ganhar mais do que
        // PontosTotal definido para o jogo.
        pontosGanhos = Math.Min(
            pontosGanhos,
            game.PontosTotal
        );

        // ============================================================
        // 6. CRIAR LOG
        // ============================================================

        var log = new HistoricoPontuacaoLog
        {
            Id = Guid.NewGuid(),
            UsuarioId = userId,
            TipoConteudo = "game",
            ConteudoId = game.Id,
            PontosGanhos = pontosGanhos,
            Descricao =
                $"{game.Titulo} " +
                $"({respostasCorretas}/{game.Perguntas.Count} acertos)",
            CreatedAt = DateTime.UtcNow
        };

        _context.HistoricoLogs.Add(log);

        // ============================================================
        // 7. ATUALIZAR XP
        // ============================================================

        var pontosAntes = usuario.Pontos;

        usuario.Pontos += pontosGanhos;

        // ============================================================
        // 8. SALVAR JOGO + LOG
        // ============================================================

        await _context.SaveChangesAsync();

        // ============================================================
        // 9. MEDALHAS
        // ============================================================

        var pontosAntesMedalhas = usuario.Pontos;
        var novasMedalhas =
            await _medalhaService
                .AvaliarEConcederMedalhasAsync(userId);
        // ============================================================
        // 10. RETORNO
        // ============================================================

        return Ok(new
        {
            sucesso = true,
            acertos = respostasCorretas,
            totalPerguntas = game.Perguntas.Count,
            pontosGanhos = pontosGanhos,
            novoTotalXp = usuario.Pontos,
            novasMedalhas = novasMedalhas.Select(m => new
            {
                m.Titulo,
                m.Figurinha,
                m.Pontos
            })
        });
    }
}