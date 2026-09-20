let leituraAtiva = null;
let precisaRecarregar = false; // <-- 1. Nossa bandeira de controle

// Filtro por pílulas
function filtrarCards(categoria, btn) {
document.querySelectorAll('.filter-pill').forEach(b => {
    b.classList.remove('active', 'bg-primary-container', 'text-on-primary', 'border-primary/30');
    b.classList.add('bg-surface-container-low', 'text-on-surface-variant', 'border-surface-container-highest/50');
});
btn.classList.add('active', 'bg-primary-container', 'text-on-primary', 'border-primary/30');
btn.classList.remove('bg-surface-container-low', 'text-on-surface-variant', 'border-surface-container-highest/50');

document.querySelectorAll('.reading-card').forEach(card => {
    if (categoria === 'all' || card.dataset.category === categoria) {
    card.style.display = 'flex';
    } else {
    card.style.display = 'none';
    }
});
}

// Abertura do Modal Dinâmico
function abrirModalLeitura(leitura) {
leituraAtiva = leitura;
document.getElementById('modal-titulo').textContent = leitura.Titulo;
document.getElementById('modal-categoria').textContent = leitura.Tipo.replace('_', ' ');
document.getElementById('modal-texto').textContent = leitura.Conteudo;

const container = document.getElementById('perguntas-container');
container.innerHTML = '';

const feedback = document.getElementById('quiz-feedback');
feedback.className = 'hidden';
feedback.innerHTML = '';

const btnSubmit = document.getElementById('btn-submit-quiz');
const xpBadge = document.getElementById('modal-xp-badge');

if (leitura.Concluida) {
    xpBadge.className = 'px-2.5 py-1 rounded bg-secondary/20 text-secondary text-xs font-mono font-semibold';
    xpBadge.textContent = '✓ Concluído (+10 XP)';
    btnSubmit.classList.add('hidden');
} else {
    xpBadge.className = 'px-2.5 py-1 rounded bg-primary-container/80 text-primary-fixed text-xs font-mono font-semibold';
    xpBadge.textContent = '+10 XP';
    btnSubmit.classList.remove('hidden');
    btnSubmit.disabled = false;
}

// Renderiza as perguntas
leitura.Perguntas.forEach((p, idx) => {
    const qDiv = document.createElement('div');
    qDiv.className = 'p-4 rounded-xl bg-surface-container/60 border border-surface-container-highest/30 flex flex-col gap-2.5';
    
    let html = `
    <div class="flex items-center justify-between text-[11px] font-mono">
        <span class="text-on-surface-variant">Afirmação ${idx + 1}</span>
        <span class="text-secondary">${p.Afirmacao.length > 30 ? 'Fixação de Conceito' : ''}</span>
    </div>
    <p class="text-xs font-medium text-on-surface leading-relaxed">${p.Afirmacao}</p>
    <div class="grid grid-cols-2 gap-2 pt-1">
        <label class="flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg text-xs font-medium cursor-pointer border transition-all ${
        leitura.Concluida 
            ? (p.IsCorreta ? 'bg-secondary/20 border-secondary text-secondary font-bold' : 'bg-surface-container-high/40 text-on-surface-variant border-transparent opacity-60')
            : 'bg-surface-container-high/60 hover:bg-surface-container-high text-on-surface border-transparent'
        }">
        <input type="radio" name="resposta_${p.Id}" value="true" ${leitura.Concluida ? (p.IsCorreta ? 'checked' : '') + ' disabled' : 'required'} class="hidden"/>
        <span>Verdadeiro</span>
        </label>
        <label class="flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg text-xs font-medium cursor-pointer border transition-all ${
        leitura.Concluida 
            ? (!p.IsCorreta ? 'bg-secondary/20 border-secondary text-secondary font-bold' : 'bg-surface-container-high/40 text-on-surface-variant border-transparent opacity-60')
            : 'bg-surface-container-high/60 hover:bg-surface-container-high text-on-surface border-transparent'
        }">
        <input type="radio" name="resposta_${p.Id}" value="false" ${leitura.Concluida ? (!p.IsCorreta ? 'checked' : '') + ' disabled' : 'required'} class="hidden"/>
        <span>Falso</span>
        </label>
    </div>
    `;

    if (leitura.Concluida && p.Explicacao) {
    html += `<div class="mt-2 text-[11px] font-mono text-secondary/90 bg-secondary/5 p-2 rounded border border-secondary/10">💡 Justificativa: ${p.Explicacao}</div>`;
    }

    qDiv.innerHTML = html;
    container.appendChild(qDiv);
});

// Se estiver desbloqueado para teste, adiciona estilos ao selecionar
if (!leitura.Concluida) {
    container.querySelectorAll('label').forEach(lbl => {
    lbl.addEventListener('click', function() {
        const parent = this.parentElement;
        parent.querySelectorAll('label').forEach(l => {
        l.classList.remove('border-secondary', 'text-secondary', 'bg-surface-container-high');
        l.classList.add('border-transparent');
        });
        this.classList.remove('border-transparent');
        this.classList.add('border-secondary', 'text-secondary', 'bg-surface-container-high');
    });
    });
}

document.getElementById('modal-leitura').classList.remove('hidden');
}

