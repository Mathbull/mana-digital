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
public class IniciativasController : Controller
{
    private readonly AppDbContext _context;
    private readonly MedalhaService _medalhaService;

    public IniciativasController(AppDbContext context, MedalhaService medalhaService)
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

        bool isAdmin = usuario.Cargo == "adm";

        // 1. Busca as iniciativas enviadas por este usuário
        var minhas = await _context.Iniciativas
            .AsNoTracking()
            .Where(i => i.UsuarioId == userId)
            .OrderByDescending(i => i.CreatedAt)
            .Select(i => new IniciativaItemDto
            {
                Id = i.Id,
                Tipo = i.Tipo,
                Titulo = i.Titulo,
                Descricao = i.Descricao,
                AnexoUrl = i.AnexoUrl,
                PontosSugeridos = i.PontosSugeridos,
                PontosAtribuidos = i.PontosAtribuidos,
                Status = i.Status,
                JustificativaAdmin = i.JustificativaAdmin,
                DataEnvio = i.CreatedAt
            }).ToListAsync();

        // 2. Se for ADM, busca a fila pendente de aprovação da empresa inteira
        var fila = new List<IniciativaItemDto>();
        if (isAdmin)
        {
            fila = await _context.Iniciativas
                .Include(i => i.Usuario)
                .AsNoTracking()
                .Where(i => i.Status == "pendente")
                .OrderBy(i => i.CreatedAt)
                .Select(i => new IniciativaItemDto
                {
                    Id = i.Id,
                    ColaboradorNome = i.Usuario != null ? i.Usuario.Nome : "Colaborador",
                    Tipo = i.Tipo,
                    Titulo = i.Titulo,
                    Descricao = i.Descricao,
                    AnexoUrl = i.AnexoUrl,
                    PontosSugeridos = i.PontosSugeridos,
                    Status = i.Status,
                    DataEnvio = i.CreatedAt
                }).ToListAsync();
        }

        var viewModel = new IniciativasViewModel
        {
            Nome = usuario.Nome,
            Apelido = usuario.Apelido,
            Email = usuario.Email,
            Cargo = usuario.Cargo,
            Pontos = usuario.Pontos,
            IsAdmin = isAdmin,
            MinhasIniciativas = minhas,
            FilaModeracao = fila
        };

