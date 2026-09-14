```sql
-- Habilita extensão para geração de UUIDs (padrão Supabase)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================================
-- MÓDULO 1: LEITURAS E PERGUNTAS (VERDADEIRO OU FALSO)
-- ==========================================================

-- Tabela de Leituras (Trechos de livros, Leis, Fatos atuais)
CREATE TABLE IF NOT EXISTS public.leitura (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    conteudo TEXT NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('trecho_livro', 'artigo_lei', 'fato_atual')),
    pontos_total INT DEFAULT 10, -- 2 perguntas de 5 pontos cada
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- Tabela de Perguntas de V/F vinculadas à leitura
-- Cada registro é uma afirmação que o usuário julga como Verdadeira ou Falsa
CREATE TABLE IF NOT EXISTS public.leitura_respostas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leitura_id UUID NOT NULL REFERENCES public.leitura(id) ON DELETE CASCADE,
    afirmacao TEXT NOT NULL, -- O texto da afirmativa a ser julgada
    is_correta BOOLEAN NOT NULL, -- TRUE se a afirmação for verdadeira, FALSE se for falsa
    pontos INT NOT NULL DEFAULT 5, -- 5 pontos por acerto
    explicacao TEXT, -- Justificativa pedagógica exibida após responder
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- ==========================================================
-- MÓDULO 2: GAMES (QUIZZES COM PONTUAÇÃO PARCIAL)
-- ==========================================================

-- Tabela que agrupa o Game / Quiz
CREATE TABLE IF NOT EXISTS public.games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    pontos_total INT DEFAULT 10, -- Total máximo do jogo
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- Tabela de Questões do Game (até 5 questões por jogo)
CREATE TABLE IF NOT EXISTS public.game_perguntas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
    pergunta TEXT NOT NULL,
    pontos INT NOT NULL DEFAULT 2, -- 2 pontos por questão (5 x 2 = 10 pts)
    ordem INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- Tabela de Alternativas das Questões (até 3 alternativas por questão)
CREATE TABLE IF NOT EXISTS public.game_respostas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pergunta_id UUID NOT NULL REFERENCES public.game_perguntas(id) ON DELETE CASCADE,
    resposta TEXT NOT NULL, -- Texto da alternativa
    is_correta BOOLEAN NOT NULL DEFAULT FALSE, -- Apenas 1 deve ser TRUE
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- ==========================================================
-- ÍNDICES PARA OTIMIZAÇÃO DE BUSCAS
-- ==========================================================
CREATE INDEX IF NOT EXISTS idx_leitura_respostas_leitura_id ON public.leitura_respostas(leitura_id);
CREATE INDEX IF NOT EXISTS idx_game_perguntas_game_id ON public.game_perguntas(game_id);
CREATE INDEX IF NOT EXISTS idx_game_respostas_pergunta_id ON public.game_respostas(pergunta_id);

-- -- ==========================================================
-- -- HABILITAÇÃO DE ROW LEVEL SECURITY (RLS) NO SUPABASE
-- -- ==========================================================
-- ALTER TABLE public.leitura ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.leitura_respostas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.game_perguntas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.game_respostas ENABLE ROW LEVEL SECURITY;

-- -- Políticas de leitura pública (usuários autenticados ou anônimos podem ler o conteúdo)
-- CREATE POLICY "Permitir leitura para todos" ON public.leitura FOR SELECT USING (true);
-- CREATE POLICY "Permitir leitura das perguntas de leitura" ON public.leitura_respostas FOR SELECT USING (true);
-- CREATE POLICY "Permitir leitura dos games" ON public.games FOR SELECT USING (true);
-- CREATE POLICY "Permitir leitura das perguntas de games" ON public.game_perguntas FOR SELECT USING (true);
-- CREATE POLICY "Permitir leitura das respostas de games" ON public.game_respostas FOR SELECT USING (true);
```

