# 📄 Documento de Implementação — Sprint 04 (`doc-implementacao-004.md`)
**Projeto Integrado Multidisciplinar VII (PIM VII)**  
**Curso:** Superior de Tecnologia em Análise e Desenvolvimento de Sistemas (ADS) / UNIP  
**Empresa-Caso:** Mana Digital (Logística Inteligente & Soluções ESG)  
**Tema:** Gamificação Tática, Quizzes Decisórios e Governança de Ações Afirmativas  
**Data da Implementação:** 20 de Setembro de 2026  
**Stack:** ASP.NET Core MVC, Entity Framework Core, PostgreSQL (Supabase), Tailwind CSS, JavaScript  

---

## 1. Resumo Executivo da Sprint

Nesta etapa, a equipe completou os dois módulos finais de interação corporativa da plataforma **Mana Digital**:
1. **Módulo de Jogos (Simuladores Antirracistas):** Implementação da camada completa (Model, Controller, ViewModels e Views) para resolução dos 4 Quizzes temáticos (20 questões com 60 alternativas), cálculo de pontuação proporcional (2 XP por questão, totalizando até 10 XP por quiz) e simulador imersivo de tomada de decisão.
2. **Módulo de Iniciativas Corporativas (ESG & Ações Práticas):** Criação da tabela relacional no Supabase, modelos C#, formulários de ação embutidos (Leitura, Convite de Colega e LinkedIn), controle de status em tempo real e painel de moderação com controle de acesso baseado em função (*Role-Based Access Control - RBAC*) para administradores.
3. **Integração com o `MedalhaService`:** Conexão dos novos módulos com o motor central de conquistas, viabilizando o desbloqueio automático de medalhas de performance (`game_perfeito`, `mito_democracia`), engajamento social (`convite_1`, `convite_5`, `linkedin_share`) e liderança corporativa (`iniciativa_1`, `iniciativa_aprovada_1`, `iniciativa_aprovada_3`).

---

## 2. Módulo de Jogos e Simuladores Decisórios

### 2.1. Modelagem Relacional & Entity Framework Core
Mapeamento formal da estrutura hierárquica `games` (1:N) `game_perguntas` (1:N) `game_respostas`:
* **`Game.cs`:** Representa a entidade principal do quiz (`id`, `titulo`, `descricao`, `pontos_total`).
* **`GamePergunta.cs`:** Mapeia as 5 perguntas com ordenação e pontuação individual (`ordem`, `pontos = 2`).
* **`GameResposta.cs`:** Mapeia as 3 alternativas de múltipla escolha com indicação de gabarito booleano (`is_correta`).
* **`AppDbContext.cs`:** Registro dos DbSets `Games`, `GamePerguntas` e `GameRespostas`.

### 2.2. Lógica de Negócio e Pontuação (`JogosController.cs`)
* **Listagem (`GET /Jogos`):** Apresenta os 4 quizzes em formato de cards táticos, checando na tabela `historico_pontuacao_log` quais quizzes já foram finalizados pelo usuário logado (exibindo selo *Concluído* ou *+10 XP*).
* **Simulador (`GET /Jogos/Jogar/{id}`):** Carrega os dados ordenados da simulação no modelo fortemente tipado `GamePlayViewModel`.
* **Processamento e Auditoria (`POST /Jogos/Finalizar`):**
  * Barreira anti-duplicação: impede concessão repetida de pontos para um mesmo quiz.
  * Validação no servidor: calcula o número de acertos multiplicando por 2 pontos (permitindo somas parciais: 0, 2, 4, 6, 8 ou 10 XP).
  * Registro contábil no `historico_pontuacao_log` e soma direta na tabela `usuarios`.
  * Avaliação imediata de medalhas pelo `MedalhaService`.

### 2.3. Interface do Simulador (`Jogos/Jogar.cshtml`)
* **Barra de Telemetria Superior:** Exibe pips dinâmicos de progresso (Questão 1 a 5) com estados visuais (*Concluída*, *Ativa com pulso* e *Pendente*).
* **Cenário Operacional:** Contextualização do caso prático de compliance logístico e apresentação das alternativas A, B e C.
* **Feedback Instantâneo:** Painel explicativo com fundamentação legal (Lei nº 7.716/1989 e Lei nº 10.639/2003).
* **Sidebar Focada:** Placar da rodada com contagem de acertos, pontuação parcial em tempo real e barra de progresso gradiente (eliminando cards secundários para evitar dispersão).

---

## 3. Módulo de Iniciativas e Responsabilidade Social (ESG)

