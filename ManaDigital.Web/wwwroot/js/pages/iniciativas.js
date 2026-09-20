const token = document.querySelector('input[name="__RequestVerificationToken"]')?.value;

async function submitLeitura() {
    const titulo = document.getElementById('titulo-leitura').value.trim();
    const resumo = document.getElementById('resumo-leitura').value.trim();
    const link = document.getElementById('link-foto-leitura').value.trim();
    if (!titulo || !resumo) return;

    const btn = document.getElementById('btn-env-leitura');
    btn.disabled = true;
    btn.innerText = 'Enviando...';

    try {
        const res = await fetch('/Iniciativas/Submeter', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'RequestVerificationToken': token },
            body: JSON.stringify({
                tipo: 'livro_resumo',
                titulo: titulo,
                descricao: resumo,
                anexoUrl: link
            })
        });
        const data = await res.json();
        if (res.ok && data.sucesso) {
            alert(data.message);
            window.location.reload();
        } else {
            alert(data.message || 'Erro ao enviar resumo.');
            btn.disabled = false;
            btn.innerText = 'Enviar Resumo';
        }
    } catch (err) {
        console.error(err);
        btn.disabled = false;
        btn.innerText = 'Enviar Resumo';
    }
}

async function generateReferral() {
    const emailInput = document.getElementById('colleague-email');
    const email = emailInput.value.trim();
    if (!email || !email.includes('@@')) {
        alert('Por favor, informe um e-mail corporativo válido.');
        return;
    }

    const btn = document.getElementById('btn-env-convite');
    btn.disabled = true;
    btn.innerText = 'Gerando...';

    try {
        const res = await fetch('/Iniciativas/Submeter', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'RequestVerificationToken': token },
            body: JSON.stringify({
                tipo: 'convite',
                titulo: `Indicação de Colega (${email})`,
                descricao: `Convite enviado para o colaborador ${email} para ingresso na plataforma de letramento racial.`,
                anexoUrl: email
            })
        });
        const data = await res.json();
        if (res.ok && data.sucesso) {
            document.getElementById('referral-result').classList.remove('hidden');
            document.getElementById('referral-result').classList.add('flex');
            emailInput.value = '';
            btn.disabled = false;
            btn.innerText = 'Gerar Convite';
        } else {
            alert(data.message || 'Erro ao registrar convite.');
            btn.disabled = false;
            btn.innerText = 'Gerar Convite';
        }
    } catch (err) {
        console.error(err);
        btn.disabled = false;
        btn.innerText = 'Gerar Convite';
    }
}

function copyReferralLink() {
    const urlText = document.getElementById('referral-url').innerText;
    navigator.clipboard.writeText(urlText).then(() => {
        alert('Link de convite corporativo copiado!');
    });
}

async function submitLinkedIn() {
    const urlInput = document.getElementById('linkedin-url');
    const url = urlInput.value.trim();
    if (!url) return;

    const btn = document.getElementById('btn-env-linkedin');
    btn.disabled = true;
    btn.innerText = 'Validando...';

    try {
        const res = await fetch('/Iniciativas/Submeter', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'RequestVerificationToken': token },
            body: JSON.stringify({
                tipo: 'linkedin',
                titulo: 'Publicação de Advocacy no LinkedIn',
                descricao: 'Compartilhamento de reflexão sobre práticas antirracistas na logística integrada.',
                anexoUrl: url
            })
        });
        const data = await res.json();
        if (res.ok && data.sucesso) {
            alert(data.message);
            window.location.reload();
        } else {
            alert(data.message || 'Erro ao submeter publicação.');
            btn.disabled = false;
            btn.innerText = 'Validar Post';
        }
    } catch (err) {
        console.error(err);
        btn.disabled = false;
        btn.innerText = 'Validar Post';
    }
}

async function moderarIniciativa(id, aprovado, pontos) {
    let justificativa = "";
    if (!aprovado) {
        justificativa = prompt("Informe o motivo da recusa para o colaborador:") || "Critérios insuficientes.";
    }

    try {
        const res = await fetch('/Iniciativas/Moderar', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'RequestVerificationToken': token },
            body: JSON.stringify({
                iniciativaId: id,
                aprovado: aprovado,
                pontos: pontos,
                justificativa: justificativa
            })
        });
        const data = await res.json();
        if (res.ok && data.sucesso) {
            alert(data.message);
            window.location.reload();
        } else {
            alert(data.message || 'Erro na moderação.');
        }
    } catch (err) {
        console.error(err);
    }
}