## Script SQL para População das Tabelas Leituras
```SQL
-- ====================================================================
-- 1. INSERÇÃO DAS 20 LEITURAS (trecho_livro, fato_atual, artigo_lei)
-- ====================================================================

INSERT INTO public.leitura (id, titulo, conteudo, tipo, pontos_total) VALUES
-- 1. Chimamanda e o conceito de Nkali
('10000000-0000-0000-0000-000000000001', 
 'O Perigo de uma História Única e a Estrutura de Poder (Nkali)', 
 'É impossível falar sobre única história sem falar sobre poder. Há uma palavra da tribo Igbo que eu lembro sempre que penso sobre as estruturas de poder do mundo: "nkali", um substantivo que livremente se traduz por "ser maior do que o outro". Histórias também são definidas pelo princípio do nkali: como são contadas, quem as conta, quando e quantas histórias são contadas depende de quem detém o poder.', 
 'trecho_livro', 10),

-- 2. Chimamanda e os Estereótipos
('10000000-0000-0000-0000-000000000002', 
 'Estereótipos e a Perda da Humanidade Compartilhada', 
 'A única história cria estereótipos. E o problema com os estereótipos não é que eles sejam mentiras, mas que eles são incompletos. Eles fazem uma história tornar-se a única história. A consequência de uma única história é que ela rouba das pessoas a sua dignidade, dificultando o reconhecimento de nossa humanidade compartilhada e enfatizando as diferenças em vez das semelhanças.', 
 'trecho_livro', 10),

-- 3. Genética e Inexistência Biológica de Raças
('10000000-0000-0000-0000-000000000003', 
 'A Inexistência Biológica de Raças Humanas', 
 'As mais recentes pesquisas dos geneticistas demonstram que nos genes não se comprovam as teorias das raças humanas. A espécie Homo sapiens não pode ser dividida em grupos biológicos distintos. A diversidade biológica é incomparavelmente pequena se confrontada às experiências ambientais e culturais. Quando afirmamos que as raças não existem biologicamente, ressaltamos que somos uma única espécie.', 
 'fato_atual', 10),

-- 4. O Conceito Político e Sócio-Histórico de Raça
('10000000-0000-0000-0000-000000000004', 
 'Raça como Categoria Sócio-Histórica e Política', 
 'As Diretrizes Curriculares Nacionais (2004) ressaltam que raça é uma construção social forjada nas relações entre brancos e negros, servindo para expor como características físicas determinam o lugar social dos indivíduos. Os movimentos negros ressignificam o termo politicamente para desconstruir o racismo e reivindicar igualdade de direitos e políticas de reparação.', 
 'trecho_livro', 10),

-- 5. O Conceito de Etnia e Etnicidade
('10000000-0000-0000-0000-000000000005', 
 'Etnia e a Dimensão Relacional da Etnicidade', 
 'Etnia diz respeito a grupos que partilham memórias, valores e sentimentos de pertencimento a uma origem comum. A identidade étnica é dialética: envolve a autoatribuição do próprio indivíduo (endógena) e o reconhecimento ou atribuição pelos outros (exógena). Por ter caráter relacional e contrastivo, a etnicidade é um processo dinâmico e nunca algo estático.', 
 'trecho_livro', 10),

-- 6. Racismo Científico do Século XIX
('10000000-0000-0000-0000-000000000006', 
 'O Racismo Científico e a Naturalização das Desigualdades', 
 'No século XIX, o racismo científico articulou a teoria positivista para classificar seres humanos hierarquicamente. Conforme Lima e Vala (2004), o racismo opera pela redução do cultural ao biológico: marcas físicas externas (como a cor da pele) são convertidas em marcas culturais internas (como inteligência ou temperamento), naturalizando desigualdades sociais.', 
 'trecho_livro', 10),

-- 7. Racialismo, Eugenia e Autoritarismo
('10000000-0000-0000-0000-000000000007', 
 'Ideologias Racialistas e Políticas Extremistas', 
 'As doutrinas racialistas do século XIX fundamentaram políticas de extermínio e eugenia no século XX, cujo caso mais extremo foi o nazismo alemão. Teorias semelhantes sustentam ideologias extremistas contemporâneas, como o manifesto do atirador da Noruega em 2011, que apontava a miscigenação brasileira de modo preconceituoso e catastrófico com base em ideias de pureza racial.', 
 'fato_atual', 10),

-- 8. O Mito da Democracia Racial
('10000000-0000-0000-0000-000000000008', 
 'Gilberto Freyre e o Mito da Democracia Racial', 
 'A partir de "Casa-Grande & Senzala" (1933), difundiu-se a noção de convivência harmônica entre colonizadores, indígenas e africanos escravizados. Essa abordagem originou o "mito da democracia racial", propagando a ideia de que o Brasil não possuiria barreiras raciais. Na prática, gerou um racismo dissimulado, negado no cotidiano, mas visível nas desigualdades.', 
 'trecho_livro', 10),

-- 9. A Fábula das Três Raças
('10000000-0000-0000-0000-000000000009', 
 'Roberto DaMatta e a Ambivalência da Fábula das Três Raças', 
 'O antropólogo Roberto DaMatta analisa que a "fábula das três raças" consolidou-se como a mais forte força cultural brasileira para idealizar o país. O discurso encobre a história de exploração, extermínio indígena e escravização de africanos, permitindo que a sociedade brasileira se imagine igualitária e harmônica enquanto preserva hierarquias sociais profundas.', 
 'trecho_livro', 10),

-- 10. O Homem Cordial de Sérgio Buarque de Holanda (UUID CORRIGIDO)
('10000000-0000-0000-0000-000000000010', 
 'A Cordialidade Brasileira em Raízes do Brasil', 
 'Em "Raízes do Brasil", Sérgio Buarque de Holanda explica o conceito do "homem cordial", originário do latim "cor, cordis" (coração). A cordialidade não significa que o brasileiro é pacífico ou educado, mas sim que rege suas relações pelo afeto e pela emoção em detrimento da lei formal, abrindo brechas para a informalidade e a ausência de limites entre o público e o privado.', 
 'trecho_livro', 10),

-- 11. Estudos Genéticos no Brasil (Pena e Bortolini)
('10000000-0000-0000-0000-000000000011', 
 'Genômica Brasileira e Ancestralidade Miscigenada', 
 'Pesquisas coordenadas pelos geneticistas Sérgio Danilo Pena (UFMG) e Maria Cátira Bortolini (UFRGS) evidenciaram que a ancestralidade genômica dos brasileiros independe da cor exterior da pele. Pessoas autodeclaradas brancas, pardas e pretas carregam significativo mosaico genético compartilhado, fruto de séculos de miscigenação, comprovando que a cor é traço fenotípico.', 
 'fato_atual', 10),

-- 12. Pressupostos do Racismo segundo Guimarães
('10000000-0000-0000-0000-000000000012', 
 'Preconceito, Discriminação e Desigualdade Estrutural', 
 'O sociólogo Antonio Sérgio Guimarães detalha que o preconceito racial opera no campo das crenças internas, enquanto a discriminação se materializa em ações e comportamentos públicos. Já a desigualdade racial traduz o racismo institucional inserido na estrutura econômica e social, observável na distribuição de renda, saúde, escolaridade e moradia.', 
 'trecho_livro', 10),

-- 13. Preconceito de Marca versus Preconceito de Origem
('10000000-0000-0000-0000-000000000013', 
 'Oracy Nogueira e as Modalidades de Preconceito Racial', 
 'Em estudo clássico (1954), o sociólogo Oracy Nogueira diferenciou o racismo praticado no Brasil e nos EUA. Nos Estados Unidos predomina o "preconceito de origem", baseado na linhagem sanguínea (basta ter ascendência negra). No Brasil atua o "preconceito de marca", em que a rejeição e o tratamento variam em função do fenótipo: tom de pele, traços faciais e textura do cabelo.', 
 'fato_atual', 10),

-- 14. Autoidentificação Racial no Censo e Movimento Negro
('10000000-0000-0000-0000-000000000014', 
 'A Importância da Autodeclaração Censitária', 
 'O IBGE classifica a população pelas categorias: branca, preta, parda, amarela e indígena. Em 1976 foram registradas 136 autodenominações informais (como "moreno claro", "café-com-leite"). Campanhas do movimento negro, como "Não deixe sua cor passar em branco" (1990) e Bamidelê (2010), atuam para incentivar a autodeclaração consciente de pretos e pardos como negros.', 
 'fato_atual', 10),

-- 15. Desigualdades Econômicas Regionais e Raciais
('10000000-0000-0000-0000-000000000015', 
 'Concentração do PIB e Disparidades Étnico-Raciais', 
 'Dados do IBGE e da PNAD revelam uma profunda correlação entre território, raça e desenvolvimento. Sul e Sudeste concentram mais de 70% do PIB nacional e predominância de pessoas autodeclaradas brancas. As regiões Norte e Nordeste reúnem maior percentual de pardos e pretos e registram índices sensivelmente inferiores de renda per capita.', 
 'fato_atual', 10),

-- 16. O Teto de Vidro no Mercado de Trabalho
('10000000-0000-0000-0000-000000000016', 
 'Pesquisa do Instituto Ethos e Barreiras Corporativas', 
 'O levantamento do Instituto Ethos nas 500 maiores empresas brasileiras apontou que a presença negra diminui à medida que os níveis hierárquicos sobem. Enquanto negros formavam fatia expressiva no quadro operacional, ocupavam pouco mais de 5% das funções executivas diretivas. A esse bloqueio invisível dá-se o nome de "teto de vidro".', 
 'fato_atual', 10),

-- 17. Desigualdade no Ensino Superior e Analfabetismo
('10000000-0000-0000-0000-000000000017', 
 'Abismo Educacional entre Brancos e Afrodescendentes', 
 'Estatísticas da PNAD indicam que a taxa de analfabetismo entre negros e pardos era mais que o dobro da observada entre brancos. No ensino superior, além de ingressarem em menor escala e concentrarem-se em instituições privadas, apenas cerca de 5% dos negros concluíam a graduação, contra aproximadamente 15% dos brancos.', 
 'fato_atual', 10),

-- 18. A Condição da Mulher Negra e a Mortalidade Materna
('10000000-0000-0000-0000-000000000018', 
 'A Tripla Vulnerabilidade Social das Mulheres Negras', 
 'Mulheres negras acumulam disparidades de gênero, raça e classe. Pesquisas de saúde pública constataram que o risco de mortalidade materna em mulheres pretas chega a ser mais de 7 vezes maior do que entre mulheres brancas. Além disso, mulheres negras têm menor acesso a consultas pré-natais completas e compõem a maioria das famílias em favelas e postos de serviço doméstico.', 
 'fato_atual', 10),

-- 19. "Escravizados" versus "Escravos" (Kabengele Munanga)
('10000000-0000-0000-0000-000000000019', 
 'A Linguagem Crítica: Escravizados em vez de Escravos', 
 'O antropólogo Kabengele Munanga defende a substituição terminológica de "escravo" por "escravizado". Dizer que uma pessoa era escrava sugere que a submissão era uma condição de sua própria essência. "Escravizado" explicita a imposição violenta de um sistema econômico mercantil sobre seres humanos que nasceram livres e que construíram redes de resistência, como os quilombos.', 
 'trecho_livro', 10),

-- 20. Lei 10.639/2003 e as Ações Afirmativas na Educação
('10000000-0000-0000-0000-000000000020', 
 'A Obrigatoriedade do Ensino da História Afro-Brasileira', 
 'A Lei Federal nº 10.639/2003 alterou a LDB (Lei nº 9.394/96) tornando obrigatória a inclusão do ensino de História e Cultura Afro-Brasileira no currículo escolar. A norma representa uma política de ação afirmativa reparatória e pedagógica, voltada para valorizar a contribuição africana na formação nacional e desconstruir preconceitos no ambiente escolar.', 
 'artigo_lei', 10);


-- ====================================================================
-- 2. INSERÇÃO DAS 40 RESPOSTAS / PERGUNTAS V/F (2 por Leitura, 5 pts cada)
-- ====================================================================

INSERT INTO public.leitura_respostas (id, leitura_id, afirmacao, is_correta, pontos, explicacao) VALUES
-- Referentes à Leitura 1
('20000000-0000-0000-0000-000000000001', 
 '10000000-0000-0000-0000-000000000001', 
 'O termo igbo "nkali" ilustra que a criação de uma história definitiva sobre um povo está intimamente ligada às relações de poder.', 
 TRUE, 5, 
 'Correto. Adichie destaca que "nkali" significa "ser maior do que o outro" e rege como histórias são contadas e controladas por quem detém o poder.'),

('20000000-0000-0000-0000-000000000002', 
 '10000000-0000-0000-0000-000000000001', 
 'A autora defende que o poder não tem influência sobre a forma como as narrativas culturais e históricas são disseminadas.', 
 FALSE, 5, 
 'Falso. A autora enfatiza enfaticamente que é impossível falar sobre a história única sem discutir as estruturas de poder.'),

-- Referentes à Leitura 2
('20000000-0000-0000-0000-000000000003', 
 '10000000-0000-0000-0000-000000000002', 
 'Para Chimamanda, o grande erro dos estereótipos reside no fato de serem narrativas parciais e incompletas tornadas absolutas.', 
 TRUE, 5, 
 'Correto. A autora frisa que os estereótipos não são necessariamente mentiras, mas sim visões incompletas que viram a única referência.'),

('20000000-0000-0000-0000-000000000004', 
 '10000000-0000-0000-0000-000000000002', 
 'A história única fortalece o reconhecimento da igualdade e dignidade entre povos de origens e culturas diferentes.', 
 FALSE, 5, 
 'Falso. Conforme o texto, a consequência da história única é roubar das pessoas sua dignidade e afastar o reconhecimento da igualdade humana.'),

-- Referentes à Leitura 3
('20000000-0000-0000-0000-000000000005', 
 '10000000-0000-0000-0000-000000000003', 
 'A genética contemporânea comprovou a inexistência de raças biológicas na espécie Homo sapiens.', 
 TRUE, 5, 
 'Correto. A moderna ciência genética demonstra que as variações genéticas entre populações humanas não sustentam a divisão biológica em raças.'),

('20000000-0000-0000-0000-000000000006', 
 '10000000-0000-0000-0000-000000000003', 
 'Traços físicos como tipo de cabelo e tom de pele servem para comprovar diferenças genéticas profundas entre grupos humanos.', 
 FALSE, 5, 
 'Falso. Essas características são apenas variações fenotípicas superficiais que não diferenciam grupos biológicos estanques.'),

-- Referentes à Leitura 4
('20000000-0000-0000-0000-000000000007', 
 '10000000-0000-0000-0000-000000000004', 
 'O conceito de raça é empregado pelos movimentos sociais antirracistas em uma dimensão sociopolítica.', 
 TRUE, 5, 
 'Correto. Embora descartado na biologia, o termo raça é utilizado politicamente para combater discriminações e fundamentar ações afirmativas.'),

('20000000-0000-0000-0000-000000000008', 
 '10000000-0000-0000-0000-000000000004', 
 'As Diretrizes Curriculares Nacionais de 2004 reafirmam o conceito estritamente biológico de raça formulado no século XVIII.', 
 FALSE, 5, 
 'Falso. As Diretrizes deixam claro que o conceito biológico do século XVIII está superado e adotam a perspectiva sócio-histórica.'),

-- Referentes à Leitura 5
('20000000-0000-0000-0000-000000000009', 
 '10000000-0000-0000-0000-000000000005', 
 'A etnicidade constitui um processo dinâmico construído a partir de autoatribuições (endógenas) e percepções alheias (exógenas).', 
 TRUE, 5, 
 'Correto. Poutignat e Streiff-Fenart ressaltam que essa dialética torna a etnicidade um processo sujeito à contínua redefinição.'),

('20000000-0000-0000-0000-000000000010', 
 '10000000-0000-0000-0000-000000000005', 
 'A identidade étnica de uma pessoa é um elemento imutável, determinado geneticamente no momento do nascimento.', 
 FALSE, 5, 
 'Falso. Etnia é uma construção sociocultural e situacional, não uma determinação genética estática.'),

-- Referentes à Leitura 6
('20000000-0000-0000-0000-000000000011', 
 '10000000-0000-0000-0000-000000000006', 
 'O racismo científico do século XIX buscou fundamentar hierarquias sociais transformando marcas físicas em traços comportamentais.', 
 TRUE, 5, 
 'Correto. Conforme Lima e Vala, o racismo científico pretendia reduzir o cultural ao biológico para legitimar privilégios de certos grupos.'),

('20000000-0000-0000-0000-000000000012', 
 '10000000-0000-0000-0000-000000000006', 
 'A ciência positivista do século XIX defendia a total igualdade de direitos e capacidades cognitivas entre todas as populações do planeta.', 
 FALSE, 5, 
 'Falso. A ciência daquele período formulou teorias racialistas hierarquizantes para justificar a dominação colonial europeia.'),

-- Referentes à Leitura 7
('20000000-0000-0000-0000-000000000013', 
 '10000000-0000-0000-0000-000000000007', 
 'O extermínio de judeus no nazismo utilizou justificativas que pretendiam ter autoridade e fundamentação científica eugênica.', 
 TRUE, 5, 
 'Correto. O regime hitlerista utilizava teses da pretensa "raça ariana superior" para justificar o assassinato em massa nas câmaras de gás.'),

('20000000-0000-0000-0000-000000000014', 
 '10000000-0000-0000-0000-000000000007', 
 'O manifesto do terrorista de 2011 na Noruega apontou a miscigenação brasileira como um exemplo ideal a ser seguido globalmente.', 
 FALSE, 5, 
 'Falso. O autor considerou a mistura de raças do Brasil como "catastrófica", demonstrando a continuidade de pensamentos eugenistas.'),

-- Referentes à Leitura 8
('20000000-0000-0000-0000-000000000015', 
 '10000000-0000-0000-0000-000000000008', 
 'O mito da democracia racial sustenta que o Brasil desfruta de relações harmoniosas entre as raças, sem preconceito estrutural.', 
 TRUE, 5, 
 'Correto. Esse mito, reforçado após 1933, camuflou o racismo ao projetar uma suposta harmonia absoluta entre colonizadores e escravizados.'),

('20000000-0000-0000-0000-000000000016', 
 '10000000-0000-0000-0000-000000000008', 
 'Pesquisas no Brasil apontam que a maioria dos cidadãos se declara abertamente racista em entrevistas de opinião pública.', 
 FALSE, 5, 
 'Falso. As pessoas costumam afirmar que pessoalmente não são racistas, mas reconhecem que o preconceito existe na sociedade em geral.'),

-- Referentes à Leitura 9
('20000000-0000-0000-0000-000000000017', 
 '10000000-0000-0000-0000-000000000009', 
 'Para Roberto DaMatta, a "fábula das três raças" opera como uma ideologia que ajuda a integrar simbolicamente a sociedade brasileira.', 
 TRUE, 5, 
 'Correto. DaMatta explica que ela é uma poderosa narrativa cultural para individualizar a cultura nacional e encobrir contradições.'),

('20000000-0000-0000-0000-000000000018', 
 '10000000-0000-0000-0000-000000000009', 
 'A história da colonização brasileira é comprovadamente desprovida de episódios de violência, rebeliões ou massacres interétnicos.', 
 FALSE, 5, 
 'Falso. A formação do país envolveu extermínio sistemático de populações indígenas, escravização e violenta repressão a revoltas.'),

-- Referentes à Leitura 10
('20000000-0000-0000-0000-000000000019', 
 '10000000-0000-0000-0000-000000000010', 
 'No conceito de "homem cordial", cordialidade refere-se à primazia do coração e das emoções sobre o formalismo legal.', 
 TRUE, 5, 
 'Correto. Sérgio Buarque de Holanda fundamenta o conceito na raiz latina "cordis", ligada às condutas afetivas e pouco formalistas.'),

('20000000-0000-0000-0000-000000000020', 
 '10000000-0000-0000-0000-000000000010', 
 'Ser "cordial" em "Raízes do Brasil" é sinônimo direto de ser um cidadão rigorosamente pacífico, cortês e respeitador das leis.', 
 FALSE, 5, 
 'Falso. A cordialidade indica passionalidade nas relações e informalidade, o que inclusive abre caminho para o "jeitinho brasileiro".'),

-- Referentes à Leitura 11
('20000000-0000-0000-0000-000000000021', 
 '10000000-0000-0000-0000-000000000011', 
 'Pesquisas de DNA demonstraram que a ancestralidade da população brasileira é intensamente miscigenada em todas as regiões.', 
 TRUE, 5, 
 'Correto. Os estudos de Pena e Bortolini mostram um fundo genético com heranças ameríndia, africana e europeia distribuídas no país.'),

('20000000-0000-0000-0000-000000000022', 
 '10000000-0000-0000-0000-000000000011', 
 'A cor da pele é uma medida científica exata para quantificar as porcentagens de ancestralidade genética de qualquer brasileiro.', 
 FALSE, 5, 
 'Falso. A cor é um traço fenotípico exterior que não reflete com exatidão a complexa herança genômica individual.'),

-- Referentes à Leitura 12
('20000000-0000-0000-0000-000000000023', 
 '10000000-0000-0000-0000-000000000012', 
 'O preconceito é um sistema subjetivo de predisposições, enquanto a discriminação configura a ação prática que prejudica indivíduos.', 
 TRUE, 5, 
 'Correto. Guimarães diferencia a convicção preconceituosa (interna) das condutas discriminatórias manifestadas socialmente.'),

('20000000-0000-0000-0000-000000000024', 
 '10000000-0000-0000-0000-000000000012', 
 'O racismo se expressa exclusivamente em ofensas verbais diretas, inexistindo sob forma de desigualdade estatística nas instituições.', 
 FALSE, 5, 
 'Falso. A desigualdade de oportunidades em renda, saúde e educação é a demonstração prática do racismo estrutural e institucional.'),

-- Referentes à Leitura 13
('20000000-0000-0000-0000-000000000025', 
 '10000000-0000-0000-0000-000000000013', 
 'No preconceito de marca (Brasil), o tratamento discriminatório varia de acordo com as características fenotípicas externas do sujeito.', 
 TRUE, 5, 
 'Correto. Oracy Nogueira destacou que traços físicos como tonalidade de pele e traços faciais balizam as reações preconceituosas no país.'),

('20000000-0000-0000-0000-000000000026', 
 '10000000-0000-0000-0000-000000000013', 
 'Nos Estados Unidos vigora o preconceito de marca, no qual a ancestralidade genealógica não tem relevância discriminatória.', 
 FALSE, 5, 
 'Falso. O modelo norte-americano é historicamente o "preconceito de origem", no qual a ascendência define a classificação racial.'),

-- Referentes à Leitura 14
('20000000-0000-0000-0000-000000000027', 
 '10000000-0000-0000-0000-000000000014', 
 'As campanhas de conscientização do movimento negro estimularam a unificação política das categorias "pretos" e "pardos" como negros.', 
 TRUE, 5, 
 'Correto. A unificação visa conferir densidade identitária e política para exigir a formulação de ações afirmativas reparatórias.'),

('20000000-0000-0000-0000-000000000028', 
 '10000000-0000-0000-0000-000000000014', 
 'Nos censos do IBGE, a identificação racial é atribuída obrigatoriamente pela avaliação visual feita pelo entrevistador.', 
 FALSE, 5, 
 'Falso. O método adotado oficialmente no Brasil é o da autodeclaração, em que o próprio cidadão declara a sua cor ou raça.'),

-- Referentes à Leitura 15
('20000000-0000-0000-0000-000000000029', 
 '10000000-0000-0000-0000-000000000015', 
 'As regiões brasileiras com maiores taxas de população preta e parda são historicamente aquelas com menor participação no PIB per capita.', 
 TRUE, 5, 
 'Correto. Dados da PNAD demonstram que o Norte e o Nordeste combinam grande contingente de negros e índices mais baixos de renda média.'),

('20000000-0000-0000-0000-000000000030', 
 '10000000-0000-0000-0000-000000000015', 
 'Entre o 1% mais rico da população brasileira, pretos e pardos ocupavam mais de 70% das vagas segundo os dados analisados.', 
 FALSE, 5, 
 'Falso. Mais de 80% do topo da pirâmide de renda era composto por pessoas autodeclaradas brancas; negros somavam apenas 15%.'),

-- Referentes à Leitura 16
('20000000-0000-0000-0000-000000000031', 
 '10000000-0000-0000-0000-000000000016', 
 'A expressão "teto de vidro" descreve a reduzida mobilidade de profissionais negros para cargos de gerência executiva em corporações.', 
 TRUE, 5, 
 'Correto. O estudo do Instituto Ethos comprovou que, embora presentes na base, negros eram pouco mais de 5% no nível executivo.'),

('20000000-0000-0000-0000-000000000032', 
 '10000000-0000-0000-0000-000000000016', 
 'A pesquisa do Instituto Ethos revelou que brancos e negros ocupavam cargos de diretoria nas maiores empresas exatamente na mesma proporção.', 
 FALSE, 5, 
 'Falso. Mais de 90% dos postos executivos das 500 maiores empresas eram preenchidos por profissionais autodeclarados brancos.'),

-- Referentes à Leitura 17
('20000000-0000-0000-0000-000000000033', 
 '10000000-0000-0000-0000-000000000017', 
 'No Brasil, a proporção de jovens brancos que concluem o ensino superior é marcadamente superior à de jovens pretos e pardos.', 
 TRUE, 5, 
 'Correto. As estatísticas oficiais atestavam aproximadamente 15% de concluintes brancos contra apenas cerca de 5% de concluintes negros.'),

('20000000-0000-0000-0000-000000000034', 
 '10000000-0000-0000-0000-000000000017', 
 'A média de anos de estudo e as taxas de alfabetização entre brancos e negros são historicamente idênticas no país.', 
 FALSE, 5, 
 'Falso. As taxas de analfabetismo entre negros chegavam a mais que o dobro das observadas na população branca.'),

-- Referentes à Leitura 18
('20000000-0000-0000-0000-000000000035', 
 '10000000-0000-0000-0000-000000000018', 
 'O risco relativo de óbito decorrente de mortalidade materna afeta com maior gravidade mulheres pretas em relação às mulheres brancas.', 
 TRUE, 5, 
 'Correto. Estudos de saúde pública registram índices de morte materna expressivamente superiores entre mulheres pretas.'),

('20000000-0000-0000-0000-000000000036', 
 '10000000-0000-0000-0000-000000000018', 
 'Mulheres negras realizam consultas pré-natais em taxas superiores às de mulheres brancas devido a políticas públicas preferenciais.', 
 FALSE, 5, 
 'Falso. Dados do Ministério da Saúde apontam que 76,6% das brancas cumpriam as 6 consultas mínimas, contra 61,3% das negras.'),

-- Referentes à Leitura 19
('20000000-0000-0000-0000-000000000037', 
 '10000000-0000-0000-0000-000000000019', 
 'Empregar o termo "escravizado" visa rejeitar a premissa ideológica de que a pessoa negra possuía uma vocação natural para o cativeiro.', 
 TRUE, 5, 
 'Correto. Munanga aponta que tais pessoas eram livres e foram sujeitas à condição forçada por um sistema mercantil opressor.'),

('20000000-0000-0000-0000-000000000038', 
 '10000000-0000-0000-0000-000000000019', 
 'Os africanos trazidos ao Brasil aceitaram passivamente o cativeiro, sem oferecer resistência ou estruturar formas alternativas de sociedade.', 
 FALSE, 5, 
 'Falso. Houve constante resistência, insurreições e a consolidação de quilombos que propunham modelos comunitários de liberdade.'),

-- Referentes à Leitura 20
('20000000-0000-0000-0000-000000000039', 
 '10000000-0000-0000-0000-000000000020', 
 'A Lei Federal nº 10.639/2003 estabeleceu a obrigatoriedade da temática de História e Cultura Afro-Brasileira nas redes de ensino.', 
 TRUE, 5, 
 'Correto. A legislação visa valorizar a contribuição civilizatória africana e incentivar uma educação antirracista.'),

('20000000-0000-0000-0000-000000000040', 
 '10000000-0000-0000-0000-000000000020', 
 'A Lei 10.639/2003 proibiu debates sobre igualdade racial nas escolas públicas para evitar conflitos étnicos em sala de aula.', 
 FALSE, 5, 
 'Falso. A lei exige exatamente o oposto: a inserção ativa de estudos curriculares sobre a história dos povos africanos e afro-brasileiros.');
```

