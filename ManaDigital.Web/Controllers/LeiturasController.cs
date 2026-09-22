using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Data;
using ManaDigital.Web.Models;
using ManaDigital.Web.ViewModels;
using ManaDigital.Web.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace ManaDigital.Web.Controllers;

[Authorize]
public class LeiturasController : Controller
{
    private readonly AppDbContext _context;
    private readonly MedalhaService _medalhaService; // <-- Injeção do serviço


    public LeiturasController(AppDbContext context, MedalhaService medalhaService)
    {
        _context = context;
        _medalhaService = medalhaService;
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId)) return RedirectToAction("Login", "Account");

        var usuario = await _context.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId);
        if (usuario == null) return RedirectToAction("Login", "Account");

        // 1. Busca quais leituras esse colaborador já concluiu
        var leiturasConcluidasIds = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(l => l.UsuarioId == userId && l.TipoConteudo == "leitura" && l.ConteudoId != null)
            .Select(l => l.ConteudoId!.Value)
            .Distinct()
            .ToListAsync();

        // 2. Busca todas as leituras e suas perguntas
        var leiturasDb = await _context.Leituras.AsNoTracking().ToListAsync();
        var respostasDb = await _context.LeituraRespostas.AsNoTracking().ToListAsync();

        var cards = leiturasDb.Select(l => new LeituraCardItemDto
        {
            Id = l.Id,
            Titulo = l.Titulo,
            Conteudo = l.Conteudo,
            Tipo = l.Tipo,
            PontosTotal = l.PontosTotal,
            Concluida = leiturasConcluidasIds.Contains(l.Id),
            Perguntas = respostasDb.Where(r => r.LeituraId == l.Id).Select(r => new PerguntaDto
            {
                Id = r.Id,
                Afirmacao = r.Afirmacao,
                IsCorreta = r.IsCorreta,
                Explicacao = r.Explicacao
            }).ToList()
        }).ToList();

        var viewModel = new LeiturasViewModel
        {
            Nome = usuario.Nome,
            Apelido = usuario.Apelido,
            Email = usuario.Email,
            Cargo = usuario.Cargo,
            Pontos = usuario.Pontos,
            TotalGeral = cards.Count,
            TotalConcluidas = leiturasConcluidasIds.Count,
            PontosUsuario = usuario.Pontos,
            Leituras = cards
        };

        return View(viewModel);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Responder([FromBody] SubmissaoLeituraDto submissao)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId)) return Unauthorized();

        var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Id == userId);
        if (usuario == null) return NotFound("Usuário não encontrado.");

        // Validação anti-fraude: já pontuou nessa leitura?
        var jaFez = await _context.HistoricoLogs.AnyAsync(l => 
            l.UsuarioId == userId && 
            l.TipoConteudo == "leitura" && 
            l.ConteudoId == submissao.LeituraId);

        if (jaFez)
        {
            return BadRequest(new { message = "Você já concluiu esta leitura. Conteúdo disponível apenas para consulta." });
        }

        var perguntas = await _context.LeituraRespostas
            .Where(r => r.LeituraId == submissao.LeituraId)
            .ToListAsync();

        int pontosGanhos = 0;
        int acertos = 0;

        foreach (var p in perguntas)
        {
            if (submissao.Respostas.TryGetValue(p.Id, out bool respostaUsuario))
            {
                if (respostaUsuario == p.IsCorreta)
                {
                    pontosGanhos += p.Pontos;
                    acertos++;
                }
            }
        }

        // Registra no Log Contábil
        var log = new HistoricoPontuacaoLog
        {
            UsuarioId = userId,
            TipoConteudo = "leitura",
            ConteudoId = submissao.LeituraId,
            PontosGanhos = pontosGanhos,
            Descricao = $"Conclusão de Leitura ({acertos}/{perguntas.Count} acertos)",
            CreatedAt = DateTime.UtcNow
        };

        _context.HistoricoLogs.Add(log);
        usuario.Pontos += pontosGanhos;

        // 1. Salva a pontuação da leitura
        await _context.SaveChangesAsync();

        // 2. Avalia se essa leitura desbloqueou alguma medalha nova!
        var medalhasNovas = await _medalhaService.AvaliarEConcederMedalhasAsync(userId);

        // 3. Devolve para o front-end
        return Ok(new 
        { 
            sucesso = true, 
            pontosGanhos, 
            novoTotalXp = usuario.Pontos,
            acertos,
            totalPerguntas = perguntas.Count,
            // Devolvemos a lista de medalhas ganhas (com os nomes exatos das suas propriedades)
            novasMedalhas = medalhasNovas.Select(m => new {
                m.Titulo,
                m.Descricao,
                m.Figurinha,
                m.Pontos
            })
        });
    }

    // ============================================================
    // API DE LEITURAS PARA O FLUTTER
    // ============================================================

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpGet("/api/leituras")]
    public async Task<IActionResult> ApiLeituras()
    {
        // 1. Recupera o ID do usuário através do JWT
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new
            {
                message = "Token inválido."
            });
        }

        // 2. Verifica se o usuário existe
        var usuarioExiste = await _context.Usuarios
            .AsNoTracking()
            .AnyAsync(u => u.Id == userId);

        if (!usuarioExiste)
        {
            return NotFound(new
            {
                message = "Usuário não encontrado."
            });
        }

        // 3. Busca as leituras já concluídas pelo usuário
        var leiturasConcluidasIds = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(l =>
                l.UsuarioId == userId &&
                l.TipoConteudo == "leitura" &&
                l.ConteudoId != null)
            .Select(l => l.ConteudoId!.Value)
            .Distinct()
            .ToListAsync();

        // 4. Busca todas as leituras
        var leiturasDb = await _context.Leituras
            .AsNoTracking()
            .ToListAsync();

        // 5. Busca todas as perguntas
        var respostasDb = await _context.LeituraRespostas
            .AsNoTracking()
            .ToListAsync();

        // 6. Monta os dados para o Flutter
        var leituras = leiturasDb.Select(leitura => new
        {
            id = leitura.Id,
            titulo = leitura.Titulo,
            conteudo = leitura.Conteudo,
            tipo = leitura.Tipo,
            pontosTotal = leitura.PontosTotal,

            concluida = leiturasConcluidasIds.Contains(leitura.Id),

            tempoMinutos = Math.Max(
                2,
                leitura.Conteudo.Split(' ').Length / 80
            ),

            perguntas = respostasDb
                .Where(resposta => resposta.LeituraId == leitura.Id)
                .Select(resposta => new
                {
                    id = resposta.Id,
                    afirmacao = resposta.Afirmacao,
                    explicacao = resposta.Explicacao

                })
                .ToList()
        }).ToList();

        // 7. Retorna as leituras em JSON
        return Ok(new
        {
            total = leituras.Count,
            leituras = leituras
        });
    }

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpPost("/api/leituras/responder")]
    public async Task<IActionResult> ResponderApi(
        [FromBody] SubmissaoLeituraDto submissao)
    {
        // 1. Recupera o ID do usuário autenticado
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new
            {
                message = "Usuário não autenticado."
            });
        }

        // 2. Valida se a leitura existe
        var leitura = await _context.Leituras
            .FirstOrDefaultAsync(l => l.Id == submissao.LeituraId);

        if (leitura == null)
        {
            return NotFound(new
            {
                message = "Leitura não encontrada."
            });
        }

        // 3. Busca o usuário
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (usuario == null)
        {
            return NotFound(new
            {
                message = "Usuário não encontrado."
            });
        }

        // 4. Verifica se o usuário já concluiu essa leitura
        var jaConcluiu = await _context.HistoricoLogs
            .AnyAsync(h =>
                h.UsuarioId == userId &&
                h.ConteudoId == submissao.LeituraId &&
                h.TipoConteudo == "leitura");

        if (jaConcluiu)
        {
            return BadRequest(new
            {
                message = "Você já concluiu esta leitura."
            });
        }

        // 5. Busca as perguntas da leitura
        var perguntas = await _context.LeituraRespostas
            .Where(p => p.LeituraId == submissao.LeituraId)
            .ToListAsync();

        if (!perguntas.Any())
        {
            return BadRequest(new
            {
                message = "Esta leitura não possui perguntas."
            });
        }

        // 6. Valida as respostas
        var pontosGanhos = 0;
        var acertos = 0;

        foreach (var pergunta in perguntas)
        {
            if (!submissao.Respostas.TryGetValue(
                    pergunta.Id,
                    out var respostaUsuario))
            {
                continue;
            }

            if (respostaUsuario == pergunta.IsCorreta)
            {
                acertos++;
                pontosGanhos += pergunta.Pontos;
            }
        }

        // 7. Atualiza os pontos do usuário
        usuario.Pontos += pontosGanhos;

        // 8. Registra a conclusão e a pontuação da leitura
        var log = new HistoricoPontuacaoLog
        {
            UsuarioId = userId,
            TipoConteudo = "leitura",
            ConteudoId = submissao.LeituraId,
            PontosGanhos = pontosGanhos,
            Descricao = $"Conclusão de Leitura ({acertos}/{perguntas.Count} acertos)",
            CreatedAt = DateTime.UtcNow
        };

        _context.HistoricoLogs.Add(log);

        // 9. Salva as alterações
        await _context.SaveChangesAsync();

        // 10. Retorna o resultado para o Flutter
        return Ok(new
        {
            sucesso = true,
            pontosGanhos,
            novoTotalXp = usuario.Pontos,
            acertos,
            totalPerguntas = perguntas.Count
        });
    }

}