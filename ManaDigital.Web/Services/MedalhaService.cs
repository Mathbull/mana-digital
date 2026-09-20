using Microsoft.EntityFrameworkCore;
using ManaDigital.Web.Data;
using ManaDigital.Web.Models;

namespace ManaDigital.Web.Services;

public class MedalhaService
{
    private readonly AppDbContext _context;

    public MedalhaService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Medalha>> AvaliarEConcederMedalhasAsync(Guid usuarioId)
    {
        var novasMedalhas = new List<Medalha>();

        // 1. Dados do Usuário
        var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Id == usuarioId);
        if (usuario == null) return novasMedalhas;

        // 2. Medalhas que ele JÁ possui (para não duplicar)
        var medalhasJaPossuidasIds = await _context.UsuarioMedalhas
            .Where(um => um.UsuarioId == usuarioId)
            .Select(um => um.MedalhaId)
            .ToListAsync();

        // 3. Medalhas que ele AINDA PODE ganhar
        var medalhasDisponiveis = await _context.Medalhas
            .Where(m => !medalhasJaPossuidasIds.Contains(m.Id))
            .ToListAsync();

        if (!medalhasDisponiveis.Any()) return novasMedalhas;

        // 4. Carrega o histórico completo de logs desse usuário
        var logs = await _context.HistoricoLogs
            .AsNoTracking()
            .Where(l => l.UsuarioId == usuarioId)
            .ToListAsync();

        // Contagens básicas
        int totalLeituras = logs.Count(l => l.TipoConteudo == "leitura");
        int totalVideos   = logs.Count(l => l.TipoConteudo == "video");
        int totalJogos    = logs.Count(l => l.TipoConteudo == "game");
        int totalIniciativas = logs.Count(l => l.TipoConteudo == "iniciativa");

        // Contagem de convites aceitos (quantos usuários foram convidados por ele)
        int totalConvites = await _context.Usuarios
            .AsNoTracking()
            .CountAsync(u => u.ConvidadoPor == usuario.Email);

        // 5. Avaliação dos 20 Critérios Oficiais
        foreach (var medalha in medalhasDisponiveis)
        {
            bool desbloqueou = medalha.CodigoCriterio.ToLower().Trim() switch
            {
                // --- ONBOARDING E BÁSICAS ---
                "primeiro_login" => true, // Já está logado e ativo no sistema
                "leitura_1"      => totalLeituras >= 1,
                "video_1"        => totalVideos >= 1,
                "game_1"         => totalJogos >= 1,
                "iniciativa_1"   => totalIniciativas >= 1,

                // --- PROGRESSÃO DE VOLUME ---
                "leitura_5"      => totalLeituras >= 5,
                "video_5"        => totalVideos >= 5,
                "total_10"       => (totalLeituras + totalVideos) >= 10,
                "triade_1"       => totalLeituras >= 1 && totalVideos >= 1 && totalJogos >= 1,

                // --- PONTUAÇÃO E PERFORMANCE ---
                "patente_alta"   => usuario.Pontos >= 500,
                // Game perfeito: acertou todas (10 pontos ganhos no log de um game)
                "game_perfeito"  => logs.Any(l => l.TipoConteudo == "game" && l.PontosGanhos >= 10),

                // --- CONTEÚDOS ESPECÍFICOS (LEIS E TEÓRICOS) ---
                // Verifica na descrição do log se contém menção às leis ou teóricos
                "lei_compliance" => logs.Any(l => l.TipoConteudo == "leitura" && 
                                             (l.Descricao.Contains("10.639") || l.Descricao.Contains("7.716") || l.Descricao.Contains("12.288"))),
                
                "teoricos_raciais" => logs.Any(l => l.TipoConteudo == "leitura" && 
                                               (l.Descricao.Contains("Chimamanda") || l.Descricao.Contains("Munanga") || l.Descricao.Contains("Djamila"))),

                "mito_democracia" => logs.Any(l => l.TipoConteudo == "game" && 
                                              l.Descricao.Contains("Democracia Racial") && l.PontosGanhos >= 10),

                // --- CONVITES E REDE ---
                "convite_1" => totalConvites >= 1,
                "convite_5" => totalConvites >= 5,

                // --- INICIATIVAS E ESG ---
                "iniciativa_aprovada_1" => logs.Count(l => l.TipoConteudo == "iniciativa" && l.Descricao.Contains("Aprovada")) >= 1,
                "iniciativa_aprovada_3" => logs.Count(l => l.TipoConteudo == "iniciativa" && l.Descricao.Contains("Aprovada")) >= 3,
                "linkedin_share"        => logs.Any(l => l.TipoConteudo == "iniciativa" && l.Descricao.Contains("LinkedIn")),

                // --- CONSTÂNCIA (5 DIAS CONSECUTIVOS) ---
                "streak_5" => CalcularDiasConsecutivos(logs) >= 5,

                _ => false
            };

            if (desbloqueou)
            {
                // Registra a conquista do usuário
                _context.UsuarioMedalhas.Add(new UsuarioMedalha
                {
                    Id = Guid.NewGuid(),
                    UsuarioId = usuarioId,
                    MedalhaId = medalha.Id,
                    DataConquista = DateTime.UtcNow
                });

                // Se a medalha bonificar com XP
                if (medalha.Pontos > 0)
                {
                    usuario.Pontos += medalha.Pontos;

                    _context.HistoricoLogs.Add(new HistoricoPontuacaoLog
                    {
                        Id = Guid.NewGuid(),
                        UsuarioId = usuarioId,
                        TipoConteudo = "medalha",
                        ConteudoId = medalha.Id,
                        PontosGanhos = medalha.Pontos,
                        Descricao = $"Medalha Conquistada: {medalha.Titulo}",
                        CreatedAt = DateTime.UtcNow
                    });
                }

                novasMedalhas.Add(medalha);
            }
        }

        if (novasMedalhas.Any())
        {
            await _context.SaveChangesAsync();
        }

        return novasMedalhas;
    }

    /// <summary>
    /// Algoritmo auxiliar para calcular quantos dias consecutivos de atividade o usuário possui.
    /// </summary>
    private static int CalcularDiasConsecutivos(List<HistoricoPontuacaoLog> logs)
    {
        if (!logs.Any()) return 0;

        // Pega as datas únicas (sem hora) ordenadas da mais recente para a mais antiga
        var datasAtivas = logs
            .Select(l => l.CreatedAt.Date)
            .Distinct()
            .OrderByDescending(d => d)
            .ToList();

        int streak = 0;
        var dataEsperada = DateTime.UtcNow.Date;

        // Se ele não pontuou hoje, verifica se pontuou ontem para não quebrar a sequência
        if (datasAtivas.First() < dataEsperada.AddDays(-1))
            return 0;

        if (datasAtivas.First() == dataEsperada.AddDays(-1))
            dataEsperada = dataEsperada.AddDays(-1);

        foreach (var data in datasAtivas)
        {
            if (data == dataEsperada)
            {
                streak++;
                dataEsperada = dataEsperada.AddDays(-1);
            }
            else
            {
                break;
            }
        }

        return streak;
    }
}