## Script SQL: Inserção de Jogos e Perguntas
```` SQL
-- ====================================================================
-- 1. INSERÇÃO DOS 4 JOGOS/QUIZZES (Tabela: games)
-- Cada jogo totaliza 10 pontos (5 questões de 2 pontos cada)
-- ====================================================================

INSERT INTO public.games (id, titulo, descricao, pontos_total) VALUES
('30000000-0000-0000-0000-000000000001', 
 'Quiz 1: Conceitos Fundamentais - Raça, Etnia e Genética', 
 'Teste seus conhecimentos sobre a superação biológica de raça, o conceito sociopolítico e a etnicidade.', 
 10),

('30000000-0000-0000-0000-000000000002', 
 'Quiz 2: Teorias Raciais e o Mito da Democracia Racial', 
 'Questões sobre o racismo científico do século XIX, Gilberto Freyre, Homem Cordial e DaMatta.', 
 10),

('30000000-0000-0000-0000-000000000003', 
 'Quiz 3: Indicadores Sociais, Mercado e Saúde no Brasil', 
 'Avaliação sobre dados estatísticos do IBGE/PNAD, desigualdades de renda, teto de vidro e saúde.', 
 10),

('30000000-0000-0000-0000-000000000004', 
 'Quiz 4: Resistência, Ações Afirmativas e Legislação', 
 'Perguntas sobre história da resistência negra, cotas, Munanga e a Lei nº 10.639/2003.', 
 10);


