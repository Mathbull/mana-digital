
# Mana Digital — Solução de Treinamento Corporativo em Diversidade Étnico-Racial
**Projeto Integrado Multidisciplinar (PIM VII) — CST em Análise e Desenvolvimento de Sistemas**

---

## 1. Visão Geral do Projeto e da Organização
* **Empresa:** Mana Digital (Empresa fictícia de médio/grande porte do setor de Logística Inteligente e Supply Chain).
* **Problema Identificado:** Baixa representatividade de pessoas negras em cargos de liderança, necessidade de letramento racial corporativo e alinhamento às diretrizes de ESG e legislação vigente.
* **Solução Proposta:** Plataforma corporativa híbrida composta por:
  1. **Aplicativo Mobile (Flutter):** App gamificado para colaboradores realizarem treinamentos, quizzes, leituras e submissão de ações afirmativas.
  2. **Plataforma Web (ASP.NET Core MVC):** Portal administrativo para gestão de RH, moderação de conteúdos e relatórios de conformidade social.
  3. **Backend API (ASP.NET Core Web API):** Serviços RESTful seguros com Entity Framework Core.
* **Embasamento Legal e Social:** Integração das diretrizes das Leis nº 10.639/2003 e nº 11.645/2008, promovendo o combate ao racismo estrutural e institucional.

---

## 2. Arquitetura da Solução

```
                    ┌─────────────────────────┐
                    │ Colaborador: App Flutter│
                    │   (Mobile / Offline-Sync)│
                    └────────────┬────────────┘
                                 │ HTTPS / JSON (JWT)
                                 ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND ASP.NET CORE                       │
│  ┌───────────────────────┐       ┌────────────────────────┐ │
│  │   ASP.NET Web API     │       │  ASP.NET Core MVC      │ │
│  │  (Endpoints p/ Mobile)│       │  (Painel Web para RH)  │ │
│  └───────────┬───────────┘       └───────────┬────────────┘ │
│              │                               │              │
│              └───────────────┬───────────────┘              │
│                              ▼                              │
│                Entity Framework Core (ORM)                  │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
                    [ Banco de Dados PostgreSQL ]
```

---

## 3. Especificação Funcional

### 3.1. Aplicativo Mobile (Flutter)
1. **Autenticação e Perfil:**
   - Login com e-mail corporativo e senha criptografada (Token JWT).
   - Tela de perfil com avatar, pontuação geral, histórico de logs e nível atual (*Bronze: 0-100 pts | Prata: 101-300 pts | Ouro: 301-600 pts | Diamante: 601+ pts*).
2. **Dashboard / Home:**
   - Ranking (Semanal, Mensal e Geral) para engajamento saudável.
   - Progresso das trilhas (leituras, vídeos, quizzes).
   - Vitrine de Medalhas (badges conquistados por conquistas).
3. **Módulo Educacional (Microlearning):**
   - **Leituras:** Pílulas de conhecimento sobre marcos históricos, conceitos de racismo estrutural e artigos de lei. Ao final, validação com 2 perguntas (Verdadeiro/Falso).
   - **Vídeos Curtos:** Conteúdos em formato dinâmico com pergunta de fixação.
   - **Quizzes (Games):** Questionários temáticos de até 5 perguntas com pontuação proporcional ao acerto.
4. **Módulo de Iniciativas:**
   - Cadastro e upload de comprovações de engajamento (fotos de leitura, link de post no LinkedIn sobre diversidade, convite de colegas).
5. **Modo Offline:**
   - Armazenamento local (Hive ou SQLite) de conteúdos já baixados para execução em áreas sem sinal de internet no galpão logístico.

### 3.2. Portal Administrativo Web (ASP.NET Core MVC)
1. **Gestão de Conteúdos:** Cadastro, edição e desativação de trilhas, textos, vídeos e quizzes.
2. **Moderação de Iniciativas:** Fila de aprovação/rejeição das atividades enviadas pelos usuários (com atribuição automática de pontos após aprovação).
3. **Relatórios Gerenciais:** Métricas de engajamento da equipe, índice de letramento racial e dados agregados de impacto organizacional.

---

## 4. Modelo Lógico de Dados (Relacional)

