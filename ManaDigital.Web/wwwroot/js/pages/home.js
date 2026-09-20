const {rankingData} = window.homeConfig;

function renderRanking(type) {
    const container = document.getElementById('ranking-list');
    if (!container) return;
    container.innerHTML = '';

    const list = rankingData[type] || [];

    if (list.length === 0) {
        container.innerHTML = '<div class="text-xs text-outline text-center py-4">Nenhuma pontuação registrada neste período.</div>';
        return;
    }

    list.forEach(item => {
        const row = document.createElement('div');
        row.className = `px-3 py-2 rounded-lg flex items-center justify-between text-xs font-code-sm transition-colors ${
            item.isUser ? 'bg-secondary/10 border border-secondary/20 text-on-surface' : 'hover:bg-surface-container/40 text-on-surface-variant'
        }`;

        row.innerHTML = `
            <div class="flex items-center gap-3">
                <span class="w-5 text-center font-bold ${item.isUser ? 'text-secondary' : 'text-outline'}">${item.rank}</span>
                <div class="flex items-center gap-1.5 font-sans">
                    <span class="font-medium text-on-surface ${item.isUser ? 'font-semibold text-secondary' : ''}">${item.name}</span>
                    <span class="text-outline text-[11px]">(${item.role})</span>
                </div>
            </div>
            <span class="font-semibold ${item.isUser ? 'text-secondary' : 'text-on-surface'}">${item.xp}</span>
        `;
        container.appendChild(row);
    });
}

function switchRanking(type) {
    ['semanal', 'mensal', 'geral'].forEach(btn => {
        const el = document.getElementById('tab-btn-' + btn);
        if (el) {
            if (btn === type) {
                el.className = 'px-2.5 py-1 rounded-md bg-surface-container-high text-secondary font-medium';
            } else {
                el.className = 'px-2.5 py-1 rounded-md text-on-surface-variant hover:text-on-surface';
            }
        }
    });
    renderRanking(type);
}

// Inicializa com o semanal
renderRanking('semanal');