-- ====================================================================
-- 2. INSERÇÃO DAS 20 PERGUNTAS (Tabela: game_perguntas)
-- 5 perguntas por Quiz, valendo 2 pontos cada
-- ====================================================================

-- --------------------------------------------------------------------
-- Perguntas do Quiz 1 (Raça, Etnia e Genética)
-- --------------------------------------------------------------------
INSERT INTO public.game_perguntas (id, game_id, pergunta, pontos, ordem) VALUES
('40000000-0000-0000-0000-000000000001', 
 '30000000-0000-0000-0000-000000000001', 
 'De acordo com os avanços da genética contemporânea citados por Flores (2008), o que a ciência afirma sobre a existência de raças humanas?', 
 2, 1),

('40000000-0000-0000-0000-000000000002', 
 '30000000-0000-0000-0000-000000000001', 
 'Segundo as Diretrizes Curriculares Nacionais de 2004, de que forma o termo "raça" deve ser compreendido no contexto brasileiro?', 
 2, 2),

('40000000-0000-0000-0000-000000000003', 
 '30000000-0000-0000-0000-000000000001', 
 'Conforme Poutignat e Streiff-Fenart (1998), a identidade étnica é definida a partir de qual processo dialético?', 
 2, 3),

('40000000-0000-0000-0000-000000000004', 
 '30000000-0000-0000-0000-000000000001', 
 'Na palestra de Chimamanda Adichie, qual é o significado do termo igbo "nkali" e como ele se articula com as narrativas históricas?', 
 2, 4),

