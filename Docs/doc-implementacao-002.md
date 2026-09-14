### 📋 Relatório Técnico Integrado de Desenvolvimento — Sprint 02

1. **Integração de Mídia com Supabase Storage:**
   * Configuração do bucket público `medalhas` no Supabase e upload dos 20 assets visuais em 3D.
   * Execução de script SQL sincronizando as URLs públicas de alta resolução na coluna `figurinha` da tabela `medalhas` com o project reference real (`lcfvuqogreczddoyxpxy`).

2. **Modelagem e Mapeamento de Dados (.NET / C#):**
   * Criação das classes de entidade `Medalha.cs` e `UsuarioMedalha.cs` mapeando para as tabelas do PostgreSQL.
   * Registro dos `DbSet<Medalha>` e `DbSet<UsuarioMedalha>` no `AppDbContext.cs`.
   * Ajuste do `HomeViewModel` com regras de progressão de patentes (Bronze, Prata, Ouro e Diamante) e resolução dos alertas de compilação (CS8618 e CS1061).

3. **UI/UX & Responsividade (Razor / Tailwind):**
   * Redesenho do card **Medalhas & Conquistas** travando suas dimensões em formato compacto (~600x242px) para não quebrar a proporção com o ranking.
   * Criação de classe CSS utilitária (`.custom-scroll`) com scrollbar fina (4px) e translúcida no tema Dark.
   * Implementação da regra visual: medalhas desbloqueadas aparecem no topo coloridas com ícone de verificado, enquanto medalhas bloqueadas permanecem abaixo com efeito cinza (*grayscale*) e cadeado.

