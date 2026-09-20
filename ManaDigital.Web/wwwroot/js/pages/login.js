function switchAuthTab(tab) {
    const loginBtn = document.getElementById("tab-login-btn");
    const registerBtn = document.getElementById("tab-register-btn");
    const loginForm = document.getElementById("login-form");
    const registerForm = document.getElementById("register-form");
    const feedbackBox = document.getElementById("auth-feedback");

    feedbackBox.classList.add("hidden");

    if (tab === "login") {
    loginBtn.className =
        "flex-1 py-space-sm px-space-md rounded-lg flex items-center justify-center gap-space-sm transition-all duration-200 bg-primary-container text-on-primary shadow-md";
    registerBtn.className =
        "flex-1 py-space-sm px-space-md rounded-lg flex items-center justify-center gap-space-sm transition-all duration-200 text-on-surface-variant hover:text-on-surface";

    loginForm.classList.remove("hidden");
    loginForm.classList.add("flex");
    registerForm.classList.add("hidden");
    registerForm.classList.remove("flex");
    } else {
    registerBtn.className =
        "flex-1 py-space-sm px-space-md rounded-lg flex items-center justify-center gap-space-sm transition-all duration-200 bg-primary-container text-on-primary shadow-md";
    loginBtn.className =
        "flex-1 py-space-sm px-space-md rounded-lg flex items-center justify-center gap-space-sm transition-all duration-200 text-on-surface-variant hover:text-on-surface";

    registerForm.classList.remove("hidden");
    registerForm.classList.add("flex");
    loginForm.classList.add("hidden");
    loginForm.classList.remove("flex");
    }
}

function togglePasswordVisibility(fieldId, btn) {
    const input = document.getElementById(fieldId);
    const icon = btn.querySelector(".material-symbols-outlined");
    if (input.type === "password") {
    input.type = "text";
    icon.textContent = "visibility_off";
    } else {
    input.type = "password";
    icon.textContent = "visibility";
    }
}

function triggerPasswordResetNotice() {
    const feedbackBox = document.getElementById("auth-feedback");
    const msg = document.getElementById("feedback-message");
    const icon = document.getElementById("feedback-icon");

    feedbackBox.classList.remove("hidden");
    icon.textContent = "mark_email_read";
    icon.className =
    "material-symbols-outlined text-secondary text-title-md";
    msg.textContent =
    "Link de recuperação enviado para o endereço corporativo verificado.";
}

function simulateAuth(type) {
    const feedbackBox = document.getElementById("auth-feedback");
    const msg = document.getElementById("feedback-message");
    const icon = document.getElementById("feedback-icon");

    feedbackBox.classList.remove("hidden");

    if (type === "login") {
    icon.textContent = "military_tech";
    icon.className =
        "material-symbols-outlined text-secondary text-title-md";
    msg.innerHTML =
        '<strong>Acesso Autorizado!</strong> Conectando ao painel Mana Digital... <span class="text-secondary font-bold">+50 XP creditados</span>';
    } else {
    icon.textContent = "task_alt";
    icon.className =
        "material-symbols-outlined text-tertiary text-title-md";
    msg.innerHTML =
        "<strong>Cadastro realizado com sucesso!</strong> Seu perfil foi integrado à frota de diversidade e governança.";
    }
}