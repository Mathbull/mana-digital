# 📄 Documento de Implementação — Sprint 03 (`doc-implementacao-003.md`)
**Projeto Integrado Multidisciplinar VII (PIM VII)**  
**Curso:** Superior de Tecnologia em Análise e Desenvolvimento de Sistemas (ADS) / UNIP  
**Empresa-Caso:** Mana Digital (Logística Inteligente & Soluções ESG)  
**Tema:** Gamificação Corporativa e Letramento Racial (Leis nº 10.639/03, 7.716/89 e 12.288/10)  
**Data da Implementação:** 19 de Setembro de 2026  
**Stack:** ASP.NET Core MVC, Entity Framework Core, PostgreSQL (Supabase), Tailwind CSS, JavaScript  

---

## 1. Objetivo da Iteração

Neste ciclo, consolidamos a experiência prática do colaborador no portal Web da **Mana Digital**, integrando os módulos de **Leituras**, **Dashboard Principal (Home)** e o **Motor Centralizado de Medalhas**, com foco em:
* Conexão ponta a ponta entre interface, backend e banco de dados relacional;
* Refinamento de User Experience (UX) com modais assíncronos e controle de recarregamento inteligente;
* Eliminação de redundâncias visuais e resolução de acoplamento entre ViewModels e Layout compartilhado;
* Calibração precisa dos 20 critérios oficiais de medalhas cadastradas no Supabase.

---

## 2. Implementações e Melhorias por Componente

### 2.1. Módulo de Leituras & Microlearning (`LeiturasController` e `index.cshtml`)
* **Grade Responsiva 3x3:** Organização dos conteúdos formativos em até 3 colunas (`grid-cols-1 md:grid-cols-2 lg:grid-cols-3`).
* **Diferenciação de Estados:**
  * *Cards Disponíveis:* Destaque visual com badge `+10 XP`, botão de ação *"Ler e Responder"*.
  * *Cards Concluídos:* Estilização em tom ciano/suave com badge `✓ Concluída`, travamento das opções de envio e liberação do botão *"Revisar Leitura"*.
* **Modal Dinâmico & Anti-Fraude:**
  * Avaliação das respostas Verdadeiro/Falso processada estritamente no servidor (`LeiturasController.Responder`).
  * Concessão de 5 pontos por afirmativa correta (máximo de 10 XP).
  * Exibição de justificativas pedagógicas oficiais vinculadas às Leis nº 10.639 e nº 12.288.
  * Validação anti-duplicação: o sistema barra tentativas de pontuar mais de uma vez no mesmo conteúdo através do `historico_pontuacao_log`.
* **Ajuste de UX no Fechamento do Modal:**
  * Substituição do recarregamento automático por temporizador (`setTimeout 1.5s`) pelo padrão de **Bandeira de Controle (Flag)**: a tela só recarrega quando o colaborador decide ativamente fechar a janela (`fecharModal`), permitindo a leitura com calma das explicações e pontuações.
* **Flexibilização da Pontuação Zero no Banco:**
  * Adequação da restrição no PostgreSQL de `CHECK (pontos_ganhos > 0)` para `CHECK (pontos_ganhos >= 0)`, permitindo registrar a conclusão do conteúdo no histórico mesmo quando o usuário não atinge acertos.

---

### 2.2. Padronização do Menu e Layout Compartilhado (`_Layout.cshtml`)
* **Herança de ViewModels (`LeiturasViewModel : HomeViewModel`):**
  * Resolução de conflito de tipagem entre a View filha e o layout compartilhado, garantindo a exibição ininterrupta do avatar, XP total e patente na barra superior.
* **Remoção de Menu Duplicado:**
  * Eliminação do `<header>` secundário presente na página de Leituras, centralizando a navegação exclusivamente no `_Layout.cshtml`.
* **Destaque Dinâmico de Rota Ativa:**
  * Implementação da checagem via `ViewContext.RouteData.Values["controller"]` para aplicar dinamicamente o destaque visual (`text-secondary bg-secondary/10`) na aba atualmente acessada (Home vs. Leituras).
* **Configuração de CORS:**
  * Adição de política de Cross-Origin no `Program.cs` para habilitar chamadas de teste e comunicação com o futuro cliente Flutter Web.

---

### 2.3. Motor de Conquistas & Gamificação (`MedalhaService.cs`)
Refatoração e calibração integral do serviço para reconhecer e avaliar automaticamente os **20 critérios reais** cadastrados na tabela `medalhas`:

