# 📄 Relatório Técnico Integrado de Desenvolvimento — Sprint 01
**Projeto Integrado Multidisciplinar VII (PIM VII)**  
**Curso:** Superior de Tecnologia em Análise e Desenvolvimento de Sistemas (ADS) / UNIP  
**Empresa-Caso:** Mana Digital (Logística Inteligente & Soluções ESG)  
**Tema:** Solução Corporativa Gamificada para Diversidade Étnico-Racial  
**Período:** 12 e 13 de Setembro de 2026  
**Stack Tecnológica:** ASP.NET Core MVC & Web API, Entity Framework Core, PostgreSQL (Supabase), Tailwind CSS, JavaScript  

---

## 1. Sumário Executivo

Neste ciclo de desenvolvimento, a equipe estruturou e validou as fundações arquiteturais, de banco de dados, segurança e backend da plataforma **Mana Digital**. O trabalho articula diretamente os quatro pilares da ementa do PIM VII:

1. **Relações Étnico-Raciais e Afrodescendência:** Integração normativa com as Leis nº 10.639/2003, nº 11.645/2008, Lei Antirracismo (nº 7.716/1989) e o Estatuto da Igualdade Racial (Lei nº 12.288/2010) aplicadas ao setor de logística corporativa.
2. **Desenvolvimento Web com .NET:** Construção do backend em ASP.NET Core, ORM com Entity Framework Core e padrão arquitetural MVC integrado a controladores de API REST para futuro consumo mobile.
3. **Modelagem de Dados Relacional:** Banco relacional em nuvem (Supabase / PostgreSQL) com modelagem orientada a extrato contábil de pontuação e trilha de auditoria.
4. **Engenharia de Software e Boas Práticas:** Adoção do padrão ViewModel, eliminação de senhas em texto puro, resolução de divergências entre dados voláteis e Claims, além de depuração de consultas LINQ e integridade de tipos anuláveis.

---

## 2. Modelagem, Infraestrutura e Carga de Dados (PostgreSQL / Supabase)

### 2.1. Estrutura das Tabelas e Regras de Integridade
* **Tabela `usuarios`:**
  * Chaves primárias no padrão UUID (`gen_random_uuid()`) para mitigação de varreduras maliciosas e ataques de enumeração.
  * Validações de integridade no banco: restrição `CHECK (cargo IN ('comum', 'adm'))` e unicidade estrita no e-mail corporativo.
  * Criação de índices de performance para autenticação e ordenação de pontuação (`idx_usuarios_pontos`).
* **Módulo de Microlearning (`leitura` e `leitura_respostas`):**
  * Estruturação de textos categorizados (`trecho_livro`, `artigo_lei`, `fato_atual`) e validações no modelo Verdadeiro/Falso (5 pontos por afirmativa, totalizando 10 pontos por leitura).
* **Módulo de Jogos e Quizzes (`games`, `game_perguntas` e `game_respostas`):**
  * Modelagem hierárquica (1:N:N) para desafios temáticos com 5 perguntas por jogo (2 pontos cada, totalizando 10 pontos) e 3 alternativas com indicação booleana de gabarito (`is_correta`).
* **Módulo de Auditoria Contábil (`historico_pontuacao_log`):**
  * Tabela de extrato transacional com carimbo temporal UTC (`created_at`) e regras de unicidade para evitar pontuações duplicadas na mesma atividade.
* **Módulo de Conquistas (`medalhas` e `usuario_medalhas`):**
  * Criação das tabelas para gestão de insígnias e relação N:N de desbloqueio por colaborador.

### 2.2. Carga Inicial de Dados Pedagógicos (Seed Data)
* **Conteúdos de Letramento Racial:**
  * Inserção de **20 leituras** corporativas baseadas em pensadores fundamentais (Chimamanda Ngozi Adichie, Kabengele Munanga, Sérgio Buarque de Holanda e Roberto DaMatta) e legislações antirracistas brasileiras.
  * Inserção de **40 afirmações de Verdadeiro ou Falso** com gabarito formal e justificativas educativas de feedback imediato.
* **Desafios Interativos:**
  * Cadastro de **4 Quizzes temáticos** contendo **20 perguntas** estruturadas e **60 opções de múltipla escolha**.
* **Engajamento e Conquistas:**
  * Cadastro de **20 medalhas corporativas** divididas por marcos da jornada do colaborador, associadas a bônus de XP.
  * Carga retroativa concedendo **50 XP de "1º Acesso"** no log contábil para colaboradores pré-existentes na base, respeitando suas datas originais de cadastro.
  * Elaboração de Master Prompt de IA para a geração padronizada de ícones 3D dos selos e medalhas.

---

## 3. Engenharia de Backend e Segurança (.NET / C#)

### 3.1. Segurança e Autenticação Híbrida
* **Criptografia de Senhas:** Aplicação da classe nativa `PasswordHasher<Usuario>` do ASP.NET Core Identity (hashing com salt via PBKDF2), impedindo o armazenamento de texto puro.
* **Autenticação em Dois Modos:**
  * *Web MVC:* Autenticação por Cookies criptografados (`CookieAuthenticationDefaults`).
  * *Mobile API:* Estruturação dos endpoints `/api/auth/login` e `/api/auth/register` para consumo do Flutter via JSON.