('40000000-0000-0000-0000-000000000005', 
 '30000000-0000-0000-0000-000000000001', 
 'O que caracteriza a noção de "realce" ou "saliência" na construção da etnicidade segundo a literatura sociológica?', 
 2, 5);

-- --------------------------------------------------------------------
-- Perguntas do Quiz 2 (Teorias Raciais e Democracia Racial)
-- --------------------------------------------------------------------
INSERT INTO public.game_perguntas (id, game_id, pergunta, pontos, ordem) VALUES
('40000000-0000-0000-0000-000000000006', 
 '30000000-0000-0000-0000-000000000002', 
 'Segundo Lima e Vala (2004), qual mecanismo ideológico caracterizou o chamado "racismo científico" formulado no século XIX?', 
 2, 1),

('40000000-0000-0000-0000-000000000007', 
 '30000000-0000-0000-0000-000000000002', 
 'De que maneira a obra "Casa-Grande & Senzala" (1933), de Gilberto Freyre, influenciou a visão sobre as relações raciais no Brasil?', 
 2, 2),

('40000000-0000-0000-0000-000000000008', 
 '30000000-0000-0000-0000-000000000002', 
 'O antropólogo Roberto DaMatta sustenta que a "fábula das três raças" opera na sociedade brasileira como:', 
 2, 3),

('40000000-0000-0000-0000-000000000009', 
 '30000000-0000-0000-0000-000000000002', 
 'No livro "Raízes do Brasil", o conceito de "homem cordial" formulado por Sérgio Buarque de Holanda expressa:', 
 2, 4),

('40000000-0000-0000-0000-000000000010', 
 '30000000-0000-0000-0000-000000000002', 
 'Qual a principal diferença entre as manifestações de preconceito no Brasil e nos Estados Unidos estabelecida por Oracy Nogueira (1954)?', 
 2, 5);

-- --------------------------------------------------------------------
-- Perguntas do Quiz 3 (Indicadores Sociais, Mercado e Saúde)
-- --------------------------------------------------------------------
INSERT INTO public.game_perguntas (id, game_id, pergunta, pontos, ordem) VALUES
('40000000-0000-0000-0000-000000000011', 
 '30000000-0000-0000-0000-000000000003', 
 'O que demonstraram os estudos genômicos de Sérgio Danilo Pena e Maria Cátira Bortolini sobre a população brasileira?', 
 2, 1),

('40000000-0000-0000-0000-000000000012', 
 '30000000-0000-0000-0000-000000000003', 
 'Com base nos dados da PNAD e do Censo do IBGE, qual fenômeno demográfico marcou a autodeclaração dos brasileiros a partir de 2008?', 
 2, 2),

('40000000-0000-0000-0000-000000000013', 
 '30000000-0000-0000-0000-000000000003', 
 'No ambiente corporativo, a que se refere o conceito de "teto de vidro" revelado pela pesquisa do Instituto Ethos (2010)?', 
 2, 3),

('40000000-0000-0000-0000-000000000014', 
 '30000000-0000-0000-0000-000000000003', 
 'Comparando trabalhadores brancos e negros com o mesmo nível de escolaridade, o que os levantamentos do IBGE comprovam sobre os salários?', 
 2, 4),

('40000000-0000-0000-0000-000000000015', 
 '30000000-0000-0000-0000-000000000003', 
 'Conforme os dados de saúde pública destacados por Quessia Rodrigues e Martins, qual realidade atinge criticamente as mulheres negras?', 
 2, 5);

-- --------------------------------------------------------------------
-- Perguntas do Quiz 4 (Resistência, Ações Afirmativas e Legislação)
-- --------------------------------------------------------------------
INSERT INTO public.game_perguntas (id, game_id, pergunta, pontos, ordem) VALUES
('40000000-0000-0000-0000-000000000016', 
 '30000000-0000-0000-0000-000000000004', 
 'Por qual razão o antropólogo Kabengele Munanga defende que se utilize o termo "escravizado" em vez de "escravo"?', 
 2, 1),

('40000000-0000-0000-0000-000000000017', 
 '30000000-0000-0000-0000-000000000004', 
 'De acordo com a definição de Bernardino (2002), qual a finalidade primordial das políticas de ação afirmativa?', 
 2, 2),

('40000000-0000-0000-0000-000000000018', 
 '30000000-0000-0000-0000-000000000004', 
 'Como Antonio Sérgio Guimarães (2004) conceitua o "racismo institucional"?', 
 2, 3),

('40000000-0000-0000-0000-000000000019', 
 '30000000-0000-0000-0000-000000000004', 
 'Qual determinação curricular fundamental foi instituída pela promulgação da Lei Federal nº 10.639/2003?', 
 2, 4),

('40000000-0000-0000-0000-000000000020', 
 '30000000-0000-0000-0000-000000000004', 
 'O que constatou a pesquisa de Santos (2006) ao analisar a aplicação de Programas de Ação Afirmativa no ensino superior (Unicamp)?', 
 2, 5);
````