### 3.1. Estrutura de Dados no Supabase (`public.iniciativas`)
Execução do script DDL criando a tabela com integridade referencial:
* `id` (UUID, Primary Key);
* `usuario_id` (FK para `usuarios`, cascade delete);
* `tipo` (restrição `CHECK` para `'livro_resumo'`, `'linkedin'`, `'convite'`, `'acao_interna'`);
* `titulo`, `descricao`, `anexo_url`, `pontos_sugeridos`, `pontos_atribuidos`;
* `status` (restrição `CHECK` para `'pendente'`, `'aprovado'`, `'rejeitado'`);
* `validado_por` (FK opcional para o administrador avaliador), `justificativa_admin`;
* `created_at` e `validado_em` (auditoria temporal com timezone UTC);
* Índices B-Tree em `usuario_id` e `status`.

### 3.2. Engenharia de Backend & Moderação Segura (`IniciativasController.cs`)
* **Envio de Proposta (`POST /Iniciativas/Submeter`):**
  * Recebe os dados via JSON (`NovaIniciativaDto`), valida campos obrigatórios e grava o registro com status `pendente`.
  * Registra evento no `historico_pontuacao_log` com 0 XP inicial e dispara o `MedalhaService` para conceder a medalha `iniciativa_1` (Voz Ativa).
* **Moderação Restrita (`POST /Iniciativas/Moderar`):**
  * Proteção RBAC: valida se o usuário autenticado possui `cargo == 'adm'`.
  * Se **Aprovado**: altera o status, define `pontos_atribuidos`, soma os pontos ao perfil do autor, grava no extrato contábil e aciona o motor de medalhas (`iniciativa_aprovada_1`, `iniciativa_aprovada_3`, `linkedin_share`).
  * Se **Rejeitado**: salva o status com a justificativa informada pelo comitê para ciência do colaborador.

### 3.3. Interface com Ações Embutidas (`Iniciativas/Index.cshtml`)
* **Grid 7/5 de Alta Densidade:**
  * *Coluna Esquerda (7 colunas):* 3 cards de ação direta com formulários próprios (sem modais obstrutivos):
    1. **Leitura Antirracista:** Título da obra, reflexão aplicada à logística e link de foto/comprovante (+60 a 80 XP).
    2. **Indicação de Colega:** Input de e-mail corporativo com gerador instantâneo de link de convite e botão de cópia (+30 XP).
    3. **Multiplicador no LinkedIn:** Input da URL da postagem externa de advocacy (+50 XP).
  * *Coluna Direita (5 colunas):* Lista de **Minhas Submissões** com badges de status em tempo real (*Em Análise* em âmbar pulsante, *Aprovado* em esmeralda e *Recusado* em vermelho).
  * *Painel de Moderação ESG:* Exibido exclusivamente para administradores abaixo da lista pessoal, permitindo aprovação ou rejeição com um clique.

---

## 4. Matriz de Arquivos Criados e Modificados

```text
ManaDigital.Web/
├── Controllers/
│   ├── JogosController.cs          # Listagem, simulador de quizzes e submissão com medalhas
│   └── IniciativasController.cs    # Cadastro de ações, histórico e moderação administrativa
├── Data/
│   └── AppDbContext.cs             # Registro dos DbSets: Games, Perguntas, Respostas e Iniciativas
├── Models/
│   ├── Game.cs                     # Entidade do Quiz
│   ├── GamePergunta.cs             # Entidade das Questões (2 pts cada)
│   ├── GameResposta.cs             # Entidade das Alternativas com gabarito booleano
│   └── Iniciativa.cs               # Entidade de Ações Corporativas ESG
├── ViewModels/
│   ├── JogosViewModel.cs           # DTOs para listagem e execução do simulador tático
│   └── IniciativasViewModel.cs     # DTOs para submissão, histórico e fila de moderação
├── Views/
│   ├── Jogos/
│   │   ├── Index.cshtml            # Catálogo dos 4 Quizzes (estilo Leituras)
│   │   └── Jogar.cshtml            # Simulador tático decisório (questões, alternativas e placar)
│   ├── Iniciativas/
│   │   └── Index.cshtml            # Painel com 3 ações embutidas, histórico e moderação ADM
│   └── Shared/
│       └── _Layout.cshtml          # Ativação das rotas no menu de navegação superior
└── Docs/
    ├── SQLs.md                     # DDL da tabela iniciativas e inserts dos 4 jogos
    └── doc-implementacao-004.md    # Este relatório técnico de consolidação