* **Usuarios** (`Id`, `Nome`, `Email`, `PasswordHash`, `Cargo`, `Role` [Admin/User], `PontosTotais`, `Patente`, `ConvidadoPorUserId`, `CriadoEm`)
* **Conteudos** (`Id`, `TipoConteudo` [Leitura/Video], `Titulo`, `Descricao`, `UrlMidiaOuTexto`, `PontosRecompensa`, `Ativo`)
* **Questoes** (`Id`, `ConteudoId` [FK opcional], `Enunciado`, `TipoQuestao` [Quiz/VF], `Pontos`)
* **OpcoesResposta** (`Id`, `QuestaoId` [FK], `TextoOpcao`, `IsCorreta`)
* **Iniciativas** (`Id`, `UsuarioId` [FK], `TipoIniciativa` [Foto/Convite/LinkedIn], `Descricao`, `UrlComprovante`, `PontosAtribuidos`, `Status` [Pendente/Aprovado/Rejeitado], `ValidadoPorAdminId` [FK, nullable], `DataEnvio`)
* **HistoricoPontuacao_Log** (`Id`, `UsuarioId` [FK], `OrigemTipo` [Conteudo/Quiz/Iniciativa], `OrigemId`, `PontosGanhos`, `DataHora`)
* **Medalhas** (`Id`, `Titulo`, `Descricao`, `IconeUrl`, `PontosNecessarios`)
* **UsuariosMedalhas** (`UsuarioId` [FK], `MedalhaId` [FK], `DataConquista`)

---

## 5. Plano de Negócios e Empreendedorismo (Estrutura PIM)
* **Proposta de Valor:** Plataforma B2B para redução de riscos reputacionais e aumento do índice ESG corporativo através de treinamento gamificado de colaboradores.
* **Público-Alvo:** Departamentos de RH e Operações Logísticas.
* **Modelo de Receita:** SaaS Corporativo (licenciamento por colaborador ativo/mês).
* **Custos Previstos:** Servidores em nuvem (Docker/PostgreSQL), suporte, produção de conteúdo pedagógico e infraestrutura de TI.


---

### 3. Conselhos do Professor para a Equipe

#### Sobre o Backend e Arquitetura (.NET + Docker + Banco)
1. **Dúvida do time: "O servidor devolve View ou JSON?"**
   * No **ASP.NET Core**, vocês podem criar uma mesma aplicação com **dois tipos de Controllers**:
     * `Controllers` herdando de `Controller` devolvem `View()` (as páginas HTML do Painel do RH em MVC).
     * `Controllers` herdando de `ControllerBase` com a anotação `[ApiController]` devolvem `Ok(objeto)` (JSON para o Flutter).
   * **Dica de ouro:** Usem **JWT (JSON Web Token)** para autenticar o Flutter e **Cookies de Autenticação** para o login web do Admin no MVC.
2. **Sobre o Banco e Docker:**
   * O **Supabase** é uma ótima ideia porque fornece um banco PostgreSQL gratuito na nuvem pronto para uso. Assim, tanto o backend local do Matheus quanto o do Wesley podem conectar na mesma `Connection String` de banco sem precisar ficar trocando dump de banco.
   * Se preferirem Docker local, basta subir uma imagem de `postgres` ou `mcr.microsoft.com/mssql/server` via `docker-compose.yml`.

#### Nivelamento do time (Matheus e Wesley)
Vocês precisam fazer um **"Dia 0 de Setup"**:
1. **Git/GitHub primeiro:** Antes de qualquer linha de código, criem o repositório no GitHub. Wesley precisa instalar o Git e aprender apenas 5 comandos: `git clone`, `git pull`, `git add .`, `git commit -m "mensagem"` e `git push`. Nada de mandar código por WhatsApp ou Drive.
2. **Divisão de Tarefas Clara:**
   * **Integrante A (Wesley/Matheus):** Pega a modelagem do Entity Framework Core e a criação dos endpoints da API REST (Login, Listar Conteúdos, Salvar Respostas).
   * **Integrante B (Wesley/Matheus):** Pega as telas do Flutter (começando pelo consumo do endpoint de Login e tela de Home com ranking).
   * **Integrante C (ou divisão compartilhada):** Escrever a fundamentação teórica sobre as Leis 10.639 e 11.645 e montar o Business Model Canvas do trabalho escrito.

#### O que vocês devem fazer AGORA:
1. Copiem o `doc-001-v2.md` acima para o repositório de vocês como base.
2. Criem o projeto ASP.NET Core (`dotnet new mvc` ou via Visual Studio criando MVC + Controllers de API).
3. Escrevam a introdução do trabalho acadêmico explicando por que a Mana Digital precisa dessa solução.

Qual é a primeira barreira que vocês querem resolver hoje: o setup do banco/GitHub com a equipe ou a estrutura inicial dos Controllers no .NET?