## Script SQL: Inserção das Alternativas (game_respostas)
```sql
-- ====================================================================
-- INSERÇÃO DAS 60 RESPOSTAS DOS GAMES (Tabela: game_respostas)
-- 3 alternativas para cada uma das 20 perguntas cadastradas
-- ====================================================================

INSERT INTO public.game_respostas (id, pergunta_id, resposta, is_correta) VALUES

-- --------------------------------------------------------------------
-- Pergunta 1: Existência de raças humanas na genética
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000001', 
 '40000000-0000-0000-0000-000000000001', 
 'A espécie Homo sapiens é biologicamente una e não pode ser subdividida em raças genéticas distintas.', 
 TRUE),
('50000000-0000-0000-0000-000000000002', 
 '40000000-0000-0000-0000-000000000001', 
 'A cor da pele e a textura do cabelo comprovam a existência de três subespécies biológicas humanas.', 
 FALSE),
('50000000-0000-0000-0000-000000000003', 
 '40000000-0000-0000-0000-000000000001', 
 'A diversidade biológica entre grupos geográficos é maior do que a diversidade cultural e ambiental.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 2: Conceito de raça nas Diretrizes Curriculares (2004)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000004', 
 '40000000-0000-0000-0000-000000000002', 
 'Como uma construção sócio-histórica e política forjada nas relações de poder, e não um dado da natureza.', 
 TRUE),
('50000000-0000-0000-0000-000000000005', 
 '40000000-0000-0000-0000-000000000002', 
 'Como um conceito estritamente biológico que determina a aptidão cognitiva natural dos indivíduos.', 
 FALSE),
('50000000-0000-0000-0000-000000000006', 
 '40000000-0000-0000-0000-000000000002', 
 'Como uma categoria a ser banida do vocabulário político por gerar divisões desnecessárias.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 3: Processo dialético da identidade étnica
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000007', 
 '40000000-0000-0000-0000-000000000003', 
 'Da interação entre a autoatribuição do sujeito (endógena) e o reconhecimento pelos outros (exógena).', 
 TRUE),
('50000000-0000-0000-0000-000000000008', 
 '40000000-0000-0000-0000-000000000003', 
 'Da herança sanguínea fixa e imutável transmitida de forma linear e fechada entre gerações.', 
 FALSE),
('50000000-0000-0000-0000-000000000009', 
 '40000000-0000-0000-0000-000000000003', 
 'Da determinação unilateral imposta pelo Estado a partir da certidão de nascimento.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 4: Conceito igbo de "nkali" em Chimamanda
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000010', 
 '40000000-0000-0000-0000-000000000004', 
 'Significa "ser maior do que o outro" e expressa como o poder determina quem conta as histórias.', 
 TRUE),
('50000000-0000-0000-0000-000000000011', 
 '40000000-0000-0000-0000-000000000004', 
 'Significa "harmonia entre povos" e descreve a tolerância cultural das nações colonizadoras.', 
 FALSE),
('50000000-0000-0000-0000-000000000012', 
 '40000000-0000-0000-0000-000000000004', 
 'Significa "solidão tribal" e retrata o isolamento forçado de comunidades rurais africanas.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 5: Noção de realce ou saliência na etnicidade
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000013', 
 '40000000-0000-0000-0000-000000000005', 
 'A capacidade do sujeito de mobilizar situacionalmente sua identidade conforme o contexto social.', 
 TRUE),
('50000000-0000-0000-0000-000000000014', 
 '40000000-0000-0000-0000-000000000005', 
 'A obrigação social de ocultar qualquer traço cultural étnico em ambientes corporativos.', 
 FALSE),
('50000000-0000-0000-0000-000000000015', 
 '40000000-0000-0000-0000-000000000005', 
 'A determinação definitiva de papéis sociais estritos para cada indivíduo de um grupo.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 6: Racismo científico do século XIX
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000016', 
 '40000000-0000-0000-0000-000000000006', 
 'A redução do cultural ao biológico, atribuindo padrões morais e comportamentais a marcas físicas.', 
 TRUE),
('50000000-0000-0000-0000-000000000017', 
 '40000000-0000-0000-0000-000000000006', 
 'A valorização da miscigenação como via exclusiva de enriquecimento cultural das nações.', 
 FALSE),
('50000000-0000-0000-0000-000000000018', 
 '40000000-0000-0000-0000-000000000006', 
 'A defesa da total igualdade social e econômica fundamentada na teoria evolucionista de Darwin.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 7: Impacto de Casa-Grande & Senzala (1933)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000019', 
 '40000000-0000-0000-0000-000000000007', 
 'Difundiu a visão de convivência harmônica entre as raças, alimentando o mito da democracia racial.', 
 TRUE),
('50000000-0000-0000-0000-000000000020', 
 '40000000-0000-0000-0000-000000000007', 
 'Denunciou o massacre colonial exigindo a criação imediata de reservas territoriais segregadas.', 
 FALSE),
('50000000-0000-0000-0000-000000000021', 
 '40000000-0000-0000-0000-000000000007', 
 'Inaugurou as primeiras propostas legislativas para o sistema de cotas no serviço público.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 8: Roberto DaMatta e a fábula das três raças
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000022', 
 '40000000-0000-0000-0000-000000000008', 
 'Uma ideologia dominante que integra o país idealmente, encobrindo violências e hierarquias sociais.', 
 TRUE),
('50000000-0000-0000-0000-000000000023', 
 '40000000-0000-0000-0000-000000000008', 
 'Uma comprovação sociológica de que o Brasil superou por completo as desigualdades de renda.', 
 FALSE),
('50000000-0000-0000-0000-000000000024', 
 '40000000-0000-0000-0000-000000000008', 
 'Um mito folclórico sem relevância sobre as instituições políticas e jurídicas brasileiras.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 9: Sérgio Buarque de Holanda e o "homem cordial"
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000025', 
 '40000000-0000-0000-0000-000000000009', 
 'A primazia do afeto e das relações pessoais sobre as leis universais e a ordem formal.', 
 TRUE),
('50000000-0000-0000-0000-000000000026', 
 '40000000-0000-0000-0000-000000000009', 
 'A vocação natural do povo brasileiro para o cumprimento rigoroso da formalidade e da lei.', 
 FALSE),
('50000000-0000-0000-0000-000000000027', 
 '40000000-0000-0000-0000-000000000009', 
 'O traço de civilidade pacífica que impede a existência de conflitos ou violências no país.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 10: Preconceito de Marca vs Preconceito de Origem (Oracy Nogueira)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000028', 
 '40000000-0000-0000-0000-000000000010', 
 'No Brasil baseia-se na aparência/fenótipo (marca); nos EUA baseia-se na ascendência (origem).', 
 TRUE),
('50000000-0000-0000-0000-000000000029', 
 '40000000-0000-0000-0000-000000000010', 
 'No Brasil é fundado na linhagem consanguínea; nos EUA varia conforme a tonalidade da pele.', 
 FALSE),
('50000000-0000-0000-0000-000000000030', 
 '40000000-0000-0000-0000-000000000010', 
 'Em ambos os países a discriminação baseia-se exclusivamente no credo religioso e na etnia.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 11: Estudos genômicos no Brasil (Pena e Bortolini)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000031', 
 '40000000-0000-0000-0000-000000000011', 
 'A ancestralidade genômica é muito miscigenada e a cor da pele não serve para medir a carga genética.', 
 TRUE),
('50000000-0000-0000-0000-000000000032', 
 '40000000-0000-0000-0000-000000000011', 
 'Brancos e negros compõem grupos genéticos puros e isolados uns dos outros no território nacional.', 
 FALSE),
('50000000-0000-0000-0000-000000000033', 
 '40000000-0000-0000-0000-000000000011', 
 'Apenas a população da região Norte possui contribuição de DNA indígena e africano.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 12: Demografia censitária a partir de 2008
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000034', 
 '40000000-0000-0000-0000-000000000012', 
 'A soma de pretos e pardos passou a representar mais da metade (mais de 50%) da população brasileira.', 
 TRUE),
('50000000-0000-0000-0000-000000000035', 
 '40000000-0000-0000-0000-000000000012', 
 'A população branca cresceu expressivamente, atingindo mais de 80% dos habitantes recenseados.', 
 FALSE),
('50000000-0000-0000-0000-000000000036', 
 '40000000-0000-0000-0000-000000000012', 
 'Houve supressão dos quesitos de autodeclaração étnico-racial em virtude de sigilo legal.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 13: Conceito de "teto de vidro" (Instituto Ethos)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000037', 
 '40000000-0000-0000-0000-000000000013', 
 'Barreira invisível que limita a ascensão de negros aos cargos mais altos de diretoria executiva.', 
 TRUE),
('50000000-0000-0000-0000-000000000038', 
 '40000000-0000-0000-0000-000000000013', 
 'Obrigatoriedade de transparência em relatórios contábeis de sustentabilidade ambiental.', 
 FALSE),
('50000000-0000-0000-0000-000000000039', 
 '40000000-0000-0000-0000-000000000013', 
 'Política interna voltada para a contratação imediata de executivos estrangeiros nas empresas.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 14: Escolaridade e desigualdade salarial
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000040', 
 '40000000-0000-0000-0000-000000000014', 
 'Negros recebem salários sensivelmente inferiores aos de brancos mesmo com o mesmo grau de estudo.', 
 TRUE),
('50000000-0000-0000-0000-000000000041', 
 '40000000-0000-0000-0000-000000000014', 
 'A remuneração de profissionais com curso superior é rigorosamente idêntica para qualquer raça.', 
 FALSE),
('50000000-0000-0000-0000-000000000042', 
 '40000000-0000-0000-0000-000000000014', 
 'A diferença salarial atinge exclusivamente profissionais que atuam no setor público concursado.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 15: Disparidades na saúde das mulheres negras
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000043', 
 '40000000-0000-0000-0000-000000000015', 
 'Maior vulnerabilidade à mortalidade materna e percentual inferior de consultas pré-natais completas.', 
 TRUE),
('50000000-0000-0000-0000-000000000044', 
 '40000000-0000-0000-0000-000000000015', 
 'Maior cobertura de atendimento hospitalar privado decorrente de incentivos governamentais.', 
 FALSE),
('50000000-0000-0000-0000-000000000045', 
 '40000000-0000-0000-0000-000000000015', 
 'Índices de saúde equivalentes aos de mulheres brancas devido à universalidade prática do SUS.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 16: Termo "escravizado" (Kabengele Munanga)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000046', 
 '40000000-0000-0000-0000-000000000016', 
 'Para enfatizar a violência imposta sobre seres humanos livres, desmistificando a submissão natural.', 
 TRUE),
('50000000-0000-0000-0000-000000000047', 
 '40000000-0000-0000-0000-000000000016', 
 'Para indicar que o cativeiro era uma atividade remunerada por meio de contratos formais de trabalho.', 
 FALSE),
('50000000-0000-0000-0000-000000000048', 
 '40000000-0000-0000-0000-000000000016', 
 'Porque a escravidão africana era uma prática exclusivamente adotada no continente europeu.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 17: Objetivo das ações afirmativas (Bernardino)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000049', 
 '40000000-0000-0000-0000-000000000017', 
 'Corrigir desigualdades e acelerar a equidade social mediante tratamento temporário diferenciado.', 
 TRUE),
('50000000-0000-0000-0000-000000000050', 
 '40000000-0000-0000-0000-000000000017', 
 'Garantir vantagens perpétuas e hereditárias aos grupos historicamente favorecidos pelo Estado.', 
 FALSE),
('50000000-0000-0000-0000-000000000051', 
 '40000000-0000-0000-0000-000000000017', 
 'Impedir que estudantes de escolas públicas ingressem em cursos superiores de alta concorrência.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 18: Racismo institucional (Guimarães)
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000052', 
 '40000000-0000-0000-0000-000000000018', 
 'Mecanismos de discriminação inscritos na operação das instituições e do sistema social.', 
 TRUE),
('50000000-0000-0000-0000-000000000053', 
 '40000000-0000-0000-0000-000000000018', 
 'Atos isolados e pontuais de preconceito interpessoal cometidos sem relação com a estrutura social.', 
 FALSE),
('50000000-0000-0000-0000-000000000054', 
 '40000000-0000-0000-0000-000000000018', 
 'Concepção segundo a qual as instituições públicas brasileiras operam sem qualquer viés racial.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 19: Marco da Lei 10.639/2003
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000055', 
 '40000000-0000-0000-0000-000000000019', 
 'A obrigatoriedade do ensino de História e Cultura Afro-Brasileira no currículo escolar oficial.', 
 TRUE),
('50000000-0000-0000-0000-000000000056', 
 '40000000-0000-0000-0000-000000000019', 
 'A exclusão de temas africanos dos livros didáticos para simplificar os parâmetros curriculares.', 
 FALSE),
('50000000-0000-0000-0000-000000000057', 
 '40000000-0000-0000-0000-000000000019', 
 'A restrição do debate racial exclusivamente aos programas acadêmicos de pós-graduação.', 
 FALSE),

-- --------------------------------------------------------------------
-- Pergunta 20: Conclusões do estudo de Santos (2006) na Unicamp
-- --------------------------------------------------------------------
('50000000-0000-0000-0000-000000000058', 
 '40000000-0000-0000-0000-000000000020', 
 'Os PAAs aumentaram as matrículas, o bom desempenho acadêmico e a valorização identitária discente.', 
 TRUE),
('50000000-0000-0000-0000-000000000059', 
 '40000000-0000-0000-0000-000000000020', 
 'A adoção do programa provocou queda acentuada no rendimento global de todos os cursos.', 
 FALSE),
('50000000-0000-0000-0000-000000000060', 
 '40000000-0000-0000-0000-000000000020', 
 'O debate sobre políticas afirmativas comprovou-se desnecessário por não haver racismo no país.', 
 FALSE);
```