* **Fluxo de Onboarding Otimizado:** Implementação de login automático e concessão de 50 XP logo após o registro, seguido de redirecionamento para a tela principal.

### 3.2. Padrão Arquitetural: "Claims vs. Dados Voláteis"
* **Diagnóstico Conceitual:** Pontuações, XP e patentes são métricas transacionais de alta frequência que se tornam obsoletas rapidamente (*stale data*) se armazenadas em Claims de cookies.
* **Implementação Técnica:**
  * **Claims** limitadas a dados perenes de identidade (`UserId`, `Email`, `Nome`, `Role`).
  * **`HomeViewModel`** alimentada a cada requisição para refletir o saldo real do banco.
  * Cálculo dinâmico das patentes corporativas:
    * *Bronze Operacional:* 0 a 99 XP
    * *Prata Logística:* 100 a 299 XP
    * *Ouro Operacional:* 300 a 599 XP
    * *Diamante Estratégico:* 600+ XP

### 3.3. Depuração e Resolução de Incidentes Técnicos
* **Correção de `InvalidCastException` (Tipagem no Banco):**
  * *Problema:* Eventos de pontuação sem vínculo com leituras ou jogos (ex.: bônus de 1º acesso ou convite) causavam falha de conversão ao carregar o log.
  * *Solução:* Ajuste da coluna e propriedade `ConteudoId` para anulável (`Guid?`), garantindo estabilidade nas consultas de histórico.
* **Correção de `InvalidOperationException` (Tradução LINQ-to-SQL):**
  * *Problema:* O Entity Framework Core falhava ao traduzir consultas complexas com `.GroupBy()` e `.Join()` simultâneos para calcular o ranking semanal e mensal no PostgreSQL.
  * *Solução:* Refatoração do método `ObterRankingsAsync` no `HomeController.cs`. A consulta foi dividida em agregação direta via LINQ no banco com `.AsNoTracking()` e posterior resolução em memória com `.ToDictionaryAsync()`, eliminando código duplicado e otimizando o plano de execução.

---

## 4. Frontend, Gamificação e Dashboard (Razor, Tailwind & JS)

### 4.1. Identidade Visual e Diretrizes Normativas
* Interface construída com **Tailwind CSS** em paleta temática *Cyber-Logistics / Dark Theme*.
* Inclusão de componentes visuais evidenciando a conformidade legal da empresa com a Lei nº 7.716/1989 e o Estatuto da Igualdade Racial.

### 4.2. Painel de Desempenho Trimestral
* Implementação do card com contagem e barras percentuais atualizadas em tempo real:
  * **Leituras:** Relação entre leituras realizadas versus total cadastrado.
  * **Jogos:** Relação entre quizzes concluídos versus total disponível.
  * **Vídeos:** Estrutura preparada com indicador de taxa de conclusão.
  * **Desempenho Global:** Média percentual ponderada de todas as atividades realizadas.

### 4.3. Sistema de Rankings e Correção no DOM
* **Integração C# com JavaScript:** Os dados dos rankings (Semanal, Mensal e Geral) calculados no backend são serializados via JSON diretamente para o script da view, permitindo alternância instantânea entre as abas sem recarregar a página.
* **Resolução de Bug no DOM:** Identificou-se que os dados chegavam à View, mas não renderizavam na tela por ausência do elemento `<div id="ranking-list">`. A correção da estrutura HTML restabeleceu a injeção dinâmica feita pela função `renderRanking()`.

---

## 5. Estrutura de Arquivos Criados e Mantidos

```text
ManaDigital.Web/
├── Controllers/
│   ├── AccountController.cs        # Autenticação, Registro, Sessão Cookie e API REST
│   └── HomeController.cs           # Dashboard, Métricas e Cálculo LINQ dos Rankings
├── Data/
│   └── AppDbContext.cs             # Mapeamento do modelo relacional via EF Core
├── Models/
│   ├── Usuario.cs                  # Entidade de Colaborador (Perfis 'adm' e 'comum')
│   ├── Leitura.cs                  # Textos, Leis e Artigos de microlearning
│   ├── Game.cs                     # Quizzes e Desafios temáticos
│   └── HistoricoPontuacaoLog.cs   # Extrato contábil de pontos (com ConteudoId Guid?)
├── ViewModels/
│   ├── HomeViewModel.cs            # Modelo fortemente tipado para o Dashboard
│   └── RankingDto.cs               # DTOs para transferência dos dados dos Leaderboards
├── Views/
│   ├── Account/
│   │   └── Login.cshtml            # Interface visual de Login e Cadastro
│   └── Home/
│       └── Index.cshtml            # Dashboard Gamificado com Leaderboards
├── appsettings.json                # String de conexão segura com o Supabase
└── Program.cs                      # Configuração de serviços, ORM e pipeline de segurança