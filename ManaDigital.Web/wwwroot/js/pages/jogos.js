
const { perguntas, gameId, pontosTotal, jaConcluido } = window.jogosConfig;

let indiceAtual = 0;
let acertos = 0;
let xpGanhos = 0;
let respondeu = false;
const respostasSelecionadas = {}; // perguntaId -> respostaId

function renderPergunta() {
    respondeu = false;
    const p = perguntas[indiceAtual];
    
    document.getElementById('question-header').textContent = `Questão ${indiceAtual + 1} de ${perguntas.length}`;
    document.getElementById('question-text').textContent = p.Pergunta;
    document.getElementById('feedback-panel').classList.add('hidden');

    // Atualiza os pips de progresso no topo
    for (let i = 0; i < perguntas.length; i++) {
        const pip = document.getElementById(`pip-${i}`);
        if (pip) {
            if (i < indiceAtual) {
                pip.className = "h-2 w-7 rounded-full bg-secondary";
            } else if (i === indiceAtual) {
                pip.className = "h-2 w-9 rounded-full bg-primary ring-2 ring-primary/30 animate-pulse";
            } else {
                pip.className = "h-2 w-7 rounded-full bg-surface-container-highest";
            }
        }
    }

    // Renderiza as alternativas A, B, C
    const container = document.getElementById('options-container');
    container.innerHTML = '';
    const letras = ['A', 'B', 'C'];

    p.Respostas.forEach((r, idx) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'choice-btn group w-full text-left p-4 sm:p-5 rounded-xl bg-surface-container border border-outline-variant/60 hover:border-secondary/40 hover:bg-surface-container-high transition-all duration-200 flex items-start gap-4 focus:outline-none';
        btn.onclick = () => selecionarOpcao(r, btn, p);

        btn.innerHTML = `
            <div class="badge-letter w-9 h-9 rounded-lg bg-surface-container-highest text-on-surface flex items-center justify-center font-code-sm text-sm font-bold shrink-0 transition-colors group-hover:bg-primary-container group-hover:text-on-primary-container">
                ${letras[idx] || (idx + 1)}
            </div>
            <div class="flex flex-col gap-1 grow">
                <span class="font-label-md text-sm sm:text-base text-on-surface font-semibold leading-snug">
                    ${r.Resposta}
                </span>
            </div>
            <span class="material-symbols-outlined text-outline group-hover:text-on-surface text-[22px] shrink-0 mt-0.5">radio_button_unchecked</span>
        `;
        container.appendChild(btn);
    });
}