## Tabela de LOG
```sql
-- ====================================================================
-- 2. TABELA DE LOG: HISTÓRICO DE PONTUAÇÃO (Ledger / Extrato)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.historico_pontuacao_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    tipo_conteudo VARCHAR(30) NOT NULL CHECK (
        tipo_conteudo IN ('leitura', 'video', 'game', 'iniciativa', 'medalha', 'convite', 'login')
    ),
    conteudo_id UUID, -- ID de referência da leitura, video, game, iniciativa ou medalha
    pontos_ganhos INT NOT NULL CHECK (pontos_ganhos > 0),
    descricao TEXT NOT NULL, -- Texto amigável (ex: "Concluiu Quiz 1: 3/5 acertos", "Indicação premiada")
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- ====================================================================
-- 3. ÍNDICES DE ALTA PERFORMANCE (Para Rankings e Consultas)
-- ====================================================================

-- Acelera o filtro de ranking por data (semanal / mensal)
CREATE INDEX IF NOT EXISTS idx_log_created_at ON public.historico_pontuacao_log(created_at);

-- Acelera a consulta do extrato do próprio usuário
CREATE INDEX IF NOT EXISTS idx_log_usuario_data ON public.historico_pontuacao_log(usuario_id, created_at DESC);

-- REGRA ANTI-DUPLICAÇÃO: 
-- Garante no banco que o usuário NUNCA pontue duas vezes pela mesma leitura, vídeo ou jogo
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuario_conteudo_unico 
ON public.historico_pontuacao_log (usuario_id, tipo_conteudo, conteudo_id) 
WHERE tipo_conteudo IN ('leitura', 'video', 'game');

```

## REGISTRO RETROATIVO DOS PONTOS DE 1º ACESSO (50 PTS)

Atenção à restrição (CHECK): Como no script anterior definimos que tipo_conteudo aceitava valores como 'login', 'leitura', etc., precisamos primeiro atualizar essa regra para aceitar formalmente o valor '1º Acesso'.

```SQL
-- ====================================================================
-- 1. ATUALIZA A REGRA DA TABELA DE LOG PARA PERMITIR '1º Acesso'
-- ====================================================================
ALTER TABLE public.historico_pontuacao_log 
    DROP CONSTRAINT IF EXISTS historico_pontuacao_log_tipo_conteudo_check;

ALTER TABLE public.historico_pontuacao_log 
    ADD CONSTRAINT historico_pontuacao_log_tipo_conteudo_check 
    CHECK (tipo_conteudo IN ('leitura', 'video', 'game', 'iniciativa', 'medalha', 'convite', 'login', '1º Acesso'));


-- ====================================================================
-- 2. REGISTRO RETROATIVO DOS PONTOS DE 1º ACESSO (50 PTS)
-- ====================================================================
INSERT INTO public.historico_pontuacao_log (
    usuario_id,
    tipo_conteudo,
    conteudo_id,
    pontos_ganhos,
    descricao,
    created_at
)
SELECT 
    u.id AS usuario_id,
    '1º Acesso' AS tipo_conteudo,
    NULL AS conteudo_id, -- Não aponta para nenhum conteúdo específico
    50 AS pontos_ganhos,
    'Bônus de boas-vindas: Primeiro acesso ao app Mana Digital' AS descricao,
    u.data_criacao AS created_at -- Usa a data original em que o usuário foi cadastrado
FROM public.usuarios u
WHERE NOT EXISTS (
    -- Cláusula de segurança: impede duplicidade caso o script seja rodado novamente
    SELECT 1 
    FROM public.historico_pontuacao_log l 
    WHERE l.usuario_id = u.id 
      AND l.tipo_conteudo = '1º Acesso'
);
```


##   Script SQL: Tabelas de Medalhas e Conquistas dos Usuários

Além da tabela medalhas, você precisa de uma tabela associativa chamada usuario_medalhas para registrar quem ganhou qual medalha e em qual data (impedindo que a mesma medalha seja ganha duas vezes pelo mesmo colaborador).

```SQL
-- ====================================================================
-- 1. TABELA DE CATÁLOGO DAS MEDALHAS
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.medalhas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    figurinha VARCHAR(255) NOT NULL, -- Caminho da imagem (ex: /images/medalhas/pioneiro.png)
    pontos INT NOT NULL DEFAULT 0, -- XP bônus concedido ao desbloquear
    codigo_criterio VARCHAR(50) UNIQUE NOT NULL, -- Código para a regra no backend (ex: 'primeiro_login')
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- ====================================================================
-- 2. TABELA DE MEDALHAS DESBLOQUEADAS PELOS USUÁRIOS
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.usuario_medalhas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    medalha_id UUID NOT NULL REFERENCES public.medalhas(id) ON DELETE CASCADE,
    data_conquista TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_usuario_medalha UNIQUE (usuario_id, medalha_id) -- Impede medalhas duplicadas
);

CREATE INDEX IF NOT EXISTS idx_usuario_medalhas_user ON public.usuario_medalhas(usuario_id);

-- RLS
ALTER TABLE public.medalhas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuario_medalhas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leitura de medalhas para todos" ON public.medalhas FOR SELECT USING (true);
CREATE POLICY "Permitir leitura de conquistas para todos" ON public.usuario_medalhas FOR SELECT USING (true);


-- ====================================================================
-- 3. INSERÇÃO DAS 20 MEDALHAS
-- ====================================================================
INSERT INTO public.medalhas (id, titulo, descricao, figurinha, pontos, codigo_criterio) VALUES
('60000000-0000-0000-0000-000000000001', 'Pioneiro da Inclusão', 'Realizou o primeiro acesso à plataforma da Mana Digital.', '/images/medalhas/pioneiro.png', 10, 'primeiro_login'),
('60000000-0000-0000-0000-000000000002', 'Primeira Página', 'Completou a sua primeira leitura sobre relações étnico-raciais.', '/images/medalhas/primeira_leitura.png', 15, 'leitura_1'),
('60000000-0000-0000-0000-000000000003', 'Olhar Atento', 'Assistiu ao seu primeiro vídeo formativo.', '/images/medalhas/primeiro_video.png', 15, 'video_1'),
('60000000-0000-0000-0000-000000000004', 'Desafiante Inicial', 'Participou do seu primeiro quiz interativo.', '/images/medalhas/primeiro_game.png', 15, 'game_1'),
('60000000-0000-0000-0000-000000000005', 'Voz Ativa', 'Submeteu a sua primeira iniciativa de inclusão para validação.', '/images/medalhas/primeira_iniciativa.png', 25, 'iniciativa_1'),
('60000000-0000-0000-0000-000000000006', 'Tríade do Saber', 'Concluiu pelo menos 1 Leitura, 1 Vídeo e 1 Jogo.', '/images/medalhas/triade_saber.png', 30, 'triade_1'),
('60000000-0000-0000-0000-000000000007', 'Leitor Dedicado', 'Completou com sucesso 5 leituras pedagógicas.', '/images/medalhas/leitor_5.png', 40, 'leitura_5'),
('60000000-0000-0000-0000-000000000008', 'Mestre da Lei', 'Respondeu corretamente às questões sobre a Lei 10.639 e 7.716.', '/images/medalhas/mestre_lei.png', 50, 'lei_compliance'),
('60000000-0000-0000-0000-000000000009', 'Quebrando Mitos', 'Gabaritou o quiz sobre a desconstrução do Mito da Democracia Racial.', '/images/medalhas/quebrando_mitos.png', 50, 'mito_democracia'),
('60000000-0000-0000-0000-000000000010', 'Histórias Reais', 'Aprofundou estudos sobre pensadores como Chimamanda e Kabengele Munanga.', '/images/medalhas/historias_reais.png', 40, 'teoricos_raciais'),
('60000000-0000-0000-0000-000000000011', 'Cineasta ESG', 'Assistiu a 5 vídeos rápidos da trilha.', '/images/medalhas/video_5.png', 40, 'video_5'),
('60000000-0000-0000-0000-000000000012', 'Mente Brilhante', 'Alcançou pontuação máxima (10/10) em qualquer um dos quizzes.', '/images/medalhas/score_maximo.png', 50, 'game_perfeito'),
('60000000-0000-0000-0000-000000000013', 'Maratonista do Hub', 'Completou um total de 10 conteúdos entre textos e vídeos.', '/images/medalhas/maratonista_10.png', 70, 'total_10'),
('60000000-0000-0000-0000-000000000014', 'Embaixador da Aliança', 'Convidou seu primeiro colega de equipe para o aplicativo.', '/images/medalhas/convite_1.png', 30, 'convite_1'),
('60000000-0000-0000-0000-000000000015', 'Multiplicador de Voz', 'Engajou 5 colegas de trabalho que se cadastraram pelo seu link.', '/images/medalhas/convite_5.png', 75, 'convite_5'),
('60000000-0000-0000-0000-000000000016', 'Agente de Mudança', 'Teve uma iniciativa aprovada pela diretoria ESG.', '/images/medalhas/iniciativa_aprovada_1.png', 50, 'iniciativa_aprovada_1'),
('60000000-0000-0000-0000-000000000017', 'Líder Transformador', 'Teve 3 iniciativas aprovadas e aplicadas na empresa.', '/images/medalhas/iniciativa_aprovada_3.png', 100, 'iniciativa_aprovada_3'),
('60000000-0000-0000-0000-000000000018', 'Voz Pública', 'Compartilhou aprendizados sobre inclusão na rede profissional (LinkedIn).', '/images/medalhas/linkedin_share.png', 50, 'linkedin_share'),
('60000000-0000-0000-0000-000000000019', 'Constância Diária', 'Acessou e pontuou por 5 dias consecutivos no treinamento.', '/images/medalhas/streak_5.png', 60, 'streak_5'),
('60000000-0000-0000-0000-000000000020', 'Guardião da Equidade', 'Alcançou a patente Diamante ou superou 500 XP na jornada.', '/images/medalhas/diamante_guardiao.png', 120, 'patente_alta');

```