1. **Onboarding & Conteúdos Básicos:** `primeiro_login`, `leitura_1`, `video_1`, `game_1`, `iniciativa_1`.
2. **Volume e Progressão:** `leitura_5`, `video_5`, `total_10` (leitura + vídeo >= 10), `triade_1` (mínimo de 1 leitura, 1 vídeo e 1 quiz).
3. **Performance e Patente:** `patente_alta` (XP >= 500), `game_perfeito` (quiz com 10/10 pontos).
4. **Conteúdo Temático Específico (Inspeção de Log):**
   * `lei_compliance`: Conclusão com sucesso de leitura contendo menção às Leis nº 10.639, 7.716 ou 12.288.
   * `teoricos_raciais`: Estudos sobre intelectuais de referência (Chimamanda Adichie, Kabengele Munanga, Djamila Ribeiro).
   * `mito_democracia`: Pontuação máxima no quiz temático sobre a desconstrução do Mito da Democracia Racial.
5. **Engajamento e Convites:** `convite_1` e `convite_5` (validados via contagem na coluna `convidado_por` da tabela `usuarios`).
6. **Iniciativas Corporativas & ESG:** `iniciativa_aprovada_1`, `iniciativa_aprovada_3`, `linkedin_share`.
7. **Constância Diária (`streak_5`):** Algoritmo dedicado `CalcularDiasConsecutivos` para identificar 5 dias ininterruptos de atividade e pontuação.
* **Garantia de Não Duplicação:** Filtro prévio por `UsuarioMedalhas` impedindo que qualquer conquista seja conferida mais de uma vez.
* **Auditoria Contábil:** Todo bônus de XP de medalha desbloqueada é automaticamente inserido na tabela `historico_pontuacao_log`.

---

### 2.4. Redesign do Dashboard (`Home/Index.cshtml`)
* **Remoção do Card Provisório:** Exclusão do bloco fixo *"Desafio do Dia • Legislação"*, limpando a poluição visual inicial.
* **Harmonia da Seção Central (Grid 50/50):**
  * Lado Esquerdo (6 colunas): **Desempenho Atual** (taxas percentuais e progresso real de Leituras, Vídeos e Jogos).
  * Lado Direito (6 colunas): **Classificação** (Leaderboard com abas Semanal, Mensal e Geral alimentadas dinamicamente).
* **Vitrine de Medalhas Ponta a Ponta (Largura Total - 12 Colunas):**
  * Alocação da seção de medalhas na base da página com visual expansivo de 4 colunas no desktop.
  * **Otimização de Altura (Scroll Interno):** Aplicação de `max-h-[255px]` e `overflow-y-auto` com scrollbar ultrafina em estilo dark, exibindo confortavelmente 3 linhas de medalhas (12 cards) de forma fixa e permitindo rolagem suave para as demais, evitando sobrecarregar a altura do dashboard.

---

## 3. Matriz de Arquivos Criados e Modificados

| Arquivo | Ação | Descrição Técnica |
| :--- | :---: | :--- |
| `Services/MedalhaService.cs` | Criado | Lógica de concessão dos 20 critérios de medalhas, streak e bônus de XP. |
| `ViewModels/LeiturasViewModel.cs` | Modificado | Herança de `HomeViewModel` para compartilhar estado de pontuação e layout. |
| `Controllers/LeiturasController.cs` | Modificado | Integração com `MedalhaService`, injeção de dependência e anti-fraude. |
| `Views/Leituras/index.cshtml` | Modificado | Grade 3x3, remoção de header duplicado e recarregamento condicionado no fechamento do modal. |
| `Views/Shared/_Layout.cshtml` | Modificado | Estilização condicional de links ativos com base na rota do controller. |
| `Views/Home/Index.cshtml` | Modificado | Reorganização 50/50 (Performance e Ranking) e vitrine de medalhas ponta a ponta com scroll. |
| `Program.cs` | Modificado | Registro do `MedalhaService` no container IoC e configuração da política de CORS. |
| `Docs/SQLs.md` | Atualizado | Documentação do `ALTER TABLE` para `CHECK (pontos_ganhos >= 0)`. |

---

## 4. Próximos Passos (Backlog Sprint 04)

1. **Módulo de Jogos e Quizzes (Games):**
   * Construção da interface interativa para resolução dos 4 quizzes cadastrados (5 perguntas por jogo, cálculo proporcional de acertos e gravação no log).
2. **Módulo de Iniciativas:**
   * Formulário de submissão de ações afirmativas (upload de comprovante e resumo) e fila de moderação para usuários administradores (`cargo = 'adm'`).
3. **Consumo da API no Flutter (Mobile):**
   * Configuração das chamadas HTTP no aplicativo mobile consumindo os endpoints de login e listagem de trilhas.