function selecionarOpcao(resposta, btnElement, pergunta) {
    if (respondeu) return;
    respondeu = true;

    respostasSelecionadas[pergunta.Id] = resposta.Id;

    const allButtons = document.querySelectorAll('.choice-btn');
    allButtons.forEach(b => b.classList.add('opacity-50', 'cursor-not-allowed'));
    btnElement.classList.remove('opacity-50');

    const feedbackPanel = document.getElementById('feedback-panel');
    const feedbackTitle = document.getElementById('feedback-title');
    const feedbackDesc = document.getElementById('feedback-desc');
    const feedbackIcon = document.getElementById('feedback-icon');
    const feedbackSymbol = document.getElementById('feedback-icon-symbol');
    const feedbackBadge = document.getElementById('feedback-badge');

    if (resposta.IsCorreta) {
        acertos++;
        xpGanhos += 2;

        btnElement.classList.add('bg-primary-container/30', 'border-secondary', 'shadow-[0_0_16px_rgba(76,215,246,0.25)]');
        btnElement.querySelector('.badge-letter').className = 'badge-letter w-9 h-9 rounded-lg bg-secondary text-on-secondary flex items-center justify-center font-code-sm text-sm font-bold shrink-0';
        btnElement.querySelector('.material-symbols-outlined').textContent = 'check_circle';
        btnElement.querySelector('.material-symbols-outlined').className = 'material-symbols-outlined text-secondary text-[22px] shrink-0 mt-0.5';

        feedbackTitle.textContent = "Resposta Correta (+2 XP)";
        feedbackTitle.className = "font-title-md text-base font-bold text-secondary";
        feedbackIcon.className = "w-10 h-10 rounded-full bg-secondary-container text-on-secondary-container flex items-center justify-center shrink-0";
        feedbackSymbol.textContent = "check";
        feedbackBadge.textContent = "+2 XP Registrados";
        feedbackBadge.className = "font-code-sm text-xs px-2.5 py-0.5 rounded bg-secondary/15 text-secondary font-semibold";
        feedbackDesc.textContent = "Excelente análise. A resposta atende com precisão aos preceitos teóricos e normativos sobre igualdade racial.";
    } else {
        btnElement.classList.add('bg-error-container/20', 'border-error', 'shadow-[0_0_16px_rgba(255,180,171,0.15)]');
        btnElement.querySelector('.badge-letter').className = 'badge-letter w-9 h-9 rounded-lg bg-error text-on-error flex items-center justify-center font-code-sm text-sm font-bold shrink-0';
        btnElement.querySelector('.material-symbols-outlined').textContent = 'cancel';
        btnElement.querySelector('.material-symbols-outlined').className = 'material-symbols-outlined text-error text-[22px] shrink-0 mt-0.5';

        feedbackTitle.textContent = "Atenção: Resposta Incorreta";
        feedbackTitle.className = "font-title-md text-base font-bold text-error";
        feedbackIcon.className = "w-10 h-10 rounded-full bg-error-container text-on-error-container flex items-center justify-center shrink-0";
        feedbackSymbol.textContent = "close";
        feedbackBadge.textContent = "0 XP";
        feedbackBadge.className = "font-code-sm text-xs px-2.5 py-0.5 rounded bg-error-container/40 text-error font-semibold";
        feedbackDesc.textContent = "Essa alternativa não reflete os consensos sociopolíticos e legais contemporâneos sobre o combate ao preconceito.";
    }

    // Atualiza sidebar do placar
    document.getElementById('hits-counter').textContent = `${acertos}/${perguntas.length} Acertos`;
    document.getElementById('score-headline').textContent = xpGanhos;
    const progresso = pontosTotal > 0 ? (xpGanhos / pontosTotal) * 100 : 0;
    document.getElementById('xp-progress-bar').style.width = `${progresso}%`;

    // Se for a última questão, troca texto do botão
    const btnNext = document.getElementById('btn-next-question');
    if (indiceAtual === perguntas.length - 1) {
        btnNext.innerHTML = '<span>Finalizar Quiz</span><span class="material-symbols-outlined text-[18px]">done_all</span>';
    }

    feedbackPanel.classList.remove('hidden');
}

async function avancarQuestao() {
    if (indiceAtual < perguntas.length - 1) {
        indiceAtual++;
        renderPergunta();
    } else {
        // Chegou ao fim: envia para o backend
        await finalizarQuiz();
    }
}

async function finalizarQuiz() {
    const token = document.querySelector('input[name="__RequestVerificationToken"]')?.value;

    try {
        const response = await fetch('/Jogos/Finalizar', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'RequestVerificationToken': token
            },
            body: JSON.stringify({
                gameId: gameId,
                respostasSelecionadas: respostasSelecionadas
            })
        });

        const data = await response.json();

        if (response.ok && data.sucesso) {
            alert(`Quiz Finalizado com sucesso!\nVocê acertou ${data.acertos}/5 e ganhou +${data.pontosGanhos} XP!`);
            window.location.href = '/Jogos/Index';
        } else {
            alert(data.message || "Quiz concluído!");
            window.location.href = '/Jogos/Index';
        }
    } catch (err) {
        console.error(err);
        window.location.href = '/Jogos/Index';
    }
}

// Inicializa a primeira pergunta
renderPergunta();