> **Template do Prompt:**  
> `3D gamification badge icon of [ELEMENTO_DA_MEDALHA], modern corporate ESG app aesthetic, glassmorphism, metallic bronze gold and cyber cyan neon accents, minimalist geometric shield or circular emblem, clean smooth textures, soft studio lighting, isolated on a pure white background, UI asset, mobile game reward, octane render, 8k --no text, --no realistic human face`

---

### 📋 As 20 Medalhas Sugeridas para a Mana Digital

Dividimos as 20 medalhas em 4 categorias de progressão:

| # | Título da Medalha | Ação / Critério de Conquista | Pontos | Elemento para o Prompt da Imagem |
|---|---|---|---|---|
| **01** | **Pioneiro da Inclusão** | 1º Login no app | 10 XP | *A glowing futuristic key unlocking a shield* |
| **02** | **Primeira Página** | Concluiu a 1ª leitura | 15 XP | *A holographic glowing open book with a leaf bookmark* |
| **03** | **Olhar Atento** | Assistiu ao 1º vídeo | 15 XP | *A floating 3D play button inside a crystal sphere* |
| **04** | **Desafiante Inicial** | Concluiu o 1º jogo/quiz | 15 XP | *A neon game controller floating over a bronze pedestal* |
| **05** | **Voz Ativa** | Enviou a 1ª iniciativa ESG | 25 XP | *A glowing megaphone emitting geometric soundwaves* |
| **06** | **Tríade do Saber** | Fez 1 leitura, 1 vídeo e 1 jogo | 30 XP | *A glowing triangle with three interconnected crystal nodes* |
| **07** | **Leitor Dedicado** | Concluiu 5 leituras | 40 XP | *A stack of three glowing digital books with a golden bookmark* |
| **08** | **Mestre da Lei** | Acertou as perguntas sobre as Leis 10.639 e 7.716 | 50 XP | *A golden scales of justice surrounded by a digital aura* |
| **09** | **Quebrando Mitos** | Concluiu com 100% o Quiz de Democracia Racial | 50 XP | *A crystal hammer shattering a dark barrier into light* |
| **10** | **Histórias Reais** | Concluiu leituras sobre Adichie e Munanga | 40 XP | *A quill pen writing golden light on a digital scroll* |
| **11** | **Cineasta ESG** | Assistiu a 5 vídeos | 40 XP | *A movie clapperboard made of brushed metal and neon ribbons* |
| **12** | **Mente Brilhante** | Gabaritou qualquer Game com 10/10 pontos | 50 XP | *A 3D glowing brain interconnected with golden synapses* |
| **13** | **Maratonista do Hub** | Concluiu 10 conteúdos no total | 70 XP | *A golden winged sneaker with futuristic neon trails* |
| **14** | **Embaixador da Aliança** | Convidou 1 colega que entrou pelo link | 30 XP | *Two metallic hands shaking forming a glowing circular emblem* |
| **15** | **Multiplicador de Voz** | Convidou 5 colegas pelo link | 75 XP | *A network constellation of five connected glowing avatars* |
| **16** | **Agente de Mudança** | Teve 1 iniciativa aprovada pela Diretoria ESG | 50 XP | *A golden certified seal with a ribbon and a verification checkmark* |
| **17** | **Líder Transformador** | Teve 3 iniciativas aprovadas | 100 XP | *A metallic star badge with three golden diamond insets* |
| **18** | **Voz Pública** | Publicou iniciativa/reflexão no LinkedIn | 50 XP | *A crystal satellite transmitting beams of golden light* |
| **19** | **Constância Diária** | Pontuou por 5 dias seguidos (Streak) | 60 XP | *A stylized 3D flame made of crystal and orange neon* |
| **20** | **Guardião da Equidade** | Atingiu a patente Ouro ou Diamante (500+ XP) | 120 XP | *A glowing diamond crown hovering over a corporate medal* |

## Adicção de URLs das figurinhas a tabela de medalhas

```SQL
-- ====================================================================
-- ATUALIZAÇÃO DAS URLs DAS MEDALHAS NO SUPABASE STORAGE
-- Project Ref: lcfvuqogreczddoyxpxy
-- ====================================================================

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Pioneiro%20da%20Inclusao.png' 
WHERE titulo = 'Pioneiro da Inclusão';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Primeira%20Pagina.png' 
WHERE titulo = 'Primeira Página';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Olhar%20Atento.png' 
WHERE titulo = 'Olhar Atento';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Desafiante%20Inicial.png' 
WHERE titulo = 'Desafiante Inicial';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Voz%20Ativa.png' 
WHERE titulo = 'Voz Ativa';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Triade%20do%20Saber.png' 
WHERE titulo = 'Tríade do Saber';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Leitor%20Dedicado.png' 
WHERE titulo = 'Leitor Dedicado';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Mestre%20da%20Lei.png' 
WHERE titulo = 'Mestre da Lei';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Quebrando%20Mitos.png' 
WHERE titulo = 'Quebrando Mitos';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Historias%20Reais.png' 
WHERE titulo = 'Histórias Reais';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Cineasta%20ESG.png' 
WHERE titulo = 'Cineasta ESG';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Mente%20Brilhante.png' 
WHERE titulo = 'Mente Brilhante';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Maratonista%20do%20Hub.png' 
WHERE titulo = 'Maratonista do Hub';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Embaixador%20da%20Alianca.png' 
WHERE titulo = 'Embaixador da Aliança';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Multiplicador%20de%20Voz.png' 
WHERE titulo = 'Multiplicador de Voz';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Agente%20de%20Mudanca.png' 
WHERE titulo = 'Agente de Mudança';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Lider%20Transformador.png' 
WHERE titulo = 'Líder Transformador';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Voz%20Publica.png' 
WHERE titulo = 'Voz Pública';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Constancia%20Diaria.png' 
WHERE titulo = 'Constância Diária';

UPDATE public.medalhas SET figurinha = 'https://lcfvuqogreczddoyxpxy.supabase.co/storage/v1/object/public/medalhas/Guardiao%20da%20Equidade.png' 
WHERE titulo = 'Guardião da Equidade';
```