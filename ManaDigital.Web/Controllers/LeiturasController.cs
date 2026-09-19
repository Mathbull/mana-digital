using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Data;
using ManaDigital.Web.Models;
using ManaDigital.Web.ViewModels;

namespace ManaDigital.Web.Controllers;

[Authorize]
public class LeiturasController : Controller
{
    private readonly AppDbContext _context;

    public LeiturasController(AppDbContext context)
    {
        _context = context;
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

        await _context.SaveChangesAsync();

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