        return View(viewModel);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Submeter([FromBody] NovaIniciativaDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdStr, out var userId)) return Unauthorized();

        if (string.IsNullOrWhiteSpace(dto.Titulo) || string.IsNullOrWhiteSpace(dto.Descricao))
        {
            return BadRequest(new { message = "Título e descrição são obrigatórios." });
        }

        int pontosBase = dto.Tipo switch
        {
            "livro_resumo" => 60,
            "linkedin" => 50,
            "convite" => 30,
            _ => 50
        };

        var iniciativa = new Iniciativa
        {
            Id = Guid.NewGuid(),
            UsuarioId = userId,
            Tipo = dto.Tipo,
            Titulo = dto.Titulo,
            Descricao = dto.Descricao,
            AnexoUrl = dto.AnexoUrl,
            PontosSugeridos = pontosBase,
            Status = "pendente",
            CreatedAt = DateTime.UtcNow
        };

        _context.Iniciativas.Add(iniciativa);

        // Registra evento no histórico para auditoria e medalha de primeiro envio
        _context.HistoricoLogs.Add(new HistoricoPontuacaoLog
        {
            Id = Guid.NewGuid(),
            UsuarioId = userId,
            TipoConteudo = "iniciativa",
            ConteudoId = iniciativa.Id,
            PontosGanhos = 0, // Pontos entram apenas após aprovação do admin
            Descricao = $"Submissão de Iniciativa: {dto.Titulo} (Aguardando Aprovação)",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync();

        // Dispara avaliação da medalha "iniciativa_1" (Voz Ativa)
        await _medalhaService.AvaliarEConcederMedalhasAsync(userId);

        return Ok(new { sucesso = true, message = "Iniciativa enviada para o Comitê ESG com sucesso!" });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Moderar([FromBody] DecisaoModeracaoDto dto)
    {
        var adminIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(adminIdStr, out var adminId)) return Unauthorized();

        var adminUser = await _context.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == adminId);
        if (adminUser == null || adminUser.Cargo != "adm")
        {
            return Forbid("Apenas administradores podem moderar iniciativas.");
        }

        var iniciativa = await _context.Iniciativas
            .Include(i => i.Usuario)
            .FirstOrDefaultAsync(i => i.Id == dto.IniciativaId);

        if (iniciativa == null) return NotFound("Iniciativa não encontrada.");
        if (iniciativa.Status != "pendente") return BadRequest("Esta iniciativa já foi moderada.");

        iniciativa.ValidadoPor = adminId;
        iniciativa.ValidadoEm = DateTime.UtcNow;
        iniciativa.JustificativaAdmin = dto.Justificativa;

        if (dto.Aprovado)
        {
            iniciativa.Status = "aprovado";
            iniciativa.PontosAtribuidos = dto.Pontos > 0 ? dto.Pontos : iniciativa.PontosSugeridos;

            // Credita os pontos no usuário autor
            if (iniciativa.Usuario != null)
            {
                iniciativa.Usuario.Pontos += iniciativa.PontosAtribuidos.Value;
            }

            // Registra no extrato contábil para alimentar medalhas
            _context.HistoricoLogs.Add(new HistoricoPontuacaoLog
            {
                Id = Guid.NewGuid(),
                UsuarioId = iniciativa.UsuarioId,
                TipoConteudo = "iniciativa",
                ConteudoId = iniciativa.Id,
                PontosGanhos = iniciativa.PontosAtribuidos.Value,
                Descricao = $"Iniciativa Aprovada ({iniciativa.Tipo}): {iniciativa.Titulo}",
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();

            // Avalia medalhas de aprovação (iniciativa_aprovada_1, iniciativa_aprovada_3, linkedin_share)
            await _medalhaService.AvaliarEConcederMedalhasAsync(iniciativa.UsuarioId);
        }
        else
        {
            iniciativa.Status = "rejeitado";
            iniciativa.PontosAtribuidos = 0;
            await _context.SaveChangesAsync();
        }

        return Ok(new { sucesso = true, message = $"Iniciativa {(dto.Aprovado ? "aprovada" : "recusada")} com sucesso!" });
    }

    // ============================================================
    // API MOBILE - INICIATIVAS
    // ============================================================

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpGet("/api/iniciativas")]
    public async Task<IActionResult> ApiIniciativas()
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized(new
            {
                message = "Token inválido."
            });
        }

        var iniciativas = await _context.Iniciativas
            .AsNoTracking()
            .Where(i => i.UsuarioId == userId)
            .OrderByDescending(i => i.CreatedAt)
            .Select(i => new IniciativaItemDto
            {
                Id = i.Id,
                Tipo = i.Tipo,
                Titulo = i.Titulo,
                Descricao = i.Descricao,
                AnexoUrl = i.AnexoUrl,
                PontosSugeridos = i.PontosSugeridos,
                PontosAtribuidos = i.PontosAtribuidos,
                Status = i.Status,
                JustificativaAdmin = i.JustificativaAdmin,
                DataEnvio = i.CreatedAt
            })
            .ToListAsync();

        return Ok(new
        {
            iniciativas
        });
    }

    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [HttpPost("/api/iniciativas/submeter")]
    public async Task<IActionResult> ApiSubmeter(
        [FromBody] NovaIniciativaDto dto)
    {
        var userIdStr =
            User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!Guid.TryParse(userIdStr, out var userId))
        {
            return Unauthorized(new
            {
                message = "Token inválido."
            });
        }

        var tipo =
            dto.Tipo?.Trim().ToLowerInvariant();

        if (string.IsNullOrWhiteSpace(tipo))
        {
            return BadRequest(new
            {
                message = "Tipo da iniciativa é obrigatório."
            });
        }

        int pontosBase;

        string titulo;
        string descricao;
        string? anexoUrl = null;

        switch (tipo)
        {
            // ====================================================
            // LEITURA
            // ====================================================
            case "livro_resumo":

                if (string.IsNullOrWhiteSpace(dto.Titulo))
                {
                    return BadRequest(new
                    {
                        message = "Informe o título da obra."
                    });
                }

                if (string.IsNullOrWhiteSpace(dto.Descricao))
                {
                    return BadRequest(new
                    {
                        message = "Informe sua reflexão sobre a leitura."
                    });
                }

                pontosBase = 60;

                titulo = dto.Titulo.Trim();
                descricao = dto.Descricao.Trim();
                anexoUrl = dto.AnexoUrl?.Trim();

                break;

            // ====================================================
            // CONVITE
            // ====================================================
            case "convite":

                if (string.IsNullOrWhiteSpace(dto.EmailIndicado))
                {
                    return BadRequest(new
                    {
                        message = "Informe o e-mail do colega."
                    });
                }

                pontosBase = 30;

                titulo = "Indicação de colega";

                descricao =
                    $"Colega indicado: {dto.EmailIndicado.Trim()}";

                break;

            // ====================================================
            // LINKEDIN
            // ====================================================
            case "linkedin":

                if (string.IsNullOrWhiteSpace(dto.AnexoUrl))
                {
                    return BadRequest(new
                    {
                        message = "Informe o link da publicação."
                    });
                }

                pontosBase = 50;

                titulo = "Multiplicador no LinkedIn";

                descricao =
                    "Publicação enviada para validação.";

                anexoUrl = dto.AnexoUrl.Trim();

                break;

            default:

                return BadRequest(new
                {
                    message = "Tipo de iniciativa inválido."
                });
        }

        var iniciativa = new Iniciativa
        {
            Id = Guid.NewGuid(),

            UsuarioId = userId,

            Tipo = tipo,

            Titulo = titulo,

            Descricao = descricao,

            AnexoUrl = anexoUrl,

            PontosSugeridos = pontosBase,

            PontosAtribuidos = null,

            Status = "pendente",

            CreatedAt = DateTime.UtcNow
        };

        _context.Iniciativas.Add(iniciativa);

        // Registra apenas a submissão.
        // Nenhum XP é concedido neste momento.
        _context.HistoricoLogs.Add(
            new HistoricoPontuacaoLog
            {
                Id = Guid.NewGuid(),

                UsuarioId = userId,

                TipoConteudo = "iniciativa",

                ConteudoId = iniciativa.Id,

                PontosGanhos = 0,

                Descricao =
                    $"Submissão de Iniciativa: {titulo} " +
                    "(Aguardando Aprovação)",

                CreatedAt = DateTime.UtcNow
            }
        );

        await _context.SaveChangesAsync();

        await _medalhaService
            .AvaliarEConcederMedalhasAsync(userId);

        return Ok(new
        {
            sucesso = true,

            iniciativa = new IniciativaItemDto
            {
                Id = iniciativa.Id,
                Tipo = iniciativa.Tipo,
                Titulo = iniciativa.Titulo,
                Descricao = iniciativa.Descricao,
                AnexoUrl = iniciativa.AnexoUrl,
                PontosSugeridos = iniciativa.PontosSugeridos,
                PontosAtribuidos = iniciativa.PontosAtribuidos,
                Status = iniciativa.Status,
                DataEnvio = iniciativa.CreatedAt
            },

            message = "Iniciativa enviada para análise."
        });
    }
}