function fecharModal() {
document.getElementById('modal-leitura').classList.add('hidden');

// Se o usuário concluiu um teste enquanto o modal estava aberto,
// a tela se atualiza no exato momento em que a janela fecha!
if (precisaRecarregar) {
    precisaRecarregar = false;
    window.location.reload();
}
}

// Envio assíncrono das respostas
async function enviarRespostas(e) {
e.preventDefault();
if (!leituraAtiva || leituraAtiva.Concluida) return;

const btnSubmit = document.getElementById('btn-submit-quiz');
btnSubmit.disabled = true;
btnSubmit.innerHTML = '<span>Validando...</span>';

const respostas = {};
leituraAtiva.Perguntas.forEach(p => {
    const checked = document.querySelector(`input[name="resposta_${p.Id}"]:checked`);
    if (checked) {
    respostas[p.Id] = checked.value === "true";
    }
});

const token = document.querySelector('input[name="__RequestVerificationToken"]')?.value;

try {
    const response = await fetch('/Leituras/Responder', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'RequestVerificationToken': token
    },
    body: JSON.stringify({
        leituraId: leituraAtiva.Id,
        respostas: respostas
    })
    });

    const data = await response.json();
    const feedback = document.getElementById('quiz-feedback');
    feedback.classList.remove('hidden');

    if (response.ok && data.sucesso) {
    // Mensagem de sucesso personalizada
    if (data.pontosGanhos > 0) {
        feedback.className = 'p-4 rounded-xl text-xs font-medium bg-secondary/10 border border-secondary/30 text-secondary flex items-center gap-2';
        feedback.innerHTML = `<span class="material-symbols-outlined text-[18px]">task_alt</span> 
        <span>Parabéns! Você acertou ${data.acertos}/${data.totalPerguntas} e ganhou <strong>+${data.pontosGanhos} XP</strong>!</span>`;
    } else {
        feedback.className = 'p-4 rounded-xl text-xs font-medium bg-amber-900/20 border border-amber-500/40 text-amber-200 flex items-center gap-2';
        feedback.innerHTML = `<span class="material-symbols-outlined text-[18px]">info</span> 
        <span>Você acertou ${data.acertos}/${data.totalPerguntas} e não pontuou desta vez. A leitura foi registrada para consulta.</span>`;
    }

    // Esconde o botão de envio para não enviar duas vezes
    btnSubmit.classList.add('hidden');

    // AVISAMOS A NOSSA BANDEIRA: "Ao fechar a janela, a página deve recarregar"
    precisaRecarregar = true;

    } else {
    feedback.className = 'p-4 rounded-xl text-xs font-medium bg-red-900/30 border border-red-500/50 text-red-200 flex items-center gap-2';
    feedback.innerHTML = `<span class="material-symbols-outlined text-[18px]">error</span> 
        <span>${data.message || 'Erro ao processar as respostas.'}</span>`;
    btnSubmit.disabled = false;
    btnSubmit.innerHTML = '<span>Tentar Novamente</span>';
    }
} catch (err) {
    console.error(err);
    btnSubmit.disabled = false;
    btnSubmit.innerHTML = '<span>Validar Respostas</span>';
}
}